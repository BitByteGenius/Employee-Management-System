import 'package:get/get.dart';

import 'package:tms/core/network/api_client.dart';
import 'package:tms/modules/department/controllers/department_controller.dart';
import 'package:tms/modules/department/repositories/department_repository.dart';
import 'package:tms/modules/department/services/department_service.dart';

class DepartmentBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<DepartmentService>()) {
      Get.lazyPut<DepartmentService>(
        () => DepartmentService(
          Get.find<ApiClient>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<DepartmentRepository>()) {
      Get.lazyPut<DepartmentRepository>(
        () => DepartmentRepository(
          Get.find<DepartmentService>(),
        ),
        fenix: true,
      );
    }

    if (!Get.isRegistered<DepartmentController>()) {
      Get.lazyPut<DepartmentController>(
        () => DepartmentController(
          Get.find<DepartmentRepository>(),
        ),
        fenix: true,
      );
    }
  }
}