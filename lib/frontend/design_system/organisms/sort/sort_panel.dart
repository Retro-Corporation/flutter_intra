import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/padding.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/space/stroke.dart';
import '../../foundation/type/typography.dart';
import '../../atoms/primitives/text.dart';
import '../../atoms/controls/button.dart';
import '../../atoms/controls/button_types.dart';
import '../../molecules/controls/labeled_checkbox.dart';
import 'sort_panel_types.dart';

/// Organism: a sort panel that groups [LabeledCheckbox] molecules by
/// [SortCategory] and enforces single-selection per category.
///
/// All state is owner-controlled via [selectedSorts]. The panel reports
/// changes upward through [onSortChanged] and fires [onClearAll] when the
/// "Clear all" button is tapped.
class SortPanel extends StatelessWidget {
  final Map<SortCategory, SortOption?> selectedSorts;
  final ValueChanged<Map<SortCategory, SortOption?>> onSortChanged;
  final VoidCallback onClearAll;

  const SortPanel({
    required this.selectedSorts,
    required this.onSortChanged,
    required this.onClearAll,
    super.key,
  });

  void _onOptionTapped(SortCategory category, SortOption option, bool checked) {
    final updated = Map<SortCategory, SortOption?>.from(selectedSorts);
    updated[category] = checked ? option : null;
    onSortChanged(updated);
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.textPrimary, width: AppStroke.xs),
      ),
      padding: EdgeInsets.all(AppPadding.cardPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          for (int i = 0; i < SortCategory.values.length; i++) ...[
            _buildCategory(SortCategory.values[i]),
            if (i < SortCategory.values.length - 1) SizedBox(height: AppGrid.grid16),
          ],
          SizedBox(height: AppGrid.grid16),
          AppButton(
            label: 'Clear all',
            type: ButtonType.outline,
            color: AppColors.textPrimary,
            onPressed: onClearAll,
          ),
        ],
      ),
    );
  }

  Widget _buildCategory(SortCategory category) {
    final options = category.options;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          category.label,
          style: AppTypography.bodySmall.semiBold,
          color: AppColors.textSecondary,
        ),
        SizedBox(height: AppGrid.grid12),
        for (int i = 0; i < options.length; i++) ...[
          LabeledCheckbox(
            label: options[i].label,
            isChecked: selectedSorts[category] == options[i],
            onChanged: (checked) => _onOptionTapped(category, options[i], checked),
          ),
          if (i < options.length - 1) SizedBox(height: AppGrid.grid12),
        ],
      ],
    );
  }
}
