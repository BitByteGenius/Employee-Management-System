import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tms/core/constants/app_colors.dart';

/// Centralized theme configuration for the TeamOrbit application.
/// Provides `ThemeData` for both light and dark modes, adhering to Material 3 principles.
class AppTheme {
  AppTheme._();

  /// Light theme configuration.
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: _lightColorScheme,
      scaffoldBackgroundColor: AppColors.background,
      textTheme: GoogleFonts.interTextTheme(ThemeData.light().textTheme),
      cardTheme: const CardThemeData(
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: AppColors.outline, width: 0.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.surface,
        foregroundColor: AppColors.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
    );
  }

  /// Dark theme configuration.
  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: _darkColorScheme,
      scaffoldBackgroundColor: AppColors.darkBackground,
      textTheme: GoogleFonts.interTextTheme(ThemeData.dark().textTheme),
      cardTheme: const CardThemeData(
        elevation: 1.0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.all(Radius.circular(12)),
          side: BorderSide(color: AppColors.outline, width: 0.5),
        ),
      ),
      appBarTheme: AppBarTheme(
        elevation: 0,
        backgroundColor: AppColors.darkSurface,
        foregroundColor: AppColors.onSurface,
        surfaceTintColor: Colors.transparent,
        titleTextStyle: GoogleFonts.inter(
          fontSize: 20,
          fontWeight: FontWeight.w600,
          color: AppColors.onSurface,
        ),
      ),
    );
  }

  // Private color scheme definitions to keep the main theme getters clean.
  static const _lightColorScheme = ColorScheme.light(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      surface: AppColors.surface,
      onSurface: AppColors.onSurface,
      error: AppColors.error,
      onError: AppColors.onError,
      outline: AppColors.outline);

  static const _darkColorScheme = ColorScheme.dark(
      primary: AppColors.primary,
      onPrimary: AppColors.onPrimary,
      secondary: AppColors.secondary,
      onSecondary: AppColors.onSecondary,
      surface: AppColors.darkSurface,
      onSurface: AppColors.onSurface,
      error: AppColors.error,
      onError: AppColors.onError,
      outline: AppColors.outline);
}
