import 'package:get/get.dart';
import 'package:tms/core/routes/app_pages.dart';
import 'package:tms/core/services/storage_service.dart';

class SplashController extends GetxController {
  SplashController(this._storage);

  final StorageService _storage;

  @override
  void onInit() {
    super.onInit();
    _bootstrap();
  }

  Future<void> _bootstrap() async {
    try {
      // Keep the splash visible briefly so startup never flashes between routes.
      await Future<void>.delayed(const Duration(milliseconds: 350));
      final token = await _storage.getAccessToken();
      final user = _storage.getUser();

      if (token == null || user == null) {
        Get.offAllNamed(AppRoutes.login);
        return;
      }

      Get.offAllNamed(AppRoutes.dashboardForRole(user['role']?.toString() ?? ''));
    } catch (_) {
      // A corrupt/expired local session must never trap the user on splash.
      Get.offAllNamed(AppRoutes.login);
    }
  }
}
