import 'package:flutter/material.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/artwork_tap_target.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/auth_consent_trail.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/full_bleed_stage.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/lit_action_pill.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/welcome_artwork.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';

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
          final contentWidth = MorrowlyFrameGuard.contentWidth(
            width,
            maxWidth: 360,
            phoneGutter: 28,
          );
          final buttonWidth = contentWidth * 0.86;
          final bottomPadding = MorrowlyFrameGuard.bottomClearance(
            context,
            minimum: 44,
            extra: 14,
          );

          return Align(
            alignment: Alignment.bottomCenter,
            child: SizedBox(
              width: contentWidth,
              child: Padding(
                padding: EdgeInsets.only(bottom: bottomPadding),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
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
                      onPressed: () {
                        if (agreementAccepted) {
                          onCredentialPath();
                        } else {
                          onAgreementMissing();
                        }
                      },
                    ),
                    if (!agreementAccepted) ...[
                      const SizedBox(height: 30),
                      AuthConsentTrail(
                        accepted: agreementAccepted,
                        onChanged: onAgreementChanged,
                        onUserAgreement: onUserAgreement,
                        onPrivacyPolicy: onPrivacyPolicy,
                      ),
                    ],
                  ],
                ),
              ),
            ),
          );
        },
      ),
    );
  }
}
