import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Light Theme Colors (White Background)
  static const Color background = Color(0xFFF9FAFB);        // clean soft off-white canvas
  static const Color surface = Color(0xFFFFFFFF);           // pure white card
  static const Color surfaceElevated = Color(0xFFF3F4F6);   // light gray card/sub-surface
  static const Color primary = Color(0xFF111827);           // high-contrast deep charcoal text
  static const Color secondary = Color(0xFF4B5563);         // slate neutral gray
  static const Color accent = Color(0xFFB45309);            // warm amber gold accent
  static const Color accentSubtle = Color(0xFFFEF3C7);      // warm amber tint
  static const Color correct = Color(0xFF059669);           // emerald green
  static const Color correctSubtle = Color(0xFFECFDF5);     // soft emerald tint
  static const Color incorrect = Color(0xFFDC2626);         // crimson red
  static const Color incorrectSubtle = Color(0xFFFEF2F2);   // soft red tint
  static const Color warning = Color(0xFFD97706);           // amber root cause
  static const Color warningSubtle = Color(0xFFFFFBEB);     // soft amber tint
  static const Color border = Color(0xFFE5E7EB);            // clean light borders
  static const Color borderHover = Color(0xFFD1D5DB);       // hovered/focused border
  static const Color agentBubble = Color(0xFFEFF6FF);       // soft AI blue tint
  static const Color agentBorder = Color(0xFFBFDBFE);       // AI blue border
  static const Color agentText = Color(0xFF1E40AF);         // AI deep blue

  // Spacing tokens
  static const double spacingXS = 4.0;
  static const double spacingSM = 8.0;
  static const double spacingMD = 16.0;
  static const double spacingLG = 24.0;
  static const double spacingXL = 32.0;

  // Border radius tokens
  static const double radiusSM = 8.0;
  static const double radiusMD = 12.0;
  static const double radiusLG = 16.0;
  static const double radiusXL = 24.0;

  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.light(
        surface: surface,
        primary: accent,
        onPrimary: Colors.white,
        onSurface: primary,
        secondary: secondary,
        error: incorrect,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.light().textTheme.copyWith(
          headlineLarge: const TextStyle(
            fontSize: 28.0,
            fontWeight: FontWeight.w700,
            color: primary,
            letterSpacing: -0.5,
          ),
          headlineMedium: const TextStyle(
            fontSize: 22.0,
            fontWeight: FontWeight.w600,
            color: primary,
            letterSpacing: -0.3,
          ),
          titleLarge: const TextStyle(
            fontSize: 18.0,
            fontWeight: FontWeight.w600,
            color: primary,
          ),
          titleMedium: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w600,
            color: primary,
          ),
          bodyLarge: const TextStyle(
            fontSize: 16.0,
            fontWeight: FontWeight.w400,
            color: primary,
            height: 1.5,
          ),
          bodyMedium: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w400,
            color: secondary,
            height: 1.4,
          ),
          labelLarge: const TextStyle(
            fontSize: 14.0,
            fontWeight: FontWeight.w600,
            color: primary,
            letterSpacing: 0.5,
          ),
          labelSmall: const TextStyle(
            fontSize: 12.0,
            fontWeight: FontWeight.w600,
            color: secondary,
            letterSpacing: 0.8,
          ),
        ),
      ),
      cardTheme: CardThemeData(
        color: surface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(radiusLG),
          side: const BorderSide(color: border, width: 1),
        ),
      ),
    );
  }
}
