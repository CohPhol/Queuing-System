import 'package:flutter/material.dart';

class AppTheme {
  // =====================
  // COLORS
  // =====================
  static const Color primary = Color(0xFF527796);
  static const Color accent = Color(0xFFF4A261);

  // DARK
  static const Color darkBg = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1A1A1A);

  // LIGHT
  static const Color lightBg = Color(0xFFF5F7FA);

  // =====================
  // DARK THEME
  // =====================
  static ThemeData darkTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.dark,

    scaffoldBackgroundColor: darkBg,

    colorScheme: const ColorScheme.dark(
      primary: primary,
      secondary: accent,
      surface: darkSurface,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: darkSurface,
      foregroundColor: Colors.white,
      elevation: 0,
    ),

    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: darkSurface,
      selectedIconTheme: IconThemeData(color: primary),
      unselectedIconTheme: IconThemeData(color: Colors.white60),
      selectedLabelTextStyle: TextStyle(color: primary),
      unselectedLabelTextStyle: TextStyle(color: Colors.white60),
    ),
  );

  // =====================
  // LIGHT THEME
  // =====================
  static ThemeData lightTheme = ThemeData(
    useMaterial3: true,
    brightness: Brightness.light,

    scaffoldBackgroundColor: lightBg,

    colorScheme: const ColorScheme.light(
      primary: primary,
      secondary: accent,
      surface: Colors.white,
    ),

    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.white,
      foregroundColor: Colors.black,
      elevation: 0,
    ),

    navigationRailTheme: const NavigationRailThemeData(
      backgroundColor: Colors.white,
      selectedIconTheme: IconThemeData(color: primary),
      unselectedIconTheme: IconThemeData(color: Colors.black45),
      selectedLabelTextStyle: TextStyle(color: primary),
      unselectedLabelTextStyle: TextStyle(color: Colors.black45),
    ),
  );
}
