import 'dart:math' as math;
import 'package:flutter/material.dart';

/// Custom painter for a classic physical compass gauge.
/// Features a fixed outer dial (N at 12 o'clock) and a dual-pointer needle:
/// - North hand (Red / Accent): Pointing towards the current heading
/// - South hand (Silver / Muted): Pointing opposite
class CompassDialPainter extends CustomPainter {
  final double headingDegrees;
  final bool isMini;
  final Color accentColor;
  final bool isDarkMode;
  final Color textColor;
  final Color subtitleColor;
  final Color borderColor;

  const CompassDialPainter({
    required this.headingDegrees,
    this.isMini = false,
    required this.accentColor,
    required this.isDarkMode,
    required this.textColor,
    required this.subtitleColor,
    required this.borderColor,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final radius = math.min(size.width, size.height) / 2;

    if (radius <= 0) return;

    // 1. Draw Dial Background & Outer Ring
    _drawDialBackground(canvas, center, radius);

    // 2. Draw Ticks & Cardinal Labels (N, E, S, W)
    _drawTicksAndCardinals(canvas, center, radius);

    // 3. Draw the Two-Hand Needle (North & South pointers)
    _drawNeedle(canvas, center, radius);

    // 4. Draw Center Pivot Cap
    _drawCenterPivot(canvas, center, radius);
  }

  void _drawDialBackground(Canvas canvas, Offset center, double radius) {
    final bgPaint = Paint()
      ..color = isDarkMode
          ? const Color(0xFF101216)
          : const Color(0xFFF0F2F5)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, radius - 1, bgPaint);

    final ringPaint = Paint()
      ..color = isDarkMode
          ? Colors.white.withValues(alpha: 0.12)
          : Colors.black.withValues(alpha: 0.10)
      ..style = PaintingStyle.stroke
      ..strokeWidth = isMini ? 1.0 : 1.5;
    canvas.drawCircle(center, radius - 1.5, ringPaint);
  }

  void _drawTicksAndCardinals(Canvas canvas, Offset center, double radius) {
    final tickPaint = Paint()
      ..strokeCap = StrokeCap.round
      ..style = PaintingStyle.stroke;

    final cardinalStyle = TextStyle(
      fontSize: isMini ? 7.5 : 12,
      fontWeight: FontWeight.w900,
      color: textColor,
      height: 1.0,
    );

    final northStyle = TextStyle(
      fontSize: isMini ? 8 : 13,
      fontWeight: FontWeight.w900,
      color: const Color(0xFFFF3B30), // Classic compass North red
      height: 1.0,
    );

    final degreeStyle = TextStyle(
      fontSize: 9,
      fontWeight: FontWeight.w600,
      color: subtitleColor,
      height: 1.0,
    );

    final totalTicks = isMini ? 12 : 72; // every 30° in mini, every 5° in full
    final innerPadding = isMini ? 3.0 : 6.0;

    for (int i = 0; i < totalTicks; i++) {
      final angleDeg = (i * 360.0 / totalTicks);
      final angleRad = (angleDeg - 90) * math.pi / 180.0;

      final cosA = math.cos(angleRad);
      final sinA = math.sin(angleRad);

      final isCardinal = angleDeg % 90 == 0;
      final isMajor = angleDeg % 30 == 0;

      if (isMini) {
        // Mini mode: simple tick lines
        final tickLength = isCardinal ? 4.0 : 2.5;
        final startR = radius - innerPadding - tickLength;
        final endR = radius - innerPadding;

        tickPaint.color = isCardinal
            ? (angleDeg == 0 ? const Color(0xFFFF3B30) : textColor)
            : subtitleColor.withValues(alpha: 0.4);
        tickPaint.strokeWidth = isCardinal ? 1.5 : 1.0;

        canvas.drawLine(
          Offset(center.dx + startR * cosA, center.dy + startR * sinA),
          Offset(center.dx + endR * cosA, center.dy + endR * sinA),
          tickPaint,
        );
      } else {
        // Detailed mode (Bottom Sheet): full ticks with degree marks
        final tickLength = isCardinal ? 8.0 : (isMajor ? 6.0 : 3.5);
        final startR = radius - innerPadding - tickLength;
        final endR = radius - innerPadding;

        tickPaint.color = isCardinal
            ? (angleDeg == 0 ? const Color(0xFFFF3B30) : textColor)
            : (isMajor
                ? textColor.withValues(alpha: 0.6)
                : subtitleColor.withValues(alpha: 0.35));
        tickPaint.strokeWidth = isCardinal ? 2.0 : (isMajor ? 1.5 : 1.0);

        canvas.drawLine(
          Offset(center.dx + startR * cosA, center.dy + startR * sinA),
          Offset(center.dx + endR * cosA, center.dy + endR * sinA),
          tickPaint,
        );

        // Draw degree numeral for major ticks (every 30°, skipping cardinals)
        if (isMajor && !isCardinal) {
          final textR = radius - innerPadding - 18.0;
          final textPainter = TextPainter(
            text: TextSpan(
              text: '${angleDeg.toInt()}°',
              style: degreeStyle,
            ),
            textDirection: TextDirection.ltr,
          )..layout();

          final pos = Offset(
            center.dx + textR * cosA - textPainter.width / 2,
            center.dy + textR * sinA - textPainter.height / 2,
          );
          textPainter.paint(canvas, pos);
        }
      }
    }

    // Draw Cardinal Labels (N, E, S, W)
    final labelRadius = isMini ? radius - 8.0 : radius - 20.0;
    const cardinals = [
      (0, 'N'),
      (90, 'E'),
      (180, 'S'),
      (270, 'W'),
    ];

    for (final item in cardinals) {
      final angleDeg = item.$1;
      final label = item.$2;
      final angleRad = (angleDeg - 90) * math.pi / 180.0;

      final style = label == 'N' ? northStyle : cardinalStyle;
      final textPainter = TextPainter(
        text: TextSpan(text: label, style: style),
        textDirection: TextDirection.ltr,
      )..layout();

      final pos = Offset(
        center.dx + labelRadius * math.cos(angleRad) - textPainter.width / 2,
        center.dy + labelRadius * math.sin(angleRad) - textPainter.height / 2,
      );
      textPainter.paint(canvas, pos);
    }
  }

  void _drawNeedle(Canvas canvas, Offset center, double radius) {
    canvas.save();
    canvas.translate(center.dx, center.dy);

    // Needle rotates by heading angle
    // In Flutter, 0 radians is 3 o'clock; heading 0° is North (12 o'clock).
    // So rotate by (headingDegrees - 90) * pi / 180 or simply headingDegrees * pi / 180
    // if we align our local coordinates with 12 o'clock (0, -needleLength).
    final rad = headingDegrees * math.pi / 180.0;
    canvas.rotate(rad);

    final needleLength = isMini ? radius * 0.72 : radius * 0.68;
    final needleHalfWidth = isMini ? 3.0 : 6.0;

    // --- NORTH HAND (Pointing up to 12 o'clock) ---
    // Left half (light / highlight)
    final northLightPath = Path()
      ..moveTo(0, 0)
      ..lineTo(-needleHalfWidth, 0)
      ..lineTo(0, -needleLength)
      ..close();

    final northLightPaint = Paint()
      ..color = const Color(0xFFFF3B30) // Vibrant Compass Red
      ..style = PaintingStyle.fill;
    canvas.drawPath(northLightPath, northLightPaint);

    // Right half (shaded for 3D bevel effect)
    final northDarkPath = Path()
      ..moveTo(0, 0)
      ..lineTo(needleHalfWidth, 0)
      ..lineTo(0, -needleLength)
      ..close();

    final northDarkPaint = Paint()
      ..color = const Color(0xFFCC1F15) // Deep Bevel Red
      ..style = PaintingStyle.fill;
    canvas.drawPath(northDarkPath, northDarkPaint);

    // --- SOUTH HAND (Pointing down to 6 o'clock) ---
    // Left half (light silver)
    final southLightPath = Path()
      ..moveTo(0, 0)
      ..lineTo(-needleHalfWidth, 0)
      ..lineTo(0, needleLength)
      ..close();

    final southLightPaint = Paint()
      ..color = isDarkMode
          ? const Color(0xFFE5E5EA) // Metallic Silver
          : const Color(0xFF8E8E93)
      ..style = PaintingStyle.fill;
    canvas.drawPath(southLightPath, southLightPaint);

    // Right half (dark metallic slate)
    final southDarkPath = Path()
      ..moveTo(0, 0)
      ..lineTo(needleHalfWidth, 0)
      ..lineTo(0, needleLength)
      ..close();

    final southDarkPaint = Paint()
      ..color = isDarkMode
          ? const Color(0xFF8E8E93) // Shaded Slate
          : const Color(0xFF48484A)
      ..style = PaintingStyle.fill;
    canvas.drawPath(southDarkPath, southDarkPaint);

    canvas.restore();
  }

  void _drawCenterPivot(Canvas canvas, Offset center, double radius) {
    final pivotRadius = isMini ? 2.8 : 6.0;

    // Pivot shadow / outer rim
    final outerPivot = Paint()
      ..color = isDarkMode ? const Color(0xFF1C1C1E) : Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, pivotRadius + (isMini ? 0.8 : 1.5), outerPivot);

    // Pivot brass / metallic hub
    final innerPivot = Paint()
      ..color = const Color(0xFFFF3B30)
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, pivotRadius, innerPivot);

    // Center pin dot
    final centerDot = Paint()
      ..color = Colors.white
      ..style = PaintingStyle.fill;
    canvas.drawCircle(center, pivotRadius * 0.45, centerDot);
  }

  @override
  bool shouldRepaint(covariant CompassDialPainter oldDelegate) {
    return oldDelegate.headingDegrees != headingDegrees ||
        oldDelegate.isMini != isMini ||
        oldDelegate.accentColor != accentColor ||
        oldDelegate.isDarkMode != isDarkMode ||
        oldDelegate.textColor != textColor ||
        oldDelegate.subtitleColor != subtitleColor ||
        oldDelegate.borderColor != borderColor;
  }
}
