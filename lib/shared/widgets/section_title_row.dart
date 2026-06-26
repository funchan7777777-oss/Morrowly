import 'package:flutter/material.dart';
import 'package:morrowly/app/theme/dawn_tonal_tokens.dart';

class SectionTitleRow extends StatelessWidget {
  const SectionTitleRow({
    super.key,
    required this.heading,
    required this.leadingGlyph,
    this.trailingNote,
  });

  final String heading;
  final IconData leadingGlyph;
  final String? trailingNote;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(leadingGlyph, size: 18, color: DawnTonalTokens.tide),
        const SizedBox(width: 8),
        Expanded(
          child: Text(heading, style: Theme.of(context).textTheme.titleMedium),
        ),
        if (trailingNote != null)
          Text(
            trailingNote!,
            style: Theme.of(
              context,
            ).textTheme.labelMedium?.copyWith(color: DawnTonalTokens.graphite),
          ),
      ],
    );
  }
}
