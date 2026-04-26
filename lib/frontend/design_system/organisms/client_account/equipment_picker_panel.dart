import 'package:flutter/material.dart';

import '../../atoms/behaviors/dashed_border.dart';
import '../../atoms/primitives/badge.dart';
import '../../atoms/primitives/badge_types.dart';
import '../../atoms/primitives/icon.dart';
import '../../atoms/primitives/scheme_option_row.dart';
import '../../atoms/primitives/text.dart';
import '../../molecules/controls/thumbnail_option_row.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/motion/curves.dart';
import '../../foundation/motion/durations.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/padding.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/opacity.dart';
import '../../foundation/space/stroke.dart';
import '../../foundation/type/typography.dart';
import '../../icons/app_icons.dart';
import '../../icons/icon_sizes.dart';
import 'equipment_picker_types.dart';

/// Organism: a panel listing selectable equipment options for an exercise.
///
/// Renders a section title followed by a scrollable list of [EquipmentOption]s
/// as [SchemeOptionRow]s. Exactly one option is active at a time — parent
/// owns [selectedId] and listens via [onSelected].
///
/// Two variants are available via [EquipmentPickerVariant]:
/// - [EquipmentPickerVariant.simple]: label-only rows (default, unchanged).
/// - [EquipmentPickerVariant.withFilters]: adds a horizontally-scrollable
///   category chip row, a subtitle label, thumbnail + label rows, an empty
///   state, and a dashed-border "Add New Equipment" footer. Filtering is the
///   **parent's responsibility** — pass a pre-filtered [options] list.
///
/// This widget is the overlay content only — it does not manage its own
/// overlay. The template or organism above owns positioning: place this inside
/// an [Overlay] or [Stack] aligned below the equipment field dropdown.
///
/// Entry animation fires once on mount ([AppDurations.toggle] /
/// [AppCurves.toggle]).
class EquipmentPickerPanel extends StatefulWidget {
  /// Panel header label — e.g. "Equipment category".
  final String title;

  /// The selectable equipment options to render. When using [withFilters],
  /// the caller pre-filters this list before passing it in.
  final List<EquipmentOption> options;

  /// ID of the currently selected [EquipmentOption]. Null when nothing selected.
  final String? selectedId;

  /// Called when the user taps an option row.
  final ValueChanged<EquipmentOption> onSelected;

  /// Which layout variant to render. Defaults to [EquipmentPickerVariant.simple].
  final EquipmentPickerVariant variant;

  // ── withFilters-only props ────────────────────────────────────────────────

  /// Category chips shown in the filter row.
  /// Required when [variant] == [EquipmentPickerVariant.withFilters].
  final List<EquipmentFilterCategory>? categories;

  /// ID of the currently active category chip. Null means no filter applied.
  final String? selectedCategoryId;

  /// Called when the user taps a chip. Passes the tapped [EquipmentFilterCategory]
  /// to select it, or null when the user taps × to clear the selection.
  /// Required when [variant] == [EquipmentPickerVariant.withFilters].
  final ValueChanged<EquipmentFilterCategory?>? onCategoryChanged;

  /// Label rendered above the options list — e.g. "Sub title".
  /// Required when [variant] == [EquipmentPickerVariant.withFilters].
  final String? subtitle;

  /// Reserved for future use — the panel renders placeholder thumbnails only.
  final Map<String, String>? thumbnailByEquipmentId;

  /// Called when the user taps the "+ Add New Equipment" footer row.
  /// Required when [variant] == [EquipmentPickerVariant.withFilters].
  final VoidCallback? onAddNew;

  /// Called when the user re-taps the already-selected option to deselect it.
  /// The panel stays open — caller sets [selectedId] to null. Optional.
  final VoidCallback? onDeselected;

  const EquipmentPickerPanel({
    super.key,
    required this.title,
    required this.options,
    required this.selectedId,
    required this.onSelected,
    this.variant = EquipmentPickerVariant.simple,
    this.categories,
    this.selectedCategoryId,
    this.onCategoryChanged,
    this.subtitle,
    this.thumbnailByEquipmentId,
    this.onAddNew,
    this.onDeselected,
  }) : assert(
          variant == EquipmentPickerVariant.simple ||
              (categories != null &&
                  onCategoryChanged != null &&
                  subtitle != null &&
                  onAddNew != null),
          'withFilters variant requires categories, onCategoryChanged, '
          'subtitle, and onAddNew.',
        );

  @override
  State<EquipmentPickerPanel> createState() => _EquipmentPickerPanelState();
}

class _EquipmentPickerPanelState extends State<EquipmentPickerPanel>
    with SingleTickerProviderStateMixin {
  // Vertical slide distance for the panel entry animation.
  static const _kEntrySlideOffset = Offset(0, 0.05);

  bool _addNewPressed = false;

  // Local display state — owns what is shown as selected. Initialized from
  // widget.selectedId and synced whenever the parent changes it. Lets the
  // panel highlight/deselect instantly without waiting for a parent round-trip.
  String? _effectiveSelectedId;

  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  @override
  void initState() {
    super.initState();
    _effectiveSelectedId = widget.selectedId;
    _entryController = AnimationController(
      vsync: this,
      duration: AppDurations.toggle,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: AppCurves.toggle,
    );
    _slideAnimation = Tween<Offset>(
      begin: _kEntrySlideOffset,
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: AppCurves.toggle,
    ));
    _entryController.forward();
  }

  @override
  void didUpdateWidget(EquipmentPickerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    // When the parent changes selectedId (e.g., a new option was committed),
    // sync the display state so the panel always reflects the parent's truth.
    if (oldWidget.selectedId != widget.selectedId) {
      _effectiveSelectedId = widget.selectedId;
    }
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
            padding: const EdgeInsets.all(AppGrid.grid16),
            child: switch (widget.variant) {
              EquipmentPickerVariant.simple => _buildSimple(),
              EquipmentPickerVariant.withFilters => _buildWithFilters(),
            },
          ),
        ),
      ),
    );
  }

  // ── simple ────────────────────────────────────────────────────────────────

  Widget _buildSimple() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          widget.title,
          style: AppTypography.bodySmall.semiBold,
          color: AppColors.textSecondary,
        ),
        const SizedBox(height: AppGrid.grid8),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: AppGrid.grid240),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
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
      ],
    );
  }

  // ── withFilters ───────────────────────────────────────────────────────────

  Widget _buildWithFilters() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppText(
          widget.title,
          style: AppTypography.body.bold,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: AppGrid.grid12),
        _buildChipRow(),
        const SizedBox(height: AppGrid.grid16),
        ConstrainedBox(
          constraints: const BoxConstraints(maxHeight: AppGrid.grid240),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                AppText(
                  widget.subtitle!,
                  style: AppTypography.body.bold,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(height: AppGrid.grid12),
                _buildOptionsList(),
                const SizedBox(height: AppGrid.grid12),
                _buildAddNewFooter(),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildChipRow() {
    // Selected chip floats to the front of the row.
    final ordered = [
      ...widget.categories!.where((c) => c.id == widget.selectedCategoryId),
      ...widget.categories!.where((c) => c.id != widget.selectedCategoryId),
    ];
    // Fixed height matches BadgeSize.md (32px). AnimatedSwitcher
    // crossfades the full row on every selection change — matching the
    // CategoryFilterOrganism pattern — so individual badge state snaps are
    // never visible.
    return SizedBox(
      height: AppGrid.grid32,
      child: AnimatedSwitcher(
        duration: AppDurations.toggle,
        switchInCurve: AppCurves.toggle,
        switchOutCurve: AppCurves.toggle,
        child: SingleChildScrollView(
          key: ValueKey(widget.selectedCategoryId),
          scrollDirection: Axis.horizontal,
          physics: const BouncingScrollPhysics(),
          child: Row(
              children: [
                for (int i = 0; i < ordered.length; i++) ...[
                  if (i > 0) const SizedBox(width: AppGrid.grid8),
                  _buildChip(ordered[i]),
                ],
              ],
            ),
          ),
      ),
    );
  }

  Widget _buildChip(EquipmentFilterCategory category) {
    final isSelected = category.id == widget.selectedCategoryId;
    return AppBadge(
      label: category.label,
      leadingIcon: isSelected ? AppIcons.close : null,
      type: isSelected ? BadgeType.filled : BadgeType.outline,
      color: isSelected ? AppColors.brand : AppColors.textPrimary,
      size: BadgeSize.md,
      minWidth: AppGrid.grid60,
      onTap: isSelected
          ? () => widget.onCategoryChanged!(null)
          : () => widget.onCategoryChanged!(category),
    );
  }

  Widget _buildOptionsList() {
    if (widget.options.isEmpty) {
      return AppText(
        'No equipment in this category yet',
        style: AppTypography.bodySmall.regular,
        color: AppColors.textSecondary,
      );
    }
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        for (int i = 0; i < widget.options.length; i++) ...[
          if (i > 0) const SizedBox(height: AppGrid.grid8),
          ThumbnailOptionRow(
            label: widget.options[i].label,
            isSelected: widget.options[i].id == _effectiveSelectedId,
            onTap: () {
              final option = widget.options[i];
              if (option.id == _effectiveSelectedId) {
                // Re-tapping the selected item → deselect immediately, stay open.
                setState(() => _effectiveSelectedId = null);
                widget.onDeselected?.call();
              } else {
                // New selection → highlight and notify parent immediately.
                // Panel stays open — dismissal is the caller's responsibility.
                setState(() => _effectiveSelectedId = option.id);
                widget.onSelected(option);
              }
            },
          ),
        ],
      ],
    );
  }

  Widget _buildAddNewFooter() {
    return DashedBorderContainer(
      borderColor: AppColors.surfaceBorder,
      borderRadius: AppRadius.sm,
      child: GestureDetector(
        onTapDown: (_) => setState(() => _addNewPressed = true),
        onTapUp: (_) {
          setState(() => _addNewPressed = false);
          widget.onAddNew?.call();
        },
        onTapCancel: () => setState(() => _addNewPressed = false),
        child: AnimatedContainer(
          duration: AppDurations.press,
          curve: AppCurves.press,
          decoration: BoxDecoration(
            color: _addNewPressed
                ? AppColors.textPrimary.withValues(alpha: AppOpacity.ghostPressed)
                : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.sm),
          ),
          padding: const EdgeInsets.symmetric(
            vertical: AppPadding.rem075,
            horizontal: AppGrid.grid12,
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              AppIcon(
                AppIcons.add,
                size: IconSizes.md,
                color: AppColors.textPrimary,
              ),
              const SizedBox(width: AppGrid.grid8),
              AppText(
                'Add New Equipment',
                style: AppTypography.body.bold,
                color: AppColors.textPrimary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
