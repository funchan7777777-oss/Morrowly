import 'package:flutter/material.dart';
import 'package:morrowly/app/theme/dawn_tonal_tokens.dart';
import 'package:morrowly/fieldnotes/daybook_seed/local_morrowly_daybook.dart';
import 'package:morrowly/journeys/present_grounding/widgets/grounding_rhythm_card.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';
import 'package:morrowly/shared/microcopy/morrowly_copy.dart';
import 'package:morrowly/shared/widgets/section_title_row.dart';
import 'package:morrowly/shared/widgets/soft_panel.dart';

class PresentGroundingScreen extends StatelessWidget {
  const PresentGroundingScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final rhythms = LocalMorrowlyDaybook.groundingRhythms;

    return LayoutBuilder(
      builder: (context, constraints) {
        final sideGutter = MorrowlyFrameGuard.sideGutter(
          constraints.maxWidth,
          maxWidth: 680,
        );
        return SingleChildScrollView(
          padding: EdgeInsets.fromLTRB(
            sideGutter,
            MorrowlyFrameGuard.topClearance(context, minimum: 64, extra: 14),
            sideGutter,
            MorrowlyFrameGuard.bottomClearance(context, minimum: 28, extra: 10),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Now space',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                MorrowlyCopy.nowTagline,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 22),
              SoftPanel(
                surfaceTint: DawnTonalTokens.paper,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.spa,
                      color: DawnTonalTokens.tide,
                      size: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Before planning more, lower the room noise.',
                            style: Theme.of(context).textTheme.titleMedium,
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Pick one tiny reset that ends clearly. Morrowly keeps this area separate from the tomorrow plan so it stays practical.',
                            style: Theme.of(context).textTheme.bodyMedium,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              SectionTitleRow(
                heading: 'Grounding rhythms',
                leadingGlyph: Icons.waves,
                trailingNote: '${rhythms.length} available',
              ),
              const SizedBox(height: 12),
              for (final rhythm in rhythms) ...[
                GroundingRhythmCard(rhythm: rhythm),
                if (rhythm != rhythms.last) const SizedBox(height: 12),
              ],
            ],
          ),
        );
      },
    );
  }
}
