import 'package:flutter/material.dart';

import '../../atoms/primitives/text.dart';
import '../../atoms/primitives/thumbnail.dart';
import '../../atoms/primitives/thumbnail_types.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/space/stroke.dart';
import '../../foundation/type/typography.dart';

/// Molecule: a selectable row that combines a [Thumbnail] placeholder and a
/// text label inside a single tappable surface.
///
/// When [isSelected], the full row (thumbnail + label) is highlighted with a
/// brand-color border and surface fill — identical selection treatment to
/// [SchemeOptionRow] but with a 60×60 thumbnail leading the row.
///
/// Filtering and data ownership belong to the caller. This molecule is a pure
/// renderer — it reports taps via [onTap] and never manages selection state
/// internally.
class ThumbnailOptionRow extends StatelessWidget {
  const ThumbnailOptionRow({
    super.key,
    required this.label,
    required this.isSelected,
    required this.onTap,
  });

  final String label;
  final bool isSelected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: isSelected ? AppColors.surface : Colors.transparent,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: isSelected
              ? Border.all(color: AppColors.brand, width: AppStroke.xs)
              : null,
        ),
        padding: const EdgeInsets.symmetric(
          horizontal: AppGrid.grid12,
          vertical: AppGrid.grid8,
        ),
        child: Row(
          children: [
            const Thumbnail(size: ThumbnailSize.size60),
            const SizedBox(width: AppGrid.grid8),
            Expanded(
              child: AppText(
                label,
                style: AppTypography.body.bold,
                color: AppColors.textPrimary,
                overflow: TextOverflow.ellipsis,
                maxLines: 1,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
