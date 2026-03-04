// database/repositories/session_repository.dart
import 'package:sqflite/sqflite.dart';

class SessionRepository {
  final DatabaseExecutor db; // ✅ allows Database OR Transaction
  SessionRepository(this.db);

  Future<int> createSession({
    required int userId,
    required int exerciseId,
  }) async {
    return db.insert('Sessions', {
      'User_ID': userId,
      'Exercise_ID': exerciseId,
    });
  }

  Future<Map<String, Object?>?> getSessionById(int sessionId) async {
    final rows = await db.query(
      'Sessions',
      where: 'Session_ID = ?',
      whereArgs: [sessionId],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, Object?>>> getSessionsByUser(int userId) async {
    return db.query(
      'Sessions',
      where: 'User_ID = ?',
      whereArgs: [userId],
      orderBy: 'Started_At DESC',
    );
  }

  Future<int> endSession({
    required int sessionId,
    String? summaryJson,
  }) async {
    return db.update(
      'Sessions',
      {
        'Ended_At': DateTime.now().toIso8601String(),
        'Summary_Json': summaryJson,
      },
      where: 'Session_ID = ?',
      whereArgs: [sessionId],
    );
  }

  Future<int> deleteSession(int sessionId) async {
    return db.delete('Sessions', where: 'Session_ID = ?', whereArgs: [sessionId]);
  }
}