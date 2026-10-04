import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/constants/app_colors.dart';
import '../../core/constants/app_constants.dart';
import '../../core/theme/hud_theme.dart';

/// Enlarged Ergonomic Bottom Action Bar.
/// Exclusively houses the trip control actions:
/// 1. Start / Stop Trip Recording
/// 2. Pause / Resume Recording
/// 3. Guarded Hold-to-Reset Trip
class ActionBar extends StatelessWidget {
  final bool isRecordingTrip;
  final VoidCallback onToggleRecording;
  final bool isTripPaused;
  final VoidCallback? onTogglePause;
  final VoidCallback onResetTrip;
  final HudTheme theme;

  // Retained as optional for backwards compatibility
  final bool isHudMirrored;
  final VoidCallback? onToggleHud;
  final bool isLandscape;
  final VoidCallback? onToggleOrientation;
  final VoidCallback? onOpenSettings;

  const ActionBar({
    super.key,
    required this.isRecordingTrip,
    required this.onToggleRecording,
    this.isTripPaused = false,
    this.onTogglePause,
    required this.onResetTrip,
    required this.theme,
    this.isHudMirrored = false,
    this.onToggleHud,
    this.isLandscape = false,
    this.onToggleOrientation,
    this.onOpenSettings,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: theme.cardBackgroundColor,
        border: Border(
          top: BorderSide(
            color: theme.cardBorderColor,
            width: 1.2,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 48,
          child: Row(
            children: [
              // 1. Pause / Resume Button (Icon only)
              SizedBox(
                width: 52,
                height: 48,
                child: _buildPauseResumeButton(),
              ),
              const SizedBox(width: 8),

              // 2. Start / Stop Button ('Start' / 'Stop' - Solid in Middle)
              Expanded(
                child: _buildStartStopButton(),
              ),
              const SizedBox(width: 8),

              // 3. Guarded 1500ms Hold-To-Reset Button (Icon only)
              SizedBox(
                width: 52,
                height: 48,
                child: _GuardedResetButton(
                  onReset: onResetTrip,
                  theme: theme,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildStartStopButton() {
    final active = isRecordingTrip;
    final solidBg = active ? const Color(0xFFFF3B30) : theme.speedNormal;
    final solidFg = active
        ? Colors.white
        : (ThemeData.estimateBrightnessForColor(solidBg) == Brightness.dark
            ? Colors.white
            : Colors.black);

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.mediumImpact();
          onToggleRecording();
        },
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          decoration: BoxDecoration(
            color: solidBg,
            borderRadius: BorderRadius.circular(10),
            boxShadow: [
              BoxShadow(
                color: solidBg.withValues(alpha: 0.35),
                blurRadius: 8,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      active
                          ? Icons.stop_rounded
                          : Icons.play_arrow_rounded,
                      size: 22,
                      color: solidFg,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      active ? 'Stop' : 'Start',
                      style: theme.getTelemetryTextStyle(
                        fontSize: 15,
                        color: solidFg,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildPauseResumeButton() {
    final canPause = isRecordingTrip;
    final isPaused = isTripPaused;

    Color bg;
    Color border;
    Color fg;
    IconData icon;
    String tooltip;

    final isDark = theme.isDarkMode;
    if (!canPause) {
      bg = isDark ? theme.cardBackgroundColor : const Color(0xFFE8E8ED);
      border = theme.cardBorderColor.withValues(alpha: 0.4);
      fg = isDark ? Colors.white24 : Colors.black26;
      icon = Icons.pause_rounded;
      tooltip = 'Pause Recording';
    } else if (isPaused) {
      bg = isDark ? const Color(0xFF10261A) : const Color(0xFFE8F5E9);
      border = const Color(0xFF34D399);
      fg = isDark ? const Color(0xFF34D399) : const Color(0xFF00897B);
      icon = Icons.play_arrow_rounded;
      tooltip = 'Resume Recording';
    } else {
      bg = isDark ? const Color(0xFF281C09) : const Color(0xFFFFF3E0);
      border = const Color(0xFFFFB340);
      fg = isDark ? const Color(0xFFFFB340) : const Color(0xFFE65100);
      icon = Icons.pause_rounded;
      tooltip = 'Pause Recording';
    }

    return Material(
      color: Colors.transparent,
      child: Tooltip(
        message: tooltip,
        child: InkWell(
          onTap: canPause
              ? () {
                  HapticFeedback.mediumImpact();
                  onTogglePause?.call();
                }
              : null,
          borderRadius: BorderRadius.circular(10),
          child: Ink(
            decoration: BoxDecoration(
              color: bg,
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: border,
                width: canPause ? 1.5 : 1.0,
              ),
            ),
            child: Center(
              child: Icon(
                icon,
                size: 22,
                color: fg,
              ),
            ),
          ),
        ),
      ),
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

          final isDark = widget.theme.isDarkMode;
          return Tooltip(
            message: 'Hold to Reset Trip',
            child: Container(
              height: 48,
              decoration: BoxDecoration(
                color: isDark ? widget.theme.cardBackgroundColor : const Color(0xFFE8E8ED),
                borderRadius: BorderRadius.circular(10),
                border: Border.all(
                  color: isHolding
                      ? AppColors.criticalRed
                      : widget.theme.cardBorderColor,
                  width: isHolding ? 1.5 : 1.0,
                ),
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(9),
                child: Stack(
                  alignment: Alignment.center,
                  children: [
                    // Progressive Fill Bar (fills bottom-to-top or left-to-right)
                    Positioned.fill(
                      child: FractionallySizedBox(
                        alignment: Alignment.bottomCenter,
                        heightFactor: progress,
                        child: Container(
                          color: AppColors.criticalRed.withValues(alpha: 0.35),
                        ),
                      ),
                    ),

                    // Reset Icon
                    Icon(
                      Icons.refresh_rounded,
                      size: 22,
                      color: isHolding
                          ? AppColors.criticalRed
                          : widget.theme.textColor.withValues(alpha: 0.85),
                    ),
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
