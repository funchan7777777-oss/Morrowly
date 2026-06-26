import 'package:flutter/material.dart';
import 'package:morrowly/app/theme/morrowly_theme.dart';
import 'package:morrowly/journeys/welcome_gate/view/welcome_gate_host.dart';

class MorrowlyApp extends StatelessWidget {
  const MorrowlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Morrowly',
      theme: MorrowlyTheme.light(),
      home: const WelcomeGateHost(),
    );
  }
}
