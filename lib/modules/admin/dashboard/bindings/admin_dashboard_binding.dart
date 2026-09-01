import 'package:get/get.dart';
import 'package:tms/modules/admin/my%20project/controller/admin_project_controller.dart';
import '../controllers/admin_dashboard_controller.dart';
import '../controllers/admin_shell_controller.dart';

class AdminDashboardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<AdminShellController>()) {
      Get.lazyPut<AdminShellController>(
        () => AdminShellController(),
        fenix: true,
      );
    }

    if (!Get.isRegistered<AdminDashboardController>()) {
      Get.lazyPut<AdminDashboardController>(
        () => AdminDashboardController(),
        fenix: true,
      );
    }

    if (!Get.isRegistered<AdminProjectController>()) {
      Get.lazyPut<AdminProjectController>(
        () => AdminProjectController(),
        fenix: true,
      );
    }
  }
}
