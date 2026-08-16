import 'package:get/get.dart';
import 'package:tms/modules/super_admin/projects/controller/project_controller.dart';

class SuperAdminProjectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<ProjectController>(() => ProjectController());
  }
}