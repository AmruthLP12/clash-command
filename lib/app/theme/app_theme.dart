import 'package:flutter/material.dart';

/// Material 3 dark theme for Clash Command.
ThemeData buildDarkTheme() {
  final base = ThemeData.dark(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFF1A1A1A),
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: const Color(0xFFB78A2E),
          brightness: Brightness.dark,
        ).copyWith(
          surface: const Color(0xFF242424),
          onSurface: const Color(0xFFF5F5F5),
          secondary: const Color(0xFFB78A2E),
          onSecondary: Colors.black,
          error: const Color(0xFFCF6679),
        ),
    cardTheme: const CardThemeData(
      color: Color(0xFF2A2A2A),
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFF242424),
      foregroundColor: Color(0xFFF5F5F5),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Color(0xFFF5F5F5),
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFF2E2E2E),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide.none,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFFB78A2E),
        foregroundColor: Colors.black,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xFFD4A84B)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFF2E2E2E),
      labelStyle: const TextStyle(color: Color(0xFFB0B0B0), fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: BorderSide.none,
    ),
    dividerColor: const Color(0xFF2E2E2E),
    iconTheme: const IconThemeData(color: Color(0xFFB0B0B0)),
  );
}

/// Material 3 light theme for Clash Command.
ThemeData buildLightTheme() {
  final base = ThemeData.light(useMaterial3: true);
  return base.copyWith(
    scaffoldBackgroundColor: const Color(0xFFF6F7F9),
    colorScheme:
        ColorScheme.fromSeed(
          seedColor: const Color(0xFF9E721D),
          brightness: Brightness.light,
        ).copyWith(
          surface: const Color(0xFFFFFFFF),
          onSurface: const Color(0xFF1A1A1A),
          secondary: const Color(0xFF9E721D),
          onSecondary: Colors.white,
          error: const Color(0xFFB00020),
        ),
    cardTheme: const CardThemeData(
      color: Color(0xFFFFFFFF),
      margin: EdgeInsets.zero,
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.all(Radius.circular(12)),
      ),
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: Color(0xFFFFFFFF),
      foregroundColor: Color(0xFF1A1A1A),
      elevation: 0,
      centerTitle: false,
      titleTextStyle: TextStyle(
        color: Color(0xFF1A1A1A),
        fontSize: 20,
        fontWeight: FontWeight.w700,
      ),
    ),
    inputDecorationTheme: const InputDecorationTheme(
      filled: true,
      fillColor: Color(0xFFEBEFF4),
      border: OutlineInputBorder(
        borderRadius: BorderRadius.all(Radius.circular(8)),
        borderSide: BorderSide.none,
      ),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: const Color(0xFF9E721D),
        foregroundColor: Colors.white,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
      ),
    ),
    textButtonTheme: TextButtonThemeData(
      style: TextButton.styleFrom(foregroundColor: const Color(0xFF9E721D)),
    ),
    chipTheme: ChipThemeData(
      backgroundColor: const Color(0xFFEBEFF4),
      labelStyle: const TextStyle(color: Color(0xFF5A626A), fontSize: 12),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(6)),
      side: BorderSide.none,
    ),
    dividerColor: const Color(0xFFEBEFF4),
    iconTheme: const IconThemeData(color: Color(0xFF5A626A)),
  );
}

/// Backwards compatibility alias for default theme (dark).
ThemeData buildAppTheme() => buildDarkTheme();
