import 'package:flutter/material.dart';

class ArtworkTapTarget extends StatelessWidget {
  const ArtworkTapTarget({
    super.key,
    required this.assetName,
    required this.onPressed,
    this.width,
    this.height,
    this.semanticLabel,
  });

  final String assetName;
  final VoidCallback onPressed;
  final double? width;
  final double? height;
  final String? semanticLabel;

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      label: semanticLabel,
      child: GestureDetector(
        behavior: HitTestBehavior.opaque,
        onTap: onPressed,
        child: Image.asset(
          assetName,
          width: width,
          height: height,
          fit: BoxFit.contain,
          filterQuality: FilterQuality.high,
        ),
      ),
    );
  }
}
