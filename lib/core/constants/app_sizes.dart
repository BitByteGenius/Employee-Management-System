// import 'package:flutter/material.dart';

// /// Spacing, dimensions, radii, and responsive breakpoints according to Stitch design system.
// class AppSizes {
//   AppSizes._();

//   // Layout Dimensions
//   static const double sidebarWidth = 240.0;
//   static const double topBarHeight = 72.0;
//   static const double maxContentWidth = 1440.0;

//   // Icon Sizes
//   static const double iconSm = 16.0;
//   static const double iconMd = 20.0;
//   static const double iconLg = 24.0;
//   static const double iconXl = 32.0;
// }

// class AppSpacing {
//   AppSpacing._();

//   static const double xs = 4.0;
//   static const double sm = 8.0;
//   static const double md = 16.0;
//   static const double lg = 24.0;
//   static const double xl = 32.0;
//   static const double xxl = 48.0;
//   static const double xxxl = 64.0;

//   static const EdgeInsets paddingXs = EdgeInsets.all(xs);
//   static const EdgeInsets paddingSm = EdgeInsets.all(sm);
//   static const EdgeInsets paddingMd = EdgeInsets.all(md);
//   static const EdgeInsets paddingLg = EdgeInsets.all(lg);
//   static const EdgeInsets paddingXl = EdgeInsets.all(xl);
// }

// class AppRadius {
//   AppRadius._();

//   static const double xs = 2.0;
//   static const double sm = 4.0;
//   static const double md = 8.0;
//   static const double lg = 12.0;
//   static const double xl = 16.0;
//   static const double full = 999.0;


//   static const BorderRadius borderXs = BorderRadius.all(Radius.circular(xs));
//   static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
//   static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
//   static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
//   static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
//   static const BorderRadius borderFull = BorderRadius.all(Radius.circular(full));
// }

// class AppBreakpoints {
//   AppBreakpoints._();

//   static const double mobile = 700.0;
//   static const double tablet = 1100.0;

//   static bool isMobile(double width) => width < mobile;
//   static bool isTablet(double width) => width >= mobile && width < tablet;
//   static bool isDesktop(double width) => width >= tablet;
// }



import 'package:flutter/material.dart';

/// Spacing, dimensions, radii, and responsive breakpoints according to Stitch design system.
class AppSizes {
  AppSizes._();

  // Layout Dimensions
  static const double sidebarWidth = 240.0;
  static const double topBarHeight = 72.0;
  static const double maxContentWidth = 1440.0;

  // Icon Sizes
  static const double iconSm = 16.0;
  static const double iconMd = 20.0;
  static const double iconLg = 24.0;
  static const double iconXl = 32.0;
}

class AppSpacing {
  AppSpacing._();

  static const double xs = 4.0;
  static const double sm = 8.0;
  static const double md = 16.0;
  static const double lg = 24.0;
  static const double xl = 32.0;
  static const double xxl = 48.0;
  static const double xxxl = 64.0;

  static const EdgeInsets paddingXs = EdgeInsets.all(xs);
  static const EdgeInsets paddingSm = EdgeInsets.all(sm);
  static const EdgeInsets paddingMd = EdgeInsets.all(md);
  static const EdgeInsets paddingLg = EdgeInsets.all(lg);
  static const EdgeInsets paddingXl = EdgeInsets.all(xl);
}

class AppRadius {
  AppRadius._();

  static const double xs = 2.0;
  static const double sm = 4.0;
  static const double md = 8.0;
  static const double lg = 12.0;
  static const double xl = 16.0;
  static const double full = 999.0;

  static const BorderRadius borderXs = BorderRadius.all(Radius.circular(xs));
  static const BorderRadius borderSm = BorderRadius.all(Radius.circular(sm));
  static const BorderRadius borderMd = BorderRadius.all(Radius.circular(md));
  static const BorderRadius borderLg = BorderRadius.all(Radius.circular(lg));
  static const BorderRadius borderXl = BorderRadius.all(Radius.circular(xl));
  static const BorderRadius borderFull = BorderRadius.all(Radius.circular(full));
}

class AppBreakpoints {
  AppBreakpoints._();

  static const double mobile = 700.0;
  static const double tablet = 1100.0;

  static bool isMobile(double width) => width < mobile;
  static bool isTablet(double width) => width >= mobile && width < tablet;
  static bool isDesktop(double width) => width >= tablet;
}