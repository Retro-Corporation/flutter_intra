import 'package:flutter/material.dart';
import '../../atoms/behaviors/pressable_surface.dart';
import '../../atoms/primitives/icon.dart';
import '../../atoms/primitives/text.dart';
import '../../foundation/color/color_utils.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/type/typography.dart';
import '../../icons/icon_sizes.dart';
import 'app_dropdown_types.dart';

/// Molecule: a tappable dropdown selector with optional label header.
///
/// Use [style] to choose the color treatment and [variant] to choose the
/// header layout — following the same two-axis pattern as [AppButton].
///
/// [AppDropdownStyle.outline] — bordered surface box (default appearance).
/// [AppDropdownStyle.filled]  — solid color box; supply [color] to set the fill.
///
/// [AppDropdownVariant.plain]      — box only, no header.
/// [AppDropdownVariant.labelOnly]  — text label rendered above the box.
/// [AppDropdownVariant.iconLabel]  — icon + text label rendered above the box.
///
/// This component is a pure tap target. It never opens a picker or manages
/// selection internally — it tells the parent something was tapped so the
/// parent can show the appropriate overlay.
class AppDropdown extends StatelessWidget {
  /// Color treatment for the box.
  final AppDropdownStyle style;

  /// Header layout variant.
  final AppDropdownVariant variant;

  /// The currently selected value. Null shows [placeholder].
  final String? value;

  /// Placeholder text shown when [value] is null.
  final String placeholder;

  /// Called when the user taps the box.
  final VoidCallback onTap;

  /// Fill color used when [style] is [AppDropdownStyle.filled].
  /// Required when style is filled.
  final Color? color;

  /// Header label text. Required for [AppDropdownVariant.labelOnly] and
  /// [AppDropdownVariant.iconLabel].
  final String? label;

  /// Icon asset path rendered before [label] in the header.
  /// Required for [AppDropdownVariant.iconLabel].
  final String? iconPath;

  /// When true, renders the outline border in [AppColors.brand] to indicate
  /// the picker it triggers is currently open. Has no effect on filled style.
  final bool isOpen;

  const AppDropdown({
    super.key,
    required this.style,
    required this.variant,
    required this.value,
    required this.placeholder,
    required this.onTap,
    this.color,
    this.label,
    this.iconPath,
    this.isOpen = false,
  })  : assert(
          style == AppDropdownStyle.outline || color != null,
          'color is required when style is filled',
        ),
        assert(
          variant == AppDropdownVariant.plain || label != null,
          'label is required for labelOnly and iconLabel variants',
        ),
        assert(
          variant != AppDropdownVariant.iconLabel || iconPath != null,
          'iconPath is required for iconLabel variant',
        );

  Color get _backgroundColor => switch (style) {
        AppDropdownStyle.outline => AppColors.surface,
        AppDropdownStyle.filled => color!,
      };

  Color get _borderColor => switch (style) {
        AppDropdownStyle.outline =>
          isOpen ? AppColors.brand : AppColors.surfaceBorder,
        AppDropdownStyle.filled => resolve700(color!),
      };

  Color get _textColor {
    if (style == AppDropdownStyle.filled) return AppColors.textPrimary;
    return value != null ? AppColors.textPrimary : AppColors.textSecondary;
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        if (variant != AppDropdownVariant.plain) ...[
          _buildHeader(),
          SizedBox(height: AppGrid.grid8),
        ],
        _buildBox(),
      ],
    );
  }

  Widget _buildHeader() {
    return switch (variant) {
      AppDropdownVariant.plain => const SizedBox.shrink(),
      AppDropdownVariant.labelOnly => AppText(
          label!,
          style: AppTypography.bodySmall.bold,
          color: AppColors.textPrimary,
        ),
      AppDropdownVariant.iconLabel => Row(
          mainAxisSize: MainAxisSize.min,
          children: [
            AppIcon(
              iconPath!,
              size: IconSizes.sm,
              color: AppColors.textPrimary,
            ),
            SizedBox(width: AppGrid.grid8),
            AppText(
              label!,
              style: AppTypography.bodySmall.bold,
              color: AppColors.textPrimary,
            ),
          ],
        ),
    };
  }

  PressableStyle get _pressStyle => switch (style) {
        AppDropdownStyle.outline => PressableStyle.outline,
        AppDropdownStyle.filled  => PressableStyle.filled,
      };

  Widget _buildBox() {
    return PressableSurface(
      onTap: onTap,
      style: _pressStyle,
      backgroundColor: _backgroundColor,
      borderColor: _borderColor,
      borderRadius: AppRadius.sm,
      child: SizedBox(
        height: AppGrid.grid48,
        width: double.infinity,
        child: Padding(
          padding: EdgeInsets.symmetric(horizontal: AppGrid.grid16),
          child: Align(
            alignment: Alignment.center,
            child: AppText(
              value ?? placeholder,
              style: AppTypography.body.bold,
              color: _textColor,
            ),
          ),
        ),
      ),
    );
  }
}
