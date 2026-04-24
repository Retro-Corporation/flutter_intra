/// The four movement disciplines a practitioner can pick from when
/// creating a new exercise.
enum ExerciseDiscipline {
  isometric,
  dynamic,
  mobility,
  plyometric;

  /// Human-readable label shown below the thumbnail card.
  String get label => switch (this) {
        ExerciseDiscipline.isometric  => 'Isometric',
        ExerciseDiscipline.dynamic    => 'Dynamic\n(Con & Ecc)',
        ExerciseDiscipline.mobility   => 'Mobility',
        ExerciseDiscipline.plyometric => 'Plyometric',
      };
}
