import 'package:sqflite/sqflite.dart';

class ExerciseRepository {
  final DatabaseExecutor db; 
  ExerciseRepository(this.db);

  Future<int> createExercise({
    required int creatorUserId,
    required String exerciseName,
    String? description,
    String? validationRules,
  }) async {
    return db.insert('Exercises', {
      'Creator_User_ID': creatorUserId,
      'Exercise_Name': exerciseName,
      'Description': description,
      'Validation_Rules': validationRules,
    });
  }

  Future<Map<String, Object?>?> getExerciseById(int exerciseId) async {
    final rows = await db.query(
      'Exercises',
      where: 'Exercise_ID = ?',
      whereArgs: [exerciseId],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, Object?>>> getExercisesByUser(int userId) async {
    return db.query(
      'Exercises',
      where: 'Creator_User_ID = ?',
      whereArgs: [userId],
      orderBy: 'Created_At DESC',
    );
  }

  Future<int> deleteExercise(int exerciseId) async {
    // Reference frames will be auto-deleted because of ON DELETE CASCADE
    // Basically occurs when you want to delete if the excerise itself doesn't exist
    return db.delete('Exercises', where: 'Exercise_ID = ?', whereArgs: [exerciseId]);
  }
}