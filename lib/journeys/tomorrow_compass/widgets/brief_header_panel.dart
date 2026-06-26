import 'package:flutter/material.dart';
import 'package:morrowly/app/theme/dawn_tonal_tokens.dart';
import 'package:morrowly/journeys/tomorrow_compass/models/morrowly_day_brief.dart';
import 'package:morrowly/shared/widgets/signal_chip.dart';
import 'package:morrowly/shared/widgets/soft_panel.dart';

class BriefHeaderPanel extends StatelessWidget {
  const BriefHeaderPanel({super.key, required this.brief});

  final MorrowlyDayBrief brief;

  @override
  Widget build(BuildContext context) {
    return SoftPanel(
      surfaceTint: DawnTonalTokens.paper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Wrap(
            spacing: 8,
            runSpacing: 8,
            children: [
              SignalChip(
                glyph: Icons.nightlight_round,
                signalText: brief.calendarFaceLabel,
                accentTone: DawnTonalTokens.tide,
              ),
              SignalChip(
                glyph: Icons.bolt,
                signalText: brief.energyWeatherLabel,
                accentTone: DawnTonalTokens.clay,
              ),
            ],
          ),
          const SizedBox(height: 18),
          Text(
            brief.openingNudge,
            style: Theme.of(context).textTheme.headlineSmall,
          ),
          const SizedBox(height: 10),
          Text(brief.dayToneLine, style: Theme.of(context).textTheme.bodyLarge),
          const SizedBox(height: 18),
          DecoratedBox(
            decoration: BoxDecoration(
              color: DawnTonalTokens.fog,
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: DawnTonalTokens.faintLine),
            ),
            child: Padding(
              padding: const EdgeInsets.all(14),
              child: Row(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const Icon(
                    Icons.label_outline,
                    color: DawnTonalTokens.moss,
                    size: 20,
                  ),
                  const SizedBox(width: 10),
                  Expanded(
                    child: Text(
                      brief.carryForwardThread,
                      style: Theme.of(context).textTheme.bodyMedium,
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
}
