import 'package:flutter/material.dart';

class LitActionPill extends StatelessWidget {
  const LitActionPill({
    super.key,
    required this.label,
    required this.onPressed,
    this.width,
    this.height = 54,
  });

  final String label;
  final VoidCallback onPressed;
  final double? width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTap: onPressed,
      child: Container(
        width: width,
        height: height,
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(999),
          gradient: const LinearGradient(
            colors: [Color(0xFFC575FF), Color(0xFFAF63F6)],
          ),
          boxShadow: [
            BoxShadow(
              color: const Color(0xFFB76CFF).withValues(alpha: 0.34),
              blurRadius: 18,
              offset: const Offset(0, 8),
            ),
          ],
        ),
        alignment: Alignment.center,
        child: Text(
          label,
          style: const TextStyle(
            color: Colors.white,
            fontSize: 16,
            fontWeight: FontWeight.w900,
          ),
        ),
      ),
    );
  }
}
