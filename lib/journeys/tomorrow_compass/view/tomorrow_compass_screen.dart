import 'package:flutter/material.dart';
import 'package:morrowly/app/theme/dawn_tonal_tokens.dart';
import 'package:morrowly/fieldnotes/daybook_seed/local_morrowly_daybook.dart';
import 'package:morrowly/journeys/tomorrow_compass/widgets/brief_header_panel.dart';
import 'package:morrowly/journeys/tomorrow_compass/widgets/intention_lane_card.dart';
import 'package:morrowly/journeys/tomorrow_compass/widgets/quiet_window_strip.dart';
import 'package:morrowly/journeys/tomorrow_compass/widgets/reflection_prompt_tile.dart';
import 'package:morrowly/shared/microcopy/morrowly_copy.dart';
import 'package:morrowly/shared/widgets/metric_pill.dart';
import 'package:morrowly/shared/widgets/section_title_row.dart';

class TomorrowCompassScreen extends StatelessWidget {
  const TomorrowCompassScreen({super.key});

  @override
  Widget build(BuildContext context) {
    const brief = LocalMorrowlyDaybook.activeBrief;

    return SingleChildScrollView(
      padding: const EdgeInsets.fromLTRB(20, 38, 20, 28),
      child: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 680),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                MorrowlyCopy.appName,
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                MorrowlyCopy.tomorrowTagline,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 22),
              Row(
                children: [
                  MetricPill(
                    metricLabel: 'Energy weather',
                    metricValue: brief.energyWeatherLabel,
                    accentTone: DawnTonalTokens.tide,
                  ),
                  const SizedBox(width: 10),
                  MetricPill(
                    metricLabel: 'Soft deadline',
                    metricValue: brief.softDeadlineHint,
                    accentTone: DawnTonalTokens.clay,
                  ),
                ],
              ),
              const SizedBox(height: 18),
              BriefHeaderPanel(brief: brief),
              const SizedBox(height: 26),
              SectionTitleRow(
                heading: 'Tomorrow commitments',
                leadingGlyph: Icons.flag_outlined,
                trailingNote: '${brief.intentions.length} lanes',
              ),
              const SizedBox(height: 12),
              for (final intention in brief.intentions) ...[
                IntentionLaneCard(intention: intention),
                if (intention != brief.intentions.last)
                  const SizedBox(height: 12),
              ],
              const SizedBox(height: 26),
              SectionTitleRow(
                heading: 'Quiet windows',
                leadingGlyph: Icons.do_not_disturb_on_outlined,
                trailingNote: '${brief.quietWindows.length} held',
              ),
              const SizedBox(height: 12),
              QuietWindowStrip(windows: brief.quietWindows),
              const SizedBox(height: 26),
              SectionTitleRow(
                heading: 'Evening questions',
                leadingGlyph: Icons.edit_note,
                trailingNote: 'handoff',
              ),
              const SizedBox(height: 12),
              for (final prompt in brief.reflectionPrompts) ...[
                ReflectionPromptTile(prompt: prompt),
                if (prompt != brief.reflectionPrompts.last)
                  const SizedBox(height: 12),
              ],
            ],
          ),
        ),
      ),
    );
  }
}
