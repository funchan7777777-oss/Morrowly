import 'package:flutter/material.dart';
import 'package:morrowly/journeys/time_capsule/data/capsule_square_seed.dart';
import 'package:morrowly/journeys/time_capsule/models/capsule_chronicle.dart';
import 'package:morrowly/journeys/time_capsule/view/capsule_editor_screen.dart';
import 'package:morrowly/journeys/time_capsule/view/my_capsules_screen.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_stage.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_widgets.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';

class CapsuleComposerScreen extends StatelessWidget {
  const CapsuleComposerScreen({super.key, required this.coinBalance});

  final int coinBalance;

  @override
  Widget build(BuildContext context) {
    return CapsuleStage(
      child: Stack(
        children: [
          CapsuleTopBar(
            title: '',
            onBack: () => Navigator.of(context).pop(),
            trailing: CapsuleAssetTap(
              assetName: CapsuleArtwork.myCapsulesSmall,
              width: 112,
              height: 40,
              semanticLabel: 'My capsules',
              onTap: () {
                Navigator.of(context).push<void>(
                  MaterialPageRoute(
                    builder: (_) => MyCapsulesScreen(
                      capsules: CapsuleSquareSeed.squareNotes()
                          .take(4)
                          .toList(),
                      coinBalance: coinBalance,
                    ),
                  ),
                );
              },
            ),
          ),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final contentWidth = MorrowlyFrameGuard.contentWidth(
                width,
                maxWidth: 430,
                phoneGutter: 24,
              );
              final side = (width - contentWidth) / 2;

              return SingleChildScrollView(
                padding: EdgeInsets.fromLTRB(
                  side,
                  MorrowlyFrameGuard.topClearance(
                    context,
                    minimum: 116,
                    extra: 48,
                  ),
                  side,
                  MorrowlyFrameGuard.bottomClearance(
                    context,
                    minimum: 34,
                    extra: 18,
                  ),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text.rich(
                      TextSpan(
                        text: 'Making ',
                        children: [
                          TextSpan(
                            text: 'time capsules',
                            style: TextStyle(color: Color(0xFFB876FF)),
                          ),
                        ],
                      ),
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 28,
                        height: 1.05,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 12),
                    Text(
                      'Write down what you want to say to your future self or someone, and one day in the future, open this surprise.',
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.82),
                        fontSize: 15,
                        height: 1.34,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 26),
                    Center(
                      child: Image.asset(
                        CapsuleArtwork.heroJar,
                        width: contentWidth * 0.82,
                        height: contentWidth * 0.66,
                        fit: BoxFit.contain,
                        filterQuality: FilterQuality.high,
                      ),
                    ),
                    const SizedBox(height: 28),
                    _CraftChoiceCard(
                      assetName: CapsuleArtwork.capsuleTypeLetter,
                      title: 'Picture Text Capsule',
                      subtitle: 'Write a letter to your future self or others.',
                      onTap: () =>
                          _openEditor(context, CapsuleCraftKind.pictureLetter),
                    ),
                    const SizedBox(height: 16),
                    _CraftChoiceCard(
                      assetName: CapsuleArtwork.capsuleTypeVideo,
                      title: 'Video capsule',
                      subtitle: 'Seal the movement and sound of this moment.',
                      onTap: () =>
                          _openEditor(context, CapsuleCraftKind.videoMemory),
                    ),
                    const SizedBox(height: 24),
                    Center(
                      child: Text(
                        'Tip: Once the capsule is sealed, its contents cannot be modified.',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.42),
                          fontSize: 11,
                          height: 1.32,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }

  Future<void> _openEditor(
    BuildContext context,
    CapsuleCraftKind craftKind,
  ) async {
    final result = await Navigator.of(context).push<CapsuleSquareNote>(
      MaterialPageRoute(
        builder: (_) =>
            CapsuleEditorScreen(craftKind: craftKind, coinBalance: coinBalance),
      ),
    );
    if (result != null && context.mounted) {
      Navigator.of(context).pop(result);
    }
  }
}

class _CraftChoiceCard extends StatelessWidget {
  const _CraftChoiceCard({
    required this.assetName,
    required this.title,
    required this.subtitle,
    required this.onTap,
  });

  final String assetName;
  final String title;
  final String subtitle;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(18),
        decoration: BoxDecoration(
          color: const Color(0xFF54405A).withValues(alpha: 0.9),
          borderRadius: BorderRadius.circular(20),
        ),
        child: Row(
          children: [
            Image.asset(
              assetName,
              width: 56,
              height: 56,
              filterQuality: FilterQuality.high,
            ),
            const SizedBox(width: 14),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 17,
                      fontWeight: FontWeight.w900,
                    ),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    subtitle,
                    style: TextStyle(
                      color: Colors.white.withValues(alpha: 0.42),
                      fontSize: 12,
                      height: 1.28,
                      fontWeight: FontWeight.w700,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
