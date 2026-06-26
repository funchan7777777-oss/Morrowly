import 'package:flutter/material.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/artwork_tap_target.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/auth_consent_trail.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/credential_mode_tabs.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/full_bleed_stage.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/gate_back_button.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/soft_entry_field.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/welcome_artwork.dart';

class CredentialPanelScreen extends StatelessWidget {
  const CredentialPanelScreen({
    super.key,
    required this.isSignupMode,
    required this.onBack,
    required this.onLoginMode,
    required this.onSignupMode,
    required this.onLoginSubmitted,
    required this.onSignupNext,
  });

  final bool isSignupMode;
  final VoidCallback onBack;
  final VoidCallback onLoginMode;
  final VoidCallback onSignupMode;
  final VoidCallback onLoginSubmitted;
  final VoidCallback onSignupNext;

  @override
  Widget build(BuildContext context) {
    return FullBleedStage(
      backgroundAsset: WelcomeArtwork.credential,
      resizeForKeyboard: true,
      child: Stack(
        children: [
          GateBackButton(onBack: onBack),
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final panelWidth = width.clamp(300.0, 420.0).toDouble() * 0.82;

              return Align(
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    (width - panelWidth) / 2,
                    330,
                    (width - panelWidth) / 2,
                    42,
                  ),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      CredentialModeTabs(
                        isSignupMode: isSignupMode,
                        onLoginSelected: onLoginMode,
                        onSignupSelected: onSignupMode,
                      ),
                      const SizedBox(height: 22),
                      const SoftEntryField(
                        label: 'Email Address',
                        placeholder: 'Please enter...',
                        trailingKind: FieldTrailingKind.clear,
                        keyboardType: TextInputType.emailAddress,
                      ),
                      const SizedBox(height: 18),
                      const SoftEntryField(
                        label: 'Password',
                        placeholder: 'Please enter...',
                        trailingKind: FieldTrailingKind.eye,
                      ),
                      const SizedBox(height: 34),
                      ArtworkTapTarget(
                        assetName: isSignupMode
                            ? WelcomeArtwork.nextButton
                            : WelcomeArtwork.loginButton,
                        width: panelWidth * 0.94,
                        semanticLabel: isSignupMode ? 'Next' : 'Log in',
                        onPressed: isSignupMode
                            ? onSignupNext
                            : onLoginSubmitted,
                      ),
                      const SizedBox(height: 28),
                      const AuthConsentTrail(),
                    ],
                  ),
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
