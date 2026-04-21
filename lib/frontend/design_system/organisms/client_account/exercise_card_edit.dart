import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../atoms/behaviors/pressable_surface.dart';
import '../../atoms/inputs/formatters/hold_duration_formatter.dart';
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
import 'exercise_types.dart';

/// Organism: edit-mode exercise card.
///
/// Composes [ExerciseFlowCarousel], score/name/delete header, muscle-group
/// pill, a **primary metric field** (Rep integer OR Hold MM:SS — selected by
/// [type]), a Sets 3D field, a [FilterButton] swap control, and an
/// [EquipmentField] — whose variant ([EquipmentFieldType]) is determined by the
/// exercise's equipment type.
///
/// Focus-driven border colors for the primary field and Sets are owned here;
/// the organism attaches listeners to the incoming focus nodes.
///
/// **Template owns:** every controller and focus node. When [type] is
/// [ExerciseType.rep], [repController] and [repFocusNode] are required and
/// [holdController]/[holdFocusNode] must be null. When [type] is
/// [ExerciseType.hold], it's the reverse. The Hold field auto-formats input
/// as `MM:SS` via [HoldDurationFormatter]; minimum-value enforcement is the
/// template's job on focus loss.
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

  /// Selects which primary field renders: Rep (integer) or Hold (MM:SS).
  final ExerciseType type;

  // ── Rep field (required when type == rep) ──
  final TextEditingController? repController;
  final FocusNode? repFocusNode;

  // ── Hold field (required when type == hold) ──
  final TextEditingController? holdController;
  final FocusNode? holdFocusNode;

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

  /// When true, renders the card's outer border in [AppColors.textPrimary]
  /// to indicate a selected state (e.g. Select mode in the Exercise Plan).
  final bool isSelected;

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
    required this.type,
    this.repController,
    this.repFocusNode,
    this.holdController,
    this.holdFocusNode,
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
    this.isSelected = false,
  })  : assert(
          type != ExerciseType.rep ||
              (repController != null && repFocusNode != null),
          'Rep-type exercise requires repController and repFocusNode.',
        ),
        assert(
          type != ExerciseType.hold ||
              (holdController != null && holdFocusNode != null),
          'Hold-type exercise requires holdController and holdFocusNode.',
        );

  @override
  State<ExerciseCardEdit> createState() => _ExerciseCardEditState();
}

class _ExerciseCardEditState extends State<ExerciseCardEdit> {
  Color _primaryBorderColor = AppColors.surfaceBorder;
  Color _setsBorderColor = AppColors.surfaceBorder;

  FocusNode get _primaryFocusNode => switch (widget.type) {
        ExerciseType.rep => widget.repFocusNode!,
        ExerciseType.hold => widget.holdFocusNode!,
      };

  @override
  void initState() {
    super.initState();
    _primaryFocusNode.addListener(_onPrimaryFocusChange);
    widget.setsFocusNode.addListener(_onSetsFocusChange);
  }

  @override
  void didUpdateWidget(ExerciseCardEdit old) {
    super.didUpdateWidget(old);
    final oldPrimary = switch (old.type) {
      ExerciseType.rep => old.repFocusNode!,
      ExerciseType.hold => old.holdFocusNode!,
    };
    if (oldPrimary != _primaryFocusNode || old.type != widget.type) {
      oldPrimary.removeListener(_onPrimaryFocusChange);
      _primaryFocusNode.addListener(_onPrimaryFocusChange);
    }
    if (old.setsFocusNode != widget.setsFocusNode) {
      old.setsFocusNode.removeListener(_onSetsFocusChange);
      widget.setsFocusNode.addListener(_onSetsFocusChange);
    }
  }

  @override
  void dispose() {
    _primaryFocusNode.removeListener(_onPrimaryFocusChange);
    widget.setsFocusNode.removeListener(_onSetsFocusChange);
    super.dispose();
  }

  void _onPrimaryFocusChange() {
    setState(() {
      _primaryBorderColor =
          _primaryFocusNode.hasFocus ? AppColors.brand : AppColors.surfaceBorder;
    });
  }

  void _onSetsFocusChange() {
    setState(() {
      _setsBorderColor =
          widget.setsFocusNode.hasFocus ? AppColors.brand : AppColors.surfaceBorder;
    });
  }

  Widget _buildPrimaryField() {
    return switch (widget.type) {
      ExerciseType.rep => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Rep',
              style: AppTypography.bodySmall.regular,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: AppGrid.grid4),
            AppTextField3D(
              controller: widget.repController!,
              focusNode: widget.repFocusNode!,
              borderColor: _primaryBorderColor,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            ),
          ],
        ),
      ExerciseType.hold => Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            AppText(
              'Hold',
              style: AppTypography.bodySmall.regular,
              color: AppColors.textPrimary,
            ),
            const SizedBox(height: AppGrid.grid4),
            AppTextField3D(
              controller: widget.holdController!,
              focusNode: widget.holdFocusNode!,
              borderColor: _primaryBorderColor,
              keyboardType: TextInputType.number,
              inputFormatters: [HoldDurationFormatter()],
            ),
          ],
        ),
    };
  }

  @override
  Widget build(BuildContext context) {
    return ClipRRect(
      borderRadius: BorderRadius.circular(AppRadius.md),
      child: Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(
          color: widget.isSelected
              ? AppColors.textPrimary
              : AppColors.surfaceBorder,
          width: AppStroke.xs,
        ),
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

            // ── Primary (Rep OR Hold) + Sets row ──
            Row(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Expanded(child: _buildPrimaryField()),
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
