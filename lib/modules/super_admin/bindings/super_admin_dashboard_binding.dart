import 'package:get/get.dart';

import 'package:tms/modules/super_admin/controllers/access_control_controller.dart';
import 'package:tms/modules/super_admin/controllers/super_admin_dashboard_controller.dart';
import 'package:tms/modules/super_admin/controllers/super_admin_shell_controller.dart';

class SuperAdminDashboardBinding extends Bindings {
  @override
  void dependencies() {
    // ------------------------------------------------------------
    // Shell Controller
    // Handles:
    // - Current route
    // - Current index
    // - Sidebar navigation
    // ------------------------------------------------------------
    Get.lazyPut<SuperAdminShellController>(
      () => SuperAdminShellController(),
      fenix: true,
    );

    // ------------------------------------------------------------
    // Dashboard Controller
    // Handles dashboard data and dashboard actions
    // ------------------------------------------------------------
    Get.lazyPut<SuperAdminDashboardController>(
      () => SuperAdminDashboardController(),
      fenix: true,
    );

    // ------------------------------------------------------------
    // Access Control Controller
    // Handles pending users, approvals, tabs, pagination, etc.
    // ------------------------------------------------------------
    Get.lazyPut<AccessControlController>(
      () => AccessControlController(),
      fenix: true,
    );
  }
}