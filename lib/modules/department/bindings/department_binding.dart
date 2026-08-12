import 'package:get/get.dart';
import 'package:tms/modules/department/controllers/department_controller.dart';

class DepartmentBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<DepartmentController>(() => DepartmentController());
  }
}
