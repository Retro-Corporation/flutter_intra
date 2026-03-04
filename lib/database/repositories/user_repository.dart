// database/repositories/user_repository.dart
import 'package:sqflite/sqflite.dart';

class UserRepository {
  final DatabaseExecutor db; // ✅ allows Database OR Transaction
  UserRepository(this.db);

  Future<int> createUser({
    required String userName,
    required String userPassword,
  }) async {
    return db.insert('Users', {
      'User_Name': userName,
      'User_Password': userPassword,
    });
  }

  Future<Map<String, Object?>?> getUserById(int userId) async {
    final rows = await db.query(
      'Users',
      where: 'User_ID = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<Map<String, Object?>?> getUserByUsername(String userName) async {
    final rows = await db.query(
      'Users',
      where: 'User_Name = ?',
      whereArgs: [userName],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<int> deleteUser(int userId) async {
    return db.delete('Users', where: 'User_ID = ?', whereArgs: [userId]);
  }
}