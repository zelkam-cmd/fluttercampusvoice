import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

class AppColors {
  // Primary brand colors from MIT App & CampusVoice
  static const Color primaryTeal = Color(0xFF2EA89D);
  static const Color primaryTealDark = Color(0xFF23857C);
  static const Color primaryTealLight = Color(0xFFE6F6F4);

  // Royal Blue banner from MIT App
  static const Color royalBlue = Color(0xFF2563EB);
  static const Color royalBlueDark = Color(0xFF1D4ED8);
  static const Color royalBlueLight = Color(0xFF3B82F6);

  // Background gradient colors
  static const Color bgGradientStart = Color(0xFFE8EEFF);
  static const Color bgGradientMid = Color(0xFFF3E8FF);
  static const Color bgGradientEnd = Color(0xFFE3F5F0);

  // Card & surface colors
  static const Color surfaceWhite = Colors.white;
  static const Color cardBorder = Color(0xFFE5E7EB);
  static const Color backgroundLight = Color(0xFFF8FAFC);

  // Text colors
  static const Color textDark = Color(0xFF111827);
  static const Color textMedium = Color(0xFF4B5563);
  static const Color textMuted = Color(0xFF6B7280);
  static const Color textLight = Color(0xFF9CA3AF);

  // Stat KPI colors
  static const Color kpiTeal = Color(0xFF0D9488);
  static const Color kpiPurple = Color(0xFF7C3AED);
  static const Color kpiOrange = Color(0xFFEA580C);
  static const Color kpiGreen = Color(0xFF16A34A);
  static const Color kpiRed = Color(0xFFDC2626);
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      scaffoldBackgroundColor: AppColors.backgroundLight,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primaryTeal,
        primary: AppColors.primaryTeal,
        secondary: AppColors.royalBlue,
        surface: AppColors.surfaceWhite,
      ),
      textTheme: GoogleFonts.plusJakartaSansTextTheme().copyWith(
        displayLarge: GoogleFonts.plusJakartaSans(
          fontSize: 26,
          fontWeight: FontWeight.bold,
          color: AppColors.textDark,
        ),
        headlineMedium: GoogleFonts.plusJakartaSans(
          fontSize: 20,
          fontWeight: FontWeight.w700,
          color: AppColors.textDark,
        ),
        titleLarge: GoogleFonts.plusJakartaSans(
          fontSize: 18,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        titleMedium: GoogleFonts.inter(
          fontSize: 15,
          fontWeight: FontWeight.w600,
          color: AppColors.textDark,
        ),
        bodyLarge: GoogleFonts.inter(
          fontSize: 14,
          fontWeight: FontWeight.w500,
          color: AppColors.textDark,
        ),
        bodyMedium: GoogleFonts.inter(
          fontSize: 13,
          fontWeight: FontWeight.w400,
          color: AppColors.textMedium,
        ),
        labelLarge: GoogleFonts.plusJakartaSans(
          fontSize: 14,
          fontWeight: FontWeight.w600,
          color: Colors.white,
        ),
      ),
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: false,
        iconTheme: IconThemeData(color: AppColors.textDark),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryTeal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(vertical: 14, horizontal: 20),
          textStyle: GoogleFonts.plusJakartaSans(
            fontSize: 15,
            fontWeight: FontWeight.w700,
          ),
          elevation: 0,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: Colors.white,
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        enabledBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: Color(0xFFD1D5DB)),
        ),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: const BorderSide(color: AppColors.primaryTeal, width: 2),
        ),
        hintStyle: GoogleFonts.inter(
          fontSize: 13,
          color: AppColors.textLight,
        ),
      ),
    );
  }
}
