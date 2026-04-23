import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/stroke.dart';
import '../../foundation/type/typography.dart';
import 'text.dart';

/// Atom: renders a horizontal divider line.
///
/// When [label] is null, renders a plain full-width horizontal line.
/// When [label] is provided, renders a labeled divider: line + centered text + line.
///
/// Usage:
/// ```dart
/// // Plain divider
/// const AppDivider()
///
/// // Labeled divider
/// const AppDivider(label: 'or')
/// ```
class AppDivider extends StatelessWidget {
  final String? label;

  const AppDivider({super.key, this.label});

  @override
  Widget build(BuildContext context) {
    if (label == null) {
      return Container(
        height: AppStroke.xs,
        color: AppColors.surfaceBorder,
      );
    }

    return Row(
      children: [
        Expanded(
          child: Container(
            height: AppStroke.xs,
            color: AppColors.surfaceBorder,
          ),
        ),
        const SizedBox(width: AppGrid.grid8),
        AppText(
          label!,
          style: AppTypography.bodySmall.bold,
          color: AppColors.textPrimary,
        ),
        const SizedBox(width: AppGrid.grid8),
        Expanded(
          child: Container(
            height: AppStroke.xs,
            color: AppColors.surfaceBorder,
          ),
        ),
      ],
    );
  }
}
