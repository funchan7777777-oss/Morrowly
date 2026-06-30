import 'dart:ui' show BlurStyle, MaskFilter;

import 'package:flutter/material.dart';

class TomorrowCompassMark extends StatelessWidget {
  const TomorrowCompassMark({super.key, this.size = 64});

  final double size;

  @override
  Widget build(BuildContext context) {
    return SizedBox.square(
      dimension: size,
      child: const CustomPaint(painter: _TomorrowCompassMarkPainter()),
    );
  }
}

class _TomorrowCompassMarkPainter extends CustomPainter {
  const _TomorrowCompassMarkPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final shortest = size.shortestSide;
    final rect = Offset.zero & size;
    final center = rect.center;
    final outerRadius = Radius.circular(shortest * 0.32);

    final shadowPaint = Paint()
      ..color = const Color(0xFF24122B).withValues(alpha: 0.28)
      ..maskFilter = MaskFilter.blur(BlurStyle.normal, shortest * 0.12);
    canvas.drawRRect(
      RRect.fromRectAndRadius(
        rect.deflate(shortest * 0.04).shift(Offset(0, shortest * 0.05)),
        outerRadius,
      ),
      shadowPaint,
    );

    final frame = RRect.fromRectAndRadius(
      rect.deflate(shortest * 0.03),
      outerRadius,
    );
    canvas.drawRRect(
      frame,
      Paint()
        ..shader = const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFF70517D), Color(0xFF51365C), Color(0xFF3B2843)],
        ).createShader(rect),
    );
    canvas.drawRRect(
      frame,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = shortest * 0.018
        ..color = Colors.white.withValues(alpha: 0.13),
    );

    final glowRadius = shortest * 0.37;
    canvas.drawCircle(
      center.translate(0, shortest * 0.02),
      glowRadius,
      Paint()
        ..color = const Color(0xFFB65CFF).withValues(alpha: 0.28)
        ..maskFilter = MaskFilter.blur(BlurStyle.normal, shortest * 0.08),
    );
    canvas.drawCircle(
      center,
      shortest * 0.34,
      Paint()
        ..shader = RadialGradient(
          center: const Alignment(-0.28, -0.34),
          radius: 0.95,
          colors: [
            Colors.white.withValues(alpha: 0.18),
            const Color(0xFFBE6BFF),
            const Color(0xFF8E48EA),
          ],
          stops: const [0, 0.42, 1],
        ).createShader(Rect.fromCircle(center: center, radius: glowRadius)),
    );
    canvas.drawCircle(
      center,
      shortest * 0.34,
      Paint()
        ..style = PaintingStyle.stroke
        ..strokeWidth = shortest * 0.018
        ..color = Colors.white.withValues(alpha: 0.28),
    );

    final orbitPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = shortest * 0.024
      ..color = Colors.white.withValues(alpha: 0.2);
    canvas.drawArc(
      Rect.fromCircle(center: center, radius: shortest * 0.29),
      0.18,
      4.2,
      false,
      orbitPaint,
    );

    final needle = _needlePath(center, shortest * 0.34);
    canvas.drawShadow(needle, const Color(0xFF3C1555), shortest * 0.03, false);
    canvas.drawPath(
      needle,
      Paint()
        ..shader = LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [
            Colors.white,
            const Color(0xFFF4E8FF),
            Colors.white.withValues(alpha: 0.88),
          ],
        ).createShader(rect),
    );

    final sparklePaint = Paint()..color = Colors.white.withValues(alpha: 0.72);
    canvas.drawCircle(
      center.translate(shortest * 0.21, -shortest * 0.2),
      shortest * 0.018,
      sparklePaint,
    );
    canvas.drawCircle(
      center.translate(-shortest * 0.23, shortest * 0.18),
      shortest * 0.014,
      sparklePaint..color = const Color(0xFFFFD9F7).withValues(alpha: 0.7),
    );
  }

  Path _needlePath(Offset center, double radius) {
    final cx = center.dx;
    final cy = center.dy;
    return Path()
      ..moveTo(cx, cy - radius * 0.66)
      ..lineTo(cx + radius * 0.43, cy - radius * 0.12)
      ..quadraticBezierTo(
        cx + radius * 0.5,
        cy - radius * 0.02,
        cx + radius * 0.36,
        cy,
      )
      ..lineTo(cx + radius * 0.14, cy - radius * 0.08)
      ..lineTo(cx + radius * 0.14, cy + radius * 0.48)
      ..quadraticBezierTo(
        cx + radius * 0.14,
        cy + radius * 0.6,
        cx,
        cy + radius * 0.6,
      )
      ..quadraticBezierTo(
        cx - radius * 0.14,
        cy + radius * 0.6,
        cx - radius * 0.14,
        cy + radius * 0.48,
      )
      ..lineTo(cx - radius * 0.14, cy - radius * 0.08)
      ..lineTo(cx - radius * 0.36, cy)
      ..quadraticBezierTo(
        cx - radius * 0.5,
        cy - radius * 0.02,
        cx - radius * 0.43,
        cy - radius * 0.12,
      )
      ..close();
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
