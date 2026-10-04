import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../core/theme/hud_theme.dart';

/// Individual quick actions widget containing HUD Mirror (flip) and Orientation toggles.
/// Rendered in AuxiliaryGrid during portrait mode, and elevated to TopStatusBar during landscape mode.
class HudQuickActions extends StatelessWidget {
  final bool isHudMirrored;
  final VoidCallback? onToggleHud;
  final bool isLandscape;
  final VoidCallback? onToggleOrientation;
  final HudTheme theme;
  final double buttonWidth;
  final double buttonHeight;

  const HudQuickActions({
    super.key,
    required this.isHudMirrored,
    required this.onToggleHud,
    required this.isLandscape,
    required this.onToggleOrientation,
    required this.theme,
    this.buttonWidth = 44,
    this.buttonHeight = 44,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildButton(
          icon: Icons.flip_rounded,
          isActive: isHudMirrored,
          tooltip: 'Flip HUD',
          onTap: onToggleHud,
        ),
        const SizedBox(width: 8),
        _buildButton(
          icon: isLandscape
              ? Icons.stay_current_portrait_rounded
              : Icons.stay_current_landscape_rounded,
          isActive: false,
          tooltip: isLandscape ? 'Portrait Mode' : 'Landscape Mode',
          onTap: onToggleOrientation,
        ),
      ],
    );
  }

  Widget _buildButton({
    required IconData icon,
    required bool isActive,
    required VoidCallback? onTap,
    required String tooltip,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          HapticFeedback.selectionClick();
          onTap?.call();
        },
        borderRadius: BorderRadius.circular(10),
        child: Ink(
          width: buttonWidth,
          height: buttonHeight,
          decoration: BoxDecoration(
            color: isActive
                ? theme.speedNormal.withValues(alpha: 0.9)
                : theme.cardBackgroundColor,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(
              color: isActive
                  ? theme.speedNormal
                  : theme.cardBorderColor,
              width: 1.2,
            ),
          ),
          child: Tooltip(
            message: tooltip,
            child: Icon(
              icon,
              size: 20,
              color: isActive
                  ? Colors.black
                  : theme.textColor.withValues(alpha: 0.9),
            ),
          ),
        ),
      ),
    );
  }
}
