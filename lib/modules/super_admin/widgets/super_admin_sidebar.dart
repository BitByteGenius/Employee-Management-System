import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:tms/core/routes/app_pages.dart';
import 'package:tms/shared/widgets/app_sidebar.dart';

class SuperAdminSidebar extends StatelessWidget {
  const SuperAdminSidebar({
    super.key,
    required this.currentRoute,
  });

  final String currentRoute;

  @override
  Widget build(BuildContext context) {
    return AppSidebar(
      roleTitle: 'TeamOrbit',
      roleSubtitle: 'Super Admin',
      currentRoute: currentRoute,
      primaryActionText: 'New User',
      primaryActionIcon: Icons.add_circle_outline,
      onPrimaryActionTap: () {
        Get.snackbar(
          'User Management',
          'Create new admin or user modal',
          snackPosition: SnackPosition.TOP,
        );
      },
      navItems: const [
        AppNavItem(
          label: 'Dashboard',
          icon: Icons.dashboard_outlined,
          route: AppRoutes.superAdminDashboard,
        ),
        AppNavItem(
          label: 'Organization',
          icon: Icons.corporate_fare_outlined,
          route: AppRoutes.departments,
        ),
        AppNavItem(
          label: 'Access Control',
          icon: Icons.admin_panel_settings_outlined,
          route: AppRoutes.accessControl,
        ),
        AppNavItem(
          label: 'Work Management',
          icon: Icons.work_outline,
          route: AppRoutes.projects,
        ),
        AppNavItem(
          label: 'Communication',
          icon: Icons.forum_outlined,
          route: AppRoutes.notifications,
        ),
        AppNavItem(
          label: 'Analytics',
          icon: Icons.analytics_outlined,
          route: AppRoutes.reports,
        ),
        AppNavItem(
          label: 'System',
          icon: Icons.settings_system_daydream_outlined,
          route: AppRoutes.superAdminDashboard,
        ),
      ],
    );
  }
}
