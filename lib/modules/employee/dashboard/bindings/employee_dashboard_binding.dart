import 'package:get/get.dart';
import 'package:tms/modules/employee/dashboard/controllers/employee_dashboard_controller.dart';
import 'package:tms/modules/employee/task/controller/employee_task_controller.dart';

class EmployeeDashboardBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<EmployeeDashboardController>()) {
      Get.lazyPut<EmployeeDashboardController>(
        () => EmployeeDashboardController(),
        fenix: true,
      );
    }
    if (!Get.isRegistered<EmployeeTaskController>()) {
      Get.lazyPut<EmployeeTaskController>(
        () => EmployeeTaskController(),
        fenix: true,
      );
    }
  }
}
