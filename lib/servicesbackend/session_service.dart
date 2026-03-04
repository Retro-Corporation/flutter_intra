// servicesbackend/session_service.dart
import 'dart:convert';
import 'dart:math';

import '../database/repositories/exercise_repository.dart';
import '../database/repositories/reference_frame_repository.dart';
import '../database/repositories/session_repository.dart';
import '../database/repositories/session_frame_repository.dart';
import '../database/repositories/session_performance_metrics_repository.dart';
import '../utils/metrics_tracker.dart';

class SessionService {
  final ExerciseRepository _exercises;
  final ReferenceFrameRepository _refFrames;
  final SessionRepository _sessions;
  final SessionFrameRepository _sessionFrames;

  // ✅ NEW: persisted metrics repo (1 row per session)
  final SessionPerformanceMetricsRepository _metricsRepo;

  // ✅ NEW: version string to compare optimizations across runs
  final String _pipelineVersion;

  SessionService(
    this._exercises,
    this._refFrames,
    this._sessions,
    this._sessionFrames,
    this._metricsRepo, {
    String pipelineVersion = 'v1_baseline',
  }) : _pipelineVersion = pipelineVersion;

  /// Start session (ensure exercise exists)
  Future<int> startSession({
    required int userId,
    required int exerciseId,
  }) async {
    final totalStart = DateTime.now();
    MetricsTracker.instance.increment('session_start_attempts');

    final exLookupStart = DateTime.now();
    final ex = await _exercises.getExerciseById(exerciseId);
    MetricsTracker.instance.recordLatency(
      'db_exercise_lookup_by_id',
      DateTime.now().difference(exLookupStart).inMilliseconds,
    );

    if (ex == null) {
      MetricsTracker.instance.increment('session_start_fail_exercise_not_found');
      throw Exception('Exercise not found.');
    }

    final createStart = DateTime.now();
    final sessionId = await _sessions.createSession(userId: userId, exerciseId: exerciseId);
    MetricsTracker.instance.recordLatency(
      'db_session_create',
      DateTime.now().difference(createStart).inMilliseconds,
    );

    MetricsTracker.instance.increment('session_start_success');
    MetricsTracker.instance.recordLatency(
      'session_start_total_time',
      DateTime.now().difference(totalStart).inMilliseconds,
    );

    return sessionId;
  }

  /// Process a live frame: compare to reference frame, store accuracy + pose JSON
  Future<double?> addLiveFrameAndScore({
    required int sessionId,
    required int exerciseId,
    required int frameNumber,
    required double timestamp,
    required String poseJson,
  }) async {
    final pipelineStart = DateTime.now();
    MetricsTracker.instance.increment('session_frames_received');

    // Fetch reference frames (MVP: once per call)
    final refFetchStart = DateTime.now();
    final refs = await _refFrames.getReferenceFramesByExerciseId(exerciseId);
    MetricsTracker.instance.recordLatency(
      'db_reference_frames_fetch_by_exercise',
      DateTime.now().difference(refFetchStart).inMilliseconds,
    );

    final refForFrame = refs.firstWhere(
      (r) => (r['Frame_Number'] as int?) == frameNumber,
      orElse: () => <String, Object?>{},
    );

    double? accuracy;

    // Accuracy compute timing
    final accuracyStart = DateTime.now();
    if (refForFrame.isNotEmpty) {
      final refPose = refForFrame['Pose_Json'] as String? ?? '';
      accuracy = _computePoseSimilarityPercent(refPose, poseJson);
      MetricsTracker.instance.increment('session_frames_scored');
    } else {
      accuracy = null;
      MetricsTracker.instance.increment('session_frames_missing_reference');
    }
    MetricsTracker.instance.recordLatency(
      'accuracy_compute_time',
      DateTime.now().difference(accuracyStart).inMilliseconds,
    );

    // DB insert timing
    final insertStart = DateTime.now();
    await _sessionFrames.insertSessionFrame(
      sessionId: sessionId,
      frameNumber: frameNumber,
      timestamp: timestamp,
      poseJson: poseJson,
      accuracy: accuracy,
    );
    MetricsTracker.instance.recordLatency(
      'db_session_frame_insert',
      DateTime.now().difference(insertStart).inMilliseconds,
    );

    MetricsTracker.instance.recordLatency(
      'session_frame_pipeline_time',
      DateTime.now().difference(pipelineStart).inMilliseconds,
    );

    return accuracy;
  }

  /// End session + store summary JSON + persist performance metrics row
  Future<void> endSession({
    required int sessionId,
  }) async {
    final totalStart = DateTime.now();
    MetricsTracker.instance.increment('session_end_attempts');

    // Fetch frames
    final fetchStart = DateTime.now();
    final frames = await _sessionFrames.getSessionFramesBySessionId(sessionId);
    MetricsTracker.instance.recordLatency(
      'db_session_frames_fetch_by_session',
      DateTime.now().difference(fetchStart).inMilliseconds,
    );

    // Compute summary timing
    final summaryStart = DateTime.now();
    final accuracies = frames
        .map((f) => f['Accuracy'])
        .whereType<num>()
        .map((n) => n.toDouble())
        .toList();

    final avgAccuracy = accuracies.isEmpty
        ? null
        : accuracies.reduce((a, b) => a + b) / accuracies.length;

    final summary = {
      'framesRecorded': frames.length,
      'framesScored': accuracies.length,
      'avgAccuracy': avgAccuracy,
    };

    MetricsTracker.instance.recordLatency(
      'session_summary_compute_time',
      DateTime.now().difference(summaryStart).inMilliseconds,
    );

    // Update session row
    final endUpdateStart = DateTime.now();
    await _sessions.endSession(
      sessionId: sessionId,
      summaryJson: jsonEncode(summary),
    );
    MetricsTracker.instance.recordLatency(
      'db_session_end_update',
      DateTime.now().difference(endUpdateStart).inMilliseconds,
    );

    // ✅ Persist 1 metrics row per session (so you can compare before vs after)
    // Uses MetricsTracker values collected during the session.
    final framesReceived = MetricsTracker.instance.getCounter('session_frames_received');
    final framesScored = MetricsTracker.instance.getCounter('session_frames_scored');
    final framesMissingRef = MetricsTracker.instance.getCounter('session_frames_missing_reference');

    await _metricsRepo.insertMetrics(
      sessionId: sessionId,
      pipelineVersion: _pipelineVersion,
      framesReceived: framesReceived,
      framesScored: framesScored,
      framesMissingReference: framesMissingRef,
      avgAccuracy: avgAccuracy,

      avgFramePipelineMs: MetricsTracker.instance.avg('session_frame_pipeline_time'),
      p95FramePipelineMs: MetricsTracker.instance.percentile('session_frame_pipeline_time', 0.95),

      avgDbInsertMs: MetricsTracker.instance.avg('db_session_frame_insert'),
      p95DbInsertMs: MetricsTracker.instance.percentile('db_session_frame_insert', 0.95),

      avgAccuracyComputeMs: MetricsTracker.instance.avg('accuracy_compute_time'),
      p95AccuracyComputeMs: MetricsTracker.instance.percentile('accuracy_compute_time', 0.95),
    );

    MetricsTracker.instance.increment('session_end_success');
    MetricsTracker.instance.recordLatency(
      'session_end_total_time',
      DateTime.now().difference(totalStart).inMilliseconds,
    );
  }

  // ----------------------------
  // Pose similarity (MVP version)
  // ----------------------------
  double? _computePoseSimilarityPercent(String refPoseJson, String livePoseJson) {
    final ref = _extractLandmarks(refPoseJson);
    final live = _extractLandmarks(livePoseJson);

    if (ref == null || live == null) return null;
    if (ref.isEmpty || live.isEmpty) return null;

    final n = min(ref.length, live.length);
    if (n < 5) return null;

    double totalDist = 0.0;
    for (int i = 0; i < n; i++) {
      final dx = ref[i].$1 - live[i].$1;
      final dy = ref[i].$2 - live[i].$2;
      final dz = ref[i].$3 - live[i].$3;
      totalDist += sqrt(dx * dx + dy * dy + dz * dz);
    }
    final avgDist = totalDist / n;

    const maxReasonableDist = 0.35;
    final normalized = (avgDist / maxReasonableDist).clamp(0.0, 1.0);
    final score = (1.0 - normalized) * 100.0;

    return double.parse(score.toStringAsFixed(2));
  }

  List<(double, double, double)>? _extractLandmarks(String poseJson) {
    try {
      final obj = jsonDecode(poseJson);
      dynamic list;

      if (obj is Map) {
        list = obj['landmarks'] ?? obj['poseLandmarks'] ?? obj['keypoints'];
      } else {
        return null;
      }

      if (list is! List) return null;

      final out = <(double, double, double)>[];
      for (final item in list) {
        if (item is Map) {
          final x = (item['x'] as num?)?.toDouble();
          final y = (item['y'] as num?)?.toDouble();
          final z = (item['z'] as num?)?.toDouble() ?? 0.0;
          if (x != null && y != null) out.add((x, y, z));
        }
      }
      return out;
    } catch (_) {
      return null;
    }
  }
}