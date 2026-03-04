// lib/controllers/exercise_controller.dart
import '../servicesbackend/exercise_service.dart';

class ExerciseController {
  final ExerciseService _exercise;

  ExerciseController(this._exercise);

  /// POST /exercises
  /// Creates an exercise + reference frames
  /// Output: { success, exerciseId }
  Future<Map<String, Object?>> createExercise({
    required int userId,
    required String name,
    String? description,
    String? validationRules,
    required List<Map<String, Object?>> referenceFrames,
  }) async {
    try {
      // Convert partner-friendly maps -> ReferenceFrameInput objects
      final frames = referenceFrames.map((f) {
        return ReferenceFrameInput(
          frameNumber: (f['frameNumber'] as num).toInt(),
          timestamp: (f['timestamp'] as num).toDouble(),
          poseJson: f['poseJson'] as String,
        );
      }).toList();

      final exerciseId = await _exercise.createExerciseWithReferenceFrames(
        creatorUserId: userId,
        exerciseName: name,
        description: description,
        validationRules: validationRules,
        frames: frames,
      );

      return {
        'success': true,
        'exerciseId': exerciseId,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// GET /exercises?userId=...
  /// Output: { success, exercises: [...] }
  Future<Map<String, Object?>> listExercises({
    required int userId,
  }) async {
    try {
      final exercises = await _exercise.listExercisesForUser(userId);
      return {
        'success': true,
        'exercises': exercises, // List<Map<String,Object?>>
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// DELETE /exercises/:id
  /// Output: { success }
  Future<Map<String, Object?>> deleteExercise({
    required int userId,
    required int exerciseId,
  }) async {
    try {
      await _exercise.deleteExercise(
        requestUserId: userId,
        exerciseId: exerciseId,
      );
      return {
        'success': true,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }
}