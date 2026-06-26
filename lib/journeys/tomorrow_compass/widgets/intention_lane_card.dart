import 'package:flutter/material.dart';
import 'package:morrowly/app/theme/dawn_tonal_tokens.dart';
import 'package:morrowly/journeys/tomorrow_compass/models/focus_weight_band.dart';
import 'package:morrowly/journeys/tomorrow_compass/models/intention_pulse.dart';
import 'package:morrowly/journeys/tomorrow_compass/models/tomorrow_intention.dart';
import 'package:morrowly/shared/widgets/signal_chip.dart';
import 'package:morrowly/shared/widgets/soft_panel.dart';

class IntentionLaneCard extends StatelessWidget {
  const IntentionLaneCard({super.key, required this.intention});

  final TomorrowIntention intention;

  @override
  Widget build(BuildContext context) {
    final pulseTone = _pulseTone(intention.pulse);

    return SoftPanel(
      interiorPadding: const EdgeInsets.all(16),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          DecoratedBox(
            decoration: BoxDecoration(
              color: pulseTone.withValues(alpha: 0.13),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Icon(_weightGlyph(intention.weightBand), color: pulseTone),
            ),
          ),
          const SizedBox(width: 14),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  intention.narrativeLabel,
                  style: Theme.of(context).textTheme.titleMedium,
                ),
                const SizedBox(height: 6),
                Text(
                  intention.whyItMatters,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 14),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: [
                    SignalChip(
                      glyph: Icons.timelapse,
                      signalText: '${intention.focusMinutes} min',
                      accentTone: pulseTone,
                    ),
                    SignalChip(
                      glyph: Icons.layers_outlined,
                      signalText: intention.weightBand.label,
                      accentTone: DawnTonalTokens.blueRoom,
                    ),
                  ],
                ),
                const SizedBox(height: 14),
                _SmallPromiseLine(
                  label: 'Work surface',
                  line: intention.workSurface,
                ),
                const SizedBox(height: 8),
                _SmallPromiseLine(
                  label: 'First visible step',
                  line: intention.firstVisibleStep,
                ),
                const SizedBox(height: 8),
                _SmallPromiseLine(
                  label: 'Fallback landing',
                  line: intention.fallbackLanding,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Color _pulseTone(IntentionPulse pulse) {
    return switch (pulse) {
      IntentionPulse.mossThread => DawnTonalTokens.moss,
      IntentionPulse.clayMarker => DawnTonalTokens.clay,
      IntentionPulse.tideMarker => DawnTonalTokens.tide,
      IntentionPulse.blueRoom => DawnTonalTokens.blueRoom,
    };
  }

  IconData _weightGlyph(FocusWeightBand band) {
    return switch (band) {
      FocusWeightBand.lightTouch => Icons.touch_app,
      FocusWeightBand.steadyBlock => Icons.event_available,
      FocusWeightBand.deepHarbor => Icons.anchor,
    };
  }
}

class _SmallPromiseLine extends StatelessWidget {
  const _SmallPromiseLine({required this.label, required this.line});

  final String label;
  final String line;

  @override
  Widget build(BuildContext context) {
    return RichText(
      text: TextSpan(
        style: Theme.of(context).textTheme.bodyMedium,
        children: [
          TextSpan(
            text: '$label: ',
            style: const TextStyle(
              color: DawnTonalTokens.ink,
              fontWeight: FontWeight.w700,
            ),
          ),
          TextSpan(text: line),
        ],
      ),
    );
  }
}
