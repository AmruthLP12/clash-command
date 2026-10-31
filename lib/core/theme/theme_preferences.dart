import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:shared_preferences/shared_preferences.dart';

/// User preference for application theme appearance.
enum AppThemeModePreference {
  system,
  dark,
  light;

  ThemeMode get themeMode {
    switch (this) {
      case AppThemeModePreference.system:
        return ThemeMode.system;
      case AppThemeModePreference.dark:
        return ThemeMode.dark;
      case AppThemeModePreference.light:
        return ThemeMode.light;
    }
  }

  String get displayName {
    switch (this) {
      case AppThemeModePreference.system:
        return 'System Default';
      case AppThemeModePreference.dark:
        return 'Dark Mode';
      case AppThemeModePreference.light:
        return 'Light Mode';
    }
  }
}

class ThemePreferencesNotifier extends StateNotifier<AppThemeModePreference> {
  ThemePreferencesNotifier() : super(AppThemeModePreference.dark) {
    _load();
  }

  static const String keyThemeMode = 'pref_theme_mode';

  Future<void> _load() async {
    try {
      final prefs = await SharedPreferences.getInstance();
      final val = prefs.getString(keyThemeMode);
      if (val != null) {
        state = AppThemeModePreference.values.firstWhere(
          (e) => e.name == val,
          orElse: () => AppThemeModePreference.dark,
        );
      }
    } catch (_) {}
  }

  Future<void> setThemeMode(AppThemeModePreference mode) async {
    state = mode;
    try {
      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(keyThemeMode, mode.name);
    } catch (_) {}
  }
}

final themePreferencesProvider =
    StateNotifierProvider<ThemePreferencesNotifier, AppThemeModePreference>(
      (ref) => ThemePreferencesNotifier(),
    );
