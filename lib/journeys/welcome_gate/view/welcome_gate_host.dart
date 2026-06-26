import 'dart:async';

import 'package:flutter/material.dart';
import 'package:morrowly/app/navigation/morrowly_tab_shell.dart';
import 'package:morrowly/journeys/welcome_gate/models/welcome_gate_scene.dart';
import 'package:morrowly/journeys/welcome_gate/view/credential_panel_screen.dart';
import 'package:morrowly/journeys/welcome_gate/view/invitation_choice_screen.dart';
import 'package:morrowly/journeys/welcome_gate/view/profile_intake_screen.dart';
import 'package:morrowly/journeys/welcome_gate/view/splash_mark_screen.dart';

class WelcomeGateHost extends StatefulWidget {
  const WelcomeGateHost({super.key});

  @override
  State<WelcomeGateHost> createState() => _WelcomeGateHostState();
}

class _WelcomeGateHostState extends State<WelcomeGateHost> {
  WelcomeGateScene _scene = WelcomeGateScene.launchMoment;
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
        onApplePath: _openProfileIntake,
        onCredentialPath: _openLogin,
      ),
      WelcomeGateScene.signInLedger => CredentialPanelScreen(
        isSignupMode: false,
        onBack: _openInvitation,
        onLoginMode: _openLogin,
        onSignupMode: _openSignup,
        onLoginSubmitted: _openHome,
        onSignupNext: _openProfileIntake,
      ),
      WelcomeGateScene.newAccountLedger => CredentialPanelScreen(
        isSignupMode: true,
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
}
