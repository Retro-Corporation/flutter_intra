import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/type/typography.dart';
import '../../atoms/primitives/text.dart';

/// Molecule: full-width label + count row for section headers.
///
/// Composes two [AppText] atoms in a [Row] with space-between alignment.
/// Both texts use [AppTypography.body.semiBold] and [AppColors.textPrimary].
class SectionHeader extends StatelessWidget {
  final String label;
  final String count;

  const SectionHeader({
    super.key,
    required this.label,
    required this.count,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        AppText(label, style: AppTypography.body.semiBold, color: AppColors.textPrimary),
        AppText(count, style: AppTypography.body.semiBold, color: AppColors.textPrimary),
      ],
    );
  }
}
