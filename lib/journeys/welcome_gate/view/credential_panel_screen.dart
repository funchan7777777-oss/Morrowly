import 'package:flutter/material.dart';
import 'package:morrowly/journeys/welcome_gate/models/account_access_draft.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/artwork_tap_target.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/auth_consent_trail.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/credential_mode_tabs.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/full_bleed_stage.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/gate_back_button.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/gate_notice_dialog.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/lit_action_pill.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/soft_entry_field.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/welcome_artwork.dart';

class CredentialPanelScreen extends StatefulWidget {
  const CredentialPanelScreen({
    super.key,
    required this.isSignupMode,
    required this.agreementAccepted,
    required this.onAgreementChanged,
    required this.onUserAgreement,
    required this.onPrivacyPolicy,
    required this.onAgreementMissing,
    required this.onBack,
    required this.onLoginMode,
    required this.onSignupMode,
    required this.onLoginSubmitted,
    required this.onSignupSubmitted,
  });

  final bool isSignupMode;
  final bool agreementAccepted;
  final ValueChanged<bool> onAgreementChanged;
  final VoidCallback onUserAgreement;
  final VoidCallback onPrivacyPolicy;
  final VoidCallback onAgreementMissing;
  final VoidCallback onBack;
  final VoidCallback onLoginMode;
  final VoidCallback onSignupMode;
  final ValueChanged<AccountAccessDraft> onLoginSubmitted;
  final ValueChanged<AccountAccessDraft> onSignupSubmitted;

  @override
  State<CredentialPanelScreen> createState() => _CredentialPanelScreenState();
}

class _CredentialPanelScreenState extends State<CredentialPanelScreen> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  @override
  void dispose() {
    _emailController.dispose();
    _passwordController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FullBleedStage(
      backgroundAsset: WelcomeArtwork.credential,
      resizeForKeyboard: true,
      child: Stack(
        children: [
          GateBackButton(onBack: widget.onBack),
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
                        isSignupMode: widget.isSignupMode,
                        onLoginSelected: widget.onLoginMode,
                        onSignupSelected: widget.onSignupMode,
                      ),
                      const SizedBox(height: 22),
                      SoftEntryField(
                        label: 'Email Address',
                        placeholder: 'Please enter...',
                        controller: _emailController,
                        trailingKind: FieldTrailingKind.clear,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 18),
                      SoftEntryField(
                        label: 'Password',
                        placeholder: 'Please enter...',
                        controller: _passwordController,
                        trailingKind: FieldTrailingKind.eye,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 34),
                      widget.isSignupMode
                          ? LitActionPill(
                              label: 'Sign up',
                              width: panelWidth * 0.94,
                              onPressed: _submitCredentials,
                            )
                          : ArtworkTapTarget(
                              assetName: WelcomeArtwork.loginButton,
                              width: panelWidth * 0.94,
                              semanticLabel: 'Log in',
                              onPressed: _submitCredentials,
                            ),
                      const SizedBox(height: 28),
                      AuthConsentTrail(
                        accepted: widget.agreementAccepted,
                        onChanged: widget.onAgreementChanged,
                        onUserAgreement: widget.onUserAgreement,
                        onPrivacyPolicy: widget.onPrivacyPolicy,
                      ),
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

  void _submitCredentials() {
    final draft = AccountAccessDraft(
      emailAddress: _emailController.text.trim(),
      passwordText: _passwordController.text,
    );

    if (!widget.agreementAccepted) {
      widget.onAgreementMissing();
      return;
    }

    if (draft.emailAddress.isEmpty || draft.passwordText.isEmpty) {
      _showMissingFieldsNotice();
      return;
    }

    if (!draft.emailAddress.contains('@') || !draft.emailAddress.contains('.')) {
      _showEmailNotice();
      return;
    }

    if (draft.passwordText.length < 6) {
      _showPasswordNotice();
      return;
    }

    if (widget.isSignupMode) {
      widget.onSignupSubmitted(draft);
    } else {
      widget.onLoginSubmitted(draft);
    }
  }

  void _showMissingFieldsNotice() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.48),
      builder: (_) => const GateNoticeDialog(
        title: 'A little more detail',
        message: 'Please enter both your email address and password to continue.',
      ),
    );
  }

  void _showEmailNotice() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.48),
      builder: (_) => const GateNoticeDialog(
        title: 'Check the email',
        message: 'Use a complete email address so Morrowly can find your local account.',
      ),
    );
  }

  void _showPasswordNotice() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.48),
      builder: (_) => const GateNoticeDialog(
        title: 'Password too short',
        message: 'Please use at least six characters before moving forward.',
      ),
    );
  }
}
