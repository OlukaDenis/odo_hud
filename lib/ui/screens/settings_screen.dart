import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/hud_theme.dart';
import '../../providers/theme_provider.dart';
import '../../services/permission_service.dart';
import '../widgets/oem_guide_modal.dart';
import '../widgets/speed_display.dart';

class SettingsScreen extends ConsumerStatefulWidget {
  const SettingsScreen({super.key});

  @override
  ConsumerState<SettingsScreen> createState() => _SettingsScreenState();
}

class _SettingsScreenState extends ConsumerState<SettingsScreen>
    with WidgetsBindingObserver {
  PermissionStatusReport? _permissionsReport;

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
      setState(() => _permissionsReport = report);
    }
  }

  void _showColorPicker(
    BuildContext context,
    String title,
    Color currentColor,
    ValueChanged<Color> onColorChanged,
  ) {
    Color selectedColor = currentColor;

    showDialog(
      context: context,
      builder: (ctx) => StatefulBuilder(
        builder: (dialogCtx, setDialogState) {
          return AlertDialog(
            backgroundColor: AppColors.charcoal,
            title: Text(title, style: const TextStyle(color: Colors.white)),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  ColorPicker(
                    pickerColor: selectedColor,
                    onColorChanged: (newColor) {
                      setDialogState(() {
                        selectedColor = newColor;
                      });
                      onColorChanged(newColor);
                    },
                    enableAlpha: false,
                    displayThumbColor: true,
                    pickerAreaHeightPercent: 0.7,
                  ),
                ],
              ),
            ),
            actions: [
              ElevatedButton(
                style: ElevatedButton.styleFrom(
                  backgroundColor: AppColors.electricGreen,
                  foregroundColor: Colors.black,
                ),
                onPressed: () => Navigator.of(ctx).pop(),
                child: const Text('Select'),
              ),
            ],
          );
        },
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final theme = ref.watch(hudThemeProvider);
    final config = ref.watch(themeConfigProvider);
    final themeNotifier = ref.read(themeConfigProvider.notifier);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardBackgroundColor,
        elevation: 0,
        title: Text(
          'HUD Settings',
          style: theme.getTelemetryTextStyle(
            fontSize: 18.0,
            color: Colors.white,
            fontWeight: FontWeight.bold,
          ),
        ),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back, color: Colors.white),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.all(16),
        children: [
          // Live Preview Card
          Container(
            height: 180,
            decoration: BoxDecoration(
              color: theme.backgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.cardBorderColor, width: 2),
            ),
            child: Center(
              child: SpeedDisplay(
                currentSpeed: 104,
                speedKmh: 104,
                isMetric: theme.isMetric,
                theme: theme,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Speed Numeral Color Controls
          _buildSectionHeader('SPEED DISPLAY COLORS', theme),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.cardBorderColor),
            ),
            child: Column(
              children: [
                _buildColorTile(
                  label: 'Normal Speed Color',
                  color: theme.speedNormal,
                  onTap: () => _showColorPicker(
                    context,
                    'Select Normal Speed Color',
                    theme.speedNormal,
                    (c) => themeNotifier.updateSpeedColors(normal: c.toARGB32()),
                  ),
                ),
                const Divider(color: Colors.white12),
                _buildColorTile(
                  label: 'Warning Speed Color',
                  color: theme.speedWarning,
                  onTap: () => _showColorPicker(
                    context,
                    'Select Warning Speed Color',
                    theme.speedWarning,
                    (c) => themeNotifier.updateSpeedColors(warning: c.toARGB32()),
                  ),
                ),
                const Divider(color: Colors.white12),
                _buildColorTile(
                  label: 'Critical Speed Color',
                  color: theme.speedCritical,
                  onTap: () => _showColorPicker(
                    context,
                    'Select Critical Speed Color',
                    theme.speedCritical,
                    (c) => themeNotifier.updateSpeedColors(critical: c.toARGB32()),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Typography Selection
          _buildSectionHeader('TYPOGRAPHY & FONTS', theme),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.cardBorderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Select Display Font Family',
                  style: TextStyle(fontSize: 12, color: Colors.white70),
                ),
                const SizedBox(height: 10),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    'Inter',
                    'Montserrat',
                    'Outfit',
                    'Poppins',
                    'Orbitron',
                  ].map((font) {
                    final isSelected = config.speedFontFamily == font;
                    return ChoiceChip(
                      label: Text(font),
                      selected: isSelected,
                      selectedColor: theme.speedNormal,
                      backgroundColor: const Color(0xFF1E1E1E),
                      labelStyle: TextStyle(
                        color: isSelected ? Colors.black : Colors.white,
                        fontWeight: FontWeight.bold,
                      ),
                      onSelected: (val) {
                        if (val) {
                          themeNotifier.updateFonts(speedFont: font);
                        }
                      },
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Speed Unit System Selection
          _buildSectionHeader('SPEED UNIT SYSTEM', theme),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.cardBorderColor),
            ),
            child: Row(
              children: [
                Expanded(
                  child: ChoiceChip(
                    label: const Center(
                      child: Text(
                        'KM/H (Metric)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    selected: config.isMetric,
                    selectedColor: theme.speedNormal,
                    backgroundColor: const Color(0xFF1E1E1E),
                    labelStyle: TextStyle(
                      color: config.isMetric ? Colors.black : Colors.white70,
                      fontSize: 13,
                    ),
                    onSelected: (val) {
                      if (val) themeNotifier.setUnitSystem(true);
                    },
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: ChoiceChip(
                    label: const Center(
                      child: Text(
                        'MPH (Imperial)',
                        style: TextStyle(fontWeight: FontWeight.bold),
                      ),
                    ),
                    selected: !config.isMetric,
                    selectedColor: theme.speedNormal,
                    backgroundColor: const Color(0xFF1E1E1E),
                    labelStyle: TextStyle(
                      color: !config.isMetric ? Colors.black : Colors.white70,
                      fontSize: 13,
                    ),
                    onSelected: (val) {
                      if (val) themeNotifier.setUnitSystem(false);
                    },
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Background Palette
          _buildSectionHeader('CANVAS BACKGROUND', theme),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: theme.cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.cardBorderColor),
            ),
            child: Row(
              children: [
                _buildBackgroundChip(
                  label: 'AMOLED Black',
                  color: AppColors.amoledBlack,
                  isSelected:
                      config.backgroundColorValue == AppColors.amoledBlack.toARGB32(),
                  onTap: () =>
                      themeNotifier.updateBackgroundColor(AppColors.amoledBlack.toARGB32()),
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _buildBackgroundChip(
                  label: 'Deep Navy',
                  color: AppColors.deepNavy,
                  isSelected:
                      config.backgroundColorValue == AppColors.deepNavy.toARGB32(),
                  onTap: () =>
                      themeNotifier.updateBackgroundColor(AppColors.deepNavy.toARGB32()),
                  theme: theme,
                ),
                const SizedBox(width: 8),
                _buildBackgroundChip(
                  label: 'Charcoal',
                  color: AppColors.charcoal,
                  isSelected:
                      config.backgroundColorValue == AppColors.charcoal.toARGB32(),
                  onTap: () =>
                      themeNotifier.updateBackgroundColor(AppColors.charcoal.toARGB32()),
                  theme: theme,
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // Speed Threshold Sliders
          _buildSectionHeader('SPEED THRESHOLDS (KM/H)', theme),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: theme.cardBackgroundColor,
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: theme.cardBorderColor),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Warning Alert Threshold',
                        style: TextStyle(color: Colors.white70)),
                    Text(
                      '${config.warningThresholdKmh.toInt()} km/h',
                      style: TextStyle(
                        color: theme.speedWarning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: config.warningThresholdKmh,
                  min: 30.0,
                  max: 180.0,
                  divisions: 30,
                  activeColor: theme.speedWarning,
                  inactiveColor: Colors.white24,
                  onChanged: (val) =>
                      themeNotifier.updateSpeedThresholds(warningKmh: val),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('Critical Alert Threshold',
                        style: TextStyle(color: Colors.white70)),
                    Text(
                      '${config.criticalThresholdKmh.toInt()} km/h',
                      style: TextStyle(
                        color: theme.speedCritical,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: config.criticalThresholdKmh,
                  min: 60.0,
                  max: 220.0,
                  divisions: 32,
                  activeColor: theme.speedCritical,
                  inactiveColor: Colors.white24,
                  onChanged: (val) =>
                      themeNotifier.updateSpeedThresholds(criticalKmh: val),
                ),
              ],
            ),
          ),
          const SizedBox(height: 24),

          // System Permissions & Background Performance (Requested by User)
          _buildSectionHeader('PERMISSIONS & SYSTEM TUNING', theme),
          _buildPermissionsCard(theme),
          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildPermissionsCard(HudTheme theme) {
    final report = _permissionsReport;
    final locGranted = report?.locationWhenInUse ?? false;
    final notifGranted = report?.notification ?? false;
    final batteryIgnored = report?.batteryOptimizationIgnored ?? false;

    return Container(
      padding: const EdgeInsets.all(14),
      decoration: BoxDecoration(
        color: theme.cardBackgroundColor,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: theme.cardBorderColor),
      ),
      child: Column(
        children: [
          // 1. GPS Location
          _buildPermissionItem(
            icon: Icons.gps_fixed_rounded,
            title: 'GPS Location',
            subtitle: locGranted ? 'High Precision GPS active' : 'Location permission required',
            isGranted: locGranted,
            actionLabel: locGranted ? 'Settings' : 'Grant',
            onTap: () async {
              if (!locGranted) {
                await PermissionService.instance.requestLocationWhenInUse();
              } else {
                await PermissionService.instance.openAppSettingsPage();
              }
              _refreshPermissions();
            },
            theme: theme,
          ),
          const Divider(color: Colors.white12, height: 20),

          // 2. Notifications
          _buildPermissionItem(
            icon: Icons.notifications_active_rounded,
            title: 'HUD Notification',
            subtitle: notifGranted ? 'Keeps telemetry active in background' : 'Notification permission disabled',
            isGranted: notifGranted,
            actionLabel: notifGranted ? 'Allowed' : 'Enable',
            onTap: () async {
              if (!notifGranted) {
                await PermissionService.instance.requestNotification();
                _refreshPermissions();
              }
            },
            theme: theme,
          ),
          const Divider(color: Colors.white12, height: 20),

          // 3. Battery Optimization
          _buildPermissionItem(
            icon: Icons.battery_saver_rounded,
            title: 'Battery Whitelist',
            subtitle: batteryIgnored
                ? 'Unrestricted (Protected from OS task killer)'
                : 'Optimized (Android may stop GPS in pocket)',
            isGranted: batteryIgnored,
            actionLabel: batteryIgnored ? 'Whitelisted' : 'Whitelist',
            onTap: () async {
              await PermissionService.instance.requestBatteryOptimizationExemption();
              _refreshPermissions();
            },
            theme: theme,
          ),
          const Divider(color: Colors.white12, height: 20),

          // 4. OEM Guide Action
          Material(
            color: Colors.transparent,
            child: ListTile(
              contentPadding: EdgeInsets.zero,
              leading: Container(
                width: 38,
                height: 38,
                decoration: BoxDecoration(
                  color: theme.speedNormal.withValues(alpha: 0.15),
                  borderRadius: BorderRadius.circular(8),
                ),
                child: Icon(Icons.phonelink_setup_rounded, color: theme.speedNormal, size: 20),
              ),
              title: const Text(
                'OEM Autostart Guide',
                style: TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              subtitle: const Text(
                'Xiaomi, Samsung, Huawei background settings',
                style: TextStyle(color: Colors.white54, fontSize: 12),
              ),
              trailing: const Icon(Icons.chevron_right_rounded, color: Colors.white70),
              onTap: () {
                HapticFeedback.selectionClick();
                OemGuideModal.show(context);
              },
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPermissionItem({
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isGranted,
    required String actionLabel,
    required VoidCallback onTap,
    required HudTheme theme,
  }) {
    return Row(
      children: [
        Container(
          width: 36,
          height: 36,
          decoration: BoxDecoration(
            color: (isGranted ? theme.speedNormal : AppColors.warningAmber).withValues(alpha: 0.15),
            borderRadius: BorderRadius.circular(8),
          ),
          child: Icon(
            icon,
            color: isGranted ? theme.speedNormal : AppColors.warningAmber,
            size: 20,
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(color: Colors.white, fontSize: 14, fontWeight: FontWeight.w600),
              ),
              const SizedBox(height: 2),
              Text(
                subtitle,
                style: TextStyle(
                  color: isGranted ? Colors.white60 : AppColors.warningAmber,
                  fontSize: 11,
                ),
              ),
            ],
          ),
        ),
        TextButton(
          style: TextButton.styleFrom(
            backgroundColor: isGranted ? const Color(0xFF1E1E1E) : theme.speedNormal,
            foregroundColor: isGranted ? Colors.white70 : Colors.black,
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
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

  Widget _buildColorTile({
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: ListTile(
        contentPadding: EdgeInsets.zero,
        title: Text(label, style: const TextStyle(color: Colors.white, fontSize: 14)),
        trailing: GestureDetector(
          onTap: onTap,
          child: Container(
            width: 32,
            height: 32,
            decoration: BoxDecoration(
              color: color,
              shape: BoxShape.circle,
              border: Border.all(color: Colors.white30, width: 2),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title, HudTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        title,
        style: theme
            .getTelemetryTextStyle(
              fontSize: 14.0,
              color: theme.speedNormal,
              fontWeight: FontWeight.bold,
            )
            .copyWith(letterSpacing: 0.5),
      ),
    );
  }

  Widget _buildBackgroundChip({
    required String label,
    required Color color,
    required bool isSelected,
    required VoidCallback onTap,
    required HudTheme theme,
  }) {
    return Expanded(
      child: GestureDetector(
        onTap: onTap,
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: color,
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color: isSelected ? theme.speedNormal : theme.cardBorderColor,
              width: isSelected ? 2 : 1,
            ),
          ),
          alignment: Alignment.center,
          child: Text(
            label,
            style: TextStyle(
              fontSize: 11,
              fontWeight: FontWeight.bold,
              color: isSelected ? theme.speedNormal : Colors.white70,
            ),
          ),
        ),
      ),
    );
  }
}
