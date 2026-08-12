import 'package:flutter/material.dart';
import 'package:get/get.dart';
import '../../../core/routes/app_pages.dart';
import '../../../shared/drawer/app_navigation_shell.dart';
import '../../dashboard/views/dashboard_grid.dart';
import '../controllers/admin_dashboard_controller.dart';

class AdminDashboardView extends StatelessWidget {
  const AdminDashboardView({super.key});

  @override
  Widget build(BuildContext context) {
    final controller = Get.put(AdminDashboardController());
    return AppNavigationShell(
      title: 'Admin',
      items: const [
        AppNavigationItem('Dashboard', Icons.dashboard_outlined, AppRoutes.adminDashboard),
        AppNavigationItem('Departments', Icons.account_tree_outlined, AppRoutes.departments),
        AppNavigationItem('Projects', Icons.work_outline, AppRoutes.projects),
        AppNavigationItem('Tasks', Icons.task_alt_outlined, AppRoutes.tasks),
        AppNavigationItem('Reports', Icons.bar_chart_outlined, AppRoutes.reports),
      ],
      child: Obx(() => DashboardGrid(heading: 'Admin Dashboard', stats: controller.stats, chartTitle: 'Department Workload', values: controller.chartValues)),
    );
  }
}
