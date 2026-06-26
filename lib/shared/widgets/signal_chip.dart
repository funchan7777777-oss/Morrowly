import 'package:flutter/material.dart';

class SignalChip extends StatelessWidget {
  const SignalChip({
    super.key,
    required this.glyph,
    required this.signalText,
    required this.accentTone,
  });

  final IconData glyph;
  final String signalText;
  final Color accentTone;

  @override
  Widget build(BuildContext context) {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: accentTone.withValues(alpha: 0.12),
        borderRadius: BorderRadius.circular(999),
      ),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
        child: Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(glyph, size: 15, color: accentTone),
            const SizedBox(width: 7),
            Flexible(
              child: Text(
                signalText,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: accentTone),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
