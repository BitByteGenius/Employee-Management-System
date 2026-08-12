import 'package:get/get.dart';
import '../network/api_client.dart';
import '../services/storage_service.dart';
import '../storage/secure_storage_service.dart';
import '../theme/theme_controller.dart';

class InitialBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<StorageService>()) {
      Get.put(StorageService(), permanent: true);
    }
    if (!Get.isRegistered<ThemeController>()) {
      Get.put(ThemeController(), permanent: true);
    }
    if (!Get.isRegistered<SecureStorageService>()) {
      Get.put(SecureStorageService(), permanent: true);
    }
    if (!Get.isRegistered<ApiClient>()) {
      Get.put(ApiClient(Get.find<StorageService>()), permanent: true);
    }
  }
}
