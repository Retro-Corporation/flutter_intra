/// Types for [CreateExerciseDetailsTemplate].

/// Which picker is currently open. [none] means all pickers are closed.
enum OpenPicker { none, bodySegment, outcome, equipment }

/// Collected form values handed to [CreateExerciseDetailsTemplate.onSubmit].
///
/// Only [name] is required for submission. The three picker-backed fields are
/// optional — the user can save with just a name and fill in the rest later.
class ExerciseDetailsData {
  final String name;
  final String? bodySegmentId;
  final String? outcomeId;
  final String? equipmentId;

  const ExerciseDetailsData({
    required this.name,
    this.bodySegmentId,
    this.outcomeId,
    this.equipmentId,
  });
}
