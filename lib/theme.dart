
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColorPalette {
  final Color primaryColor;
  final Color accentColor;
  final String name;

  const AppColorPalette({
    required this.primaryColor,
    required this.accentColor,
    required this.name,
  });

  static const List<AppColorPalette> palettes = [
    AppColorPalette(name: 'Default Blue', primaryColor: Color(0xFF0D47A1), accentColor: Color(0xFF4CAF50)), // Deep Blue & Green
    AppColorPalette(name: 'Purple Haze', primaryColor: Color(0xFF6A1B9A), accentColor: Color(0xFFD81B60)), // Deep Purple & Pink
    AppColorPalette(name: 'Ocean Teal', primaryColor: Color(0xFF00695C), accentColor: Color(0xFF80CBC4)), // Dark Teal & Light Teal
    AppColorPalette(name: 'Sunset Orange', primaryColor: Color(0xFFE65100), accentColor: Color(0xFFFFCA28)), // Deep Orange & Amber
    AppColorPalette(name: 'Forest Green', primaryColor: Color(0xFF2E7D32), accentColor: Color(0xFF81C784)), // Green & Light Green
    AppColorPalette(name: 'Sky Blue', primaryColor: Color(0xFF0277BD), accentColor: Color(0xFF81D4FA)), // Blue & Light Blue
    AppColorPalette(name: 'Lavender', primaryColor: Color(0xFF5E35B1), accentColor: Color(0xFFE6EE9C)), // Deep Purple & Lime
    AppColorPalette(name: 'Sunrise', primaryColor: Color(0xFFF57C00), accentColor: Color(0xFFFFEE58)), // Orange & Yellow
  ];
}

class AppTheme {
  static const Color _lightBackgroundColor = Color(0xFFF5F5F5); // Light Grey
  static const Color _darkBackgroundColor = Color(0xFF121212); // Almost Black

  static Color _getTextColorForBackground(Color backgroundColor) {
    return ThemeData.estimateBrightnessForColor(backgroundColor) == Brightness.dark
        ? Colors.white
        : Colors.black;
  }

  static ThemeData lightTheme(AppColorPalette palette) => ThemeData(
    brightness: Brightness.light,
    primaryColor: palette.primaryColor,
    scaffoldBackgroundColor: _lightBackgroundColor,
    textTheme: GoogleFonts.latoTextTheme(ThemeData.light().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: palette.primaryColor,
      foregroundColor: _getTextColorForBackground(palette.primaryColor),
      elevation: 0,
      titleTextStyle: TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: _getTextColorForBackground(palette.primaryColor),
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 2,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: palette.accentColor,
        foregroundColor: _getTextColorForBackground(palette.accentColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: Colors.grey[200],
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: palette.accentColor,
      foregroundColor: _getTextColorForBackground(palette.accentColor),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: palette.primaryColor,
      brightness: Brightness.light,
      secondary: palette.accentColor,
    ).copyWith(background: _lightBackgroundColor),
  );

  static ThemeData darkTheme(AppColorPalette palette) => ThemeData(
    brightness: Brightness.dark,
    primaryColor: palette.primaryColor,
    scaffoldBackgroundColor: _darkBackgroundColor,
    textTheme: GoogleFonts.latoTextTheme(ThemeData.dark().textTheme),
    appBarTheme: AppBarTheme(
      backgroundColor: const Color(0xFF1F1F1F), // Darker grey for app bar
      foregroundColor: Colors.white,
      elevation: 0,
      titleTextStyle: const TextStyle(
        fontSize: 20,
        fontWeight: FontWeight.bold,
        color: Colors.white,
      ),
    ),
    cardTheme: CardThemeData(
      elevation: 4,
      color: const Color(0xFF1E1E1E), // Slightly lighter than background
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
      ),
      margin: const EdgeInsets.symmetric(vertical: 8, horizontal: 16),
    ),
    elevatedButtonTheme: ElevatedButtonThemeData(
      style: ElevatedButton.styleFrom(
        backgroundColor: palette.accentColor,
        foregroundColor: _getTextColorForBackground(palette.accentColor),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 24),
      ),
    ),
    inputDecorationTheme: InputDecorationTheme(
      border: OutlineInputBorder(
        borderRadius: BorderRadius.circular(12),
        borderSide: BorderSide.none,
      ),
      filled: true,
      fillColor: const Color(0xFF2C2C2C),
    ),
    floatingActionButtonTheme: FloatingActionButtonThemeData(
      backgroundColor: palette.accentColor,
      foregroundColor: _getTextColorForBackground(palette.accentColor),
    ),
    colorScheme: ColorScheme.fromSeed(
      seedColor: palette.primaryColor,
      brightness: Brightness.dark,
      secondary: palette.accentColor,
    ).copyWith(background: _darkBackgroundColor),
  );
}
