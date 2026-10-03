import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/hud_theme.dart';

class ActionBar extends StatelessWidget {
  final bool isHudMirrored;
  final VoidCallback onToggleHud;
  final bool isLandscape;
  final VoidCallback onToggleOrientation;
  final bool isRecordingTrip;
  final VoidCallback onToggleRecording;
  final VoidCallback onResetTrip;
  final VoidCallback? onOpenSettings; // Retained as optional for backwards compatibility
  final HudTheme theme;

  const ActionBar({
    super.key,
    required this.isHudMirrored,
    required this.onToggleHud,
    required this.isLandscape,
    required this.onToggleOrientation,
    required this.isRecordingTrip,
    required this.onToggleRecording,
    required this.onResetTrip,
    this.onOpenSettings,
    required this.theme,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: theme.cardBackgroundColor.withValues(alpha: 0.8),
        border: Border(
          top: BorderSide(
            color: theme.cardBorderColor.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      child: Row(
        children: [
          // 1. HUD Mirror Button
          Expanded(
            child: _buildHudMirrorButton(),
          ),
          const SizedBox(width: 8),

          // 2. Orientation Toggle Button
          Expanded(
            child: _buildOrientationButton(),
          ),
          const SizedBox(width: 8),

          // 3. Start / Stop Trip Recording Button (Replacing Settings migrated to top toolbar)
          Expanded(
            flex: 1,
            child: _buildTripRecordingButton(),
          ),
          const SizedBox(width: 8),

          // 4. Guarded 1500ms Hold-To-Reset Button
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
        backgroundColor:
            isHudMirrored ? theme.speedNormal : const Color(0xFF1E1E1E),
        foregroundColor: isHudMirrored ? Colors.black : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: isHudMirrored ? theme.speedNormal : theme.cardBorderColor,
          ),
        ),
      ),
      icon: Icon(
        Icons.flip,
        size: 16,
        color: isHudMirrored ? Colors.black : theme.speedNormal,
      ),
      label: Text(
        isHudMirrored ? 'Mirrored' : 'HUD Flip',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.getTelemetryTextStyle(
          fontSize: 12,
          color: isHudMirrored ? Colors.black : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: onToggleHud,
    );
  }

  Widget _buildOrientationButton() {
    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF1E1E1E),
        foregroundColor: Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(color: theme.cardBorderColor),
        ),
      ),
      icon: Icon(
        isLandscape
            ? Icons.stay_current_portrait_rounded
            : Icons.stay_current_landscape_rounded,
        size: 16,
        color: theme.speedNormal,
      ),
      label: Text(
        isLandscape ? 'Portrait' : 'Landscape',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.getTelemetryTextStyle(
          fontSize: 12,
          color: Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: onToggleOrientation,
    );
  }

  Widget _buildTripRecordingButton() {
    final active = isRecordingTrip;

    return ElevatedButton.icon(
      style: ElevatedButton.styleFrom(
        backgroundColor: active ? const Color(0xFF2C1014) : const Color(0xFF1E1E1E),
        foregroundColor: active ? Colors.redAccent : Colors.white,
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 4),
        elevation: active ? 2 : 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(8),
          side: BorderSide(
            color: active
                ? Colors.redAccent
                : theme.cardBorderColor.withValues(alpha: 0.9),
            width: active ? 1.5 : 1.0,
          ),
        ),
      ),
      icon: Icon(
        active ? Icons.stop_rounded : Icons.fiber_manual_record_rounded,
        size: 16,
        color: active ? Colors.redAccent : const Color(0xFFFF455B),
      ),
      label: Text(
        active ? 'Stop Trip' : 'Start Trip',
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: theme.getTelemetryTextStyle(
          fontSize: 12,
          color: active ? Colors.redAccent : Colors.white,
          fontWeight: FontWeight.bold,
        ),
      ),
      onPressed: () {
        HapticFeedback.mediumImpact();
        onToggleRecording();
      },
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
                color: isHolding
                    ? AppColors.criticalRed
                    : widget.theme.cardBorderColor,
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
                        size: 14,
                        color:
                            isHolding ? AppColors.criticalRed : Colors.white70,
                      ),
                      const SizedBox(width: 4),
                      Text(
                        isHolding
                            ? '${(1.5 - progress * 1.5).toStringAsFixed(1)}s'
                            : 'Reset Trip',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: widget.theme.getTelemetryTextStyle(
                          fontSize: 11,
                          color:
                              isHolding ? AppColors.criticalRed : Colors.white,
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
