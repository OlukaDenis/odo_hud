import 'package:flutter/material.dart';
import 'package:flutter_colorpicker/flutter_colorpicker.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../core/constants/app_colors.dart';
import '../../core/theme/hud_theme.dart';
import '../../providers/theme_provider.dart';
import '../widgets/speed_display.dart';

class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  void _showColorPicker(
    BuildContext context,
    String title,
    Color currentColor,
    ValueChanged<Color> onColorChanged,
  ) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        backgroundColor: AppColors.charcoal,
        title: Text(title, style: const TextStyle(color: Colors.white)),
        content: SingleChildScrollView(
          child: ColorPicker(
            pickerColor: currentColor,
            onColorChanged: onColorChanged,
            enableAlpha: false,
            displayThumbColor: true,
            pickerAreaHeightPercent: 0.7,
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
      ),
    );
  }

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final theme = ref.watch(hudThemeProvider);
    final config = ref.watch(themeConfigProvider);
    final themeNotifier = ref.read(themeConfigProvider.notifier);

    return Scaffold(
      backgroundColor: theme.backgroundColor,
      appBar: AppBar(
        backgroundColor: theme.cardBackgroundColor,
        elevation: 0,
        title: Text(
          'HUD SETTINGS',
          style: theme.getTelemetryTextStyle(
            fontSize: 18,
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
                customFontSize: 90,
              ),
            ),
          ),
          const SizedBox(height: 24),

          // Unit System
          _buildSectionHeader('UNIT SYSTEM', theme),
          SwitchListTile(
            title: Text(
              'Metric Units (KM/H, KM)',
              style: theme.getTelemetryTextStyle(fontSize: 15, color: Colors.white),
            ),
            subtitle: Text(
              theme.isMetric ? 'Displaying km/h and km' : 'Displaying mph and miles',
              style: TextStyle(color: theme.cardLabelColor, fontSize: 12),
            ),
            value: theme.isMetric,
            activeThumbColor: theme.speedNormal,
            onChanged: (val) => themeNotifier.toggleUnitSystem(),
          ),
          const Divider(color: Colors.white12),

          // Background Color Presets
          _buildSectionHeader('BACKGROUND COLOR', theme),
          Row(
            children: [
              _buildBackgroundChip(
                label: 'AMOLED Black',
                color: AppColors.amoledBlack,
                isSelected: config.backgroundColorValue == 0xFF000000,
                onTap: () => themeNotifier.updateBackgroundColor(0xFF000000),
                theme: theme,
              ),
              const SizedBox(width: 8),
              _buildBackgroundChip(
                label: 'Deep Navy',
                color: AppColors.deepNavy,
                isSelected: config.backgroundColorValue == 0xFF050B14,
                onTap: () => themeNotifier.updateBackgroundColor(0xFF050B14),
                theme: theme,
              ),
              const SizedBox(width: 8),
              _buildBackgroundChip(
                label: 'Charcoal',
                color: AppColors.charcoal,
                isSelected: config.backgroundColorValue == 0xFF121212,
                onTap: () => themeNotifier.updateBackgroundColor(0xFF121212),
                theme: theme,
              ),
            ],
          ),
          const Divider(color: Colors.white12, height: 32),

          // Speedometer Typography
          _buildSectionHeader('SPEEDOMETER FONT', theme),
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              'Bebas Neue',
              'Orbitron',
              'JetBrains Mono',
              'Share Tech Mono',
            ].map((font) {
              final isSelected = config.speedFontFamily == font;
              return ChoiceChip(
                label: Text(
                  font,
                  style: TextStyle(
                    color: isSelected ? Colors.black : Colors.white70,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                selected: isSelected,
                selectedColor: theme.speedNormal,
                backgroundColor: const Color(0xFF1E1E1E),
                onSelected: (val) {
                  if (val) themeNotifier.updateFonts(speedFont: font);
                },
              );
            }).toList(),
          ),
          const Divider(color: Colors.white12, height: 32),

          // Speed Alert Colors
          _buildSectionHeader('SPEED ALERT COLORS', theme),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.speedNormal,
              radius: 14,
            ),
            title: Text(
              'Normal Speed Color',
              style: theme.getTelemetryTextStyle(fontSize: 14, color: Colors.white),
            ),
            trailing: const Icon(Icons.colorize, color: Colors.white70),
            onTap: () => _showColorPicker(
              context,
              'Normal Speed Color',
              theme.speedNormal,
              (c) => themeNotifier.updateSpeedColors(normal: c.toARGB32()),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.speedWarning,
              radius: 14,
            ),
            title: Text(
              'Warning Speed Color',
              style: theme.getTelemetryTextStyle(fontSize: 14, color: Colors.white),
            ),
            trailing: const Icon(Icons.colorize, color: Colors.white70),
            onTap: () => _showColorPicker(
              context,
              'Warning Speed Color',
              theme.speedWarning,
              (c) => themeNotifier.updateSpeedColors(warning: c.toARGB32()),
            ),
          ),
          ListTile(
            leading: CircleAvatar(
              backgroundColor: theme.speedCritical,
              radius: 14,
            ),
            title: Text(
              'Critical Speed Color',
              style: theme.getTelemetryTextStyle(fontSize: 14, color: Colors.white),
            ),
            trailing: const Icon(Icons.colorize, color: Colors.white70),
            onTap: () => _showColorPicker(
              context,
              'Critical Speed Color',
              theme.speedCritical,
              (c) => themeNotifier.updateSpeedColors(critical: c.toARGB32()),
            ),
          ),
          const Divider(color: Colors.white12, height: 32),

          // Speed Threshold Sliders
          _buildSectionHeader('SPEED ALERT THRESHOLDS', theme),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Warning Threshold',
                      style: theme.getTelemetryTextStyle(fontSize: 13, color: Colors.white),
                    ),
                    Text(
                      '${config.warningThresholdKmh.toStringAsFixed(0)} KM/H',
                      style: theme.getTelemetryTextStyle(
                        fontSize: 13,
                        color: theme.speedWarning,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ],
                ),
                Slider(
                  value: config.warningThresholdKmh,
                  min: 40.0,
                  max: 160.0,
                  divisions: 24,
                  activeColor: theme.speedWarning,
                  inactiveColor: Colors.white24,
                  onChanged: (val) =>
                      themeNotifier.updateSpeedThresholds(warningKmh: val),
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      'Critical Threshold',
                      style: theme.getTelemetryTextStyle(fontSize: 13, color: Colors.white),
                    ),
                    Text(
                      '${config.criticalThresholdKmh.toStringAsFixed(0)} KM/H',
                      style: theme.getTelemetryTextStyle(
                        fontSize: 13,
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
        ],
      ),
    );
  }

  Widget _buildSectionHeader(String title, HudTheme theme) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12, top: 4),
      child: Text(
        title,
        style: theme.getTelemetryTextStyle(
          fontSize: 13,
          color: theme.speedNormal,
          fontWeight: FontWeight.bold,
        ).copyWith(letterSpacing: 2),
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
