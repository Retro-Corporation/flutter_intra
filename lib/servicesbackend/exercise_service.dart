// servicesbackend/exercise_service.dart
import 'dart:convert';

import 'package:sqflite/sqflite.dart';

import '../database/repositories/exercise_repository.dart';
import '../database/repositories/reference_frame_repository.dart';
import '../utils/metrics_tracker.dart';

class ReferenceFrameInput {
  final int frameNumber;
  final double timestamp;
  final String poseJson;

  ReferenceFrameInput({
    required this.frameNumber,
    required this.timestamp,
    required this.poseJson,
  });
}

class ExerciseService {
  final Database _db;
  final ExerciseRepository _exercises;
  final ReferenceFrameRepository _refFrames;

  ExerciseService(this._db, this._exercises, this._refFrames);

  /// Creates an exercise + inserts reference frames
  Future<int> createExerciseWithReferenceFrames({
    required int creatorUserId,
    required String exerciseName,
    String? description,
    String? validationRules,
    required List<ReferenceFrameInput> frames,
  }) async {
    final totalStart = DateTime.now();

    final name = exerciseName.trim();
    if (name.isEmpty) {
      MetricsTracker.instance.increment('exercise_create_fail_empty_name');
      throw Exception('Exercise name cannot be empty.');
    }
    if (frames.isEmpty) {
      MetricsTracker.instance.increment('exercise_create_fail_no_frames');
      throw Exception('Exercise must have at least 1 reference frame.');
    }

    // Validation timing
    final validateStart = DateTime.now();
    _validateReferenceFrames(frames);
    MetricsTracker.instance.recordLatency(
      'exercise_reference_validation_time',
      DateTime.now().difference(validateStart).inMilliseconds,
    );

    MetricsTracker.instance.increment('exercise_create_attempts');

    // Transaction ensures exercise + frames either both save or neither saves.
    final txnStart = DateTime.now();
    final exerciseId = await _db.transaction<int>((txn) async {
      final exRepo = ExerciseRepository(txn);
      final rfRepo = ReferenceFrameRepository(txn);

      // Exercise insert timing
      final insertExerciseStart = DateTime.now();
      final createdId = await exRepo.createExercise(
        creatorUserId: creatorUserId,
        exerciseName: name,
        description: description,
        validationRules: validationRules,
      );
      MetricsTracker.instance.recordLatency(
        'db_exercise_insert',
        DateTime.now().difference(insertExerciseStart).inMilliseconds,
      );

      // Reference frames insert timing (per-frame + total)
      final framesTotalStart = DateTime.now();
      for (final f in frames) {
        final frameStart = DateTime.now();
        await rfRepo.insertReferenceFrame(
          exerciseId: createdId,
          frameNumber: f.frameNumber,
          timestamp: f.timestamp,
          poseJson: f.poseJson,
        );
        MetricsTracker.instance.recordLatency(
          'db_reference_frame_insert',
          DateTime.now().difference(frameStart).inMilliseconds,
        );
        MetricsTracker.instance.increment('reference_frames_inserted');
      }
      MetricsTracker.instance.recordLatency(
        'db_reference_frames_insert_total',
        DateTime.now().difference(framesTotalStart).inMilliseconds,
      );

      return createdId;
    });

    MetricsTracker.instance.recordLatency(
      'db_exercise_create_transaction_time',
      DateTime.now().difference(txnStart).inMilliseconds,
    );

    MetricsTracker.instance.increment('exercise_create_success');
    MetricsTracker.instance.recordLatency(
      'exercise_create_total_time',
      DateTime.now().difference(totalStart).inMilliseconds,
    );

    return exerciseId;
  }

  /// Ownership check before delete
  Future<void> deleteExercise({
    required int requestUserId,
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

    final owner = exercise['Creator_User_ID'] as int?;
    if (owner == null || owner != requestUserId) {
      MetricsTracker.instance.increment('exercise_delete_fail_not_owner');
      throw Exception('Not allowed: you do not own this exercise.');
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

  Future<List<Map<String, Object?>>> listExercisesForUser(int userId) async {
    final start = DateTime.now();
    final list = await _exercises.getExercisesByUser(userId);
    MetricsTracker.instance.recordLatency(
      'db_exercises_list_by_user',
      DateTime.now().difference(start).inMilliseconds,
    );
    MetricsTracker.instance.increment('exercise_list_calls');
    return list;
  }

  // --- validation helpers ---
  void _validateReferenceFrames(List<ReferenceFrameInput> frames) {
    final sorted = [...frames]..sort((a, b) => a.frameNumber.compareTo(b.frameNumber));

    final seen = <int>{};
    for (final f in sorted) {
      if (f.frameNumber < 0) throw Exception('Frame number cannot be negative.');
      if (f.timestamp < 0) throw Exception('Timestamp cannot be negative.');
      if (f.poseJson.trim().isEmpty) throw Exception('Pose JSON cannot be empty.');

      if (seen.contains(f.frameNumber)) {
        throw Exception('Duplicate frame_number found: ${f.frameNumber}');
      }
      seen.add(f.frameNumber);

      try {
        jsonDecode(f.poseJson);
      } catch (_) {
        throw Exception('Invalid Pose JSON for frame ${f.frameNumber}');
      }
    }
  }
}