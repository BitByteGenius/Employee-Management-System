import 'package:flutter/material.dart';

/// A centralized class for the application's color palette.
/// This ensures consistency and easy theme management.
class AppColors {
  // This class is not meant to be instantiated.
  AppColors._();

  // --- Primary Palette ---
  // A professional and calming blue, suitable for an enterprise application.
  static const Color primary = Color(0xFF4A90E2);
  static const Color onPrimary = Color(0xFFFFFFFF);
  static const Color primaryContainer = Color(0xFFD8E6F8);
  static const Color onPrimaryContainer = Color(0xFF0D1F33);

  // --- Secondary Palette ---
  // A complementary color for secondary actions or highlights.
  static const Color secondary = Color(0xFF50C878); // Emerald Green
  static const Color onSecondary = Color(0xFFFFFFFF);
  static const Color secondaryContainer = Color(0xFFD5F2DD);
  static const Color onSecondaryContainer = Color(0xFF0E2A16);

  // --- Neutral Palette ---
  // Used for backgrounds, surfaces, and text.
  static const Color background = Color(0xFFF8F9FA); // Off-white
  static const Color onBackground = Color(0xFF1C1C1E);
  static const Color surface = Color(0xFFFFFFFF);
  static const Color onSurface = Color(0xFF1C1C1E);
  static const Color surfaceVariant = Color(0xFFE7E9EC);
  static const Color onSurfaceVariant = Color(0xFF43474E);
  static const Color outline = Color(0xFF74777F);

  // --- Semantic Colors ---
  // For conveying specific meanings like success, error, or warning.
  static const Color success = Color(0xFF28A745);
  static const Color error = Color(0xFFDC3545);
  static const Color onError = Color(0xFFFFFFFF);
  static const Color warning = Color(0xFFFFC107);

  // --- Dark Theme Overrides ---
  static const Color darkBackground = Color(0xFF121212);
  static const Color darkSurface = Color(0xFF1E1E1E);
}
