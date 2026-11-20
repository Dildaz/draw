import 'package:flutter/material.dart';

class AppColors {
  static const Color bgCream = Color(0xFFFFF8F0);
  static const Color bgWarm = Color(0xFFFFF1E4);
  static const Color card = Color(0xFFFFFFFF);
  static const Color cardBorder = Color(0xFFEEDFD0);
  static const Color ink = Color(0xFF2B2129);
  static const Color inkMuted = Color(0xFF7B6B73);

  static const Color coral = Color(0xFFF05D5E);
  static const Color coralDark = Color(0xFFD14142);
  static const Color amber = Color(0xFFFFB703);
  static const Color amberDark = Color(0xFFD99400);
  static const Color green = Color(0xFF4BB543);
  static const Color greenDark = Color(0xFF358A2F);
  static const Color sky = Color(0xFF4D96FF);
  static const Color skyDark = Color(0xFF2B73D9);
  static const Color purple = Color(0xFF7B5BF2);
  static const Color purpleDark = Color(0xFF5B3CD1);
  static const Color pink = Color(0xFFFF6B9D);
  static const Color neonBg = Color(0xFF161326);
}

class AppTheme {
  static ThemeData build() {
    const baseText = TextTheme(
      displaySmall: TextStyle(
        fontFamily: 'Baloo',
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
        height: 1.15,
      ),
      headlineMedium: TextStyle(
        fontFamily: 'Baloo',
        fontWeight: FontWeight.w800,
        color: AppColors.ink,
        height: 1.2,
      ),
      headlineSmall: TextStyle(
        fontFamily: 'Baloo',
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      titleLarge: TextStyle(
        fontFamily: 'Baloo',
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      titleMedium: TextStyle(
        fontFamily: 'Baloo',
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
      bodyLarge: TextStyle(
        fontFamily: 'Baloo',
        fontWeight: FontWeight.w600,
        color: AppColors.ink,
      ),
      bodyMedium: TextStyle(
        fontFamily: 'Baloo',
        fontWeight: FontWeight.w600,
        color: AppColors.inkMuted,
      ),
      labelLarge: TextStyle(
        fontFamily: 'Baloo',
        fontWeight: FontWeight.w700,
        color: AppColors.ink,
      ),
    );

    return ThemeData(
      useMaterial3: true,
      fontFamily: 'Baloo',
      scaffoldBackgroundColor: AppColors.bgCream,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.coral,
        surface: AppColors.bgCream,
      ),
      textTheme: baseText,
      appBarTheme: const AppBarTheme(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        foregroundColor: AppColors.ink,
        titleTextStyle: TextStyle(
          fontFamily: 'Baloo',
          fontSize: 22,
          fontWeight: FontWeight.w800,
          color: AppColors.ink,
        ),
      ),
    );
  }
}
