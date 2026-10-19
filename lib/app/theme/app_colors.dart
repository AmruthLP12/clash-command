import 'package:flutter/material.dart';

/// Design tokens for the Clash Command dark theme.
///
/// Dark gaming utility aesthetic: charcoal surfaces, warm gold accents,
/// high-contrast typography.
abstract class AppColors {
  // Surfaces
  static const Color background = Color(0xFF1A1A1A);
  static const Color surface = Color(0xFF242424);
  static const Color surfaceVariant = Color(0xFF2E2E2E);
  static const Color card = Color(0xFF2A2A2A);

  // Gold accent
  static const Color accent = Color(0xFFB78A2E);
  static const Color accentLight = Color(0xFFD4A84B);
  static const Color accentDim = Color(0xFF8A6520);

  // Status colors
  static const Color active = Color(0xFF4CAF50);
  static const Color pastDue = Color(0xFFFF9800);
  static const Color cancelled = Color(0xFF757575);
  static const Color completed = Color(0xFF9E9E9E);

  // Text
  static const Color textPrimary = Color(0xFFF5F5F5);
  static const Color textSecondary = Color(0xFFB0B0B0);
  static const Color textMuted = Color(0xFF757575);

  // Error
  static const Color error = Color(0xFFCF6679);
}
