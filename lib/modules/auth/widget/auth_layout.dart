import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/constants/app_colors.dart';
import '../../../core/theme/theme_controller.dart';
import 'auth_branding.dart';

class AuthLayout extends StatelessWidget {
  const AuthLayout({
    super.key,
    required this.child,
  });

  final Widget child;

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final width = MediaQuery.sizeOf(context).width;
    final isDesktop = width >= 950;

    return Scaffold(
      backgroundColor: isDark ? AppColors.darkBackground : AppColors.background,
      body: Stack(
        children: [
          // Background ambient light pattern for light/dark mode
          Positioned(
            top: 0,
            right: 0,
            child: Container(
              width: 500,
              height: 500,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                gradient: RadialGradient(
                  colors: [
                    AppColors.secondary.withValues(alpha: isDark ? 0.08 : 0.03),
                    Colors.transparent,
                  ],
                ),
              ),
            ),
          ),

          // Main Layout
          isDesktop ? _buildDesktopLayout(context) : _buildMobileLayout(context),

          // Theme Toggle Button (Top-Right)
          Positioned(
            top: 20,
            right: 24,
            child: _buildThemeToggle(context, isDark),
          ),
        ],
      ),
    );
  }

  Widget _buildDesktopLayout(BuildContext context) {
    return Row(
      children: [
        // Left Branding Panel (45% width)
        const Expanded(
          flex: 45,
          child: AuthBranding(),
        ),

        // Right Form Area (55% width)
        Expanded(
          flex: 55,
          child: Center(
            child: SingleChildScrollView(
              padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 48),
              child: child,
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildMobileLayout(BuildContext context) {
    return SafeArea(
      child: LayoutBuilder(
        builder: (context, constraints) {
          return SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 32),
            child: ConstrainedBox(
              constraints: BoxConstraints(minHeight: constraints.maxHeight - 64),
              child: IntrinsicHeight(
                child: Center(
                  child: child,
                ),
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildThemeToggle(BuildContext context, bool isDark) {
    if (!Get.isRegistered<ThemeController>()) {
      Get.put(ThemeController());
    }
    final themeCtrl = Get.find<ThemeController>();

    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: () {
          themeCtrl.changeTheme(isDark ? ThemeMode.light : ThemeMode.dark);
        },
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.all(10),
          decoration: BoxDecoration(
            color: isDark
                ? Colors.white.withValues(alpha: 0.08)
                : Colors.black.withValues(alpha: 0.04),
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: isDark
                  ? Colors.white.withValues(alpha: 0.12)
                  : Colors.black.withValues(alpha: 0.08),
            ),
          ),
          child: Icon(
            isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            size: 20,
            color: isDark ? const Color(0xFFFBBF24) : AppColors.primary,
          ),
        ),
      ),
    );
  }
}
