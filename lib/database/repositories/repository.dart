import 'package:sqflite/sqflite.dart';


/// TABLE NAME CONSTANTS
/// Keep these consistent with schema.dart

class DbTables {
  static const String users = 'User';
  static const String exercises = 'Exercise';
  static const String systemMetrics = 'System_Metrics';
}


// USER REPOSITORY
// Handles all database operations for User

class UserRepository {
  final DatabaseExecutor db;

  UserRepository(this.db);

  Future<int> createUser({
    required String userName,
    required String userPassword,
  }) async {
    return db.insert(DbTables.users, {
      'User_Name': userName,
      'User_Password': userPassword,
    });
  }

  Future<Map<String, Object?>?> getUserById(int userId) async {
    final rows = await db.query(
      DbTables.users,
      where: 'User_id = ?',
      whereArgs: [userId],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<Map<String, Object?>?> getUserByUsername(String userName) async {
    final rows = await db.query(
      DbTables.users,
      where: 'User_Name = ?',
      whereArgs: [userName],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, Object?>>> getAllUsers() async {
    return db.query(
      DbTables.users,
      orderBy: 'User_id ASC',
    );
  }

  Future<int> deleteUser(int userId) async {
    return db.delete(
      DbTables.users,
      where: 'User_id = ?',
      whereArgs: [userId],
    );
  }
}

// EXERCISE REPOSITORY
// Handles all database operations for Exercise
class ExerciseRepository {
  final DatabaseExecutor db;

  ExerciseRepository(this.db);

  Future<int> createExercise({
    required String exerciseName,
    String? description,
    required String referencePoseJson,
    String? createdAt,
  }) async {
    return db.insert(DbTables.exercises, {
      'Exercise_Name': exerciseName,
      'Description': description,
      'Reference_Pose_Json': referencePoseJson,
      'Created_AT': createdAt ?? DateTime.now().toIso8601String(),
    });
  }

  Future<Map<String, Object?>?> getExerciseById(int exerciseId) async {
    final rows = await db.query(
      DbTables.exercises,
      where: 'Exercise_id = ?',
      whereArgs: [exerciseId],
      limit: 1,
    );
    return rows.isEmpty ? null : rows.first;
  }

  Future<List<Map<String, Object?>>> getAllExercises() async {
    return db.query(
      DbTables.exercises,
      orderBy: 'Created_AT DESC',
    );
  }

  Future<int> updateExercise({
    required int exerciseId,
    required String exerciseName,
    String? description,
    required String referencePoseJson,
  }) async {
    return db.update(
      DbTables.exercises,
      {
        'Exercise_Name': exerciseName,
        'Description': description,
        'Reference_Pose_Json': referencePoseJson,
      },
      where: 'Exercise_id = ?',
      whereArgs: [exerciseId],
    );
  }

  Future<int> deleteExercise(int exerciseId) async {
    return db.delete(
      DbTables.exercises,
      where: 'Exercise_id = ?',
      whereArgs: [exerciseId],
    );
  }
}

// SYSTEM METRICS REPOSITORY
// Handles all database operations for System_Metrics
class SystemMetricsRepository {
  final DatabaseExecutor db;

  SystemMetricsRepository(this.db);

  Future<int> insertMetric({
    required String endpoint,
    required double latencyMs,
    required double processingTimeMs,
    required String status,
    String? timeStamp,
  }) async {
    return db.insert(DbTables.systemMetrics, {
      'Endpoint': endpoint,
      'Latency_Ms': latencyMs,
      'Processing_Time_Ms': processingTimeMs,
      'Status': status,
      'TimeStamp': timeStamp ?? DateTime.now().toIso8601String(),
    });
  }

  Future<List<Map<String, Object?>>> getAllMetrics() async {
    return db.query(
      DbTables.systemMetrics,
      orderBy: 'TimeStamp DESC',
    );
  }

  Future<List<Map<String, Object?>>> getMetricsByEndpoint(String endpoint) async {
    return db.query(
      DbTables.systemMetrics,
      where: 'Endpoint = ?',
      whereArgs: [endpoint],
      orderBy: 'TimeStamp DESC',
    );
  }

  Future<int> deleteAllMetrics() async {
    return db.delete(DbTables.systemMetrics);
  }
}