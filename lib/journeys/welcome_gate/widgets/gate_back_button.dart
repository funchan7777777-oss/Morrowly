import 'package:flutter/material.dart';
import 'package:morrowly/shared/layout/morrowly_frame_guard.dart';

class GateBackButton extends StatelessWidget {
  const GateBackButton({
    super.key,
    required this.onBack,
    this.left = 16,
    this.minimumTop = 54,
    this.extraTop = 8,
  });

  final VoidCallback onBack;
  final double left;
  final double minimumTop;
  final double extraTop;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      top: MorrowlyFrameGuard.topClearance(
        context,
        minimum: minimumTop,
        extra: extraTop,
      ),
      left: left,
      child: IconButton(
        onPressed: onBack,
        icon: const Icon(Icons.chevron_left, color: Colors.white, size: 30),
        splashRadius: 22,
        tooltip: 'Back',
      ),
    );
  }
}
