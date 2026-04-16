import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/type/typography.dart';
import '../../atoms/controls/checkbox.dart';
import '../../atoms/primitives/text.dart';

/// Molecule: a labeled checkbox that composes [AppCheckbox] and [AppText].
///
/// Tapping anywhere on the row — label or checkbox — toggles the value via
/// [onChanged]. State is fully parent-controlled through [isChecked].
class LabeledCheckbox extends StatelessWidget {
  final String label;
  final bool isChecked;
  final ValueChanged<bool> onChanged;

  const LabeledCheckbox({
    required this.label,
    required this.isChecked,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => onChanged(!isChecked),
      behavior: HitTestBehavior.opaque,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppCheckbox(
            selected: isChecked,
            onChanged: onChanged,
          ),
          SizedBox(width: AppGrid.grid12),
          Expanded(
            child: AppText(
              label,
              style: AppTypography.body.regular,
              color: AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}
