import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/motion/curves.dart';
import '../../foundation/motion/durations.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/space/stroke.dart';
import '../../foundation/type/typography.dart';
import '../../atoms/primitives/text.dart';
import '../../atoms/primitives/scheme_option_row.dart';
import 'label_option_picker_types.dart';

/// Generic label-only picker panel organism.
///
/// Renders a titled panel of selectable [LabelOption]s in either a single
/// column or a 2-column grid, depending on [layout]. Fires [onSelected] when
/// the user taps an option — does not manage selection state internally.
///
/// Entry animation: fade + slide (5 % vertical offset), mirroring
/// [EquipmentPickerPanel]. Uses [AppDurations.toggle] + [AppCurves.toggle].
///
/// This widget is the overlay content only — it does not manage its own
/// overlay. The caller controls visibility and positioning.
class LabelOptionPickerPanel extends StatefulWidget {
  const LabelOptionPickerPanel({
    super.key,
    required this.title,
    required this.options,
    required this.selectedId,
    required this.onSelected,
    required this.layout,
  });

  /// Header label shown above the options (e.g. "Body Segments").
  final String title;

  /// The full list of selectable options.
  final List<LabelOption> options;

  /// The [LabelOption.id] of the currently selected option, or null.
  final String? selectedId;

  /// Called with the tapped [LabelOption] when the user makes a selection.
  final ValueChanged<LabelOption> onSelected;

  /// Whether to render options in a single column or a 2-column grid.
  final LabelPickerLayout layout;

  @override
  State<LabelOptionPickerPanel> createState() => _LabelOptionPickerPanelState();
}

class _LabelOptionPickerPanelState extends State<LabelOptionPickerPanel>
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
            color: AppColors.surface,
            border: Border.all(
              color: AppColors.textPrimary,
              width: AppStroke.md,
            ),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppGrid.grid16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText(
                  widget.title,
                  style: AppTypography.body.bold,
                  color: AppColors.textPrimary,
                ),
                SizedBox(height: AppGrid.grid8),
                _buildBody(),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildBody() {
    return switch (widget.layout) {
      LabelPickerLayout.column => _buildColumn(),
      LabelPickerLayout.grid2 => _buildGrid2(),
    };
  }

  Widget _buildColumn() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: widget.options
          .map((opt) => SchemeOptionRow(
                label: opt.label,
                isSelected: opt.id == widget.selectedId,
                onTap: () => widget.onSelected(opt),
              ))
          .toList(),
    );
  }

  Widget _buildGrid2() {
    final rowCount = (widget.options.length / 2).ceil();
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(rowCount, (i) {
        final leftOpt = widget.options[i * 2];
        final rightIndex = i * 2 + 1;
        final isLastRow = i == rowCount - 1;
        return Padding(
          padding: EdgeInsets.only(
            bottom: isLastRow ? 0 : AppGrid.grid4,
          ),
          child: Row(
            children: [
              Expanded(
                child: SchemeOptionRow(
                  label: leftOpt.label,
                  isSelected: leftOpt.id == widget.selectedId,
                  onTap: () => widget.onSelected(leftOpt),
                ),
              ),
              SizedBox(width: AppGrid.grid8),
              Expanded(
                child: rightIndex < widget.options.length
                    ? SchemeOptionRow(
                        label: widget.options[rightIndex].label,
                        isSelected:
                            widget.options[rightIndex].id == widget.selectedId,
                        onTap: () =>
                            widget.onSelected(widget.options[rightIndex]),
                      )
                    : const SizedBox(),
              ),
            ],
          ),
        );
      }),
    );
  }
}
