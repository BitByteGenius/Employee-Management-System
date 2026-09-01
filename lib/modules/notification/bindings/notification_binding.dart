import 'package:get/get.dart';
import '../../../../core/network/api_client.dart';
import '../controllers/notification_controller.dart';
import '../services/notification_service.dart';

class NotificationBinding extends Bindings {
  @override
  void dependencies() {
    if (!Get.isRegistered<NotificationService>()) {
      Get.lazyPut<NotificationService>(
        () => NotificationService(Get.find<ApiClient>()),
        fenix: true,
      );
    }

    if (!Get.isRegistered<NotificationController>()) {
      Get.lazyPut<NotificationController>(
        () => NotificationController(Get.find<NotificationService>()),
        fenix: true,
      );
    }
  }
}
