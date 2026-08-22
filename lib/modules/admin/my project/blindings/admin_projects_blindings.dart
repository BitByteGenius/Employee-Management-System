import 'package:get/get.dart';
import 'package:tms/modules/admin/my%20project/controller/admin_project_controller.dart';

class AdminprojectBinding extends Bindings {
  @override
  void dependencies() {
   if (!Get.isRegistered<AdminProjectController>()) {
      Get.lazyPut<AdminProjectController>(
        () => AdminProjectController(),
        fenix: true,
      );
    }

  }
}
