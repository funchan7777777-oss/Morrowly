import 'package:flutter/material.dart';
import 'package:morrowly/journeys/welcome_gate/models/account_access_draft.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/credential_mode_tabs.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/full_bleed_stage.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/gate_back_button.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/gate_notice_dialog.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/lit_action_pill.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/soft_entry_field.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/welcome_artwork.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';

class CredentialPanelScreen extends StatefulWidget {
  const CredentialPanelScreen({
    super.key,
    required this.isSignupMode,
    required this.agreementAccepted,
    required this.onAgreementMissing,
    required this.onBack,
    required this.onLoginMode,
    required this.onSignupMode,
    required this.onLoginSubmitted,
    required this.onSignupSubmitted,
  });

  final bool isSignupMode;
  final bool agreementAccepted;
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
          LayoutBuilder(
            builder: (context, constraints) {
              final width = constraints.maxWidth;
              final panelWidth = MorrowlyFrameGuard.contentWidth(
                width,
                maxWidth: 350,
                phoneGutter: 28,
              );
              final topGuard = MorrowlyFrameGuard.topClearance(
                context,
                minimum: 110,
                extra: 20,
              );
              final bottomGuard = MorrowlyFrameGuard.bottomClearance(
                context,
                minimum: 42,
                extra: 12,
              );

              return Align(
                alignment: Alignment.bottomCenter,
                child: SingleChildScrollView(
                  padding: EdgeInsets.fromLTRB(
                    (width - panelWidth) / 2,
                    topGuard,
                    (width - panelWidth) / 2,
                    bottomGuard,
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
                        placeholder: 'name@example.com',
                        controller: _emailController,
                        trailingKind: FieldTrailingKind.clear,
                        keyboardType: TextInputType.emailAddress,
                        textInputAction: TextInputAction.next,
                      ),
                      const SizedBox(height: 18),
                      SoftEntryField(
                        label: 'Password',
                        placeholder: 'Private key for your capsule',
                        controller: _passwordController,
                        trailingKind: FieldTrailingKind.eye,
                        textInputAction: TextInputAction.done,
                      ),
                      const SizedBox(height: 34),
                      LitActionPill(
                        label: widget.isSignupMode ? 'Sign up' : 'Start',
                        width: panelWidth * 0.94,
                        onPressed: _submitCredentials,
                      ),
                    ],
                  ),
                ),
              );
            },
          ),
          GateBackButton(onBack: widget.onBack),
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

    if (!draft.emailAddress.contains('@') ||
        !draft.emailAddress.contains('.')) {
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
        message:
            'Add the email and private key that will open your Morrowly shelf.',
      ),
    );
  }

  void _showEmailNotice() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.48),
      builder: (_) => const GateNoticeDialog(
        title: 'Check the email',
        message:
            'Use a complete email address so Morrowly can find your local account.',
      ),
    );
  }

  void _showPasswordNotice() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.48),
      builder: (_) => const GateNoticeDialog(
        title: 'Password too short',
        message: 'Use at least six characters for this private capsule key.',
      ),
    );
  }
}
