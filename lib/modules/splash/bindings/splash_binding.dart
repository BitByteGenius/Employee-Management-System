import 'package:get/get.dart';
import 'package:tms/core/services/storage_service.dart';
import 'package:tms/modules/splash/controllers/splash_controller.dart';

class SplashBinding extends Bindings {
  @override
  void dependencies() {
    Get.lazyPut<SplashController>(
      () => SplashController(
        Get.find<StorageService>(),
      ),
    );
  }
}
