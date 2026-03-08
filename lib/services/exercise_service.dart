import 'dart:convert';

import '../database/repositories/repository.dart';
import '../utils/metrics_tracker.dart';

class ExerciseService {
  final ExerciseRepository _exercises;

  ExerciseService(this._exercises);

  /// Create a new exercise
  Future<int> createExercise({
    required String exerciseName,
    String? description,
    required String referencePoseJson,
  }) async {
    final totalStart = DateTime.now();

    final name = exerciseName.trim();

    if (name.isEmpty) {
      MetricsTracker.instance.increment('exercise_create_fail_empty_name');
      throw Exception('Exercise name cannot be empty.');
    }

    _validateReferencePose(referencePoseJson);

    MetricsTracker.instance.increment('exercise_create_attempts');

    final insertStart = DateTime.now();

    final exerciseId = await _exercises.createExercise(
      exerciseName: name,
      description: description,
      referencePoseJson: referencePoseJson,
    );

    MetricsTracker.instance.recordLatency(
      'db_exercise_insert',
      DateTime.now().difference(insertStart).inMilliseconds,
    );

    MetricsTracker.instance.increment('exercise_create_success');

    MetricsTracker.instance.recordLatency(
      'exercise_create_total_time',
      DateTime.now().difference(totalStart).inMilliseconds,
    );

    return exerciseId;
  }

  /// Delete exercise
  Future<void> deleteExercise({
    required int exerciseId,
  }) async {
    final totalStart = DateTime.now();

    MetricsTracker.instance.increment('exercise_delete_attempts');

    final lookupStart = DateTime.now();

    final exercise = await _exercises.getExerciseById(exerciseId);

    MetricsTracker.instance.recordLatency(
      'db_exercise_lookup_by_id',
      DateTime.now().difference(lookupStart).inMilliseconds,
    );

    if (exercise == null) {
      MetricsTracker.instance.increment('exercise_delete_fail_not_found');
      throw Exception('Exercise not found.');
    }

    final deleteStart = DateTime.now();

    await _exercises.deleteExercise(exerciseId);

    MetricsTracker.instance.recordLatency(
      'db_exercise_delete',
      DateTime.now().difference(deleteStart).inMilliseconds,
    );

    MetricsTracker.instance.increment('exercise_delete_success');

    MetricsTracker.instance.recordLatency(
      'exercise_delete_total_time',
      DateTime.now().difference(totalStart).inMilliseconds,
    );
  }

  /// Get all exercises
  Future<List<Map<String, Object?>>> listExercises() async {
    final start = DateTime.now();

    final list = await _exercises.getAllExercises();

    MetricsTracker.instance.recordLatency(
      'db_exercises_list',
      DateTime.now().difference(start).inMilliseconds,
    );

    MetricsTracker.instance.increment('exercise_list_calls');

    return list;
  }

  /// Get single exercise
  Future<Map<String, Object?>?> getExercise(int exerciseId) async {
    final start = DateTime.now();

    final exercise = await _exercises.getExerciseById(exerciseId);

    MetricsTracker.instance.recordLatency(
      'db_exercise_lookup_by_id',
      DateTime.now().difference(start).inMilliseconds,
    );

    return exercise;
  }

  /// Validate pose JSON
  void _validateReferencePose(String poseJson) {
    final trimmed = poseJson.trim();

    if (trimmed.isEmpty) {
      throw Exception('Reference pose JSON cannot be empty.');
    }

    try {
      final decoded = jsonDecode(trimmed);

      if (decoded is! Map && decoded is! List) {
        throw Exception('Reference pose must be valid JSON.');
      }
    } catch (_) {
      throw Exception('Invalid reference pose JSON format.');
    }
  }
}