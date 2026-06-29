import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CapsuleStage extends StatelessWidget {
  const CapsuleStage({
    super.key,
    required this.child,
    this.resizeForKeyboard = false,
  });

  final Widget child;
  final bool resizeForKeyboard;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        resizeToAvoidBottomInset: resizeForKeyboard,
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFF2D2327),
        body: DecoratedBox(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
              colors: [Color(0xFF8542B3), Color(0xFF4F315B), Color(0xFF2C2426)],
              stops: [0, 0.52, 1],
            ),
          ),
          child: Stack(
            fit: StackFit.expand,
            children: [
              Positioned.fill(
                child: IgnorePointer(
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      gradient: RadialGradient(
                        center: const Alignment(0.18, -0.7),
                        radius: 0.9,
                        colors: [
                          Colors.white.withValues(alpha: 0.1),
                          Colors.transparent,
                        ],
                      ),
                    ),
                  ),
                ),
              ),
              child,
            ],
          ),
        ),
      ),
    );
  }
}
