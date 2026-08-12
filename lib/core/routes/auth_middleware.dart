import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'app_pages.dart';

class AuthMiddleware extends GetMiddleware {
  @override
  Future<GetNavConfig?> redirectDelegate(GetNavConfig route) async {
    const storage = FlutterSecureStorage();
    final token = await storage.read(key: 'access_token');
    if (token == null && route.uri.path != AppRoutes.login) {
      return GetNavConfig.fromRoute(AppRoutes.login);
    }
    return null;
  }
}

class PermissionMiddleware extends GetMiddleware {
  PermissionMiddleware(this.permission);
  final String permission;
}
