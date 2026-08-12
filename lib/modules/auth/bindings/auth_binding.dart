import 'package:get/get.dart';
import 'package:tms/core/network/api_client.dart';
import 'package:tms/core/services/storage_service.dart';
import 'package:tms/modules/auth/controller/login_controller.dart';
import 'package:tms/modules/auth/controller/register_controller.dart';

class AuthBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<RegisterController>(
      () => RegisterController(Get.find<ApiClient>()),
      fenix: true,
    );
    Get.lazyPut<LoginController>(
      () => LoginController(
        apiClient: Get.find<ApiClient>(),
        storage: Get.find<StorageService>(),
      ),
      fenix: true,
    );
  }
}
