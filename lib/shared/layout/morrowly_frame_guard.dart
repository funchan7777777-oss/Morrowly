import 'dart:math' as math;

import 'package:flutter/material.dart';

abstract final class MorrowlyFrameGuard {
  static double topClearance(
    BuildContext context, {
    double minimum = 64,
    double extra = 0,
  }) {
    final topInset = MediaQuery.viewPaddingOf(context).top;
    return math.max(minimum, topInset + extra);
  }

  static double topBarContentClearance(
    BuildContext context, {
    double topMinimum = 48,
    double topExtra = -6,
    double topBarHeight = 44,
    double gap = 22,
  }) {
    return topClearance(context, minimum: topMinimum, extra: topExtra) +
        topBarHeight +
        gap;
  }

  static double bottomClearance(
    BuildContext context, {
    double minimum = 28,
    double extra = 0,
  }) {
    final bottomInset = MediaQuery.viewPaddingOf(context).bottom;
    return math.max(minimum, bottomInset + extra);
  }

  static double contentWidth(
    double viewportWidth, {
    double maxWidth = 680,
    double phoneGutter = 20,
  }) {
    return math.min(maxWidth, math.max(0, viewportWidth - phoneGutter * 2));
  }

  static double sideGutter(
    double viewportWidth, {
    double maxWidth = 680,
    double phoneGutter = 20,
  }) {
    final width = contentWidth(
      viewportWidth,
      maxWidth: maxWidth,
      phoneGutter: phoneGutter,
    );
    return math.max(phoneGutter, (viewportWidth - width) / 2);
  }
}
