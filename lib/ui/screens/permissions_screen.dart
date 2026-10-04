import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/hud_theme.dart';
import '../../providers/theme_provider.dart';
import '../../services/permission_service.dart';
import '../widgets/oem_guide_modal.dart';

class PermissionsScreen extends ConsumerStatefulWidget {
  const PermissionsScreen({super.key});

  @override
  ConsumerState<PermissionsScreen> createState() => _PermissionsScreenState();
}

class _PermissionsScreenState extends ConsumerState<PermissionsScreen>
    with WidgetsBindingObserver {
  PermissionStatusReport? _permissionsReport;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _refreshPermissions();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.resumed) {
      _refreshPermissions();
    }
  }

  Future<void> _refreshPermissions() async {
    final report = await PermissionService.instance.checkCurrentStatus();
    if (mounted) {
      setState(() {
        _permissionsReport = report;
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(hudThemeProvider);
    final report = _permissionsReport;
    final locGranted = report?.locationWhenInUse ?? false;
    final notifGranted = report?.notification ?? false;
    final batteryIgnored = report?.batteryOptimizationIgnored ?? false;
    final allGranted = locGranted && notifGranted && batteryIgnored;

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardBackgroundColor,
        elevation: 0,
        title: Text(
          'PERMISSIONS & SYSTEM TUNING',
          style: theme.getTelemetryTextStyle(
            fontSize: 16.0,
            color: theme.textColor,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: Icon(Icons.arrow_back_rounded, color: theme.textColor),
          onPressed: () => Navigator.of(context).pop(),
        ),
        actions: [
          IconButton(
            icon: Icon(Icons.refresh_rounded, color: theme.textColor),
            tooltip: 'Refresh Status',
            onPressed: () {
              HapticFeedback.selectionClick();
              _refreshPermissions();
            },
          ),
        ],
      ),
      body: _isLoading
          ? Center(
              child: CircularProgressIndicator(color: theme.speedNormal),
            )
          : ListView(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 20),
              children: [
                // Top Status Banner
                _buildStatusBanner(allGranted, theme),
                const SizedBox(height: 24),

                // Core Permissions Section
                _buildSectionHeader('CORE HARDWARE & BACKGROUND ACCESS', theme),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.cardBorderColor),
                  ),
                  child: Column(
                    children: [
                      // 1. GPS Location
                      _buildPermissionRow(
                        icon: Icons.gps_fixed_rounded,
                        title: 'GPS Location',
                        subtitle: locGranted
                            ? 'High Precision GPS telemetry active'
                            : 'Essential for live speed and distance calculation',
                        isGranted: locGranted,
                        actionLabel: locGranted ? 'Settings' : 'Grant',
                        onTap: () async {
                          if (!locGranted) {
                            await PermissionService.instance
                                .requestLocationWhenInUse();
                          } else {
                            await PermissionService.instance
                                .openAppSettingsPage();
                          }
                          _refreshPermissions();
                        },
                        theme: theme,
                      ),
                      Divider(color: theme.dividerColor, height: 24),

                      // 2. HUD Notification
                      _buildPermissionRow(
                        icon: Icons.notifications_active_rounded,
                        title: 'HUD Notification',
                        subtitle: notifGranted
                            ? 'Foreground service notification active'
                            : 'Prevents Android from freezing tracking when app is minimized',
                        isGranted: notifGranted,
                        actionLabel: notifGranted ? 'Allowed' : 'Enable',
                        onTap: () async {
                          if (!notifGranted) {
                            await PermissionService.instance
                                .requestNotification();
                            _refreshPermissions();
                          }
                        },
                        theme: theme,
                      ),
                      Divider(color: theme.dividerColor, height: 24),

                      // 3. Battery Optimization
                      _buildPermissionRow(
                        icon: Icons.battery_saver_rounded,
                        title: 'Battery Whitelist',
                        subtitle: batteryIgnored
                            ? 'Unrestricted (Bypasses OS DOZE mode sleep throttle)'
                            : 'Android battery optimizer may kill background ride tracking',
                        isGranted: batteryIgnored,
                        actionLabel:
                            batteryIgnored ? 'Whitelisted' : 'Whitelist',
                        onTap: () async {
                          await PermissionService.instance
                              .requestBatteryOptimizationExemption();
                          _refreshPermissions();
                        },
                        theme: theme,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),

                // OEM Manufacturer Aggressive Killer Section
                _buildSectionHeader('OEM AUTOSTART & POWER MANAGEMENT', theme),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: theme.cardBackgroundColor,
                    borderRadius: BorderRadius.circular(14),
                    border: Border.all(color: theme.cardBorderColor),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Container(
                            padding: const EdgeInsets.all(8),
                            decoration: BoxDecoration(
                              color: theme.speedNormal.withValues(alpha: 0.15),
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: Icon(
                              Icons.phonelink_setup_rounded,
                              color: theme.speedNormal,
                              size: 22,
                            ),
                          ),
                          const SizedBox(width: 12),
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(
                                  'OEM Autostart Guide',
                                  style: TextStyle(
                                    color: theme.textColor,
                                    fontSize: 15,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                                const SizedBox(height: 2),
                                Text(
                                  'Xiaomi, Samsung, OnePlus & Huawei kill apps aggressively',
                                  style: TextStyle(
                                    color: theme.subtitleColor,
                                    fontSize: 12,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 14),
                      Text(
                        'Custom Android skins (MIUI/HyperOS, OneUI, ColorOS) have aggressive task-killers that silence GPS even when background permission is granted. Follow our step-by-step manufacturer guide to lock OdoHUD in recent apps.',
                        style: TextStyle(
                          color: theme.subtitleColor,
                          fontSize: 12,
                          height: 1.4,
                        ),
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        width: double.infinity,
                        child: OutlinedButton.icon(
                          style: OutlinedButton.styleFrom(
                            foregroundColor: theme.speedNormal,
                            side: BorderSide(
                              color: theme.speedNormal.withValues(alpha: 0.5),
                            ),
                            padding: const EdgeInsets.symmetric(vertical: 12),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(10),
                            ),
                          ),
                          icon: const Icon(Icons.menu_book_rounded, size: 18),
                          label: const Text(
                            'Open OEM Step-by-Step Guide',
                            style: TextStyle(fontWeight: FontWeight.bold),
                          ),
                          onPressed: () {
                            HapticFeedback.selectionClick();
                            OemGuideModal.show(context);
                          },
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
              ],
            ),
    );
  }

  Widget _buildStatusBanner(bool allGranted, HudTheme theme) {
    final bannerColor =
        allGranted ? theme.speedNormal : AppColors.warningAmber;

    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: bannerColor.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: bannerColor.withValues(alpha: 0.35)),
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Icon(
            allGranted
                ? Icons.verified_user_rounded
                : Icons.warning_amber_rounded,
            color: bannerColor,
            size: 26,
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  allGranted
                      ? 'System Fully Optimized'
                      : 'Attention: Permissions Incomplete',
                  style: TextStyle(
                    color: bannerColor,
                    fontSize: 15,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  allGranted
                      ? 'All permissions active. Telemetry, GPS odometer, and background tracking will operate continuously without interruptions.'
                      : 'Please enable all permissions below to prevent Android from halting your trip recording when the screen turns off.',
                  style: TextStyle(
                    color: theme.textColor.withValues(alpha: 0.8),
                    fontSize: 12,
                    height: 1.35,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionRow({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isGranted,
    required String actionLabel,
    required VoidCallback onTap,
    required HudTheme theme,
  }) {
    final statusColor =
        isGranted ? theme.speedNormal : AppColors.warningAmber;

    return Row(
      children: [
        Container(
          width: 40,
          height: 40,
          decoration: BoxDecoration(
            color: statusColor.withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: statusColor, size: 20),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: TextStyle(
                  color: theme.textColor,
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: isGranted ? theme.subtitleColor : AppColors.warningAmber,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(width: 8),
        ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor:
                isGranted ? theme.cardBorderColor : theme.speedNormal,
            foregroundColor: isGranted ? theme.textColor : Colors.black,
            elevation: 0,
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(8),
            ),
          ),
          onPressed: () {
            HapticFeedback.selectionClick();
            onTap();
          },
          child: Text(
            actionLabel,
            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
          ),
        ),
      ],
    );
  }

  Widget _buildSectionHeader(String title, HudTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10, left: 4),
      child: Text(
        title,
        style: theme
            .getTelemetryTextStyle(
              fontSize: 13.0,
              color: theme.speedNormal,
              fontWeight: FontWeight.bold,
            )
            .copyWith(letterSpacing: 0.5),
      ),
    );
  }
}
