import 'package:flutter/material.dart';
import '../../atoms/behaviors/pressable_surface.dart';
import '../../atoms/primitives/score_badge.dart';
import '../../atoms/primitives/score_badge_types.dart';
import '../../atoms/primitives/text.dart';
import '../../atoms/primitives/thumbnail.dart';
import '../../atoms/primitives/thumbnail_types.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/padding.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/space/stroke.dart';
import '../../foundation/type/typography.dart';

/// Molecule: read-only exercise card for the exercise list.
///
/// Displays score, exercise name, muscle group badge, and three
/// metrics (rep range, set count, equipment). Composes [ScoreBadge]
/// and [AppText] atoms — no interaction state of its own.
///
/// Wrap in a [GestureDetector] or supply [onTap] to make it tappable.
class ExerciseCardRead extends StatelessWidget {
  final double score;

  /// Underline color for [ScoreBadge] — resolved by caller from domain state.
  final Color scoreColor;

  final ScoreBadgeVariant scoreVariant;
  final String exerciseName;

  /// Muscle group label shown as a full-width pill badge (e.g. "Shoulder flexion").
  final String muscleGroup;

  /// Rep count or hold duration (e.g. "Rep 3" or "Hold 1:30").
  final String reps;
  final String setCount;
  final String equipment;
  final VoidCallback onTap;

  /// When true, renders the card's border in [AppColors.textPrimary]
  /// to indicate a selected state (e.g. Select mode in the Exercise Plan).
  final bool isSelected;

  const ExerciseCardRead({
    super.key,
    required this.score,
    required this.scoreColor,
    required this.scoreVariant,
    required this.exerciseName,
    required this.muscleGroup,
    required this.reps,
    required this.setCount,
    required this.equipment,
    required this.onTap,
    this.isSelected = false,
  });

  @override
  Widget build(BuildContext context) {
    return PressableSurface(
      onTap: onTap,
      backgroundColor: AppColors.surface,
      borderColor:
          isSelected ? AppColors.textPrimary : AppColors.surfaceBorder,
      borderRadius: AppRadius.md,
      child: Padding(
        padding: const EdgeInsets.all(AppPadding.rem075),
        child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // ── Thumbnail ──
          const Thumbnail(size: ThumbnailSize.size100),

          const SizedBox(width: AppGrid.grid12),

          // ── Content — fixed to thumbnail height so metrics pin to bottom ──
          Expanded(
            child: SizedBox(
              height: AppGrid.grid100,
              child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                // ── Score + name ──
                Row(
                  children: [
                    ScoreBadge(
                      score: score,
                      underlineColor: scoreColor,
                      size: ScoreBadgeSize.sm,
                      variant: scoreVariant,
                    ),
                    const SizedBox(width: AppGrid.grid8),
                    Expanded(
                      child: AppText(
                        exerciseName,
                        style: AppTypography.body.bold,
                        color: AppColors.textPrimary,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                      ),
                    ),
                  ],
                ),

                // ── Muscle group pill badge ──
                Container(
                  height: AppGrid.grid28,
                  width: double.infinity,
                  decoration: BoxDecoration(
                    border: Border.all(
                        color: AppColors.surfaceBorder, width: AppStroke.xs),
                    borderRadius: BorderRadius.circular(AppRadius.pill),
                  ),
                  alignment: Alignment.center,
                  child: AppText(
                    muscleGroup,
                    style: AppTypography.bodySmall.regular,
                    color: AppColors.textPrimary,
                  ),
                ),

                // ── Metrics row ──
                Row(
                  children: [
                    AppText(
                      reps,
                      style: AppTypography.bodySmall.bold,
                      color: AppColors.textPrimary,
                    ),
                    const Spacer(),
                    AppText(
                      setCount,
                      style: AppTypography.bodySmall.bold,
                      color: AppColors.textPrimary,
                    ),
                    const Spacer(),
                    AppText(
                      equipment,
                      style: AppTypography.bodySmall.bold,
                      color: AppColors.textPrimary,
                    ),
                  ],
                ),
              ],
              ),
            ),
          ),
        ],
        ),
      ),
    );
  }
}
