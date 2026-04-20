import 'package:flutter/material.dart';
import '../../atoms/controls/button.dart';
import '../../atoms/controls/button_types.dart';
import '../../atoms/primitives/scheme_option_row.dart';
import '../../atoms/primitives/text.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/motion/curves.dart';
import '../../foundation/motion/durations.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/type/typography.dart';
import '../../icons/app_icons.dart';
import 'set_scheme_picker_types.dart';

/// Organism: a panel for selecting a set scheme from grouped options.
///
/// Renders a scrollable list of [SetSchemeGroup]s, each with a header and
/// [SchemeOptionRow]s. Pinned below the scroll area is a full-width
/// "Create new" button that routes to a new scheme creation flow.
///
/// This widget is the overlay content — it does not manage its own overlay.
/// The template owns positioning: place this inside an [Overlay] with
///   top:    buttonBottom + [AppGrid.grid20]
///   bottom: [AppGrid.grid20]
/// so it fills the available vertical space between those bounds.
///
/// Entry animation fires once on mount ([AppDurations.toggle] /
/// [AppCurves.toggle]).
class SetSchemePickerPanel extends StatefulWidget {
  final List<SetSchemeGroup> groups;

  /// ID of the currently selected [SetScheme]. Null when nothing is selected.
  final String? selectedId;

  /// Called when the user taps a scheme row.
  final ValueChanged<SetScheme> onSelected;

  /// Called when the user taps "Create new". Navigation is a template concern.
  final VoidCallback onCreateNew;

  const SetSchemePickerPanel({
    super.key,
    required this.groups,
    required this.selectedId,
    required this.onSelected,
    required this.onCreateNew,
  });

  @override
  State<SetSchemePickerPanel> createState() => _SetSchemePickerPanelState();
}

class _SetSchemePickerPanelState extends State<SetSchemePickerPanel>
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
            border: Border.all(color: AppColors.textPrimary, width: 1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          child: Padding(
            padding: EdgeInsets.all(AppGrid.grid16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // ── Scrollable scheme list — shrinks to content, capped by
                // the parent's height constraint (Positioned bottom: grid20
                // in template, ConstrainedBox in catalog). ──
                Flexible(
                  child: SingleChildScrollView(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      crossAxisAlignment: CrossAxisAlignment.stretch,
                      children: _buildGroups(),
                    ),
                  ),
                ),
                // ── Divider ──
                Divider(
                  color: AppColors.surfaceBorder,
                  height: AppGrid.grid16,
                  thickness: 1,
                ),
                // ── Create new button ──
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    leadingIcon: AppIcons.add,
                    label: 'Create new',
                    type: ButtonType.outline,
                    color: AppColors.textPrimary,
                    size: ButtonSize.md,
                    onPressed: widget.onCreateNew,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  List<Widget> _buildGroups() {
    final children = <Widget>[];
    for (var i = 0; i < widget.groups.length; i++) {
      if (i > 0) children.add(SizedBox(height: AppGrid.grid8));
      final group = widget.groups[i];
      children.add(
        AppText(
          group.name,
          style: AppTypography.bodySmall.semiBold,
          color: AppColors.textSecondary,
        ),
      );
      children.add(SizedBox(height: AppGrid.grid8));
      for (final scheme in group.schemes) {
        children.add(
          SchemeOptionRow(
            label: scheme.label,
            isSelected: scheme.id == widget.selectedId,
            onTap: () => widget.onSelected(scheme),
          ),
        );
      }
    }
    return children;
  }
}
