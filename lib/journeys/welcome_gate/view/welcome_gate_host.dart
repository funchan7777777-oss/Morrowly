import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morrowly/app/navigation/morrowly_tab_shell.dart';
import 'package:morrowly/journeys/welcome_gate/data/local_gate_store.dart';
import 'package:morrowly/journeys/welcome_gate/models/account_access_draft.dart';
import 'package:morrowly/journeys/welcome_gate/models/credential_gate_seed.dart';
import 'package:morrowly/journeys/welcome_gate/models/legal_document_marker.dart';
import 'package:morrowly/journeys/welcome_gate/models/profile_intake_draft.dart';
import 'package:morrowly/journeys/welcome_gate/models/welcome_gate_scene.dart';
import 'package:morrowly/journeys/welcome_gate/view/credential_handoff_loading_screen.dart';
import 'package:morrowly/journeys/welcome_gate/view/credential_panel_screen.dart';
import 'package:morrowly/journeys/welcome_gate/view/invitation_choice_screen.dart';
import 'package:morrowly/journeys/welcome_gate/view/legal_document_viewer.dart';
import 'package:morrowly/journeys/welcome_gate/view/profile_intake_screen.dart';
import 'package:morrowly/journeys/welcome_gate/view/startup_loading_screen.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/agreement_needed_dialog.dart';
import 'package:morrowly/journeys/welcome_gate/widgets/gate_notice_dialog.dart';
import 'package:morrowly/shared/moderation/morrowly_content_safety.dart';
import 'package:sign_in_with_apple/sign_in_with_apple.dart';

class WelcomeGateHost extends StatefulWidget {
  const WelcomeGateHost({super.key});

  @override
  State<WelcomeGateHost> createState() => _WelcomeGateHostState();
}

class _WelcomeGateHostState extends State<WelcomeGateHost> {
  WelcomeGateScene _scene = WelcomeGateScene.launchMoment;
  LocalGateStore? _gateStore;
  PendingCredentialSeed _pendingSeed = const PendingCredentialSeed(
    intent: CredentialGateIntent.localRegistration,
  );
  bool _agreementAccepted = false;

  @override
  void initState() {
    super.initState();
    _prepareLaunchRoute();
  }

  @override
  Widget build(BuildContext context) {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      switchInCurve: Curves.easeOutCubic,
      switchOutCurve: Curves.easeInCubic,
      child: _buildScene(),
    );
  }

  Widget _buildScene() {
    return switch (_scene) {
      WelcomeGateScene.launchMoment => const StartupLoadingScreen(),
      WelcomeGateScene.invitationDeck => InvitationChoiceScreen(
        agreementAccepted: _agreementAccepted,
        onAgreementChanged: _setAgreementAccepted,
        onUserAgreement: () =>
            _openLegalDocument(LegalDocumentMarker.userAgreement),
        onPrivacyPolicy: () =>
            _openLegalDocument(LegalDocumentMarker.privacyPolicy),
        onAgreementMissing: _showAgreementPrompt,
        onApplePath: _beginAppleSignIn,
        onCredentialPath: _openLogin,
      ),
      WelcomeGateScene.signInLedger => CredentialPanelScreen(
        isSignupMode: false,
        agreementAccepted: _agreementAccepted,
        onAgreementMissing: _showAgreementPrompt,
        onBack: _openInvitation,
        onLoginMode: _openLogin,
        onSignupMode: _openSignup,
        onLoginSubmitted: _handleLocalLogin,
        onSignupSubmitted: _beginLocalRegistration,
      ),
      WelcomeGateScene.newAccountLedger => CredentialPanelScreen(
        isSignupMode: true,
        agreementAccepted: _agreementAccepted,
        onAgreementMissing: _showAgreementPrompt,
        onBack: _openInvitation,
        onLoginMode: _openLogin,
        onSignupMode: _openSignup,
        onLoginSubmitted: _handleLocalLogin,
        onSignupSubmitted: _beginLocalRegistration,
      ),
      WelcomeGateScene.profileIntake => ProfileIntakeScreen(
        seed: _pendingSeed,
        onBack: _pendingSeed.isApple ? _openInvitation : _openSignup,
        onProfileSubmitted: _completeProfile,
      ),
      WelcomeGateScene.credentialHandoff =>
        const CredentialHandoffLoadingScreen(),
      WelcomeGateScene.daybookHome => MorrowlyTabShell(
        onSignedOut: _openInvitation,
        onLoggedOut: _openLogin,
        onAccountDeleted: _openInvitation,
      ),
    };
  }

  Future<void> _prepareLaunchRoute() async {
    final storeFuture = LocalGateStore.open();
    await Future<void>.delayed(const Duration(milliseconds: 1450));
    final store = await storeFuture;

    if (!mounted) {
      return;
    }

    _gateStore = store;
    setState(() {
      _agreementAccepted = store.hasAcceptedLegalAgreement;
      _scene = store.hasActiveSession
          ? WelcomeGateScene.daybookHome
          : WelcomeGateScene.invitationDeck;
    });
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

  Future<void> _beginAppleSignIn() async {
    if (!_agreementAccepted) {
      _showAgreementPrompt();
      return;
    }

    try {
      final available = await SignInWithApple.isAvailable();
      if (!available) {
        _showNotice(
          title: 'Apple sign in unavailable',
          message:
              'Sign in with Apple is not available on this device right now. Use email sign in or try again later.',
          icon: Icons.apple,
        );
        return;
      }

      final credential = await SignInWithApple.getAppleIDCredential(
        scopes: [
          AppleIDAuthorizationScopes.email,
          AppleIDAuthorizationScopes.fullName,
        ],
      );

      final seededName = _appleKeeperName(credential);
      _pendingSeed = PendingCredentialSeed(
        intent: CredentialGateIntent.appleProfile,
        appleUserIdentifier: credential.userIdentifier ?? '',
        emailAddress: credential.email ?? '',
        profileName: seededName,
      );

      if (!mounted) {
        return;
      }
      await _completeAppleSignIn();
    } on SignInWithAppleAuthorizationException catch (error) {
      if (error.code == AuthorizationErrorCode.canceled) {
        return;
      }
      _showNotice(
        title: 'Apple sign in paused',
        message:
            'Apple did not complete the sign in. Try again or use email sign in.',
        icon: Icons.apple,
      );
    } catch (_) {
      _showNotice(
        title: 'Apple sign in paused',
        message:
            'Morrowly could not complete Apple sign in. Check your Apple account and try again.',
        icon: Icons.apple,
      );
    }
  }

  Future<void> _handleLocalLogin(AccountAccessDraft draft) async {
    final store = await _ensureStore();
    await store.acceptLocalLogin(
      emailAddress: draft.emailAddress,
      passwordText: draft.passwordText,
    );

    if (!mounted) {
      return;
    }

    _showCredentialHandoffThenHome();
  }

  void _beginLocalRegistration(AccountAccessDraft draft) {
    _pendingSeed = PendingCredentialSeed(
      intent: CredentialGateIntent.localRegistration,
      emailAddress: draft.emailAddress,
      passwordText: draft.passwordText,
    );
    setState(() => _scene = WelcomeGateScene.profileIntake);
  }

  Future<void> _completeProfile(ProfileIntakeDraft profile) async {
    final store = await _ensureStore();
    try {
      await store.completeProfile(seed: _pendingSeed, profile: profile);
    } on MorrowlyContentSafetyException catch (issue) {
      _showNotice(
        title: issue.title,
        message: issue.message,
        icon: Icons.verified_user_outlined,
      );
      return;
    }

    if (!mounted) {
      return;
    }

    setState(() => _scene = WelcomeGateScene.daybookHome);
  }

  Future<void> _completeAppleSignIn() async {
    final seededName = _pendingSeed.profileName.trim().isEmpty
        ? 'New Timekeeper'
        : _pendingSeed.profileName.trim();
    await _completeProfile(
      ProfileIntakeDraft(keeperName: seededName, chosenHandle: seededName),
    );
  }

  Future<LocalGateStore> _ensureStore() async {
    final existingStore = _gateStore;
    if (existingStore != null) {
      return existingStore;
    }
    final openedStore = await LocalGateStore.open();
    _gateStore = openedStore;
    return openedStore;
  }

  void _showCredentialHandoffThenHome() {
    setState(() => _scene = WelcomeGateScene.credentialHandoff);
    Future<void>.delayed(const Duration(milliseconds: 3600), () {
      if (mounted) {
        setState(() => _scene = WelcomeGateScene.daybookHome);
      }
    });
  }

  String _appleKeeperName(AuthorizationCredentialAppleID credential) {
    final givenName = credential.givenName?.trim() ?? '';
    final familyName = credential.familyName?.trim() ?? '';
    final fullName = [
      givenName,
      familyName,
    ].where((part) => part.isNotEmpty).join(' ').trim();
    if (fullName.isNotEmpty) {
      return fullName;
    }

    final email = credential.email?.trim() ?? '';
    if (email.contains('@')) {
      return email.split('@').first;
    }

    final savedName = _gateStore?.savedKeeperName ?? '';
    if (savedName.isNotEmpty) {
      return savedName;
    }

    return 'New Timekeeper';
  }

  void _setAgreementAccepted(bool accepted) {
    setState(() => _agreementAccepted = accepted);
    unawaited(_persistAgreementAccepted(accepted));
  }

  Future<void> _persistAgreementAccepted(bool accepted) async {
    final store = await _ensureStore();
    await store.setLegalAgreementAccepted(accepted);
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

  void _showNotice({
    required String title,
    required String message,
    required IconData icon,
  }) {
    showDialog<void>(
      context: context,
      barrierColor: Colors.black.withValues(alpha: 0.48),
      builder: (_) =>
          GateNoticeDialog(title: title, message: message, icon: icon),
    );
  }
}
