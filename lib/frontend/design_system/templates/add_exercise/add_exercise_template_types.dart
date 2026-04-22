import 'package:flutter/foundation.dart';
import '../../organisms/exercise_list/exercise_section_row_types.dart';

/// Data for a single section on the Add Exercise page.
///
/// Maps 1:1 onto [ExerciseSectionRowOrganism]. The template constructs one
/// section row per entry in the sections list and threads its own
/// `selectedIds` into each row.
@immutable
class ExerciseSectionData {
  final String title;
  final ExerciseSectionLayout layout;
  final List<ExerciseItem> items;
  final String? iconPath;

  const ExerciseSectionData({
    required this.title,
    required this.layout,
    required this.items,
    this.iconPath,
  });
}
