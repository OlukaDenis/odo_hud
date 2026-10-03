import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../data/database/isar_service.dart';
import '../services/permission_service.dart';

final permissionServiceProvider = Provider<PermissionService>((ref) {
  return PermissionService.instance;
});

final permissionStatusProvider =
    StateNotifierProvider<PermissionStatusNotifier, AsyncValue<PermissionStatusReport>>(
        (ref) {
  return PermissionStatusNotifier(ref.watch(permissionServiceProvider));
});

class PermissionStatusNotifier
    extends StateNotifier<AsyncValue<PermissionStatusReport>> {
  final PermissionService _service;

  PermissionStatusNotifier(this._service) : super(const AsyncValue.loading()) {
    checkStatus();
  }

  Future<void> checkStatus() async {
    state = const AsyncValue.loading();
    try {
      final report = await _service.checkCurrentStatus();
      state = AsyncValue.data(report);
    } catch (e, st) {
      state = AsyncValue.error(e, st);
    }
  }

  Future<bool> requestLocation() async {
    final grantedInUse = await _service.requestLocationWhenInUse();
    if (grantedInUse) {
      await _service.requestLocationAlways();
    }
    await checkStatus();
    return grantedInUse;
  }

  Future<bool> requestNotification() async {
    final granted = await _service.requestNotification();
    await checkStatus();
    return granted;
  }

  Future<bool> requestBatteryOptimization() async {
    final granted = await _service.requestBatteryOptimizationExemption();
    await checkStatus();
    return granted;
  }
}

final onboardingCompletedProvider = FutureProvider<bool>((ref) async {
  final config = await IsarService.instance.getThemeConfig();
  return config.onboardingCompleted;
});
