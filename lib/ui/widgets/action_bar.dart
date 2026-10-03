import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/hud_theme.dart';

class ActionBar extends StatelessWidget {
  final bool isHudMirrored;
  final VoidCallback onToggleHud;
  final VoidCallback onOpenSettings;
  final VoidCallback onResetTrip;
  final HudTheme theme;

  const ActionBar({
    super.key,
    required this.isHudMirrored,
    required this.onToggleHud,
    required this.onOpenSettings,
    required this.onResetTrip,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardBackgroundColor.withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(color: theme.cardBorderColor, width: 1),
        ),
      ),
      child: Row(
        children: [
          // HUD Mirror Button
          Expanded(
            child: _buildHudMirrorButton(),
          ),
          const SizedBox(width: 8),

          // Settings Button
          Expanded(
            child: _buildSettingsButton(),
          ),
          const SizedBox(width: 8),

          // Guarded 1500ms Hold-To-Reset Button
          Expanded(
            child: _GuardedResetButton(
              onReset: onResetTrip,
              theme: theme,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHudMirrorButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: isHudMirrored ? theme.speedNormal : const Color(0xFF1E1E1E),
        foregroundColor: isHudMirrored ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isHudMirrored ? theme.speedNormal : theme.cardBorderColor,
          ),
        ),
      ),
      icon: Icon(
        Icons.flip,
        size: 18,
        color: isHudMirrored ? Colors.black : theme.speedNormal,
      ),
      label: Text(
        isHudMirrored ? 'HUD ON' : 'HUD MIRROR',
        style: theme.getTelemetryTextStyle(
          fontSize: 12,
          color: isHudMirrored ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: onToggleHud,
    );
  }

  Widget _buildSettingsButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: theme.cardBorderColor),
        ),
      ),
      icon: const Icon(Icons.tune, size: 18, color: Colors.white70),
      label: Text(
        'SETTINGS',
        style: theme.getTelemetryTextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: onOpenSettings,
    );
  }
}

class _GuardedResetButton extends StatefulWidget {
  final VoidCallback onReset;
  final HudTheme theme;

  const _GuardedResetButton({
    required this.onReset,
    required this.theme,
  });

  @override
  State<_GuardedResetButton> createState() => _GuardedResetButtonState();
}

class _GuardedResetButtonState extends State<_GuardedResetButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: AppConstants.resetHoldDurationMs),
    );

    _controller.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        HapticFeedback.heavyImpact();
        widget.onReset();
        _controller.reset();
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onTapDown(TapDownDetails details) {
    HapticFeedback.selectionClick();
    _controller.forward();
  }

  void _onTapUp(TapUpDetails details) {
    if (_controller.status != AnimationStatus.completed) {
      _controller.reverse();
    }
  }

  void _onTapCancel() {
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTapDown: _onTapDown,
      onTapUp: _onTapUp,
      onTapCancel: _onTapCancel,
      child: AnimatedBuilder(
        animation: _controller,
        builder: (context, child) {
          final progress = _controller.value;
          final isHolding = progress > 0.0;

          return Container(
            height: 48,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(8),
              border: Border.all(
                color: isHolding ? AppColors.criticalRed : widget.theme.cardBorderColor,
                width: isHolding ? 1.5 : 1.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(7),
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Progressive Fill Bar
                  Positioned.fill(
                    child: FractionallySizedBox(
                      alignment: Alignment.centerLeft,
                      widthFactor: progress,
                      child: Container(
                        color: AppColors.criticalRed.withValues(alpha: 0.4),
                      ),
                    ),
                  ),

                  // Button Text & Icon
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.refresh,
                        size: 16,
                        color: isHolding ? AppColors.criticalRed : Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isHolding ? 'HOLD ${( (1.5 - progress * 1.5) ).toStringAsFixed(1)}s' : 'RESET (HOLD)',
                        style: widget.theme.getTelemetryTextStyle(
                          fontSize: 11,
                          color: isHolding ? AppColors.criticalRed : Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
