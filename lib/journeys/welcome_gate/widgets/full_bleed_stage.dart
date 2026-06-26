import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class FullBleedStage extends StatelessWidget {
  const FullBleedStage({
    super.key,
    required this.backgroundAsset,
    required this.child,
    this.resizeForKeyboard = false,
  });

  final String backgroundAsset;
  final Widget child;
  final bool resizeForKeyboard;

  @override
  Widget build(BuildContext context) {
    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle.light,
      child: Scaffold(
        resizeToAvoidBottomInset: resizeForKeyboard,
        extendBody: true,
        extendBodyBehindAppBar: true,
        backgroundColor: const Color(0xFF2A2224),
        body: Stack(
          fit: StackFit.expand,
          children: [
            Image.asset(
              backgroundAsset,
              fit: BoxFit.fill,
              filterQuality: FilterQuality.high,
            ),
            child,
          ],
        ),
      ),
    );
  }
}
