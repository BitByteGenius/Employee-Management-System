import '../models/auth_tokens.dart';
import '../repositories/auth_repository.dart';

class AuthSessionManager {
  AuthSessionManager(this._repository);

  final AuthRepository _repository;

  bool _isRefreshing = false;

  Future<AuthTokens?> refreshSession() async {
    if (_isRefreshing) return null;

    _isRefreshing = true;

    try {
      return await _repository.refreshToken();
    } finally {
      _isRefreshing = false;
    }
  }
}