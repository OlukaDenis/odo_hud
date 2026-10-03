import 'dart:io';
import 'package:flutter/foundation.dart';
import 'package:flutter_foreground_task/flutter_foreground_task.dart';

@pragma('vm:entry-point')
void startCallback() {
  FlutterForegroundTask.setTaskHandler(ForegroundTelemetryTaskHandler());
}

class ForegroundTelemetryTaskHandler extends TaskHandler {
  @override
  Future<void> onStart(DateTime timestamp, TaskStarter starter) async {}

  @override
  void onRepeatEvent(DateTime timestamp) {}

  @override
  Future<void> onDestroy(DateTime timestamp, bool isStopped) async {}
}

class ForegroundServiceManager {
  static final ForegroundServiceManager instance = ForegroundServiceManager._();
  ForegroundServiceManager._();

  bool _isInitialized = false;

  Future<void> init() async {
    if (_isInitialized || kIsWeb || !Platform.isAndroid) return;

    FlutterForegroundTask.init(
      androidNotificationOptions: AndroidNotificationOptions(
        channelId: 'odo_hud_telemetry_silent_v2',
        channelName: 'OdoHUD Telemetry Tracking',
        channelDescription:
            'Continuous background odometer & speed tracking service',
        channelImportance: NotificationChannelImportance.LOW,
        priority: NotificationPriority.LOW,
        enableVibration: false,
        playSound: false,
        showWhen: false,
      ),
      iosNotificationOptions: const IOSNotificationOptions(
        showNotification: false,
        playSound: false,
      ),
      foregroundTaskOptions: ForegroundTaskOptions(
        eventAction: ForegroundTaskEventAction.repeat(5000),
        autoRunOnBoot: false,
        allowWakeLock: true,
      ),
    );

    _isInitialized = true;
  }

  Future<bool> startService() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    await init();

    if (await FlutterForegroundTask.isRunningService) {
      return true;
    }

    final result = await FlutterForegroundTask.startService(
      serviceId: 256,
      notificationTitle: 'OdoHUD Ride',
      notificationText: 'Tracking your ride...',
      callback: startCallback,
    );

    return result is ServiceRequestSuccess;
  }

  Future<void> updateNotification({
    required double speedKmh,
    required double tripKm,
    required String timeFormatted,
    required bool isMetric,
  }) async {
    if (kIsWeb || !Platform.isAndroid) return;
    if (!await FlutterForegroundTask.isRunningService) return;

    final speedStr = isMetric
        ? '${speedKmh.toStringAsFixed(0)} km/h'
        : '${(speedKmh * 0.621371).toStringAsFixed(0)} mph';

    final distStr = isMetric
        ? '${tripKm.toStringAsFixed(1)} km'
        : '${(tripKm * 0.621371).toStringAsFixed(1)} mi';

    FlutterForegroundTask.updateService(
      notificationTitle: 'OdoHUD • $speedStr',
      notificationText: '$distStr • $timeFormatted moving',
    );
  }

  Future<bool> stopService() async {
    if (kIsWeb || !Platform.isAndroid) return false;
    final result = await FlutterForegroundTask.stopService();
    return result is ServiceRequestSuccess;
  }
}
