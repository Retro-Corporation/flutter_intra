/// Rendering variants for [ExerciseCardRead].
enum ExerciseCardReadVariant {
  /// Full card — score badge, muscle group pill, selection state.
  /// All of [score], [scoreColor], [scoreVariant], and [muscleGroup] are required.
  full,

  /// Simple card — thumbnail + exercise name + metrics row only.
  /// No score badge, no muscle group pill, no selection state.
  /// Used in the Given Exercise onboarding screen (Screen 08).
  simple,
}
