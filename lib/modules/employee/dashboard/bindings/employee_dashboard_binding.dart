import 'package:get/get.dart';
import 'package:tms/modules/employee/dashboard/controllers/employee_dashboard_controller.dart';
import 'package:tms/modules/employee/task/controller/employee_task_controller.dart';

class EmployeeDashboardBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<EmployeeDashboardController>(() => EmployeeDashboardController());
    Get.lazyPut<EmployeeTaskController>(() => EmployeeTaskController());
  }
}
