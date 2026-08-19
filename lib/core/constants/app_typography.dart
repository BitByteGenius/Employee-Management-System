import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';

/// Typography definitions based on the Stitch layout design system.
/// Uses Inter for headlines/body and JetBrains Mono for monospaced labels/badges.
class AppTypography {
  AppTypography._();

  static TextStyle displayLg({Color? color}) => GoogleFonts.inter(
        fontSize: 48,
        height: 56 / 48,
        letterSpacing: -0.96,
        fontWeight: FontWeight.w700,
        color: color,
      );

  static TextStyle headlineLg({Color? color}) => GoogleFonts.inter(
        fontSize: 32,
        height: 40 / 32,
        letterSpacing: -0.32,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle headlineMd({Color? color}) => GoogleFonts.inter(
        fontSize: 24,
        height: 32 / 24,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle headlineSm({Color? color}) => GoogleFonts.inter(
        fontSize: 20,
        height: 28 / 20,
        fontWeight: FontWeight.w600,
        color: color,
      );

  static TextStyle titleLg({Color? color}) => GoogleFonts.inter(
        fontSize: 18,
        height: 26 / 18,
        fontWeight: FontWeight.w500,
        color: color,
      );

  static TextStyle bodyLg({Color? color}) => GoogleFonts.inter(
        fontSize: 16,
        height: 24 / 16,
        fontWeight: FontWeight.w400,
        color: color,
      );

  static TextStyle bodyMd({Color? color, FontWeight? fontWeight}) => GoogleFonts.inter(
        fontSize: 14,
        height: 20 / 14,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: color,
      );

  static TextStyle bodySm({Color? color, FontWeight? fontWeight}) => GoogleFonts.inter(
        fontSize: 13,
        height: 18 / 13,
        fontWeight: fontWeight ?? FontWeight.w400,
        color: color,
      );

  static TextStyle labelMd({Color? color, FontWeight? fontWeight}) => GoogleFonts.jetBrainsMono(
        fontSize: 12,
        height: 16 / 12,
        letterSpacing: 0.6,
        fontWeight: fontWeight ?? FontWeight.w500,
        color: color,
      );

  static TextStyle labelSm({Color? color}) => GoogleFonts.jetBrainsMono(
        fontSize: 10,
        height: 14 / 10,
        letterSpacing: 0.5,
        fontWeight: FontWeight.w500,
        color: color,
      );
}
