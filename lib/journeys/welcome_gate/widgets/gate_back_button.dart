import 'package:flutter/material.dart';

class GateBackButton extends StatelessWidget {
  const GateBackButton({super.key, required this.onBack});

  final VoidCallback onBack;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: 54,
      left: 16,
      child: IconButton(
        onPressed: onBack,
        icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
        splashRadius: 22,
        tooltip: 'Back',
      ),
    );
  }
}
