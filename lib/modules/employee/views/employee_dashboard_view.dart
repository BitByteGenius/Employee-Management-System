import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_pages.dart';
import '../../../shared/drawer/app_navigation_shell.dart';
import '../../dashboard/views/dashboard_grid.dart';
import '../controllers/employee_dashboard_controller.dart';

class EmployeeDashboardView extends StatelessWidget {
  const EmployeeDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(EmployeeDashboardController());
    return AppNavigationShell(
      title: 'Employee',
      items: const [
        AppNavigationItem('Dashboard', Icons.dashboard_outlined, AppRoutes.employeeDashboard),
        AppNavigationItem('My Projects', Icons.work_outline, AppRoutes.projects),
        AppNavigationItem('My Tasks', Icons.task_alt_outlined, AppRoutes.tasks),
        AppNavigationItem('Notifications', Icons.notifications_outlined, AppRoutes.notifications),
        AppNavigationItem('Profile', Icons.person_outline, AppRoutes.profile),
      ],
      child: Obx(() => DashboardGrid(heading: 'Employee Dashboard', stats: controller.stats, chartTitle: 'My Productivity', values: controller.chartValues)),
    );
  }
}
