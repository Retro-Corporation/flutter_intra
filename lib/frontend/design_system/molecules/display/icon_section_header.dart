import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/type/typography.dart';
import '../../icons/icon_sizes.dart';
import '../../atoms/primitives/icon.dart';
import '../../atoms/primitives/text.dart';

/// Molecule: optional leading icon + bold label + trailing horizontal divider.
///
/// Composes [AppIcon] and [AppText] atoms in a [Row]. The trailing divider
/// renders whether or not [iconPath] is provided.
class IconSectionHeader extends StatelessWidget {
  final String label;
  final String? iconPath;

  const IconSectionHeader({
    super.key,
    required this.label,
    this.iconPath,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        if (iconPath != null) ...[
          AppIcon(
            iconPath!,
            size: IconSizes.md,
            color: AppColors.textPrimary,
          ),
          const SizedBox(width: AppGrid.grid8),
        ],
        AppText(
          label,
          style: AppTypography.body.semiBold,
          color: AppColors.textPrimary,
        ),
        const SizedBox(width: AppGrid.grid8),
        Expanded(
          child: Container(
            height: 1,
            color: AppColors.surfaceBorder,
          ),
        ),
      ],
    );
  }
}
