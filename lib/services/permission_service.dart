import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';
import 'package:permission_handler/permission_handler.dart';

class PermissionStatusReport {
  final bool locationWhenInUse;
  final bool locationAlways;
  final bool notification;
  final bool batteryOptimizationIgnored;

  const PermissionStatusReport({
    this.locationWhenInUse = false,
    this.locationAlways = false,
    this.notification = false,
    this.batteryOptimizationIgnored = false,
  });

  bool get isReady =>
      locationWhenInUse && (Platform.isAndroid ? notification : true);
}

class PermissionService {
  static final PermissionService instance = PermissionService._();
  PermissionService._();

  Future<PermissionStatusReport> checkCurrentStatus() async {
    final locWhenInUse = await Permission.locationWhenInUse.isGranted;
    final locAlways = await Permission.locationAlways.isGranted;
    final notification = await Permission.notification.isGranted;

    bool batteryIgnored = false;
    if (!kIsWeb && Platform.isAndroid) {
      try {
        batteryIgnored = await FlutterForegroundTask.isIgnoringBatteryOptimizations;
      } catch (e) {
        debugPrint('Error checking battery optimization: $e');
        batteryIgnored = await Permission.ignoreBatteryOptimizations.isGranted;
      }
    } else {
      batteryIgnored = true;
    }

    return PermissionStatusReport(
      locationWhenInUse: locWhenInUse,
      locationAlways: locAlways,
      notification: notification,
      batteryOptimizationIgnored: batteryIgnored,
    );
  }

  Future<bool> requestLocationWhenInUse() async {
    final status = await Permission.locationWhenInUse.request();
    return status.isGranted;
  }

  Future<bool> requestLocationAlways() async {
    if (await Permission.locationWhenInUse.isGranted) {
      final status = await Permission.locationAlways.request();
      return status.isGranted;
    }
    return false;
  }

  Future<bool> requestNotification() async {
    final status = await Permission.notification.request();
    return status.isGranted;
  }

  Future<bool> requestBatteryOptimizationExemption() async {
    if (!kIsWeb && Platform.isAndroid) {
      try {
        final requested = await FlutterForegroundTask.requestIgnoreBatteryOptimization();
        if (requested) return true;
        await FlutterForegroundTask.openIgnoreBatteryOptimizationSettings();
        return await FlutterForegroundTask.isIgnoringBatteryOptimizations;
      } catch (e) {
        debugPrint('Battery optimization request failed: $e');
        final status = await Permission.ignoreBatteryOptimizations.request();
        return status.isGranted;
      }
    }
    return true;
  }

  Future<bool> openAppSettingsPage() async {
    return await openAppSettings();
  }
}
