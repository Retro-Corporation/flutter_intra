/// Layout variants for [ExerciseSectionRowOrganism].
enum ExerciseSectionLayout { templateRow, exerciseGrid }

/// Data for a single exercise card rendered inside an exercise section.
///
/// [label] is rendered only when the section uses [ExerciseSectionLayout.templateRow]
/// (large cards with bottom titles). It is ignored for [ExerciseSectionLayout.exerciseGrid]
/// (small, unlabeled cards).
class ExerciseItem {
  final String id;
  final String? label;
  const ExerciseItem({required this.id, this.label});
}
