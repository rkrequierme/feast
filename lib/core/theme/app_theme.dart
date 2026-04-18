import 'package:flutter/material.dart';
import 'app_colors.dart';

/// The centralized ThemeData for the Feast app.
/// Provides consistent styling across all Material widgets.
class AppTheme {
  AppTheme._(); // Prevent instantiation

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: Colors.white,
      primaryColor: feastGreen,

      // ── Color Scheme ───────────────────────────────────────────────────
      colorScheme: const ColorScheme.light(
        primary: feastGreen,
        secondary: feastBlue,
        surface: Colors.white,
        error: Colors.red,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: Colors.black87,
        onError: Colors.white,
      ),

      // ── AppBar ─────────────────────────────────────────────────────────
      appBarTheme: const AppBarTheme(
        backgroundColor: feastGreen,
        foregroundColor: Colors.white,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w800,
          fontSize: 18,
          color: Colors.white,
        ),
      ),

      // ── Elevated Button ────────────────────────────────────────────────
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: feastGreen,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(25),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 24),
          textStyle: const TextStyle(
            fontFamily: 'Outfit',
            fontWeight: FontWeight.w700,
            fontSize: 14,
          ),
        ),
      ),

      // ── Text Theme ─────────────────────────────────────────────────────
      textTheme: const TextTheme(
        headlineLarge: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w800,
          fontSize: 24,
          color: Colors.black,
        ),
        headlineMedium: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w800,
          fontSize: 20,
          color: Colors.black,
        ),
        titleLarge: TextStyle(
          fontFamily: 'Outfit',
          fontWeight: FontWeight.w700,
          fontSize: 18,
          color: Colors.black,
        ),
        titleMedium: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w700,
          fontSize: 16,
          color: Colors.black,
        ),
        bodyLarge: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 16,
          color: Colors.black87,
        ),
        bodyMedium: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 14,
          color: Colors.black87,
        ),
        bodySmall: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 12,
          color: Colors.black54,
        ),
      ),

      // ── Input Decoration ───────────────────────────────────────────────
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 14,
        ),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: BorderSide(color: Colors.grey.shade300),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(10),
          borderSide: const BorderSide(color: feastGreen, width: 2),
        ),
        hintStyle: const TextStyle(
          fontFamily: 'Nunito',
          color: Colors.grey,
          fontSize: 14,
        ),
      ),

      // ── Divider ────────────────────────────────────────────────────────
      dividerTheme: DividerThemeData(
        color: Colors.grey.shade200,
        thickness: 1,
      ),

      // ── Bottom Nav ─────────────────────────────────────────────────────
      bottomNavigationBarTheme: const BottomNavigationBarThemeData(
        backgroundColor: Colors.white,
        selectedItemColor: feastGreen,
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedLabelStyle: TextStyle(
          fontFamily: 'Nunito',
          fontWeight: FontWeight.w700,
          fontSize: 11,
        ),
        unselectedLabelStyle: TextStyle(
          fontFamily: 'Nunito',
          fontSize: 11,
        ),
      ),
    );
  }
}
