import 'package:get/get.dart';
import 'package:tms/modules/task/controllers/task_controller.dart';

class TaskBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<TaskController>(() => TaskController());
  }
}
