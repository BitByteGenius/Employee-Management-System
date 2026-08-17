import 'package:get/get.dart';
import 'package:tms/core/network/api_client.dart';
import 'package:tms/modules/super_admin/projects/controller/project_controller.dart';
import 'package:tms/modules/super_admin/projects/services/deliverable_service.dart';

class SuperAdminProjectBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DeliverableService>(
      () => DeliverableService(Get.find<ApiClient>()),
    );

    Get.lazyPut<ProjectController>(() => ProjectController());
  }
}
