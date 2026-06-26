import 'package:flutter/material.dart';
import 'package:morrowly/app/theme/dawn_tonal_tokens.dart';
import 'package:morrowly/journeys/memory_ribbon/models/recent_turning_point.dart';
import 'package:morrowly/shared/widgets/signal_chip.dart';
import 'package:morrowly/shared/widgets/soft_panel.dart';

class RecentTurningPointTile extends StatelessWidget {
  const RecentTurningPointTile({super.key, required this.turningPoint});

  final RecentTurningPoint turningPoint;

  @override
  Widget build(BuildContext context) {
    return SoftPanel(
      interiorPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SignalChip(
            glyph: Icons.history,
            signalText: turningPoint.recordedLabel,
            accentTone: _toneForSentiment(turningPoint.sentimentMarker),
          ),
          const SizedBox(height: 14),
          Text(
            turningPoint.shortScene,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            turningPoint.keptBecause,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          DecoratedBox(
            decoration: BoxDecoration(
              color: DawnTonalTokens.fog,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: DawnTonalTokens.faintLine),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.arrow_forward,
                    size: 18,
                    color: DawnTonalTokens.tide,
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      turningPoint.tomorrowUse,
                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                        color: DawnTonalTokens.ink,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Color _toneForSentiment(String marker) {
    return switch (marker) {
      'steady' => DawnTonalTokens.tide,
      'useful' => DawnTonalTokens.moss,
      'bright' => DawnTonalTokens.clay,
      _ => DawnTonalTokens.blueRoom,
    };
  }
}
