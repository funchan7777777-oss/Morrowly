import 'package:flutter/material.dart';
import 'package:morrowly/app/theme/dawn_tonal_tokens.dart';
import 'package:morrowly/journeys/tomorrow_compass/models/evening_reflection_prompt.dart';
import 'package:morrowly/shared/widgets/signal_chip.dart';
import 'package:morrowly/shared/widgets/soft_panel.dart';

class ReflectionPromptTile extends StatelessWidget {
  const ReflectionPromptTile({super.key, required this.prompt});

  final EveningReflectionPrompt prompt;

  @override
  Widget build(BuildContext context) {
    return SoftPanel(
      interiorPadding: const EdgeInsets.all(16),
      surfaceTint: DawnTonalTokens.paper,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SignalChip(
            glyph: Icons.edit,
            signalText: prompt.belongsToMoment,
            accentTone: DawnTonalTokens.clay,
          ),
          const SizedBox(height: 14),
          Text(
            prompt.questionLine,
            style: Theme.of(context).textTheme.titleMedium,
          ),
          const SizedBox(height: 8),
          Text(
            prompt.softerFollowUp,
            style: Theme.of(context).textTheme.bodyMedium,
          ),
          const SizedBox(height: 14),
          Text(
            prompt.answerLeadIn,
            style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              color: DawnTonalTokens.tide,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}
