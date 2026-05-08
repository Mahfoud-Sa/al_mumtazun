import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

import 'app_colors.dart';

class AppTheme {
  static ThemeData light() {
    return _build(
      brightness: Brightness.light,
      primary: AppColors.primary,
      onPrimary: Colors.white,
      secondary: AppColors.secondary,
      onSecondary: Colors.white,
      error: AppColors.error,
      onError: AppColors.onError,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      onSurfaceVariant: AppColors.onSurfaceVariant,
      outline: AppColors.outline,
      outlineVariant: AppColors.outlineVariant,
      background: AppColors.background,
      surfaceContainerLow: AppColors.surfaceContainerLow,
      card: Colors.white,
    );
  }

  static ThemeData dark() {
    return _build(
      brightness: Brightness.dark,
      primary: const Color(0xFFE7EEF7),
      onPrimary: const Color(0xFF061A2D),
      secondary: const Color(0xFFFFC46B),
      onSecondary: const Color(0xFF402900),
      error: const Color(0xFFFFB4AB),
      onError: const Color(0xFF690005),
      surface: const Color(0xFF111820),
      onSurface: const Color(0xFFE2E8F0),
      onSurfaceVariant: const Color(0xFFB8C2CC),
      outline: const Color(0xFF8D99A6),
      outlineVariant: const Color(0xFF334050),
      background: const Color(0xFF0B1118),
      surfaceContainerLow: const Color(0xFF17212B),
      card: const Color(0xFF141D26),
    );
  }

  static ThemeData _build({
    required Brightness brightness,
    required Color primary,
    required Color onPrimary,
    required Color secondary,
    required Color onSecondary,
    required Color error,
    required Color onError,
    required Color surface,
    required Color onSurface,
    required Color onSurfaceVariant,
    required Color outline,
    required Color outlineVariant,
    required Color background,
    required Color surfaceContainerLow,
    required Color card,
  }) {
    final base = ThemeData(
      useMaterial3: true,
      colorScheme: ColorScheme(
        brightness: brightness,
        primary: primary,
        onPrimary: onPrimary,
        secondary: secondary,
        onSecondary: onSecondary,
        error: error,
        onError: onError,
        surface: surface,
        onSurface: onSurface,
        onSurfaceVariant: onSurfaceVariant,
        outline: outline,
        outlineVariant: outlineVariant,
        surfaceContainerLow: surfaceContainerLow,
      ),
    );

    final textTheme = GoogleFonts.interTextTheme(base.textTheme).copyWith(
      headlineLarge: GoogleFonts.inter(
        fontSize: 30,
        height: 38 / 30,
        fontWeight: FontWeight.w700,
        letterSpacing: -0.02 * 30,
      ),
      headlineMedium: GoogleFonts.inter(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w600,
        letterSpacing: -0.01 * 24,
      ),
      headlineSmall: GoogleFonts.inter(
        fontSize: 18,
        height: 24 / 18,
        fontWeight: FontWeight.w600,
      ),
      bodyLarge: GoogleFonts.inter(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
      ),
      bodyMedium: GoogleFonts.inter(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: FontWeight.w400,
      ),
      labelLarge: GoogleFonts.inter(
        fontSize: 12,
        height: 16 / 12,
        fontWeight: FontWeight.w600,
        letterSpacing: 0.05 * 12,
      ),
    );

    return base.copyWith(
      scaffoldBackgroundColor: background,
      textTheme: textTheme,
      dividerTheme: DividerThemeData(color: outlineVariant),
      appBarTheme: AppBarTheme(
        backgroundColor: surface,
        foregroundColor: primary,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        scrolledUnderElevation: 0,
      ),
      cardTheme: CardThemeData(
        color: card,
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: const BorderRadius.all(Radius.circular(8)),
          side: BorderSide(color: outlineVariant),
        ),
        margin: EdgeInsets.zero,
      ),
    );
  }
}
