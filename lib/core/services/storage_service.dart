import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import 'package:get/get.dart';
import 'package:get_storage/get_storage.dart';

/// Central storage service for secure token storage and app preferences.
class StorageService extends GetxService {
  final _secureStorage = const FlutterSecureStorage();
  final _box = GetStorage();

  static const _accessTokenKey = 'access_token';
  static const _refreshTokenKey = 'refresh_token';
  static const _userDataKey = 'user_data';
  static const _themeModeKey = 'theme_mode';

  Future<void> saveTokens({
    required String accessToken,
    required String refreshToken,
  }) async {
    try {
      await _secureStorage.write(key: _accessTokenKey, value: accessToken);
      await _secureStorage.write(key: _refreshTokenKey, value: refreshToken);
    } catch (e) {
      debugPrint('[StorageService] Secure storage write error: $e');
    }
    await _box.write(_accessTokenKey, accessToken);
    await _box.write(_refreshTokenKey, refreshToken);
  }

  Future<String?> get accessToken async {
    try {
      final secure = await _secureStorage.read(key: _accessTokenKey);
      if (secure != null && secure.isNotEmpty) return secure;
    } catch (_) {}
    final boxToken = _box.read<String>(_accessTokenKey);
    return (boxToken != null && boxToken.isNotEmpty) ? boxToken : null;
  }

  Future<String?> get refreshToken async {
    try {
      final secure = await _secureStorage.read(key: _refreshTokenKey);
      if (secure != null && secure.isNotEmpty) return secure;
    } catch (_) {}
    final boxToken = _box.read<String>(_refreshTokenKey);
    return (boxToken != null && boxToken.isNotEmpty) ? boxToken : null;
  }

  Future<String?> getAccessToken() async => await accessToken;
  Future<String?> getRefreshToken() async => await refreshToken;

  Future<void> saveUser(Map<String, dynamic> userData) async {
    await _box.write(_userDataKey, jsonEncode(userData));
  }

  Map<String, dynamic>? getUser() {
    final raw = _box.read<String>(_userDataKey);
    if (raw == null || raw.isEmpty) return null;
    try {
      return jsonDecode(raw) as Map<String, dynamic>;
    } catch (_) {
      return null;
    }
  }

  String getThemeMode() => _box.read<String>(_themeModeKey) ?? 'system';
  Future<void> saveThemeMode(String mode) async => await _box.write(_themeModeKey, mode);

  Future<void> clearSession() async {
    try {
      await _secureStorage.delete(key: _accessTokenKey);
      await _secureStorage.delete(key: _refreshTokenKey);
    } catch (_) {}
    await _box.remove(_accessTokenKey);
    await _box.remove(_refreshTokenKey);
    await _box.remove(_userDataKey);
  }

  Future<void> clearTokens() => clearSession();
}
