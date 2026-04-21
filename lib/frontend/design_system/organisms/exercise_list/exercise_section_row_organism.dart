import 'package:flutter/widgets.dart';
import '../../foundation/space/grid.dart';
import '../../molecules/cards/exercise_thumbnail_card.dart';
import '../../molecules/cards/exercise_thumbnail_card_types.dart';
import '../../molecules/display/icon_section_header.dart';
import 'exercise_section_row_types.dart';

/// Organism: a titled section of exercise cards. Renders either a horizontal
/// row of large labeled cards ([ExerciseSectionLayout.templateRow]) or a 2-row
/// horizontally-scrolling grid of small cards ([ExerciseSectionLayout.exerciseGrid]).
/// Pure renderer — reports card taps upward via [onCardTap] and never mutates
/// selection state.
class ExerciseSectionRowOrganism extends StatelessWidget {
  final String title;
  final ExerciseSectionLayout layout;
  final List<ExerciseItem> items;
  final void Function(String exerciseId) onCardTap;
  final String? iconPath;
  final List<String> selectedIds;

  const ExerciseSectionRowOrganism({
    super.key,
    required this.title,
    required this.layout,
    required this.items,
    required this.onCardTap,
    this.iconPath,
    this.selectedIds = const [],
  });

  @override
  Widget build(BuildContext context) {
    if (items.isEmpty) {
      return const SizedBox.shrink();
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        IconSectionHeader(label: title, iconPath: iconPath),
        const SizedBox(height: AppGrid.grid8),
        switch (layout) {
          ExerciseSectionLayout.templateRow => _buildTemplateRow(),
          ExerciseSectionLayout.exerciseGrid => _buildExerciseGrid(),
        },
      ],
    );
  }

  // ── Private layout builders ──

  Widget _buildTemplateRow() {
    final children = <Widget>[];
    for (var i = 0; i < items.length; i++) {
      final item = items[i];
      children.add(
        ExerciseThumbnailCard(
          size: ExerciseThumbnailCardSize.large,
          label: item.label,
          selected: selectedIds.contains(item.id),
          onTap: () => onCardTap(item.id),
        ),
      );
      if (i < items.length - 1) {
        children.add(_buildCardSpacer());
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Row(children: children),
    );
  }

  Widget _buildExerciseGrid() {
    final topItems = <ExerciseItem>[];
    final bottomItems = <ExerciseItem>[];
    for (var i = 0; i < items.length; i++) {
      if (i.isEven) {
        topItems.add(items[i]);
      } else {
        bottomItems.add(items[i]);
      }
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        mainAxisSize: MainAxisSize.min,
        children: [
          _buildGridRow(topItems),
          const SizedBox(height: AppGrid.grid16),
          _buildGridRow(bottomItems),
        ],
      ),
    );
  }

  Widget _buildGridRow(List<ExerciseItem> rowItems) {
    final children = <Widget>[];
    for (var i = 0; i < rowItems.length; i++) {
      final item = rowItems[i];
      children.add(
        ExerciseThumbnailCard(
          size: ExerciseThumbnailCardSize.small,
          selected: selectedIds.contains(item.id),
          onTap: () => onCardTap(item.id),
        ),
      );
      if (i < rowItems.length - 1) {
        children.add(_buildCardSpacer());
      }
    }
    return Row(children: children);
  }

  Widget _buildCardSpacer() => const SizedBox(width: AppGrid.grid16);
}
