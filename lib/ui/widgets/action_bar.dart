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
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
      decoration: BoxDecoration(
        color: theme.cardBackgroundColor.withValues(alpha: 0.85),
        border: Border(
          top: BorderSide(
            color: theme.cardBorderColor.withValues(alpha: 0.6),
            width: 1,
          ),
        ),
      ),
      child: SafeArea(
        top: false,
        child: SizedBox(
          height: 54,
          child: Row(
            children: [
              // 1. Pause / Resume Trip Recording Button
              Expanded(
                flex: 4,
                child: _buildPauseResumeButton(),
              ),
              const SizedBox(width: 10),

              // 2. Start / Stop Trip Recording Button (Solid in Middle)
              Expanded(
                flex: 5,
                child: _buildStartStopButton(),
              ),
              const SizedBox(width: 10),

              // 3. Guarded 1500ms Hold-To-Reset Button
              Expanded(
                flex: 4,
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
                      active ? 'Stop Trip' : 'Start Trip',
                      style: theme.getTelemetryTextStyle(
                        fontSize: 14,
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
    String label;

    if (!canPause) {
      bg = const Color(0xFF161616);
      border = theme.cardBorderColor.withValues(alpha: 0.4);
      fg = Colors.white24;
      icon = Icons.pause_rounded;
      label = 'Pause';
    } else if (isPaused) {
      bg = const Color(0xFF10261A);
      border = const Color(0xFF34D399);
      fg = const Color(0xFF34D399);
      icon = Icons.play_arrow_rounded;
      label = 'Resume';
    } else {
      bg = const Color(0xFF281C09);
      border = const Color(0xFFFFB340);
      fg = const Color(0xFFFFB340);
      icon = Icons.pause_rounded;
      label = 'Pause';
    }

    return Material(
      color: Colors.transparent,
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
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6),
              child: FittedBox(
                fit: BoxFit.scaleDown,
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      icon,
                      size: 20,
                      color: fg,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      label,
                      style: theme.getTelemetryTextStyle(
                        fontSize: 14,
                        color: fg,
                        fontWeight: FontWeight.bold,
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
            height: 54,
            decoration: BoxDecoration(
              color: const Color(0xFF1E1E1E),
              borderRadius: BorderRadius.circular(10),
              border: Border.all(
                color: isHolding
                    ? AppColors.criticalRed
                    : widget.theme.cardBorderColor.withValues(alpha: 0.8),
                width: isHolding ? 1.5 : 1.0,
              ),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(9),
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
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 6),
                    child: FittedBox(
                      fit: BoxFit.scaleDown,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Icon(
                            Icons.refresh_rounded,
                            size: 18,
                            color: isHolding
                                ? AppColors.criticalRed
                                : Colors.white70,
                          ),
                          const SizedBox(width: 5),
                          Text(
                            isHolding
                                ? '${(1.5 - progress * 1.5).toStringAsFixed(1)}s'
                                : 'Reset Trip',
                            style: widget.theme.getTelemetryTextStyle(
                              fontSize: 14,
                              color: isHolding
                                  ? AppColors.criticalRed
                                  : Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
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
