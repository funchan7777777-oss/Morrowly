import 'dart:math' as math;

import 'package:flutter/material.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/full_bleed_stage.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/welcome_artwork.dart';

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
    return FullBleedStage(
      backgroundAsset: WelcomeArtwork.credential,
      child: Center(
        child: SizedBox(
          width: 284,
          child: AnimatedBuilder(
            animation: _controller,
            builder: (context, _) {
              final drift = Curves.easeInOutSine.transform(
                math.sin(_controller.value * math.pi * 2) * 0.5 + 0.5,
              );

              return Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  SizedBox(
                    width: 164,
                    height: 164,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Transform.scale(
                          scale: 0.94 + drift * 0.08,
                          child: Container(
                            width: 132,
                            height: 132,
                            decoration: BoxDecoration(
                              shape: BoxShape.circle,
                              color: const Color(
                                0xFFB86DFF,
                              ).withValues(alpha: 0.14 + drift * 0.06),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFFFF55DC,
                                  ).withValues(alpha: 0.2 + drift * 0.12),
                                  blurRadius: 38,
                                  spreadRadius: 4,
                                ),
                              ],
                            ),
                          ),
                        ),
                        CustomPaint(
                          size: const Size(150, 150),
                          painter: _HandoffOrbitPainter(
                            progress: _controller.value,
                          ),
                        ),
                        Transform.translate(
                          offset: Offset(0, -4 + drift * 8),
                          child: Container(
                            width: 92,
                            height: 92,
                            padding: const EdgeInsets.all(12),
                            decoration: BoxDecoration(
                              color: Colors.white.withValues(alpha: 0.94),
                              borderRadius: BorderRadius.circular(28),
                              boxShadow: [
                                BoxShadow(
                                  color: const Color(
                                    0xFF1F1225,
                                  ).withValues(alpha: 0.22),
                                  blurRadius: 24,
                                  offset: const Offset(0, 12),
                                ),
                              ],
                            ),
                            child: Image.asset(
                              WelcomeArtwork.appMark,
                              fit: BoxFit.contain,
                              filterQuality: FilterQuality.high,
                            ),
                          ),
                        ),
                        Positioned(
                          right: 25,
                          bottom: 30,
                          child: _PulsePebble(progress: _controller.value),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 22),
                  const Text(
                    'Opening your room',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 22,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Carrying your saved profile into Morrowly.',
                    textAlign: TextAlign.center,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.58),
                      fontSize: 12,
                      height: 1.35,
                      fontWeight: FontWeight.w700,
                      letterSpacing: 0,
                    ),
                  ),
                  const SizedBox(height: 24),
                  _HandoffProgressRibbon(progress: _controller.value),
                ],
              );
            },
          ),
        ),
      ),
    );
  }
}

class _HandoffProgressRibbon extends StatelessWidget {
  const _HandoffProgressRibbon({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final widthFactor = 0.34 + Curves.easeInOutCubic.transform(progress) * 0.58;

    return Container(
      width: 188,
      height: 8,
      decoration: BoxDecoration(
        color: Colors.white.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      alignment: Alignment.centerLeft,
      clipBehavior: Clip.antiAlias,
      child: FractionallySizedBox(
        widthFactor: widthFactor,
        child: Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(999),
            gradient: const LinearGradient(
              colors: [Color(0xFFFF5EDD), Color(0xFFB56EFF)],
            ),
            boxShadow: [
              BoxShadow(
                color: const Color(0xFFFF5EDD).withValues(alpha: 0.35),
                blurRadius: 12,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _PulsePebble extends StatelessWidget {
  const _PulsePebble({required this.progress});

  final double progress;

  @override
  Widget build(BuildContext context) {
    final lift = math.sin(progress * math.pi * 2) * 2.5;

    return Transform.translate(
      offset: Offset(0, lift),
      child: Container(
        width: 34,
        height: 34,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: const Color(0xFFB86DFF),
          border: Border.all(color: Colors.white.withValues(alpha: 0.26)),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB86DFF).withValues(alpha: 0.36),
              blurRadius: 16,
              offset: const Offset(0, 6),
            ),
          ],
        ),
        child: const Icon(Icons.bolt_rounded, color: Colors.white, size: 17),
      ),
    );
  }
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
