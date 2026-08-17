// import 'package:dio/dio.dart';
// import '../constants/api_endpoints.dart';
// import '../services/storage_service.dart';

// class ApiClient {
//   ApiClient(this._storage) {
//     dio = Dio(
//       BaseOptions(
//         baseUrl: ApiEndpoints.baseUrl,
//         connectTimeout: const Duration(seconds: 20),
//         receiveTimeout: const Duration(seconds: 20),
//         headers: {'Content-Type': 'application/json'},
//       ),
//     );

//     dio.interceptors.add(
//       InterceptorsWrapper(
//         onRequest: (options, handler) async {
//           final token = await _storage.accessToken;
//           if (token != null && token.isNotEmpty) {
//             options.headers['Authorization'] = 'Bearer $token';
//           }
//           handler.next(options);
//         },
//         onError: (DioException error, handler) async {
//           if (error.response?.statusCode == 401 &&
//               !error.requestOptions.path.contains('/auth/login') &&
//               !error.requestOptions.path.contains('/auth/refresh-token')) {
//             final refreshed = await _tryRefreshToken();
//             if (refreshed) {
//               final opts = error.requestOptions;
//               final newToken = await _storage.accessToken;
//               opts.headers['Authorization'] = 'Bearer $newToken';
//               try {
//                 final response = await dio.fetch(opts);
//                 return handler.resolve(response);
//               } catch (e) {
//                 return handler.next(error);
//               }
//             }
//           }
//           return handler.next(error);
//         },
//       ),
//     );
//   }

//   final StorageService _storage;
//   late final Dio dio;

//   Future<bool> _tryRefreshToken() async {
//     final rToken = await _storage.refreshToken;
//     if (rToken == null || rToken.isEmpty) return false;
//     try {
//       final res = await Dio(BaseOptions(baseUrl: ApiEndpoints.baseUrl)).post(
//         ApiEndpoints.refreshToken,
//         data: {'refreshToken': rToken},
//       );
//       if (res.statusCode == 200 && res.data['success'] == true) {
//         final data = res.data['data'];
//         await _storage.saveTokens(
//           accessToken: data['accessToken'],
//           refreshToken: data['refreshToken'],
//         );
//         return true;
//       }
//     } catch (_) {
//       await _storage.clearSession();
//     }
//     return false;
//   }
// }

import 'package:dio/dio.dart';

import '../constants/api_endpoints.dart';
import '../services/storage_service.dart';

class ApiClient {
  ApiClient(this._storage) {
    dio = Dio(
      BaseOptions(
        baseUrl: ApiEndpoints.baseUrl,
        connectTimeout: const Duration(seconds: 20),
        sendTimeout: const Duration(seconds: 20),
        receiveTimeout: const Duration(seconds: 20),
        headers: const {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
      ),
    );

    dio.interceptors.add(
      InterceptorsWrapper(
        onRequest: _onRequest,
        onError: _onError,
      ),
    );
  }

  final StorageService _storage;

  late final Dio dio;

  bool _isRefreshing = false;
  Future<bool>? _refreshFuture;

  // ============================================================
  // REQUEST
  // ============================================================

  Future<void> _onRequest(
    RequestOptions options,
    RequestInterceptorHandler handler,
  ) async {
    try {
      final token = await _storage.accessToken;

      if (token != null && token.isNotEmpty) {
        options.headers['Authorization'] = 'Bearer $token';
      }

      handler.next(options);
    } catch (e) {
      handler.next(options);
    }
  }

  // ============================================================
  // ERROR
  // ============================================================

  Future<void> _onError(
    DioException error,
    ErrorInterceptorHandler handler,
  ) async {
    final statusCode = error.response?.statusCode;
    final request = error.requestOptions;

    final isUnauthorized = statusCode == 401;

    final isAuthRequest =
        request.path.contains('/auth/login') ||
        request.path.contains('/auth/register') ||
        request.path.contains('/auth/refresh-token');

    final alreadyRetried = request.extra['retried'] == true;

    if (!isUnauthorized || isAuthRequest || alreadyRetried) {
      handler.next(error);
      return;
    }

    try {
      final refreshed = await _refreshAccessToken();

      if (!refreshed) {
        await _storage.clearSession();
        handler.next(error);
        return;
      }

      final newToken = await _storage.accessToken;

      if (newToken == null || newToken.isEmpty) {
        await _storage.clearSession();
        handler.next(error);
        return;
      }

      final retryOptions = request.copyWith(
        headers: {
          ...request.headers,
          'Authorization': 'Bearer $newToken',
        },
        extra: {
          ...request.extra,
          'retried': true,
        },
      );

      final response = await dio.fetch<dynamic>(retryOptions);

      handler.resolve(response);
    } on DioException catch (_) {
      handler.next(error);
    } catch (_) {
      handler.next(error);
    }
  }

  // ============================================================
  // REFRESH TOKEN
  // ============================================================

  Future<bool> _refreshAccessToken() async {
    if (_isRefreshing && _refreshFuture != null) {
      return _refreshFuture!;
    }

    _isRefreshing = true;

    final future = _performRefreshToken();

    _refreshFuture = future;

    try {
      return await future;
    } finally {
      _isRefreshing = false;
      _refreshFuture = null;
    }
  }

  Future<bool> _performRefreshToken() async {
    final refreshToken = await _storage.refreshToken;

    if (refreshToken == null || refreshToken.isEmpty) {
      return false;
    }

    try {
      final refreshDio = Dio(
        BaseOptions(
          baseUrl: ApiEndpoints.baseUrl,
          connectTimeout: const Duration(seconds: 15),
          sendTimeout: const Duration(seconds: 15),
          receiveTimeout: const Duration(seconds: 15),
          headers: const {
            'Content-Type': 'application/json',
            'Accept': 'application/json',
          },
        ),
      );

      final response = await refreshDio.post(
        ApiEndpoints.refreshToken,
        data: {
          'refreshToken': refreshToken,
        },
      );

      if (response.statusCode != 200) {
        return false;
      }

      final body = response.data;

      if (body is! Map<String, dynamic>) {
        return false;
      }

      if (body['success'] != true) {
        return false;
      }

      final data = body['data'];

      if (data is! Map<String, dynamic>) {
        return false;
      }

      final accessToken = data['accessToken']?.toString();
      final newRefreshToken = data['refreshToken']?.toString();

      if (accessToken == null || accessToken.isEmpty) {
        return false;
      }

      await _storage.saveTokens(
  accessToken: accessToken,
  refreshToken: (newRefreshToken?.isNotEmpty == true)
      ? newRefreshToken!
      : refreshToken,
);

      return true;
    } on DioException {
      await _storage.clearSession();
      return false;
    } catch (_) {
      await _storage.clearSession();
      return false;
    }
  }

  // ============================================================
  // GET
  // ============================================================

  Future<Response<T>> get<T>(
    String path, {
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.get<T>(
      path,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // ============================================================
  // POST
  // ============================================================

  Future<Response<T>> post<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.post<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // ============================================================
  // PUT
  // ============================================================

  Future<Response<T>> put<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.put<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // ============================================================
  // PATCH
  // ============================================================

  Future<Response<T>> patch<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.patch<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }

  // ============================================================
  // DELETE
  // ============================================================

  Future<Response<T>> delete<T>(
    String path, {
    dynamic data,
    Map<String, dynamic>? queryParameters,
    Options? options,
  }) {
    return dio.delete<T>(
      path,
      data: data,
      queryParameters: queryParameters,
      options: options,
    );
  }
}