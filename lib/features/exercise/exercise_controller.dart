import 'exercise_service.dart';

class ExerciseController {
  final ExerciseService _exercise;

  ExerciseController(this._exercise);

  Future<Map<String, Object?>> createExercise({
    required String name,
    String? description,
    required String referencePoseJson,
  }) async {
    try {
      final exerciseId = await _exercise.createExercise(
        exerciseName: name,
        description: description,
        referencePoseJson: referencePoseJson,
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

  /// GET /exercises
  /// Output: { success, exercises: [...] }
  Future<Map<String, Object?>> listExercises() async {
    try {
      final exercises = await _exercise.listExercises();

      return {
        'success': true,
        'exercises': exercises,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// Convenience method for UI:
  /// returns just List<Map<String, Object?>> of exercises.
  Future<List<Map<String, Object?>>> getAllExercises() async {
    final result = await listExercises();

    if (result['success'] == true) {
      final exercises = result['exercises'];

      if (exercises is List) {
        return exercises
            .map<Map<String, Object?>>(
              (e) => Map<String, Object?>.from(e as Map),
            )
            .toList();
      }
      return [];
    } else {
      throw Exception(result['error'] ?? 'Failed to load exercises');
    }
  }

  /// GET /exercises/:id
  Future<Map<String, Object?>> getExercise({
    required int exerciseId,
  }) async {
    try {
      final exercise = await _exercise.getExercise(exerciseId);

      if (exercise == null) {
        return {
          'success': false,
          'error': 'Exercise not found',
        };
      }

      return {
        'success': true,
        'exercise': exercise,
      };
    } catch (e) {
      return {
        'success': false,
        'error': e.toString(),
      };
    }
  }

  /// DELETE /exercises/:id
  Future<Map<String, Object?>> deleteExercise({
    required int exerciseId,
  }) async {
    try {
      await _exercise.deleteExercise(
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