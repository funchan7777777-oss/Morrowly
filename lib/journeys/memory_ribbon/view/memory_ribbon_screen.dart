import 'package:flutter/material.dart';
import 'package:morrowly/app/theme/dawn_tonal_tokens.dart';
import 'package:morrowly/fieldnotes/daybook_seed/local_morrowly_daybook.dart';
import 'package:morrowly/journeys/memory_ribbon/widgets/recent_turning_point_tile.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';
import 'package:morrowly/shared/microcopy/morrowly_copy.dart';
import 'package:morrowly/shared/widgets/section_title_row.dart';
import 'package:morrowly/shared/widgets/soft_panel.dart';

class MemoryRibbonScreen extends StatelessWidget {
  const MemoryRibbonScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final turningPoints = LocalMorrowlyDaybook.memoryRibbon;

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
                'Memory ribbon',
                style: Theme.of(context).textTheme.displaySmall,
              ),
              const SizedBox(height: 8),
              Text(
                MorrowlyCopy.ribbonTagline,
                style: Theme.of(context).textTheme.bodyLarge,
              ),
              const SizedBox(height: 22),
              SoftPanel(
                surfaceTint: DawnTonalTokens.paper,
                child: Row(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Icon(
                      Icons.bookmark_border,
                      color: DawnTonalTokens.clay,
                      size: 28,
                    ),
                    const SizedBox(width: 14),
                    Expanded(
                      child: Text(
                        'Not every note needs a folder. Some just need a clear reason to return tomorrow.',
                        style: Theme.of(context).textTheme.bodyLarge,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 26),
              SectionTitleRow(
                heading: 'Kept turning points',
                leadingGlyph: Icons.bookmark_border,
                trailingNote: '${turningPoints.length} notes',
              ),
              const SizedBox(height: 12),
              for (final point in turningPoints) ...[
                RecentTurningPointTile(turningPoint: point),
                if (point != turningPoints.last) const SizedBox(height: 12),
              ],
            ],
          ),
        );
      },
    );
  }
}
