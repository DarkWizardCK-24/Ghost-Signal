import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Neon Colors
  static const Color neonGreen = Color(0xFF00FF41);
  static const Color neonPurple = Color(0xFFBF00FF);
  static const Color neonBlue = Color(0xFF00D9FF);
  static const Color neonPink = Color(0xFFFF0080);
  static const Color darkBg = Color(0xFF0A0E27);
  static const Color cardBg = Color(0xFF151A33);
  static const Color accentDark = Color(0xFF1E2442);

  static ThemeData get darkTheme {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBg,
      primaryColor: neonGreen,
      colorScheme: const ColorScheme.dark(
        primary: neonGreen,
        secondary: neonPurple,
        surface: cardBg,
        background: darkBg,
        error: neonPink,
      ),
      textTheme: GoogleFonts.interTextTheme(
        ThemeData.dark().textTheme.apply(
          bodyColor: Colors.white,
          displayColor: Colors.white,
        ),
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 24,
          fontWeight: FontWeight.bold,
          color: neonGreen,
        ),
      ),
      cardTheme: CardThemeData(
        color: cardBg,
        elevation: 8,
        shadowColor: neonGreen.withOpacity(0.2),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
          side: BorderSide(color: neonGreen.withOpacity(0.3), width: 1),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonGreen,
          foregroundColor: darkBg,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: accentDark,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: neonGreen.withOpacity(0.3)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: neonGreen.withOpacity(0.3)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: neonGreen, width: 2),
        ),
        labelStyle: GoogleFonts.inter(color: neonGreen),
        hintStyle: GoogleFonts.inter(color: Colors.grey),
      ),
      iconTheme: const IconThemeData(
        color: neonGreen,
      ),
    );
  }

  static BoxDecoration glowingContainer({Color? color}) {
    return BoxDecoration(
      color: cardBg,
      borderRadius: BorderRadius.circular(16),
      border: Border.all(
        color: (color ?? neonGreen).withOpacity(0.5),
        width: 2,
      ),
      boxShadow: [
        BoxShadow(
          color: (color ?? neonGreen).withOpacity(0.3),
          blurRadius: 20,
          spreadRadius: 2,
        ),
      ],
    );
  }

  static BoxDecoration neonGradient() {
    return BoxDecoration(
      gradient: LinearGradient(
        colors: [
          neonGreen.withOpacity(0.2),
          neonPurple.withOpacity(0.2),
          neonBlue.withOpacity(0.2),
        ],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ),
      borderRadius: BorderRadius.circular(16),
    );
  }
}