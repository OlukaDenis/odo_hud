import 'package:flutter/material.dart';
import '../../../core/theme/hud_theme.dart';
import 'compass_dial_painter.dart';

/// Animated Compass Dial widget that smoothly interpolates rotation
/// without spinning wildly across the 360° boundary.
class CompassDial extends StatefulWidget {
  final double headingDegrees;
  final double size;
  final bool isMini;
  final HudTheme theme;

  const CompassDial({
    super.key,
    required this.headingDegrees,
    required this.size,
    this.isMini = false,
    required this.theme,
  });

  @override
  State<CompassDial> createState() => _CompassDialState();
}

class _CompassDialState extends State<CompassDial>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _animation;
  double _currentDisplayAngle = 0.0;
  double _targetDisplayAngle = 0.0;

  @override
  void initState() {
    super.initState();
    _currentDisplayAngle = widget.headingDegrees;
    _targetDisplayAngle = widget.headingDegrees;

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 320),
    );

    _animation = Tween<double>(
      begin: _currentDisplayAngle,
      end: _targetDisplayAngle,
    ).animate(CurvedAnimation(
      parent: _controller,
      curve: Curves.easeOutCubic,
    ))..addListener(() {
        setState(() {
          _currentDisplayAngle = _animation.value;
        });
      });
  }

  @override
  void didUpdateWidget(covariant CompassDial oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.headingDegrees != widget.headingDegrees) {
      // Calculate shortest angular path across 360° boundary
      final delta =
          ((widget.headingDegrees - _currentDisplayAngle + 540) % 360) - 180;
      final newTarget = _currentDisplayAngle + delta;

      _animation = Tween<double>(
        begin: _currentDisplayAngle,
        end: newTarget,
      ).animate(CurvedAnimation(
        parent: _controller,
        curve: Curves.easeOutCubic,
      ));

      _controller.reset();
      _controller.forward();
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return RepaintBoundary(
      child: CustomPaint(
        size: Size(widget.size, widget.size),
        painter: CompassDialPainter(
          headingDegrees: _currentDisplayAngle,
          isMini: widget.isMini,
          accentColor: widget.theme.speedNormal,
          isDarkMode: widget.theme.isDarkMode,
          textColor: widget.theme.textColor,
          subtitleColor: widget.theme.subtitleColor,
          borderColor: widget.theme.cardBorderColor,
        ),
      ),
    );
  }
}
