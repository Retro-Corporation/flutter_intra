import '../services/exercise_service.dart';


// Updated File
class ExerciseController {
  final ExerciseService _exercise;

  ExerciseController(this._exercise);

  /// POST /exercises
  /// Creates an exercise
  /// Output: { success, exerciseId }
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
  /// Output: { success }
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