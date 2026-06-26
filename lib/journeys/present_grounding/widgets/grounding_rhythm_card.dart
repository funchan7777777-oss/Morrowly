import 'package:flutter/material.dart';
import 'package:morrowly/app/theme/dawn_tonal_tokens.dart';
import 'package:morrowly/journeys/present_grounding/models/grounding_rhythm.dart';
import 'package:morrowly/shared/widgets/signal_chip.dart';
import 'package:morrowly/shared/widgets/soft_panel.dart';

class GroundingRhythmCard extends StatelessWidget {
  const GroundingRhythmCard({super.key, required this.rhythm});

  final GroundingRhythm rhythm;

  @override
  Widget build(BuildContext context) {
    final accentTone = _toneForMood(rhythm.colorMood);

    return SoftPanel(
      interiorPadding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Expanded(
                child: Text(
                  rhythm.displayName,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
              ),
              SignalChip(
                glyph: Icons.timer_outlined,
                signalText: '${rhythm.minutes} min',
                accentTone: accentTone,
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(
            rhythm.settlingPhrase,
            style: Theme.of(context).textTheme.bodyLarge,
          ),
          const SizedBox(height: 14),
          Text(
            rhythm.bodyCue,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: DawnTonalTokens.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          const SizedBox(height: 6),
          Text(
            rhythm.repeatPattern,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
        ],
      ),
    );
  }

  Color _toneForMood(String mood) {
    return switch (mood) {
      'clay' => DawnTonalTokens.clay,
      'moss' => DawnTonalTokens.moss,
      'blue' => DawnTonalTokens.blueRoom,
      _ => DawnTonalTokens.tide,
    };
  }
}
