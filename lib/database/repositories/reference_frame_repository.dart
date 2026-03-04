// database/repositories/reference_frame_repository.dart
import 'package:sqflite/sqflite.dart';

class ReferenceFrameRepository {
  final DatabaseExecutor db; // ✅ allows Database OR Transaction
  ReferenceFrameRepository(this.db);

  Future<int> insertReferenceFrame({
    required int exerciseId,
    required int frameNumber,
    required double timestamp,
    required String poseJson,
  }) async {
    return db.insert('Exercise_Reference_Frames', {
      'Exercise_ID': exerciseId,
      'Frame_Number': frameNumber,
      'Timestamp': timestamp,
      'Pose_Json': poseJson,
    });
  }

  Future<List<Map<String, Object?>>> getReferenceFramesByExerciseId(int exerciseId) async {
    return db.query(
      'Exercise_Reference_Frames',
      where: 'Exercise_ID = ?',
      whereArgs: [exerciseId],
      orderBy: 'Frame_Number ASC',
    );
  }

  Future<int> deleteFramesByExerciseId(int exerciseId) async {
    return db.delete(
      'Exercise_Reference_Frames',
      where: 'Exercise_ID = ?',
      whereArgs: [exerciseId],
    );
  }
}