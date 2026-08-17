import 'package:get/get.dart';

import 'package:tms/core/network/api_client.dart';
import 'package:tms/modules/department/controllers/department_controller.dart';
import 'package:tms/modules/department/repositories/department_repository.dart';
import 'package:tms/modules/department/services/department_service.dart';
import 'package:tms/modules/super_admin/acces%20controll/controller/access_control_controller.dart';
import 'package:tms/modules/super_admin/dashboard/controllers/super_admin_dashboard_controller.dart';
import 'package:tms/modules/super_admin/dashboard/controllers/super_admin_shell_controller.dart';
import 'package:tms/modules/super_admin/projects/controller/project_controller.dart';
import 'package:tms/modules/super_admin/projects/repositories/project_repository.dart';
import 'package:tms/modules/super_admin/projects/services/deliverable_service.dart';
import 'package:tms/modules/super_admin/projects/services/project_service.dart';

class SuperAdminDashboardBinding extends Bindings {
  @override
  void dependencies() {
    // ------------------------------------------------------------
    // Shell Controller
    // ------------------------------------------------------------
    if (!Get.isRegistered<SuperAdminShellController>()) {
      Get.lazyPut<SuperAdminShellController>(
        () => SuperAdminShellController(),
        fenix: true,
      );
    }

    // ------------------------------------------------------------
    // Dashboard Controller
    // ------------------------------------------------------------
    if (!Get.isRegistered<SuperAdminDashboardController>()) {
      Get.lazyPut<SuperAdminDashboardController>(
        () => SuperAdminDashboardController(),
        fenix: true,
      );
    }

    // ------------------------------------------------------------
    // Access Control Controller
    // ------------------------------------------------------------
    if (!Get.isRegistered<AccessControlController>()) {
      Get.lazyPut<AccessControlController>(
        () => AccessControlController(),
        fenix: true,
      );
    }

    // ------------------------------------------------------------
    // Department dependencies
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
    // ------------------------------------------------------------
    if (!Get.isRegistered<DeliverableService>()) {
      Get.lazyPut<DeliverableService>(
        () => DeliverableService(Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ProjectService>()) {
      Get.lazyPut<ProjectService>(
        () => ProjectService(Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ProjectRepository>()) {
      Get.lazyPut<ProjectRepository>(
        () => ProjectRepository(Get.find<ProjectService>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<ProjectController>()) {
      Get.lazyPut<ProjectController>(
        () => ProjectController(
          repository: Get.find<ProjectRepository>(),
          deliverableService: Get.find<DeliverableService>(),
        ),
        fenix: true,
      );
    }
  }
}