import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/type/typography.dart';
import '../../icons/icon_sizes.dart';
import '../../atoms/primitives/icon.dart';
import '../../atoms/primitives/text.dart';

/// Molecule: tappable inline CTA composed of an [AppIcon] + [AppText].
///
/// Used in empty states (e.g. "+ Add Clients").
/// Both icon and text use [AppColors.textPrimary] to match Figma empty state.
class IconTextAction extends StatelessWidget {
  final String iconPath;
  final String label;
  final VoidCallback onTap;

  const IconTextAction({
    super.key,
    required this.iconPath,
    required this.label,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          AppIcon(iconPath, size: IconSizes.md, color: AppColors.textPrimary),
          SizedBox(width: AppGrid.grid8),
          AppText(label, style: AppTypography.body.regular, color: AppColors.textPrimary),
        ],
      ),
    );
  }
}
