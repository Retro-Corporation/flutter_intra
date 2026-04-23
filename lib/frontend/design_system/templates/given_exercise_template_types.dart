/// State variants for [GivenExerciseTemplate].
enum GivenExerciseState {
  /// Exercise list loaded — renders [ExerciseCardRead] items.
  loaded,

  /// Fetching exercise data — renders [ExerciseCardSkeleton] placeholders.
  loading,

  /// Fetch failed or zero exercises assigned — renders empty state container.
  error,
}

/// Identity data for the prescribing practitioner.
class PractitionerInfo {
  final String avatarUrl;
  final String name;
  final String clinic;

  const PractitionerInfo({
    required this.avatarUrl,
    required this.name,
    required this.clinic,
  });
}

/// Data for a single exercise entry in the loaded list.
/// Field shape matches [ExerciseCardReadVariant.simple] props exactly.
class ExerciseData {
  final String exerciseName;
  final String repLabel;
  final String repValue;
  final String setLabel;
  final String setValue;
  final String? equipmentLabel;
  final String? equipmentValue;

  const ExerciseData({
    required this.exerciseName,
    required this.repLabel,
    required this.repValue,
    required this.setLabel,
    required this.setValue,
    this.equipmentLabel,
    this.equipmentValue,
  });
}
