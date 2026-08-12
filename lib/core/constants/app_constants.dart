import 'package:flutter/material.dart';

class AppColors {
  static const primary = Color(0xFF2563EB);
  static const secondary = Color(0xFF14B8A6);
  static const success = Color(0xFF16A34A);
  static const warning = Color(0xFFF59E0B);
  static const danger = Color(0xFFDC2626);
  static const ink = Color(0xFF111827);
  static const muted = Color(0xFF6B7280);
  static const surface = Color(0xFFF8FAFC);
  static const darkSurface = Color(0xFF111827);
}

class AppPadding {
  static const xs = 8.0;
  static const sm = 12.0;
  static const md = 16.0;
  static const lg = 24.0;
  static const xl = 32.0;
}

class AppRadius {
  static const sm = 6.0;
  static const md = 8.0;
}

class AppFontSize {
  static const body = 14.0;
  static const title = 20.0;
  static const heading = 28.0;
}

class AppDuration {
  static const fast = Duration(milliseconds: 180);
  static const normal = Duration(milliseconds: 280);
}

class AppStrings {
  static const appName = 'TMS';
  static const apiBaseUrl = 'http://localhost:5000/api/v1';
}

class AppAssets {
  static const logo = 'assets/images/logo.png';
}

class AppShadow {
  static List<BoxShadow> card(BuildContext context) => [
        BoxShadow(
          color: Theme.of(context).shadowColor.withValues(alpha: .08),
          blurRadius: 18,
          offset: const Offset(0, 8),
        ),
      ];
}
