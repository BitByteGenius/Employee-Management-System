import 'package:get/get.dart';
import 'package:tms/modules/super_admin/controllers/access_control_controller.dart';

class AccessControlBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccessControlController>(() => AccessControlController());
  }
}
