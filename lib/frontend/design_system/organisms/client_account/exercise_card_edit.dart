import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../atoms/behaviors/pressable_surface.dart';
import '../../atoms/inputs/text_field_3d.dart';
import '../../atoms/primitives/icon.dart';
import '../../atoms/primitives/score_badge.dart';
import '../../atoms/primitives/score_badge_types.dart';
import '../../atoms/primitives/text.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/space/stroke.dart';
import '../../foundation/type/typography.dart';
import '../../icons/app_icons.dart';
import '../../icons/icon_sizes.dart';
import '../../molecules/cards/exercise_flow_carousel.dart';
import '../../molecules/form_fields/equipment_field.dart';
import '../../molecules/form_fields/equipment_field_types.dart';

/// Organism: edit-mode exercise card.
///
/// Composes [ExerciseFlowCarousel], score/name/delete header, muscle-group
/// pill, Rep + Sets 3D fields, a [FilterButton] swap control, and an
/// [EquipmentField] — whose variant ([EquipmentFieldType]) is determined by the
/// exercise's equipment type.
///
/// Focus-driven border colors for Rep and Sets are owned here; the organism
/// attaches listeners to the incoming focus nodes.
///
/// **Template owns:** [repController], [setsController], [repFocusNode],
/// [setsFocusNode], and any equipment controller/focus node. This organism
/// never creates or disposes them.
class ExerciseCardEdit extends StatefulWidget {
  // ── Carousel ──
  final List<String?> thumbnails;
  final int currentIndex;
  final ValueChanged<int> onIndexChanged;

  // ── Score / header ──
  final double score;
  final Color scoreColor;
  final ScoreBadgeVariant scoreVariant;
  final String exerciseName;

  /// Muscle group label shown as a full-width pill badge (e.g. "Shoulder flexion").
  final String muscleGroup;

  // ── Rep field ──
  final TextEditingController repController;
  final FocusNode repFocusNode;

  // ── Sets field ──
  final TextEditingController setsController;
  final FocusNode setsFocusNode;

  // ── Equipment field (passed through to EquipmentField) ──

  /// Label rendered above the equipment field.
  /// Varies by exercise: e.g. "Dumbbell" for numbered, "Equipment" for others.
  final String equipmentLabel;

  final EquipmentFieldType equipmentType;

  // numbered
  final TextEditingController? equipmentController;
  final FocusNode? equipmentFocusNode;

  /// Unit suffix for numbered variant: 'lb' or 'kg'.
  final String equipmentUnit;

  // selectable
  final String? selectedEquipmentValue;
  final VoidCallback? onEquipmentDropdownTap;
  final bool isEquipmentDropdownOpen;

  // staticDisplay
  final String? staticEquipmentValue;

  // ── Actions ──
  final VoidCallback onDelete;
  final VoidCallback onSwap;

  const ExerciseCardEdit({
    super.key,
    required this.thumbnails,
    required this.currentIndex,
    required this.onIndexChanged,
    required this.score,
    required this.scoreColor,
    required this.scoreVariant,
    required this.exerciseName,
    required this.muscleGroup,
    required this.repController,
    required this.repFocusNode,
    required this.setsController,
    required this.setsFocusNode,
    required this.equipmentLabel,
    required this.equipmentType,
    this.equipmentController,
    this.equipmentFocusNode,
    this.equipmentUnit = 'lb',
    this.selectedEquipmentValue,
    this.onEquipmentDropdownTap,
    this.isEquipmentDropdownOpen = false,
    this.staticEquipmentValue,
    required this.onDelete,
    required this.onSwap,
  });

  @override
  State<ExerciseCardEdit> createState() => _ExerciseCardEditState();
}

class _ExerciseCardEditState extends State<ExerciseCardEdit> {
  Color _repBorderColor = AppColors.surfaceBorder;
  Color _setsBorderColor = AppColors.surfaceBorder;

  @override
  void initState() {
    super.initState();
    widget.repFocusNode.addListener(_onRepFocusChange);
    widget.setsFocusNode.addListener(_onSetsFocusChange);
  }

  @override
  void didUpdateWidget(ExerciseCardEdit old) {
    super.didUpdateWidget(old);
    if (old.repFocusNode != widget.repFocusNode) {
      old.repFocusNode.removeListener(_onRepFocusChange);
      widget.repFocusNode.addListener(_onRepFocusChange);
    }
    if (old.setsFocusNode != widget.setsFocusNode) {
      old.setsFocusNode.removeListener(_onSetsFocusChange);
      widget.setsFocusNode.addListener(_onSetsFocusChange);
    }
  }

  @override
  void dispose() {
    widget.repFocusNode.removeListener(_onRepFocusChange);
    widget.setsFocusNode.removeListener(_onSetsFocusChange);
    super.dispose();
  }

  void _onRepFocusChange() {
    setState(() {
      _repBorderColor =
          widget.repFocusNode.hasFocus ? AppColors.brand : AppColors.surfaceBorder;
    });
  }

  void _onSetsFocusChange() {
    setState(() {
      _setsBorderColor =
          widget.setsFocusNode.hasFocus ? AppColors.brand : AppColors.surfaceBorder;
    });
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.surfaceBorder, width: AppStroke.xs),
      ),
      child: Padding(
        padding: const EdgeInsets.all(AppGrid.grid20),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // ── Carousel ──
            ExerciseFlowCarousel(
              thumbnails: widget.thumbnails,
              currentIndex: widget.currentIndex,
              onIndexChanged: widget.onIndexChanged,
            ),

            const SizedBox(height: AppGrid.grid12),

            // ── Score + name + delete ──
            Row(
              children: [
                ScoreBadge(
                  score: widget.score,
                  underlineColor: widget.scoreColor,
                  size: ScoreBadgeSize.sm,
                  variant: widget.scoreVariant,
                ),
                const SizedBox(width: AppGrid.grid8),
                Expanded(
                  child: AppText(
                    widget.exerciseName,
                    style: AppTypography.body.bold,
                    color: AppColors.textPrimary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
                GestureDetector(
                  onTap: widget.onDelete,
                  child: AppIcon(
                    AppIcons.delete,
                    size: IconSizes.md,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppGrid.grid8),

            // ── Muscle group pill ──
            Container(
              height: AppGrid.grid28,
              decoration: BoxDecoration(
                border: Border.all(color: AppColors.surfaceBorder, width: AppStroke.xs),
                borderRadius: BorderRadius.circular(AppRadius.pill),
              ),
              alignment: Alignment.center,
              child: AppText(
                widget.muscleGroup,
                style: AppTypography.bodySmall.regular,
                color: AppColors.textPrimary,
              ),
            ),

            const SizedBox(height: AppGrid.grid12),

            // ── Rep + Sets row ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Rep',
                        style: AppTypography.bodySmall.regular,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: AppGrid.grid4),
                      AppTextField3D(
                        controller: widget.repController,
                        focusNode: widget.repFocusNode,
                        borderColor: _repBorderColor,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ],
                  ),
                ),
                const SizedBox(width: AppGrid.grid12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Sets',
                        style: AppTypography.bodySmall.regular,
                        color: AppColors.textPrimary,
                      ),
                      const SizedBox(height: AppGrid.grid4),
                      AppTextField3D(
                        controller: widget.setsController,
                        focusNode: widget.setsFocusNode,
                        borderColor: _setsBorderColor,
                        keyboardType: TextInputType.number,
                        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
                      ),
                    ],
                  ),
                ),
              ],
            ),

            const SizedBox(height: AppGrid.grid12),

            // ── Swap + Equipment row ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      'Swap',
                      style: AppTypography.bodySmall.regular,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(height: AppGrid.grid4),
                    SizedBox(
                      height: AppGrid.grid48,
                      width: AppGrid.grid48,
                      child: PressableSurface(
                        backgroundColor: AppColors.surface,
                        borderColor: AppColors.surfaceBorder,
                        borderRadius: AppRadius.sm,
                        onTap: widget.onSwap,
                        child: Center(
                          child: AppIcon(
                            AppIcons.refresh,
                            size: IconSizes.md,
                            color: AppColors.textPrimary,
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(width: AppGrid.grid12),
                Expanded(
                  child: EquipmentField(
                    label: widget.equipmentLabel,
                    type: widget.equipmentType,
                    controller: widget.equipmentController,
                    focusNode: widget.equipmentFocusNode,
                    unit: widget.equipmentUnit,
                    selectedValue: widget.selectedEquipmentValue,
                    onDropdownTap: widget.onEquipmentDropdownTap,
                    isDropdownOpen: widget.isEquipmentDropdownOpen,
                    staticValue: widget.staticEquipmentValue,
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
      ),
    );
  }
}
