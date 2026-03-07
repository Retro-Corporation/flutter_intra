import 'dart:convert';
import 'dart:math';
import 'package:crypto/crypto.dart';

import '../database/repositories/repository.dart';

class AuthService {
  final UserRepository _users;

  AuthService(this._users);

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

    final hashedPassword = _hashPassword(password);

    return _users.createUser(
      userName: name,
      userPassword: hashedPassword,
    );
  }

  Future<Map<String, Object?>> login({
    required String userName,
    required String password,
  }) async {
    final name = userName.trim();

    if (name.isEmpty || password.isEmpty) {
      throw Exception('Username and password are required.');
    }

    final user = await _users.getUserByUsername(name);
    if (user == null) {
      throw Exception('Invalid username or password.');
    }

    final storedPassword = (user['User_Password'] as String?) ?? '';
    final isValid = _verifyPassword(password, storedPassword);

    if (!isValid) {
      throw Exception('Invalid username or password.');
    }

    return user;
  }

  Future<Map<String, Object?>?> getUserById(int userId) async {
    return _users.getUserById(userId);
  }

  String _hashPassword(String password) {
    final salt = _randomSalt();
    final digest = sha256.convert(utf8.encode('$salt:$password')).toString();
    return '$salt:$digest';
  }

  bool _verifyPassword(String password, String storedValue) {
    final parts = storedValue.split(':');
    if (parts.length != 2) return false;

    final salt = parts[0];
    final savedDigest = parts[1];
    final newDigest = sha256.convert(utf8.encode('$salt:$password')).toString();

    return newDigest == savedDigest;
  }

  String _randomSalt() {
    final random = Random.secure();
    final bytes = List<int>.generate(16, (_) => random.nextInt(256));
    return base64UrlEncode(bytes);
  }
}