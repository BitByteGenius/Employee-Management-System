import 'package:get/get.dart';
import 'package:tms/modules/super_admin/acces%20controll/controller/access_control_controller.dart';

class AccessControlBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<AccessControlController>(
      () => AccessControlController(),
    );
  }
}
