import 'dart:async';
import 'package:flutter/foundation.dart';
import 'package:isar/isar.dart';
import 'package:path_provider/path_provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../models/telemetry_record.dart';
import '../models/theme_config_record.dart';
import '../models/trip_record.dart';

class IsarService {
  static IsarService? _instance;
  static IsarService get instance => _instance ??= IsarService._();

  IsarService._();

  Isar? _isar;
  Completer<Isar>? _initCompleter;

  Future<Isar> get isar async {
    final existing = Isar.getInstance();
    if (existing != null && existing.isOpen) {
      _isar = existing;
      return existing;
    }
    if (_isar != null && _isar!.isOpen) {
      return _isar!;
    }
    if (_initCompleter != null) {
      return _initCompleter!.future;
    }

    _initCompleter = Completer<Isar>();
    try {
      final db = await _initDb();
      _isar = db;
      _initCompleter!.complete(db);
      return db;
    } catch (e, st) {
      _initCompleter!.completeError(e, st);
      _initCompleter = null;
      rethrow;
    }
  }

  Future<Isar> _initDb() async {
    final existing = Isar.getInstance();
    if (existing != null && existing.isOpen) {
      return existing;
    }

    final dir = await getApplicationDocumentsDirectory();
    Isar db;
    try {
      db = Isar.getInstance() ??
          await Isar.open(
            [TelemetryRecordSchema, ThemeConfigRecordSchema, TripRecordSchema],
            directory: dir.path,
            inspector: false,
          );
    } catch (e) {
      final fallback = Isar.getInstance();
      if (fallback != null && fallback.isOpen) {
        db = fallback;
      } else {
        rethrow;
      }
    }

    // Seed TelemetryRecord singleton (id = 1) if not exists
    final existingTelemetry = await db.telemetryRecords.get(1);
    if (existingTelemetry == null) {
      await db.writeTxn(() async {
        final initialTelemetry = TelemetryRecord()..id = 1;
        await db.telemetryRecords.put(initialTelemetry);
      });
    }

    // Seed ThemeConfigRecord singleton (id = 1) if not exists
    final existingTheme = await db.themeConfigRecords.get(1);
    if (existingTheme == null) {
      await db.writeTxn(() async {
        final initialTheme = ThemeConfigRecord()..id = 1;
        await db.themeConfigRecords.put(initialTheme);
      });
    }

    return db;
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
    final theme = config ?? (ThemeConfigRecord()..id = 1);
    if (theme.speedFontFamily.isEmpty || theme.speedFontFamily == 'Bebas Neue') {
      theme.speedFontFamily = 'Inter';
    }
    return theme;
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

  Future<bool> isOnboardingCompleted() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      if (prefs.containsKey('onboarding_completed')) {
        return prefs.getBool('onboarding_completed') ?? false;
      }
    } catch (_) {}

    try {
      final config = await getThemeConfig();
      return config.onboardingCompleted;
    } catch (_) {
      return false;
    }
  }

  Future<void> setOnboardingCompleted(bool completed) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setBool('onboarding_completed', completed);
    } catch (e) {
      debugPrint('Error saving onboarding in SharedPreferences: $e');
    }

    try {
      final db = await isar;
      final config = await getThemeConfig();
      await db.writeTxn(() async {
        config.onboardingCompleted = completed;
        await db.themeConfigRecords.put(config);
      });
    } catch (e) {
      debugPrint('Error setting onboarding completed: $e');
    }
  }

  // --- Trip Records ---

  Future<Id> saveTrip(TripRecord trip) async {
    final db = await isar;
    return await db.writeTxn(() async {
      return await db.tripRecords.put(trip);
    });
  }

  Future<List<TripRecord>> getAllTrips() async {
    final db = await isar;
    return await db.tripRecords.where().sortByStartTimeDesc().findAll();
  }

  Stream<List<TripRecord>> watchAllTrips() async* {
    final db = await isar;
    yield* db.tripRecords.where().sortByStartTimeDesc().watch(fireImmediately: true);
  }

  Future<bool> deleteTrip(Id id) async {
    final db = await isar;
    return await db.writeTxn(() async {
      return await db.tripRecords.delete(id);
    });
  }

  Future<void> clearAllTrips() async {
    final db = await isar;
    await db.writeTxn(() async {
      await db.tripRecords.clear();
    });
  }
}
