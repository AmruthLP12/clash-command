import 'package:flutter/material.dart';

/// Design tokens for Clash Command, supporting dynamic light and dark palettes.
///
/// Dark gaming utility aesthetic: charcoal surfaces, warm gold accents.
/// Light clean aesthetic: crisp surfaces, refined warm gold accents.
abstract class AppColors {
  static bool _isLight = false;

  /// Updates the active palette mode.
  static void setLight(bool light) {
    _isLight = light;
  }

  /// Whether light mode is currently active.
  static bool get isLight => _isLight;

  // Surfaces
  static Color get background =>
      _isLight ? const Color(0xFFF6F7F9) : const Color(0xFF1A1A1A);
  static Color get surface =>
      _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF242424);
  static Color get surfaceVariant =>
      _isLight ? const Color(0xFFEBEFF4) : const Color(0xFF2E2E2E);
  static Color get card =>
      _isLight ? const Color(0xFFFFFFFF) : const Color(0xFF2A2A2A);

  // Gold accent
  static Color get accent =>
      _isLight ? const Color(0xFF9E721D) : const Color(0xFFB78A2E);
  static Color get accentLight =>
      _isLight ? const Color(0xFFB78A2E) : const Color(0xFFD4A84B);
  static Color get accentDim =>
      _isLight ? const Color(0xFF7A5818) : const Color(0xFF8A6520);

  // Status colors
  static Color get active =>
      _isLight ? const Color(0xFF2E7D32) : const Color(0xFF4CAF50);
  static Color get pastDue =>
      _isLight ? const Color(0xFFE65100) : const Color(0xFFFF9800);
  static Color get cancelled => const Color(0xFF757575);
  static Color get completed =>
      _isLight ? const Color(0xFF757575) : const Color(0xFF9E9E9E);

  // Text
  static Color get textPrimary =>
      _isLight ? const Color(0xFF1A1A1A) : const Color(0xFFF5F5F5);
  static Color get textSecondary =>
      _isLight ? const Color(0xFF5A626A) : const Color(0xFFB0B0B0);
  static Color get textMuted =>
      _isLight ? const Color(0xFF8A929B) : const Color(0xFF757575);

  // Error
  static Color get error =>
      _isLight ? const Color(0xFFB00020) : const Color(0xFFCF6679);
}
