import 'package:flutter/material.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/full_bleed_stage.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/welcome_artwork.dart';

class SplashMarkScreen extends StatelessWidget {
  const SplashMarkScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return const FullBleedStage(
      backgroundAsset: WelcomeArtwork.splash,
      child: SizedBox.expand(),
    );
  }
}
