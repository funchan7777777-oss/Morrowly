import 'package:flutter/material.dart';
import 'package:morrowly/app/theme/dawn_tonal_tokens.dart';

class MetricPill extends StatelessWidget {
  const MetricPill({
    super.key,
    required this.metricLabel,
    required this.metricValue,
    required this.accentTone,
  });

  final String metricLabel;
  final String metricValue;
  final Color accentTone;

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: DecoratedBox(
        decoration: BoxDecoration(
          color: DawnTonalTokens.paper,
          borderRadius: BorderRadius.circular(18),
          border: Border.all(color: DawnTonalTokens.faintLine),
        ),
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 13),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                metricLabel,
                maxLines: 1,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.labelMedium?.copyWith(color: accentTone),
              ),
              const SizedBox(height: 6),
              Text(
                metricValue,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(
                  context,
                ).textTheme.titleMedium?.copyWith(fontSize: 14),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
