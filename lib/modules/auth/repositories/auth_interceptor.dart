import 'package:dio/dio.dart';
import 'package:get/get.dart';
import 'package:tms/core/routes/app_pages.dart';
import 'package:tms/core/services/storage_service.dart';
import 'package:tms/modules/auth/services/auth_session_manager.dart';

class AuthInterceptor extends Interceptor {
  AuthInterceptor(this._sessionManager, this._storage);

  final AuthSessionManager _sessionManager;
  final StorageService _storage;

  @override
  Future<void> onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    final token = await _storage.accessToken;
    if (token != null && token.isNotEmpty) {
      options.headers['Authorization'] = 'Bearer $token';
    }
    handler.next(options);
  }

  @override
  Future<void> onError(
    DioException err,
    ErrorInterceptorHandler handler,
  ) async {
    if (err.response?.statusCode != 401) {
      return handler.next(err);
    }

    final tokens = await _sessionManager.refreshSession();
    if (tokens == null) {
      await _storage.clearSession();
      Get.offAllNamed(AppRoutes.login);
      return handler.next(err);
    }

    final request = err.requestOptions;
    request.headers['Authorization'] = 'Bearer ${tokens.accessToken}';
    final dio = Get.find<Dio>();
    handler.resolve(await dio.fetch(request));
  }
}
