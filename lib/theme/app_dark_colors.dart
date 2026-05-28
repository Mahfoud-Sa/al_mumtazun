import 'package:flutter/material.dart';

/// Dark mode color definitions used throughout the app.
/// These colors correspond to the values currently hard‑coded in
/// `AppTheme.dark()` and provide a single source of truth for the dark
/// color scheme.
class AppDarkColors {
  // Primary and accent colors
  static const primary = Color(0xFFE7EEF7);
  static const onPrimary = Color(0xFF1A2B3C);
  static const secondary = Color(0xFFF7941D);
  static const onSecondary = Colors.white;

  // Background and surface colors
  static const background = Color(0xFF0B1118);
  static const surface = Color(0xFF111820);
  static const surfaceContainer = Color(0xFF141D26);
  static const surfaceContainerLow = Color(0xFF17212B);
  static const surfaceContainerHigh = Color(0xFF1E2A36);
  static const surfaceContainerHighest = Color(0xFF26333F);

  // On‑surface variants
  static const onSurface = Color(0xFFE2E8F0);
  static const onSurfaceVariant = Color(0xFFB8C2CC);

  // Outline colors
  static const outline = Color(0xFF8D99A6);
  static const outlineVariant = Color(0xFF334050);

  // Error colors
  static const error = Color(0xFFFFB4AB);
  static const onError = Color(0xFF690005);
  static const errorContainer = Color(0xFFBA1A1A);
  static const onErrorContainer = Color(0xFFFFDAD6);

  // Semantic colors (reuse from light palette where appropriate)
  static const success = Color(0xFF2E7D32);
  static const successContainer = Color(0xFFE8F5E9);
  static const warning = Color(0xFFEDC62F);
  static const warningContainer = Color(0xFFFFF3E0);
  static const info = Color(0xFF0288D1);
  static const infoContainer = Color(0xFFE1F5FE);

  static const red = error;
  static const redBg = errorContainer;
  static const green = success;
  static const greenBg = successContainer;
  static const yellow = warning;
  static const yellowBg = warningContainer;
  static const blue = info;
  static const blueBg = infoContainer;

  static const shadow = Color(0x1A000000);
}
