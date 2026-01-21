import 'package:flutter/material.dart';

class AppColors {
  static const Color background = Color(0xFF1B1E28); // Deep dark blue-grey
  static const Color surface = Color(0xFF242A37);    // Slightly lighter surface
  static const Color primary = Color(0xFF246BFD);   // Vibrant blue
  static const Color accent = Color(0xFF00B2FF);    // Lighter cyan-blue
  static const Color textPrimary = Colors.white;
  static const Color textSecondary = Color(0xFF8E8E93);
  
  static const LinearGradient primaryGradient = LinearGradient(
    colors: [Color(0xFF246BFD), Color(0xFF00B2FF)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static const LinearGradient accentGradient = LinearGradient(
    colors: [Color(0xFF323B4A), Color(0xFF1B1E28)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
}

class AppTheme {
  static ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    scaffoldBackgroundColor: AppColors.background,
    primaryColor: AppColors.primary,
    colorScheme: const ColorScheme.dark(
      primary: AppColors.primary,
      secondary: AppColors.accent,
      surface: AppColors.surface,
    ),
    appBarTheme: const AppBarTheme(
      backgroundColor: AppColors.background,
      elevation: 0,
    ),
    textTheme: const TextTheme(
      headlineMedium: TextStyle(color: AppColors.textPrimary, fontWeight: FontWeight.bold),
      bodyLarge: TextStyle(color: AppColors.textPrimary),
      bodyMedium: TextStyle(color: AppColors.textSecondary),
    ),
  );
}
