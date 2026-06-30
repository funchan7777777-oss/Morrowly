import 'package:flutter/material.dart';
import 'package:morrowly/app/theme/dawn_tonal_tokens.dart';

abstract final class MorrowlyFontFamilies {
  static const body = 'MorrowlyNunito';
  static const display = 'MorrowlyQuicksand';
  static const accent = 'MorrowlyFredoka';
}

abstract final class MorrowlyTheme {
  static ThemeData light() {
    final scheme =
        ColorScheme.fromSeed(
          seedColor: DawnTonalTokens.tide,
          brightness: Brightness.light,
        ).copyWith(
          primary: DawnTonalTokens.tide,
          secondary: DawnTonalTokens.clay,
          tertiary: DawnTonalTokens.moss,
          surface: DawnTonalTokens.paper,
          surfaceContainerHighest: DawnTonalTokens.fog,
          outlineVariant: DawnTonalTokens.faintLine,
          onSurface: DawnTonalTokens.ink,
          onSurfaceVariant: DawnTonalTokens.graphite,
        );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      fontFamily: MorrowlyFontFamilies.body,
      fontFamilyFallback: const [
        MorrowlyFontFamilies.display,
        MorrowlyFontFamilies.accent,
      ],
      scaffoldBackgroundColor: DawnTonalTokens.fog,
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: DawnTonalTokens.paper,
        indicatorColor: DawnTonalTokens.tide.withValues(alpha: 0.14),
        labelTextStyle: WidgetStateProperty.resolveWith(
          (states) => TextStyle(
            color: states.contains(WidgetState.selected)
                ? DawnTonalTokens.tide
                : DawnTonalTokens.graphite,
            fontWeight: states.contains(WidgetState.selected)
                ? FontWeight.w700
                : FontWeight.w500,
            fontSize: 12,
            fontFamily: MorrowlyFontFamilies.display,
          ),
        ),
      ),
      textTheme: const TextTheme(
        displaySmall: TextStyle(
          fontFamily: MorrowlyFontFamilies.accent,
          fontSize: 34,
          height: 1.05,
          fontWeight: FontWeight.w800,
          color: DawnTonalTokens.ink,
        ),
        headlineSmall: TextStyle(
          fontFamily: MorrowlyFontFamilies.display,
          fontSize: 22,
          height: 1.18,
          fontWeight: FontWeight.w700,
          color: DawnTonalTokens.ink,
        ),
        titleMedium: TextStyle(
          fontFamily: MorrowlyFontFamilies.display,
          fontSize: 16,
          height: 1.3,
          fontWeight: FontWeight.w700,
          color: DawnTonalTokens.ink,
        ),
        bodyLarge: TextStyle(
          fontFamily: MorrowlyFontFamilies.body,
          fontSize: 16,
          height: 1.45,
          color: DawnTonalTokens.graphite,
        ),
        bodyMedium: TextStyle(
          fontFamily: MorrowlyFontFamilies.body,
          fontSize: 14,
          height: 1.42,
          color: DawnTonalTokens.graphite,
        ),
        labelMedium: TextStyle(
          fontFamily: MorrowlyFontFamilies.display,
          fontSize: 12,
          height: 1.2,
          fontWeight: FontWeight.w700,
          color: DawnTonalTokens.graphite,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: DawnTonalTokens.fog,
        foregroundColor: DawnTonalTokens.ink,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          fontFamily: MorrowlyFontFamilies.display,
          fontSize: 18,
          height: 1.2,
          fontWeight: FontWeight.w800,
          color: DawnTonalTokens.ink,
        ),
        toolbarTextStyle: TextStyle(
          fontFamily: MorrowlyFontFamilies.body,
          fontSize: 14,
          height: 1.25,
          fontWeight: FontWeight.w600,
          color: DawnTonalTokens.graphite,
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: DawnTonalTokens.tide,
          foregroundColor: DawnTonalTokens.paper,
          textStyle: const TextStyle(
            fontFamily: MorrowlyFontFamilies.display,
            fontWeight: FontWeight.w800,
          ),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
        ),
      ),
    );
  }
}
