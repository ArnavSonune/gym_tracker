import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppTheme {
  // Solo Leveling Color Palette
  static const Color neonBlue = Color(0xFF00D9FF);
  static const Color neonPurple = Color(0xFF9D4EDD);
  static const Color darkBackground = Color(0xFF0A0E27);
  static const Color darkSurface = Color(0xFF141B3D);
  static const Color darkerSurface = Color(0xFF0D1129);
  
  // Accent Colors
  static const Color accentGold = Color(0xFFFFD700);
  static const Color successGreen = Color(0xFF00FF88);
  static const Color dangerRed = Color(0xFFFF4757);
  static const Color warningOrange = Color(0xFFFF9F43);
  
  // Text Colors
  static const Color textPrimary = Color(0xFFFFFFFF);
  static const Color textSecondary = Color(0xFFB8B8D1);
  static const Color textTertiary = Color(0xFF6B7280);
  
  // Glass Effect Colors
  static const Color glassWhite = Color(0x1AFFFFFF);
  static const Color glassBlue = Color(0x1A00D9FF);
  
  // Rank Colors
  static const Color rankE = Color(0xFF9E9E9E);
  static const Color rankD = Color(0xFF4CAF50);
  static const Color rankC = Color(0xFF2196F3);
  static const Color rankB = Color(0xFF9C27B0);
  static const Color rankA = Color(0xFFFF9800);
  static const Color rankS = Color(0xFFFFD700);

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      scaffoldBackgroundColor: darkBackground,
      
      colorScheme: const ColorScheme.dark(
        primary: neonBlue,
        secondary: neonPurple,
        surface: darkSurface,
        error: dangerRed,
        onPrimary: Colors.black,
        onSecondary: Colors.white,
        onSurface: textPrimary,
      ),
      
      // Text Theme
      textTheme: TextTheme(
        // Display styles (for big titles)
        displayLarge: GoogleFonts.orbitron(
          fontSize: 57,
          fontWeight: FontWeight.bold,
          color: textPrimary,
          letterSpacing: -0.5,
        ),
        displayMedium: GoogleFonts.orbitron(
          fontSize: 45,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        displaySmall: GoogleFonts.orbitron(
          fontSize: 36,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        
        // Headline styles (for section headers)
        headlineLarge: GoogleFonts.orbitron(
          fontSize: 32,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        headlineMedium: GoogleFonts.orbitron(
          fontSize: 28,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        headlineSmall: GoogleFonts.orbitron(
          fontSize: 24,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        
        // Title styles (for card titles)
        titleLarge: GoogleFonts.inter(
          fontSize: 22,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        titleSmall: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
        ),
        
        // Body styles (for regular text)
        bodyLarge: GoogleFonts.inter(
          fontSize: 16,
          fontWeight: FontWeight.normal,
          color: textPrimary,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.normal,
          color: textSecondary,
        ),
        bodySmall: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.normal,
          color: textTertiary,
        ),
        
        // Label styles (for buttons, labels)
        labelLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: textPrimary,
          letterSpacing: 0.5,
        ),
        labelMedium: GoogleFonts.inter(
          fontSize: 12,
          fontWeight: FontWeight.w600,
          color: textSecondary,
          letterSpacing: 0.5,
        ),
        labelSmall: GoogleFonts.inter(
          fontSize: 11,
          fontWeight: FontWeight.w500,
          color: textTertiary,
          letterSpacing: 0.5,
        ),
      ),
      
      // AppBar Theme
      appBarTheme: AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        titleTextStyle: GoogleFonts.orbitron(
          fontSize: 20,
          fontWeight: FontWeight.bold,
          color: textPrimary,
        ),
        iconTheme: const IconThemeData(color: neonBlue),
      ),
      
      // Card Theme
      cardTheme: CardThemeData(
        color: darkSurface,
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
      ),
      
      // Input Decoration Theme
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: darkerSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: glassBlue, width: 1),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: glassBlue, width: 1),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: neonBlue, width: 2),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: const BorderSide(color: dangerRed, width: 1),
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
        hintStyle: GoogleFonts.inter(
          color: textTertiary,
          fontSize: 14,
        ),
      ),
      
      // Elevated Button Theme
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: neonBlue,
          foregroundColor: Colors.black,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(12),
          ),
          textStyle: GoogleFonts.inter(
            fontSize: 16,
            fontWeight: FontWeight.bold,
            letterSpacing: 0.5,
          ),
        ),
      ),
      
      // Text Button Theme
      textButtonTheme: TextButtonThemeData(
        style: TextButton.styleFrom(
          foregroundColor: neonBlue,
          textStyle: GoogleFonts.inter(
            fontSize: 14,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      
      // Icon Theme
      iconTheme: const IconThemeData(
        color: neonBlue,
        size: 24,
      ),
      
      // Divider Theme
      dividerTheme: const DividerThemeData(
        color: glassWhite,
        thickness: 1,
        space: 1,
      ),
    );
  }

  // Helper method to get rank color
  static Color getRankColor(String rank) {
    switch (rank.toUpperCase()) {
      case 'E':
        return rankE;
      case 'D':
        return rankD;
      case 'C':
        return rankC;
      case 'B':
        return rankB;
      case 'A':
        return rankA;
      case 'S':
        return rankS;
      default:
        return rankE;
    }
  }

  // Helper method to get rank from level
  static String getRankFromLevel(int level) {
    if (level <= 10) return 'E';
    if (level <= 20) return 'D';
    if (level <= 30) return 'C';
    if (level <= 40) return 'B';
    if (level <= 50) return 'A';
    return 'S';
  }

  // Glassmorphism Box Decoration
  static BoxDecoration glassDecoration({
    Color? color,
    double borderRadius = 16,
    bool showBorder = true,
    Color? borderColor,
  }) {
    return BoxDecoration(
      color: color ?? glassWhite,
      borderRadius: BorderRadius.circular(borderRadius),
      border: showBorder
          ? Border.all(
              color: borderColor ?? glassBlue,
              width: 1,
            )
          : null,
      boxShadow: [
        BoxShadow(
          color: (borderColor ?? neonBlue).withOpacity(0.1),
          blurRadius: 20,
          offset: const Offset(0, 4),
        ),
      ],
    );
  }

  // Glow Shadow for buttons and highlights
  static List<BoxShadow> glowShadow({
    Color? color,
    double blurRadius = 20,
    double spreadRadius = 0,
  }) {
    return [
      BoxShadow(
        color: (color ?? neonBlue).withOpacity(0.3),
        blurRadius: blurRadius,
        spreadRadius: spreadRadius,
        offset: const Offset(0, 0),
      ),
    ];
  }
}