import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/type/typography.dart';
import '../../icons/icon_sizes.dart';
import '../primitives/icon.dart';
import '../primitives/text.dart';
import '../behaviors/pressable_surface.dart';
import 'filter_button_types.dart';

class FilterButton extends StatelessWidget {
  final FilterButtonState state;
  final VoidCallback onTap;
  final Color backgroundColor;

  /// Icon asset path rendered inside the button box. Always required —
  /// state drives border and background color only.
  final String icon;

  /// Optional label rendered adjacent to the button box.
  final String? label;

  /// When true, [label] renders below the box. When false (default), above.
  final bool labelBelow;

  const FilterButton({
    required this.state,
    required this.onTap,
    required this.icon,
    this.backgroundColor = AppColors.surface,
    this.label,
    this.labelBelow = false,
    super.key,
  });

  Color get _borderColor => switch (state) {
        FilterButtonState.idle => AppColors.surfaceBorder,
        FilterButtonState.open => AppColors.textPrimary,
        FilterButtonState.sorted => AppColors.brand,
      };

  Color get _iconColor => switch (state) {
        FilterButtonState.idle => AppColors.textPrimary,
        FilterButtonState.open => AppColors.textPrimary,
        FilterButtonState.sorted => AppColors.brand,
      };

  Widget get _labelWidget => AppText(
        label!,
        style: AppTypography.bodySmall.bold,
        color: AppColors.textPrimary,
      );

  @override
  Widget build(BuildContext context) {
    final box = SizedBox(
      height: AppGrid.grid40,
      width: AppGrid.grid40,
      child: PressableSurface(
        backgroundColor: backgroundColor,
        borderColor: _borderColor,
        borderRadius: AppRadius.sm,
        onTap: onTap,
        child: Center(
          child: AppIcon(icon, size: IconSizes.md, color: _iconColor),
        ),
      ),
    );

    if (label == null) return box;

    return Column(
      mainAxisSize: MainAxisSize.min,
      children: labelBelow
          ? [box, const SizedBox(height: AppGrid.grid4), _labelWidget]
          : [_labelWidget, const SizedBox(height: AppGrid.grid4), box],
    );
  }
}
