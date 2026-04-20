import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/type/typography.dart';
import 'text.dart';

// Selectable row atom used in picker panels (SetSchemePickerPanel,
// EquipmentPickerPanel, etc.). Generic API — works for any picker overlay,
// not scheme-specific.
class SchemeOptionRow extends StatelessWidget {
  const SchemeOptionRow({
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
              ? Border.all(color: AppColors.brand, width: 1)
              : null,
        ),
        padding: EdgeInsets.symmetric(
          horizontal: AppGrid.grid12,
          vertical: AppGrid.grid8,
        ),
        child: AppText(
          label,
          style: AppTypography.body.bold,
          color: AppColors.textPrimary,
          overflow: TextOverflow.ellipsis,
          maxLines: 1,
        ),
      ),
    );
  }
}
