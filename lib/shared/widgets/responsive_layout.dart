import 'package:flutter/material.dart';

class ResponsiveLayout extends StatelessWidget {
  const ResponsiveLayout({super.key, required this.mobile, required this.tablet, required this.desktop});

  final Widget mobile;
  final Widget tablet;
  final Widget desktop;

  static bool isDesktop(BuildContext context) => MediaQuery.sizeOf(context).width >= 1100;
  static bool isTablet(BuildContext context) {
    final width = MediaQuery.sizeOf(context).width;
    return width >= 700 && width < 1100;
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(builder: (_, constraints) {
      if (constraints.maxWidth >= 1100) return desktop;
      if (constraints.maxWidth >= 700) return tablet;
      return mobile;
    });
  }
}
