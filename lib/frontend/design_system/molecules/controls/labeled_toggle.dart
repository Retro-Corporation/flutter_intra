import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/type/typography.dart';
import '../../atoms/controls/toggle.dart';
import '../../atoms/primitives/text.dart';

/// Molecule: label + toggle row for notification/preference settings rows.
///
/// Fully parent-controlled — reflects [value] as-is and fires [onChanged]
/// on toggle tap. No internal state.
class LabeledToggle extends StatelessWidget {
  final String label;
  final bool value;
  final ValueChanged<bool> onChanged;

  const LabeledToggle({
    required this.label,
    required this.value,
    required this.onChanged,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: AppText(
            label,
            style: AppTypography.body.regular,
            color: AppColors.textPrimary,
          ),
        ),
        AppToggle(
          value: value,
          onChanged: onChanged,
        ),
      ],
    );
  }
}
