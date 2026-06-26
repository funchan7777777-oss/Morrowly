import 'package:flutter/material.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/artwork_tap_target.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/auth_consent_trail.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/full_bleed_stage.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/lit_action_pill.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/welcome_artwork.dart';

class InvitationChoiceScreen extends StatelessWidget {
  const InvitationChoiceScreen({
    super.key,
    required this.agreementAccepted,
    required this.onAgreementChanged,
    required this.onUserAgreement,
    required this.onPrivacyPolicy,
    required this.onAgreementMissing,
    required this.onApplePath,
    required this.onCredentialPath,
  });

  final bool agreementAccepted;
  final ValueChanged<bool> onAgreementChanged;
  final VoidCallback onUserAgreement;
  final VoidCallback onPrivacyPolicy;
  final VoidCallback onAgreementMissing;
  final VoidCallback onApplePath;
  final VoidCallback onCredentialPath;

  @override
  Widget build(BuildContext context) {
    return FullBleedStage(
      backgroundAsset: WelcomeArtwork.invitation,
      child: LayoutBuilder(
        builder: (context, constraints) {
          final width = constraints.maxWidth;
          final buttonWidth = width.clamp(300.0, 390.0).toDouble() * 0.78;

          return Padding(
            padding: EdgeInsets.fromLTRB(width * 0.08, 0, width * 0.08, 44),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                ArtworkTapTarget(
                  assetName: WelcomeArtwork.appleButton,
                  width: buttonWidth,
                  semanticLabel: 'Sign in with Apple',
                  onPressed: () {
                    if (agreementAccepted) {
                      onApplePath();
                    } else {
                      onAgreementMissing();
                    }
                  },
                ),
                const SizedBox(height: 18),
                LitActionPill(
                  label: 'Log in',
                  width: buttonWidth,
                  onPressed: onCredentialPath,
                ),
                const SizedBox(height: 34),
                AuthConsentTrail(
                  accepted: agreementAccepted,
                  onChanged: onAgreementChanged,
                  onUserAgreement: onUserAgreement,
                  onPrivacyPolicy: onPrivacyPolicy,
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
