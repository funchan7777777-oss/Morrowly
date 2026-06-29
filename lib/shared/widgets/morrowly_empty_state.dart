import 'package:flutter/material.dart';

class MorrowlyEmptyState extends StatelessWidget {
  const MorrowlyEmptyState({super.key, this.width = 188, this.height = 214});

  final double width;
  final double height;

  @override
  Widget build(BuildContext context) {
    return Center(
      child: Image.asset(
        'assets/images/empty.png',
        width: width,
        height: height,
        fit: BoxFit.contain,
        filterQuality: FilterQuality.high,
      ),
    );
  }
}
