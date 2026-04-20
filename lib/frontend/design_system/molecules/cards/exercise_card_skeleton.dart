import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/padding.dart';
import '../../foundation/space/radius.dart';

/// Molecule: loading skeleton for [ExerciseCardRead].
///
/// Renders a static placeholder layout at the same dimensions as the read card.
/// All content areas are solid grey blocks — no shimmer animation (added later).
/// Zero constructor params — structure is fixed.
class ExerciseCardSkeleton extends StatelessWidget {
  const ExerciseCardSkeleton({super.key});

  Widget _placeholder({
    double? width,
    required double height,
    required Color color,
    double? radius,
  }) {
    final effectiveRadius = radius ?? AppRadius.sm;
    return Container(
      width: width,
      height: height,
      decoration: BoxDecoration(
        color: color,
        borderRadius: BorderRadius.circular(effectiveRadius),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.surfaceBorder, width: 1),
      ),
      padding: EdgeInsets.all(AppPadding.rem075),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Thumbnail placeholder
          _placeholder(
            width: AppGrid.grid76,
            height: AppGrid.grid76,
            color: AppColors.grey800,
            radius: AppRadius.sm,
          ),
          SizedBox(width: AppGrid.grid12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                // Score + name row
                Row(
                  children: [
                    _placeholder(
                      width: AppGrid.grid32,
                      height: AppGrid.grid12,
                      color: AppColors.grey800,
                    ),
                    SizedBox(width: AppGrid.grid8),
                    _placeholder(
                      width: AppGrid.grid80,
                      height: AppGrid.grid12,
                      color: AppColors.grey700,
                    ),
                  ],
                ),
                SizedBox(height: AppGrid.grid8),
                // Badge placeholder — full width, pill shape
                _placeholder(
                  width: double.infinity,
                  height: AppGrid.grid28,
                  color: AppColors.grey800,
                  radius: AppRadius.pill,
                ),
                SizedBox(height: AppGrid.grid8),
                // Metrics row
                Row(
                  children: [
                    _placeholder(
                      width: AppGrid.grid48,
                      height: AppGrid.grid12,
                      color: AppColors.grey700,
                    ),
                    const Spacer(),
                    _placeholder(
                      width: AppGrid.grid36,
                      height: AppGrid.grid12,
                      color: AppColors.grey700,
                    ),
                    const Spacer(),
                    _placeholder(
                      width: AppGrid.grid64,
                      height: AppGrid.grid12,
                      color: AppColors.grey700,
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
