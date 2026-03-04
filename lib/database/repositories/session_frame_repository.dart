import 'package:sqflite/sqflite.dart';

class SessionFrameRepository {
  final DatabaseExecutor db; 
  SessionFrameRepository(this.db);

  Future<int> insertSessionFrame({
    required int sessionId,
    required int frameNumber,
    required double timestamp,
    required String poseJson,
    double? accuracy,
  }) async {
    return db.insert('Session_Frames', {
      'Session_ID': sessionId,
      'Frame_Number': frameNumber,
      'Timestamp': timestamp,
      'Pose_Json': poseJson,
      'Accuracy': accuracy,
    });
  }

  Future<List<Map<String, Object?>>> getSessionFramesBySessionId(int sessionId) async {
    return db.query(
      'Session_Frames',
      where: 'Session_ID = ?',
      whereArgs: [sessionId],
      orderBy: 'Frame_Number ASC',
    );
  }

  Future<int> deleteSessionFramesBySessionId(int sessionId) async {
    return db.delete(
      'Session_Frames',
      where: 'Session_ID = ?',
      whereArgs: [sessionId],
    );
  }
}