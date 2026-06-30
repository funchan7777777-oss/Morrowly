import 'package:flutter/material.dart';
import 'package:morrowly/journeys/time_capsule/data/capsule_square_seed.dart';
import 'package:morrowly/journeys/time_capsule/models/capsule_chronicle.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_stage.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_widgets.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';

const _sealedArtworkNaturalHeightRatio = 764 / 780;
const _sealedArtworkVisibleHeightRatio = 0.72;
const _capsuleButtonHeightRatio = 108 / 568;

class CapsuleSuccessScreen extends StatelessWidget {
  const CapsuleSuccessScreen({super.key, required this.capsule});

  final PublicCapsuleSeal capsule;

  @override
  Widget build(BuildContext context) {
    final waitsForPublicReview =
        capsule.shelfScope == CapsuleShelfScope.publicSquare &&
        capsule.isLocalDraft;
    return CapsuleStage(
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final artworkWidth = MorrowlyFrameGuard.contentWidth(
                width,
                maxWidth: 430,
                phoneGutter: 0,
              );
              final artworkHeight =
                  artworkWidth * _sealedArtworkVisibleHeightRatio;
              final artworkNaturalHeight =
                  artworkWidth * _sealedArtworkNaturalHeightRatio;
              final contentWidth = MorrowlyFrameGuard.contentWidth(
                width,
                maxWidth: 430,
                phoneGutter: 24,
              );
              final side = (width - contentWidth) / 2;
              final buttonWidth = contentWidth * 0.84;
              final buttonHeight = buttonWidth * _capsuleButtonHeightRatio;
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  0,
                  MorrowlyFrameGuard.topBarContentClearance(context),
                  0,
                  MorrowlyFrameGuard.bottomClearance(
                    context,
                    minimum: 82,
                    extra: 48,
                  ),
                ),
                child: Column(
                  children: [
                    SizedBox(
                      width: artworkWidth,
                      height: artworkHeight,
                      child: ClipRect(
                        child: OverflowBox(
                          alignment: Alignment.topCenter,
                          minWidth: artworkWidth,
                          maxWidth: artworkWidth,
                          minHeight: artworkNaturalHeight,
                          maxHeight: artworkNaturalHeight,
                          child: Image.asset(
                            CapsuleArtwork.sealedPostcard,
                            width: artworkWidth,
                            height: artworkNaturalHeight,
                            fit: BoxFit.fill,
                            filterQuality: FilterQuality.high,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: 24),
                      child: Text(
                        waitsForPublicReview
                            ? 'The time capsule has been\nsealed for review.'
                            : 'The time capsule has been\nsuccessfully sealed!!',
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          color: Colors.white,
                          fontSize: 22,
                          height: 1.24,
                          fontWeight: FontWeight.w900,
                        ),
                      ),
                    ),
                    const SizedBox(height: 22),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: side),
                      child: Text(
                        waitsForPublicReview
                            ? 'It is saved in My Capsules. Public display waits for review before it can appear in the square.'
                            : 'It will automatically start at ${capsuleClockStamp(capsule.unlocksAt)} on ${capsuleDateStamp(capsule.unlocksAt)}',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.36),
                          fontSize: 13,
                          height: 1.3,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const SizedBox(height: 48),
                    Padding(
                      padding: EdgeInsets.symmetric(horizontal: side),
                      child: Text(
                        'You can check it in [ My Capsules ]',
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          color: Colors.white.withValues(alpha: 0.34),
                          fontSize: 13,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    ),
                    const Spacer(),
                    CapsuleAssetTap(
                      assetName: CapsuleArtwork.viewCapsules,
                      width: buttonWidth,
                      height: buttonHeight,
                      semanticLabel: 'View my capsules',
                      onTap: () => Navigator.of(context).pop(capsule),
                    ),
                    const SizedBox(height: 14),
                    CapsuleAssetTap(
                      assetName: CapsuleArtwork.backHome,
                      width: buttonWidth,
                      height: buttonHeight,
                      semanticLabel: 'Back to Home',
                      onTap: () => Navigator.of(context).pop(capsule),
                    ),
                  ],
                ),
              );
            },
          ),
          CapsuleTopBar(
            title: 'Sealed successfully',
            onBack: () => Navigator.of(context).pop(capsule),
          ),
        ],
      ),
    );
  }
}
