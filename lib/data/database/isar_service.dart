import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import '../models/telemetry_record.dart';
import '../models/theme_config_record.dart';

class IsarService {
  static IsarService? _instance;
  static IsarService get instance => _instance ??= IsarService._();

  IsarService._();

  Isar? _isar;

  Future<Isar> get isar async {
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }
    _isar = await _initDb();
    return _isar!;
  }

  Future<Isar> _initDb() async {
    final dir = await getApplicationDocumentsDirectory();
    final isar = await Isar.open(
      [TelemetryRecordSchema, ThemeConfigRecordSchema],
      directory: dir.path,
      inspector: kDebugMode,
    );

    // Seed TelemetryRecord singleton (id = 1) if not exists
    final existingTelemetry = await isar.telemetryRecords.get(1);
    if (existingTelemetry == null) {
      await isar.writeTxn(() async {
        final initialTelemetry = TelemetryRecord()..id = 1;
        await isar.telemetryRecords.put(initialTelemetry);
      });
    }

    // Seed ThemeConfigRecord singleton (id = 1) if not exists
    final existingTheme = await isar.themeConfigRecords.get(1);
    if (existingTheme == null) {
      await isar.writeTxn(() async {
        final initialTheme = ThemeConfigRecord()..id = 1;
        await isar.themeConfigRecords.put(initialTheme);
      });
    }

    return isar;
  }

  Future<TelemetryRecord> getTelemetryRecord() async {
    final db = await isar;
    final record = await db.telemetryRecords.get(1);
    return record ?? (TelemetryRecord()..id = 1);
  }

  Future<void> saveTelemetryRecord(TelemetryRecord record) async {
    final db = await isar;
    await db.writeTxn(() async {
      record.id = 1;
      record.lastSavedTimestamp = DateTime.now();
      await db.telemetryRecords.put(record);
    });
  }

  Future<void> resetTrip() async {
    final db = await isar;
    final record = await db.telemetryRecords.get(1) ?? (TelemetryRecord()..id = 1);
    await db.writeTxn(() async {
      record.activeTripMeters = 0.0;
      record.activeTripMovingSeconds = 0;
      record.maxSpeedKmh = 0.0;
      record.lastSavedTimestamp = DateTime.now();
      await db.telemetryRecords.put(record);
    });
  }

  Future<ThemeConfigRecord> getThemeConfig() async {
    final db = await isar;
    final config = await db.themeConfigRecords.get(1);
    return config ?? (ThemeConfigRecord()..id = 1);
  }

  Stream<ThemeConfigRecord?> watchThemeConfig() async* {
    final db = await isar;
    yield* db.themeConfigRecords.watchObject(1, fireImmediately: true);
  }

  Future<void> saveThemeConfig(ThemeConfigRecord config) async {
    final db = await isar;
    await db.writeTxn(() async {
      config.id = 1;
      await db.themeConfigRecords.put(config);
    });
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    final db = await isar;
    final config = await getThemeConfig();
    await db.writeTxn(() async {
      config.onboardingCompleted = completed;
      await db.themeConfigRecords.put(config);
    });
  }
}
