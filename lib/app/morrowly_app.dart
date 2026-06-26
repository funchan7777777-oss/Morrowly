import 'package:flutter/material.dart';
import 'package:morrowly/app/navigation/morrowly_tab_shell.dart';
import 'package:morrowly/app/theme/morrowly_theme.dart';

class MorrowlyApp extends StatelessWidget {
  const MorrowlyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Morrowly',
      theme: MorrowlyTheme.light(),
      home: const MorrowlyTabShell(),
    );
  }
}
