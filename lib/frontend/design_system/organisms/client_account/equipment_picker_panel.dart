import 'package:flutter/material.dart';
import '../../atoms/primitives/scheme_option_row.dart';
import '../../atoms/primitives/text.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/motion/curves.dart';
import '../../foundation/motion/durations.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/space/stroke.dart';
import '../../foundation/type/typography.dart';
import 'equipment_picker_types.dart';

/// Organism: a panel listing selectable equipment options for an exercise.
///
/// Renders a section title followed by a scrollable list of [EquipmentOption]s
/// as [SchemeOptionRow]s. Exactly one option is active at a time — parent
/// owns [selectedId] and listens via [onSelected].
///
/// This widget is the overlay content only — it does not manage its own
/// overlay. The template or organism above owns positioning: place this inside
/// an [Overlay] or [Stack] aligned below the [EquipmentField] dropdown.
///
/// Entry animation fires once on mount ([AppDurations.toggle] /
/// [AppCurves.toggle]).
class EquipmentPickerPanel extends StatefulWidget {
  /// Panel header label — e.g. "Related equipment".
  final String title;

  /// The selectable equipment options for this exercise.
  final List<EquipmentOption> options;

  /// ID of the currently selected [EquipmentOption]. Null when nothing selected.
  final String? selectedId;

  /// Called when the user taps an option row.
  final ValueChanged<EquipmentOption> onSelected;

  const EquipmentPickerPanel({
    super.key,
    required this.title,
    required this.options,
    required this.selectedId,
    required this.onSelected,
  });

  @override
  State<EquipmentPickerPanel> createState() => _EquipmentPickerPanelState();
}

class _EquipmentPickerPanelState extends State<EquipmentPickerPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: AppDurations.toggle,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: AppCurves.toggle,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.05),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: AppCurves.toggle,
    ));
    _entryController.forward();
  }

  @override
  void dispose() {
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: DecoratedBox(
          decoration: BoxDecoration(
            color: AppColors.grey850,
            border: Border.all(color: AppColors.textPrimary, width: AppStroke.xs),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppGrid.grid16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  AppText(
                    widget.title,
                    style: AppTypography.bodySmall.semiBold,
                    color: AppColors.textSecondary,
                  ),
                  const SizedBox(height: AppGrid.grid8),
                  for (final option in widget.options)
                    SchemeOptionRow(
                      label: option.label,
                      isSelected: option.id == widget.selectedId,
                      onTap: () => widget.onSelected(option),
                    ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
