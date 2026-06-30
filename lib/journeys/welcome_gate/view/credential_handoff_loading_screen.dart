import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CredentialHandoffLoadingScreen extends StatefulWidget {
  const CredentialHandoffLoadingScreen({super.key});

  @override
  State<CredentialHandoffLoadingScreen> createState() =>
      _CredentialHandoffLoadingScreenState();
}

class _CredentialHandoffLoadingScreenState
    extends State<CredentialHandoffLoadingScreen>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2600),
    )..repeat();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFF211728),
        body: Stack(
          fit: StackFit.expand,
          children: [
            const _HandoffBackdrop(),
            SafeArea(
              child: Center(
                child: Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 34),
                  child: ConstrainedBox(
                    constraints: const BoxConstraints(maxWidth: 340),
                    child: AnimatedBuilder(
                      animation: _controller,
                      builder: (context, _) {
                        final drift = Curves.easeInOutSine.transform(
                          math.sin(_controller.value * math.pi * 2) * 0.5 + 0.5,
                        );

                        return Transform.translate(
                          offset: const Offset(0, -12),
                          child: Column(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              _HandoffSignal(progress: _controller.value),
                              const SizedBox(height: 28),
                              const Text(
                                'Opening your room',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white,
                                  fontSize: 24,
                                  height: 1.08,
                                  fontWeight: FontWeight.w900,
                                  letterSpacing: 0,
                                ),
                              ),
                              const SizedBox(height: 9),
                              Text(
                                'Carrying your saved profile into Morrowly.',
                                textAlign: TextAlign.center,
                                style: TextStyle(
                                  color: Colors.white.withValues(alpha: 0.62),
                                  fontSize: 13,
                                  height: 1.35,
                                  fontWeight: FontWeight.w700,
                                  letterSpacing: 0,
                                ),
                              ),
                              const SizedBox(height: 26),
                              _HandoffProgressRibbon(
                                progress: _controller.value,
                                drift: drift,
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _HandoffBackdrop extends StatelessWidget {
  const _HandoffBackdrop();

  @override
  Widget build(BuildContext context) {
    return const DecoratedBox(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: [Color(0xFF9D42D8), Color(0xFF5D3369), Color(0xFF201724)],
          stops: [0, 0.5, 1],
        ),
      ),
      child: CustomPaint(
        painter: _HandoffBackdropPainter(),
        child: SizedBox.expand(),
      ),
    );
  }
}

class _HandoffProgressRibbon extends StatelessWidget {
  const _HandoffProgressRibbon({required this.progress, required this.drift});

  final double progress;
  final double drift;

  @override
  Widget build(BuildContext context) {
    final thumbAlignment = Alignment(-1 + progress * 2, 0);

    return Container(
      width: 214,
      height: 10,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
        border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
      ),
      clipBehavior: Clip.antiAlias,
      child: Stack(
        fit: StackFit.expand,
        children: [
          Align(
            alignment: thumbAlignment,
            child: FractionallySizedBox(
              widthFactor: 0.42 + drift * 0.1,
              child: DecoratedBox(
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(999),
                  gradient: const LinearGradient(
                    colors: [
                      Color(0x00FFFFFF),
                      Color(0xFFFF6ECF),
                      Color(0xFFA875FF),
                      Color(0x00FFFFFF),
                    ],
                    stops: [0, 0.28, 0.72, 1],
                  ),
                  boxShadow: [
                    BoxShadow(
                      color: const Color(0xFFFF6ECF).withValues(alpha: 0.42),
                      blurRadius: 16,
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _HandoffSignal extends StatelessWidget {
  const _HandoffSignal({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final wave = math.sin(progress * math.pi * 2);
    final pulse = Curves.easeInOutSine.transform(wave * 0.5 + 0.5);

    return SizedBox(
      width: 190,
      height: 190,
      child: Stack(
        alignment: Alignment.center,
        children: [
          Transform.scale(
            scale: 0.92 + pulse * 0.08,
            child: Container(
              width: 144,
              height: 144,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    const Color(0xFFFF70D1).withValues(alpha: 0.2),
                    const Color(0xFFAE76FF).withValues(alpha: 0.08),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),
          CustomPaint(
            size: const Size(174, 174),
            painter: _HandoffOrbitPainter(progress: progress),
          ),
          Transform.translate(
            offset: Offset(0, -5 + pulse * 10),
            child: const _MorrowlySeal(),
          ),
          Positioned(
            right: 29,
            bottom: 38,
            child: _SignalPebble(progress: progress),
          ),
        ],
      ),
    );
  }
}

class _MorrowlySeal extends StatelessWidget {
  const _MorrowlySeal();

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 96,
      height: 96,
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(30),
        gradient: const LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [Color(0xFFFF78D7), Color(0xFF9B70FF)],
        ),
        border: Border.all(color: Colors.white.withValues(alpha: 0.2)),
        boxShadow: [
          BoxShadow(
            color: const Color(0xFFFF5DCF).withValues(alpha: 0.26),
            blurRadius: 26,
            offset: const Offset(0, 14),
          ),
        ],
      ),
      child: Stack(
        alignment: Alignment.center,
        children: [
          Container(
            width: 52,
            height: 52,
            decoration: BoxDecoration(
              color: Colors.white.withValues(alpha: 0.16),
              shape: BoxShape.circle,
            ),
          ),
          const Text(
            'M',
            style: TextStyle(
              color: Colors.white,
              fontSize: 42,
              height: 1,
              fontWeight: FontWeight.w900,
              letterSpacing: 0,
            ),
          ),
          Positioned(
            right: 24,
            top: 26,
            child: Container(
              width: 6,
              height: 6,
              decoration: BoxDecoration(
                color: Colors.white.withValues(alpha: 0.9),
                shape: BoxShape.circle,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class _SignalPebble extends StatelessWidget {
  const _SignalPebble({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final lift = math.sin(progress * math.pi * 2) * 3;

    return Transform.translate(
      offset: Offset(0, lift),
      child: Container(
        width: 36,
        height: 36,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFFF6ECF),
          border: Border.all(color: Colors.white.withValues(alpha: 0.32)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFFF6ECF).withValues(alpha: 0.38),
              blurRadius: 16,
              offset: const Offset(0, 7),
            ),
          ],
        ),
        child: const Icon(Icons.check_rounded, color: Colors.white, size: 19),
      ),
    );
  }
}

class _HandoffBackdropPainter extends CustomPainter {
  const _HandoffBackdropPainter();

  @override
  void paint(Canvas canvas, Size size) {
    final topBand = Path()
      ..moveTo(0, size.height * 0.15)
      ..cubicTo(
        size.width * 0.18,
        size.height * 0.09,
        size.width * 0.68,
        size.height * 0.2,
        size.width,
        size.height * 0.12,
      )
      ..lineTo(size.width, size.height * 0.27)
      ..cubicTo(
        size.width * 0.62,
        size.height * 0.36,
        size.width * 0.24,
        size.height * 0.18,
        0,
        size.height * 0.29,
      )
      ..close();

    canvas.drawPath(
      topBand,
      Paint()..color = Colors.white.withValues(alpha: 0.045),
    );

    final lowerBand = Path()
      ..moveTo(0, size.height * 0.58)
      ..cubicTo(
        size.width * 0.22,
        size.height * 0.48,
        size.width * 0.74,
        size.height * 0.66,
        size.width,
        size.height * 0.54,
      )
      ..lineTo(size.width, size.height * 0.76)
      ..cubicTo(
        size.width * 0.66,
        size.height * 0.84,
        size.width * 0.28,
        size.height * 0.62,
        0,
        size.height * 0.76,
      )
      ..close();

    canvas.drawPath(
      lowerBand,
      Paint()..color = const Color(0xFFFF7DCE).withValues(alpha: 0.055),
    );

    final linePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 1.2
      ..color = Colors.white.withValues(alpha: 0.055);

    for (var index = 0; index < 4; index++) {
      final y = size.height * (0.42 + index * 0.08);
      final path = Path()
        ..moveTo(size.width * -0.1, y)
        ..quadraticBezierTo(
          size.width * 0.5,
          y + 26 - index * 8,
          size.width * 1.1,
          y - 6,
        );
      canvas.drawPath(path, linePaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HandoffBackdropPainter oldDelegate) => false;
}

class _HandoffOrbitPainter extends CustomPainter {
  const _HandoffOrbitPainter({required this.progress});

  final double progress;

  @override
  void paint(Canvas canvas, Size size) {
    final center = size.center(Offset.zero);
    final radius = size.shortestSide / 2 - 8;
    final rect = Rect.fromCircle(center: center, radius: radius);
    final basePaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 2
      ..color = Colors.white.withValues(alpha: 0.1);

    canvas.drawCircle(center, radius, basePaint);

    final sweepPaint = Paint()
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4
      ..strokeCap = StrokeCap.round
      ..shader = const SweepGradient(
        colors: [
          Color(0x00FFFFFF),
          Color(0xFFFF62DF),
          Color(0xFFB66DFF),
          Color(0x00FFFFFF),
        ],
        stops: [0, 0.42, 0.72, 1],
      ).createShader(rect);

    canvas.save();
    canvas.translate(center.dx, center.dy);
    canvas.rotate(progress * math.pi * 2);
    canvas.translate(-center.dx, -center.dy);
    canvas.drawArc(rect, -math.pi * 0.55, math.pi * 1.35, false, sweepPaint);
    canvas.restore();

    final dotPaint = Paint()..color = Colors.white.withValues(alpha: 0.72);
    for (var index = 0; index < 3; index++) {
      final phase = progress + index / 3;
      final angle = phase * math.pi * 2;
      final dotCenter = Offset(
        center.dx + math.cos(angle) * (radius - 5),
        center.dy + math.sin(angle) * (radius - 5),
      );
      canvas.drawCircle(dotCenter, 2.8 - index * 0.35, dotPaint);
    }
  }

  @override
  bool shouldRepaint(covariant _HandoffOrbitPainter oldDelegate) {
    return oldDelegate.progress != progress;
  }
}
