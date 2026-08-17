import 'package:get/get.dart';

import 'package:tms/core/network/api_client.dart';
import 'package:tms/modules/department/controllers/department_controller.dart';
import 'package:tms/modules/department/repositories/department_repository.dart';
import 'package:tms/modules/department/services/department_service.dart';
import 'package:tms/modules/super_admin/acces%20controll/controller/access_control_controller.dart';
import 'package:tms/modules/super_admin/dashboard/controllers/super_admin_dashboard_controller.dart';
import 'package:tms/modules/super_admin/dashboard/controllers/super_admin_shell_controller.dart';
import 'package:tms/modules/super_admin/projects/controller/project_controller.dart';
import 'package:tms/modules/super_admin/projects/services/deliverable_service.dart';

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

    // ------------------------------------------------------------
    // Department dependencies
    // Required because SuperAdminShellView renders DepartmentView
    // in an IndexedStack, which is built eagerly for all routes.
    // ------------------------------------------------------------
    if (!Get.isRegistered<DepartmentService>()) {
      Get.lazyPut<DepartmentService>(
        () => DepartmentService(Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<DepartmentRepository>()) {
      Get.lazyPut<DepartmentRepository>(
        () => DepartmentRepository(Get.find<DepartmentService>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<DepartmentController>()) {
      Get.lazyPut<DepartmentController>(
        () => DepartmentController(Get.find<DepartmentRepository>()),
        fenix: true,
      );
    }

    // ------------------------------------------------------------
    // Project dependencies
    // Required because SuperAdminShellView renders
    // ProjectsOverviewScreen (GetView<ProjectController>) in an
    // IndexedStack, which is built eagerly for all routes.
    // DeliverableService must be registered before ProjectController
    // because ProjectController resolves it at field-initializer time.
    // ------------------------------------------------------------
    if (!Get.isRegistered<DeliverableService>()) {
      Get.lazyPut<DeliverableService>(
        () => DeliverableService(Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ProjectController>()) {
      Get.lazyPut<ProjectController>(
        () => ProjectController(),
        fenix: true,
      );
    }
  }
}