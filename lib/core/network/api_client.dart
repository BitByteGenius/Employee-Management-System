import 'package:dio/dio.dart';
import '../constants/api_endpoints.dart';
import '../services/storage_service.dart';

class ApiClient {
  ApiClient(this._storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: {'Content-Type': 'application/json'},
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: (options, handler) async {
          final token = await _storage.accessToken;
          if (token != null && token.isNotEmpty) {
            options.headers['Authorization'] = 'Bearer $token';
          }
          handler.next(options);
        },
        onError: (DioException error, handler) async {
          if (error.response?.statusCode == 401 &&
              !error.requestOptions.path.contains('/auth/login') &&
              !error.requestOptions.path.contains('/auth/refresh-token')) {
            final refreshed = await _tryRefreshToken();
            if (refreshed) {
              final opts = error.requestOptions;
              final newToken = await _storage.accessToken;
              opts.headers['Authorization'] = 'Bearer $newToken';
              try {
                final response = await dio.fetch(opts);
                return handler.resolve(response);
              } catch (e) {
                return handler.next(error);
              }
            }
          }
          return handler.next(error);
        },
      ),
    );
  }

  final StorageService _storage;
  late final Dio dio;

  Future<bool> _tryRefreshToken() async {
    final rToken = await _storage.refreshToken;
    if (rToken == null || rToken.isEmpty) return false;
    try {
      final res = await Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl)).post(
        ApiEndpoints.refreshToken,
        data: {'refreshToken': rToken},
      );
      if (res.statusCode == 200 && res.data['success'] == true) {
        final data = res.data['data'];
        await _storage.saveTokens(
          accessToken: data['accessToken'],
          refreshToken: data['refreshToken'],
        );
        return true;
      }
    } catch (_) {
      await _storage.clearSession();
    }
    return false;
  }
}

