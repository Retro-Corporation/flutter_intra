/// Variant of [ExerciseDetailTemplate].
///
/// - [basic] — single exercise; one Add button.
/// - [set]   — multiple exercises in a swipeable carousel; two Add buttons.
/// - [template] — multiple exercises in a swipeable carousel; one Add button.
enum ExerciseDetailVariant { basic, set, template }

/// One exercise slot in [ExerciseDetailTemplate].
class ExerciseDetailItem {
  final String id;
  final String name;
  final String muscleGroup;

  /// When null the equipment text is hidden entirely.
  final String? equipment;

  const ExerciseDetailItem({
    required this.id,
    required this.name,
    required this.muscleGroup,
    this.equipment,
  });
}
