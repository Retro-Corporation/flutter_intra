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
/// metrics (rep/hold, set count, equipment). Composes [ScoreBadge]
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

  /// First metric label — e.g. "Rep" or "Hold".
  final String repLabel;

  /// First metric value — e.g. "6" or "00:45".
  final String repValue;

  /// Second metric label — e.g. "Set".
  final String setLabel;

  /// Second metric value — e.g. "4".
  final String setValue;

  /// Equipment label (e.g. "Dumbell"). When longer than 4 characters, it's
  /// truncated internally to 4 + "...". When both [equipmentLabel] and
  /// [equipmentValue] are null, the equipment slot is omitted entirely.
  final String? equipmentLabel;

  /// Equipment measurement value (e.g. "15lb"). Null is allowed.
  final String? equipmentValue;

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
    required this.repLabel,
    required this.repValue,
    required this.setLabel,
    required this.setValue,
    this.equipmentLabel,
    this.equipmentValue,
    required this.onTap,
    this.isSelected = false,
  });

  String get _truncatedEquipmentLabel {
    if (equipmentLabel == null) return '';
    return equipmentLabel!.length > 4
        ? '${equipmentLabel!.substring(0, 4)}...'
        : equipmentLabel!;
  }

  bool get _hasEquipment =>
      equipmentLabel != null || equipmentValue != null;

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

                // ── Metrics row — three label/value groups distributed
                // by spaceBetween. Equipment group is Flexible so its
                // value (not the label) is the thing that clips on
                // pathologically narrow viewports.
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    _MetricGroup(label: repLabel, value: repValue),
                    _MetricGroup(label: setLabel, value: setValue),
                    if (_hasEquipment)
                      Flexible(
                        child: _MetricGroup(
                          label: _truncatedEquipmentLabel,
                          value: equipmentValue,
                          ellipsizeValue: true,
                        ),
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

/// One label/value pair in the metrics row. File-private — its structure
/// only makes sense inside [ExerciseCardRead] (CCP).
class _MetricGroup extends StatelessWidget {
  final String label;
  final String? value;
  final bool ellipsizeValue;

  const _MetricGroup({
    required this.label,
    this.value,
    this.ellipsizeValue = false,
  });

  @override
  Widget build(BuildContext context) {
    final labelText = AppText(
      label,
      style: AppTypography.bodySmall.bold,
      color: AppColors.textPrimary,
      maxLines: 1,
    );

    if (value == null) {
      return labelText;
    }

    final valueText = AppText(
      value!,
      style: AppTypography.bodySmall.bold,
      color: AppColors.textPrimary,
      maxLines: 1,
      overflow: ellipsizeValue ? TextOverflow.ellipsis : null,
    );

    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        labelText,
        const SizedBox(width: AppGrid.grid4),
        if (ellipsizeValue) Flexible(child: valueText) else valueText,
      ],
    );
  }
}
