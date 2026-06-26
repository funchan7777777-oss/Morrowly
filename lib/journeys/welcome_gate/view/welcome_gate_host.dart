import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morrowly/app/navigation/morrowly_tab_shell.dart';
import 'package:morrowly/journeys/welcome_gate/models/legal_document_marker.dart';
import 'package:morrowly/journeys/welcome_gate/models/welcome_gate_scene.dart';
import 'package:morrowly/journeys/welcome_gate/view/legal_document_viewer.dart';
import 'package:morrowly/journeys/welcome_gate/view/credential_panel_screen.dart';
import 'package:morrowly/journeys/welcome_gate/view/invitation_choice_screen.dart';
import 'package:morrowly/journeys/welcome_gate/view/profile_intake_screen.dart';
import 'package:morrowly/journeys/welcome_gate/view/splash_mark_screen.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/agreement_needed_dialog.dart';

class WelcomeGateHost extends StatefulWidget {
  const WelcomeGateHost({super.key});

  @override
  State<WelcomeGateHost> createState() => _WelcomeGateHostState();
}

class _WelcomeGateHostState extends State<WelcomeGateHost> {
  WelcomeGateScene _scene = WelcomeGateScene.launchMoment;
  bool _agreementAccepted = false;
  Timer? _handoffTimer;

  @override
  void initState() {
    super.initState();
    _handoffTimer = Timer(const Duration(milliseconds: 950), () {
      if (mounted) {
        setState(() => _scene = WelcomeGateScene.invitationDeck);
      }
    });
  }

  @override
  void dispose() {
    _handoffTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 260),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _buildScene(),
    );
  }

  Widget _buildScene() {
    return switch (_scene) {
      WelcomeGateScene.launchMoment => const SplashMarkScreen(),
      WelcomeGateScene.invitationDeck => InvitationChoiceScreen(
        agreementAccepted: _agreementAccepted,
        onAgreementChanged: _setAgreementAccepted,
        onUserAgreement: () =>
            _openLegalDocument(LegalDocumentMarker.userAgreement),
        onPrivacyPolicy: () =>
            _openLegalDocument(LegalDocumentMarker.privacyPolicy),
        onAgreementMissing: _showAgreementPrompt,
        onApplePath: _openProfileIntake,
        onCredentialPath: _openLogin,
      ),
      WelcomeGateScene.signInLedger => CredentialPanelScreen(
        isSignupMode: false,
        agreementAccepted: _agreementAccepted,
        onAgreementChanged: _setAgreementAccepted,
        onUserAgreement: () =>
            _openLegalDocument(LegalDocumentMarker.userAgreement),
        onPrivacyPolicy: () =>
            _openLegalDocument(LegalDocumentMarker.privacyPolicy),
        onAgreementMissing: _showAgreementPrompt,
        onBack: _openInvitation,
        onLoginMode: _openLogin,
        onSignupMode: _openSignup,
        onLoginSubmitted: _openHome,
        onSignupNext: _openProfileIntake,
      ),
      WelcomeGateScene.newAccountLedger => CredentialPanelScreen(
        isSignupMode: true,
        agreementAccepted: _agreementAccepted,
        onAgreementChanged: _setAgreementAccepted,
        onUserAgreement: () =>
            _openLegalDocument(LegalDocumentMarker.userAgreement),
        onPrivacyPolicy: () =>
            _openLegalDocument(LegalDocumentMarker.privacyPolicy),
        onAgreementMissing: _showAgreementPrompt,
        onBack: _openInvitation,
        onLoginMode: _openLogin,
        onSignupMode: _openSignup,
        onLoginSubmitted: _openHome,
        onSignupNext: _openProfileIntake,
      ),
      WelcomeGateScene.profileIntake => ProfileIntakeScreen(
        onBack: _openSignup,
        onStart: _openHome,
      ),
      WelcomeGateScene.daybookHome => const MorrowlyTabShell(),
    };
  }

  void _openInvitation() {
    setState(() => _scene = WelcomeGateScene.invitationDeck);
  }

  void _openLogin() {
    setState(() => _scene = WelcomeGateScene.signInLedger);
  }

  void _openSignup() {
    setState(() => _scene = WelcomeGateScene.newAccountLedger);
  }

  void _openProfileIntake() {
    setState(() => _scene = WelcomeGateScene.profileIntake);
  }

  void _openHome() {
    setState(() => _scene = WelcomeGateScene.daybookHome);
  }

  void _setAgreementAccepted(bool accepted) {
    setState(() => _agreementAccepted = accepted);
  }

  void _openLegalDocument(LegalDocumentMarker document) {
    Navigator.of(context).push(
      MaterialPageRoute<void>(
        builder: (_) => LegalDocumentViewer(document: document),
      ),
    );
  }

  void _showAgreementPrompt() {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.48),
      builder: (_) => const AgreementNeededDialog(),
    );
  }
}
