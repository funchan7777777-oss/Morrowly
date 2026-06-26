import 'package:flutter/material.dart';
import 'package:morrowly/app/theme/dawn_tonal_tokens.dart';

class SoftPanel extends StatelessWidget {
  const SoftPanel({
    super.key,
    required this.child,
    this.interiorPadding = const EdgeInsets.all(18),
    this.surfaceTint,
    this.strokeTone,
    this.cornerRadius = 24,
  });

  final Widget child;
  final EdgeInsetsGeometry interiorPadding;
  final Color? surfaceTint;
  final Color? strokeTone;
  final double cornerRadius;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: surfaceTint ?? DawnTonalTokens.paper,
        borderRadius: BorderRadius.circular(cornerRadius),
        border: Border.all(color: strokeTone ?? DawnTonalTokens.faintLine),
        boxShadow: const [
          BoxShadow(
            color: DawnTonalTokens.softShadow,
            blurRadius: 24,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Padding(padding: interiorPadding, child: child),
    );
  }
}
