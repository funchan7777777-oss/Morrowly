import 'package:flutter/material.dart';

class MorrowlyAvatarPlaceholder extends StatelessWidget {
  const MorrowlyAvatarPlaceholder({
    super.key,
    required this.radius,
    required this.label,
  });

  final double radius;
  final String label;

  @override
  Widget build(BuildContext context) {
    final size = radius * 2;
    final initial = _initialFor(label);
    final showDetails = radius >= 22;
    return Semantics(
      label: label.isEmpty ? 'Profile placeholder' : '$label profile',
      image: true,
      child: SizedBox.square(
        dimension: size,
        child: DecoratedBox(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            gradient: const LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [Color(0xFFFFBFEF), Color(0xFFB66DFF), Color(0xFF6545D7)],
              stops: [0, 0.5, 1],
            ),
            border: Border.all(
              color: Colors.white.withValues(alpha: 0.42),
              width: radius >= 28 ? 2 : 1.3,
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFB66DFF).withValues(alpha: 0.34),
                blurRadius: radius * 0.62,
                offset: Offset(0, radius * 0.18),
              ),
            ],
          ),
          child: ClipOval(
            child: Stack(
              fit: StackFit.expand,
              children: [
                DecoratedBox(
                  decoration: BoxDecoration(
                    gradient: RadialGradient(
                      center: const Alignment(-0.34, -0.46),
                      radius: 0.76,
                      colors: [
                        Colors.white.withValues(alpha: 0.5),
                        Colors.white.withValues(alpha: 0),
                      ],
                    ),
                  ),
                ),
                CustomPaint(painter: _AvatarOrbitPainter()),
                Center(
                  child: Text(
                    initial,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: radius * 0.78,
                      height: 1,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                      shadows: [
                        Shadow(
                          color: Colors.black.withValues(alpha: 0.18),
                          blurRadius: radius * 0.16,
                          offset: Offset(0, radius * 0.06),
                        ),
                      ],
                    ),
                  ),
                ),
                if (showDetails) ...[
                  Positioned(
                    right: radius * 0.24,
                    top: radius * 0.22,
                    child: Icon(
                      Icons.auto_awesome_rounded,
                      color: Colors.white.withValues(alpha: 0.92),
                      size: radius * 0.38,
                    ),
                  ),
                  Positioned(
                    left: radius * 0.3,
                    bottom: radius * 0.24,
                    child: Container(
                      width: radius * 0.42,
                      height: radius * 0.42,
                      decoration: BoxDecoration(
                        color: Colors.white.withValues(alpha: 0.24),
                        shape: BoxShape.circle,
                      ),
                    ),
                  ),
                ],
              ],
            ),
          ),
        ),
      ),
    );
  }
}

String _initialFor(String label) {
  final trimmed = label.trim();
  if (trimmed.isEmpty) {
    return 'M';
  }
  return String.fromCharCode(trimmed.runes.first).toUpperCase();
}

class _AvatarOrbitPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final orbitPaint = Paint()
      ..color = Colors.white.withValues(alpha: 0.3)
      ..style = PaintingStyle.stroke
      ..strokeWidth = size.width * 0.035
      ..strokeCap = StrokeCap.round;

    final orbitRect = Rect.fromCenter(
      center: Offset(size.width * 0.52, size.height * 0.7),
      width: size.width * 0.84,
      height: size.height * 0.32,
    );
    canvas.drawArc(orbitRect, 3.46, 1.92, false, orbitPaint);

    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.78);
    canvas.drawCircle(
      Offset(size.width * 0.28, size.height * 0.3),
      size.width * 0.026,
      dotPaint,
    );
    canvas.drawCircle(
      Offset(size.width * 0.72, size.height * 0.62),
      size.width * 0.018,
      dotPaint..color = Colors.white.withValues(alpha: 0.56),
    );
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
