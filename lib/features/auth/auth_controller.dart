import 'auth_service.dart';

class AuthController {
  final AuthService _auth;

  AuthController(this._auth);

  Object? _currentUser;

  bool get isLoggedIn => _currentUser != null;

  /// POST /auth/register
  /// Input: username, password
  /// Output: { success, userId }
  Future<Map<String, Object?>> register({
    required String username,
    required String password,
  }) async {
    try {
      final userId = await _auth.register(userName: username, password: password);
      return {
        'success': true,
        'userId': userId,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// POST /auth/login
  /// Input: username, password
  /// Output: { success, user }
  Future<Map<String, Object?>> login({
    required String username,
    required String password,
  }) async {
    try {
      final user = await _auth.login(userName: username, password: password);
      _currentUser = user;
      return {
        'success': true,
        'user': user,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Clears the session
  void logout() {
    _currentUser = null;
  }
}