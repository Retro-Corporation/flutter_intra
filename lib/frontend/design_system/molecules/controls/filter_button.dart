import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/radius.dart';
import '../../icons/app_icons.dart';
import '../../icons/icon_sizes.dart';
import '../../atoms/primitives/icon.dart';
import '../../atoms/behaviors/pressable_surface.dart';
import 'filter_button_types.dart';

class FilterButton extends StatelessWidget {
  final FilterButtonState state;
  final VoidCallback onTap;
  final Color backgroundColor;

  const FilterButton({
    required this.state,
    required this.onTap,
    this.backgroundColor = AppColors.surface,
    super.key,
  });

  Color get _borderColor => switch (state) {
        FilterButtonState.idle => AppColors.surfaceBorder,
        FilterButtonState.open => AppColors.textPrimary,
        FilterButtonState.sorted => AppColors.brand,
      };

  Color get _iconColor => switch (state) {
        FilterButtonState.idle => AppColors.textSecondary,
        FilterButtonState.open => AppColors.textPrimary,
        FilterButtonState.sorted => AppColors.brand,
      };

  String get _iconPath => switch (state) {
        FilterButtonState.idle => AppIcons.filter,
        FilterButtonState.open => AppIcons.filterFilled,
        FilterButtonState.sorted => AppIcons.filterFilled,
      };

  @override
  Widget build(BuildContext context) {
    return PressableSurface(
      backgroundColor: backgroundColor,
      borderColor: _borderColor,
      borderRadius: AppRadius.sm,
      onTap: onTap,
      child: Center(
        child: AppIcon(_iconPath, size: IconSizes.md, color: _iconColor),
      ),
    );
  }
}
