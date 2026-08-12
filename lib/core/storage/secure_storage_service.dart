import '../services/storage_service.dart';
import 'package:get/get.dart';

class SecureStorageService {
  StorageService get _service => Get.find<StorageService>();

  Future<void> saveTokens(String accessToken, String refreshToken) =>
      _service.saveTokens(accessToken: accessToken, refreshToken: refreshToken);

  Future<String?> get accessToken => _service.accessToken;
  Future<String?> get refreshToken => _service.refreshToken;
  Future<void> clear() => _service.clearSession();
}

