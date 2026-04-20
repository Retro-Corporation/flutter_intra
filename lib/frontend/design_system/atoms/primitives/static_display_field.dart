import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/space/stroke.dart';
import '../../foundation/type/typography.dart';
import 'text.dart';

/// Atom: read-only flat display field.
///
/// Renders a bordered box with centered text. Used for equipment values
/// that are static and non-interactive (e.g., "Doorway", "No Equipment").
/// Has no label — label is the caller's responsibility.
class AppStaticDisplayField extends StatelessWidget {
  final String value;

  const AppStaticDisplayField({
    super.key,
    required this.value,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      height: AppGrid.grid48,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.sm),
        border: Border.all(color: AppColors.surfaceBorder, width: AppStroke.xs),
      ),
      alignment: Alignment.center,
      padding: const EdgeInsets.symmetric(horizontal: AppGrid.grid16),
      child: AppText(value, style: AppTypography.body.bold, color: AppColors.textPrimary),
    );
  }
}
