import 'package:flutter/material.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/artwork_tap_target.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/welcome_artwork.dart';

class CredentialModeTabs extends StatelessWidget {
  const CredentialModeTabs({
    super.key,
    required this.isSignupMode,
    required this.onLoginSelected,
    required this.onSignupSelected,
  });

  final bool isSignupMode;
  final VoidCallback onLoginSelected;
  final VoidCallback onSignupSelected;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _ModeTab(
            label: 'Log in',
            inactiveAsset: WelcomeArtwork.inactiveLogin,
            active: !isSignupMode,
            onPressed: onLoginSelected,
          ),
        ),
        Expanded(
          child: _ModeTab(
            label: 'Sign up',
            inactiveAsset: WelcomeArtwork.inactiveSignup,
            active: isSignupMode,
            onPressed: onSignupSelected,
          ),
        ),
      ],
    );
  }
}

class _ModeTab extends StatelessWidget {
  const _ModeTab({
    required this.label,
    required this.inactiveAsset,
    required this.active,
    required this.onPressed,
  });

  final String label;
  final String inactiveAsset;
  final bool active;
  final VoidCallback onPressed;

  @override
  Widget build(BuildContext context) {
    if (!active) {
      return Center(
        child: ArtworkTapTarget(
          assetName: inactiveAsset,
          width: 102,
          height: 42,
          semanticLabel: label,
          onPressed: onPressed,
        ),
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Text(
            label,
            style: const TextStyle(
              color: Colors.white,
              fontSize: 17,
              fontWeight: FontWeight.w800,
              height: 1,
            ),
          ),
          const SizedBox(height: 3),
          Image.asset(
            WelcomeArtwork.activeUnderline,
            width: 88,
            height: 22,
            fit: BoxFit.fill,
            filterQuality: FilterQuality.high,
          ),
        ],
      ),
    );
  }
}
