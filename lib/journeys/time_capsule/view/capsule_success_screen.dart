import 'package:flutter/material.dart';
import 'package:morrowly/journeys/time_capsule/data/capsule_square_seed.dart';
import 'package:morrowly/journeys/time_capsule/models/capsule_chronicle.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_stage.dart';
import 'package:morrowly/journeys/time_capsule/widgets/capsule_widgets.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';

class CapsuleSuccessScreen extends StatelessWidget {
  const CapsuleSuccessScreen({super.key, required this.capsule});

  final CapsuleSquareNote capsule;

  @override
  Widget build(BuildContext context) {
    return CapsuleStage(
      child: Stack(
        children: [
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final contentWidth = MorrowlyFrameGuard.contentWidth(
                width,
                maxWidth: 430,
                phoneGutter: 24,
              );
              final side = (width - contentWidth) / 2;
              return Padding(
                padding: EdgeInsets.fromLTRB(
                  side,
                  MorrowlyFrameGuard.topClearance(
                    context,
                    minimum: 112,
                    extra: 46,
                  ),
                  side,
                  MorrowlyFrameGuard.bottomClearance(
                    context,
                    minimum: 30,
                    extra: 18,
                  ),
                ),
                child: Column(
                  children: [
                    Image.asset(
                      CapsuleArtwork.sealedPostcard,
                      width: contentWidth * 0.78,
                      height: contentWidth * 0.68,
                      fit: BoxFit.contain,
                      filterQuality: FilterQuality.high,
                    ),
                    const SizedBox(height: 22),
                    const Text(
                      'The time capsule has been\nsuccessfully sealed!!',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 22,
                        height: 1.24,
                        fontWeight: FontWeight.w900,
                      ),
                    ),
                    const SizedBox(height: 22),
                    Text(
                      'It will automatically start at ${capsuleClockStamp(capsule.openingAt)} on ${capsuleDateStamp(capsule.openingAt)}',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.36),
                        fontSize: 13,
                        height: 1.3,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const SizedBox(height: 44),
                    Text(
                      'You can check it in [ My Capsules ]',
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        color: Colors.white.withValues(alpha: 0.34),
                        fontSize: 13,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                    const Spacer(),
                    CapsuleAssetTap(
                      assetName: CapsuleArtwork.viewCapsules,
                      width: contentWidth * 0.76,
                      height: 46,
                      semanticLabel: 'View my capsules',
                      onTap: () => Navigator.of(context).pop(capsule),
                    ),
                    const SizedBox(height: 14),
                    CapsuleAssetTap(
                      assetName: CapsuleArtwork.backHome,
                      width: contentWidth * 0.84,
                      height: 50,
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
