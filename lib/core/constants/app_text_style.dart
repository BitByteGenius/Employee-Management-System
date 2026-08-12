import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:tms/core/constants/app_colors.dart';

/// Centralized text styles for the TeamOrbit application.
class AppTextStyle {
  AppTextStyle._();

  static final TextStyle heading1 = GoogleFonts.inter(
    fontSize: 32,
    fontWeight: FontWeight.bold,
    color: AppColors.onBackground,
  );

  static final TextStyle bodyRegular = GoogleFonts.inter(
    fontSize: 16,
    fontWeight: FontWeight.normal,
    color: AppColors.onSurfaceVariant,
  );
}
