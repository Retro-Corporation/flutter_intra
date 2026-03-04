import 'package:sqflite/sqflite.dart';

class SessionPerformanceMetricsRepository {
  final DatabaseExecutor db;
  SessionPerformanceMetricsRepository(this.db);

  Future<int> insertMetrics({
    required int sessionId,
    required String pipelineVersion,
    required int framesReceived,
    required int framesScored,
    required int framesMissingReference,
    double? avgAccuracy,
    double? avgFramePipelineMs,
    double? p95FramePipelineMs,
    double? avgDbInsertMs,
    double? p95DbInsertMs,
    double? avgAccuracyComputeMs,
    double? p95AccuracyComputeMs,
  }) {
    return db.insert('Session_Performance_Metrics', {
      'Session_ID': sessionId,
      'Pipeline_Version': pipelineVersion,

      'Frames_Received': framesReceived,
      'Frames_Scored': framesScored,
      'Frames_Missing_Reference': framesMissingReference,

      'Avg_Accuracy': avgAccuracy,

      'Avg_Frame_Pipeline_Ms': avgFramePipelineMs,
      'P95_Frame_Pipeline_Ms': p95FramePipelineMs,

      'Avg_Db_Session_Frame_Insert_Ms': avgDbInsertMs,
      'P95_Db_Session_Frame_Insert_Ms': p95DbInsertMs,

      'Avg_Accuracy_Compute_Ms': avgAccuracyComputeMs,
      'P95_Accuracy_Compute_Ms': p95AccuracyComputeMs,
    });
  }

  Future<List<Map<String, Object?>>> getBySessionId(int sessionId) {
    return db.query(
      'Session_Performance_Metrics',
      where: 'Session_ID = ?',
      whereArgs: [sessionId],
      orderBy: 'Created_At DESC',
    );
  }
}