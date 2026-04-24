import 'package:flutter/widgets.dart';

import '../../foundation/space/grid.dart';
import '../../molecules/cards/exercise_thumbnail_card.dart';
import '../../molecules/cards/exercise_thumbnail_card_types.dart';
import 'exercise_type_grid_types.dart';

/// A 2×2 grid of exercise discipline cards.
///
/// Owns single-select state — tapping an unselected card selects it;
/// tapping the already-selected card deselects it. Reports every change
/// upward via [onChanged]. Never navigates or calls a service.
class ExerciseTypeGridOrganism extends StatefulWidget {
  const ExerciseTypeGridOrganism({
    super.key,
    this.initialValue,
    required this.onChanged,
  });

  final ExerciseDiscipline? initialValue;
  final ValueChanged<ExerciseDiscipline?> onChanged;

  @override
  State<ExerciseTypeGridOrganism> createState() =>
      _ExerciseTypeGridOrganismState();
}

class _ExerciseTypeGridOrganismState extends State<ExerciseTypeGridOrganism> {
  ExerciseDiscipline? _selected;

  @override
  void initState() {
    super.initState();
    _selected = widget.initialValue;
  }

  void _handleTap(ExerciseDiscipline discipline) {
    setState(() {
      _selected = _selected == discipline ? null : discipline;
    });
    widget.onChanged(_selected);
  }

  @override
  Widget build(BuildContext context) {
    return GridView.count(
      crossAxisCount: 2,
      crossAxisSpacing: AppGrid.grid16,
      mainAxisSpacing: AppGrid.grid16,
      childAspectRatio: 0.75,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      children: ExerciseDiscipline.values.map((discipline) {
        return ExerciseThumbnailCard(
          size: ExerciseThumbnailCardSize.large,
          label: discipline.label,
          selected: _selected == discipline,
          onTap: () => _handleTap(discipline),
        );
      }).toList(),
    );
  }
}
