// services/auth_service.dart
import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

import '../database/repositories/user_repository.dart';

class AuthService {
  final UserRepository _users;

  AuthService(this._users);

  /// Register a new user (business logic: validate + unique + hash)
  Future<int> register({
    required String userName,
    required String password,
  }) async {
    final name = userName.trim();
    if (name.isEmpty) {
      throw Exception('Username cannot be empty.');
    }
    if (password.length < 6) {
      throw Exception('Password must be at least 6 characters.');
    }

    final existing = await _users.getUserByUsername(name);
    if (existing != null) {
      throw Exception('Username already exists.');
    }

    final hashed = _hashPassword(password);
    return _users.createUser(userName: name, userPassword: hashed);
  }

  /// Login (business logic: verify password)
  Future<Map<String, Object?>> login({
    required String userName,
    required String password,
  }) async {
    final name = userName.trim();
    final user = await _users.getUserByUsername(name);
    if (user == null) {
      throw Exception('Invalid username or password.');
    }

    final stored = (user['User_Password'] as String?) ?? '';
    if (!_verifyPassword(password, stored)) {
      throw Exception('Invalid username or password.');
    }

    return user; // In real apps you’d return a JWT/token, but this is fine for MVP.
  }

  // --- Password hashing (simple salted SHA-256) ---
  // For production, switch to a strong password hash (bcrypt/argon2).
  String _hashPassword(String password) {
    final salt = _randomSalt();
    final digest = sha256.convert(utf8.encode('$salt:$password')).toString();
    return '$salt:$digest';
  }

  bool _verifyPassword(String password, String stored) {
    final parts = stored.split(':');
    if (parts.length != 2) return false;
    final salt = parts[0];
    final digest = parts[1];
    final attempt = sha256.convert(utf8.encode('$salt:$password')).toString();
    return attempt == digest;
  }

  String _randomSalt() {
    final r = Random.secure();
    final bytes = List<int>.generate(16, (_) => r.nextInt(256));
    return base64UrlEncode(bytes);
  }
}