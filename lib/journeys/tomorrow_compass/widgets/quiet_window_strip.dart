import 'package:flutter/material.dart';
import 'package:morrowly/app/theme/dawn_tonal_tokens.dart';
import 'package:morrowly/journeys/tomorrow_compass/models/quiet_focus_window.dart';
import 'package:morrowly/shared/formatting/minute_window_formatter.dart';
import 'package:morrowly/shared/widgets/signal_chip.dart';
import 'package:morrowly/shared/widgets/soft_panel.dart';

class QuietWindowStrip extends StatelessWidget {
  const QuietWindowStrip({super.key, required this.windows});

  final List<QuietFocusWindow> windows;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        for (final window in windows) ...[
          SoftPanel(
            interiorPadding: const EdgeInsets.all(16),
            surfaceTint: DawnTonalTokens.paper,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  children: [
                    Expanded(
                      child: Text(
                        window.doorwayLabel,
                        style: Theme.of(context).textTheme.titleMedium,
                      ),
                    ),
                    SignalChip(
                      glyph: Icons.schedule,
                      signalText: MinuteWindowFormatter.clockRange(
                        window.startsAtMinute,
                        window.closesAtMinute,
                      ),
                      accentTone: DawnTonalTokens.tide,
                    ),
                  ],
                ),
                const SizedBox(height: 12),
                Text(
                  window.attentionBoundary,
                  style: Theme.of(context).textTheme.bodyMedium,
                ),
                const SizedBox(height: 10),
                Text(
                  window.recoveryPermission,
                  style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: DawnTonalTokens.moss,
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                Text(
                  window.interruptionPolicy,
                  style: Theme.of(context).textTheme.labelMedium,
                ),
              ],
            ),
          ),
          if (window != windows.last) const SizedBox(height: 12),
        ],
      ],
    );
  }
}
