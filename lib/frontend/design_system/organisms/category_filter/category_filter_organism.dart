import 'package:flutter/material.dart';

import '../../foundation/color/colors.dart';
import '../../foundation/motion/curves.dart';
import '../../foundation/motion/durations.dart';
import '../../foundation/space/grid.dart';
import '../../icons/app_icons.dart';
import '../../atoms/primitives/badge.dart';
import '../../atoms/primitives/badge_types.dart';
import 'category_filter_types.dart';

/// Organism: 3-row chip filter for category / body region / outcome selection.
///
/// Layout:
/// - Default: row 1 = overall chips, row 2 = body parts.
/// - Expanded (any overall or body part selected): row 1 merges the pinned
///   selections with the remaining body parts, row 2 becomes outcomes.
///
/// State is owned internally. Every selection change is reported via
/// [onFilterChanged] as a `(String? overall, String? bodyPart, String? outcome)`
/// tuple. The organism never navigates, never calls a service.
class CategoryFilterOrganism extends StatefulWidget {
  final List<CategoryChip> overallChips;
  final List<String> bodyPartChips;
  final List<String> outcomeChips;
  final void Function(String? overall, String? bodyPart, String? outcome)
      onFilterChanged;

  const CategoryFilterOrganism({
    super.key,
    required this.overallChips,
    required this.bodyPartChips,
    required this.outcomeChips,
    required this.onFilterChanged,
  });

  @override
  State<CategoryFilterOrganism> createState() => _CategoryFilterOrganismState();
}

class _CategoryFilterOrganismState extends State<CategoryFilterOrganism> {
  /// Fixed row height — matches the intrinsic height of [BadgeSize.md] (32px)
  /// plus an 8px buffer so focus rings / taps are not clipped. Uses the
  /// nearest existing AppGrid token (40).
  static const double _chipRowHeight = AppGrid.grid40;

  String? _selectedOverall;
  String? _selectedBodyPart;
  String? _selectedOutcome;

  final ScrollController _row1Scroll = ScrollController();
  final ScrollController _row2Scroll = ScrollController();

  bool get _isExpanded =>
      _selectedOverall != null || _selectedBodyPart != null;

  @override
  void dispose() {
    _row1Scroll.dispose();
    _row2Scroll.dispose();
    super.dispose();
  }

  // ── Tap handlers ──

  void _onOverallTap(String label) {
    setState(() {
      if (_selectedOverall == label) {
        _selectedOverall = null;
      } else {
        _selectedOverall = label;
        // Selecting a new overall clears dependent rows.
        _selectedBodyPart = null;
        _selectedOutcome = null;
      }
    });
    _scrollRowsToStart();
    _emitChange();
  }

  void _onBodyPartTap(String label) {
    setState(() {
      _selectedBodyPart = _selectedBodyPart == label ? null : label;
    });
    _scrollRowsToStart();
    _emitChange();
  }

  void _onOutcomeTap(String label) {
    setState(() {
      _selectedOutcome = _selectedOutcome == label ? null : label;
    });
    _scrollRowsToStart();
    _emitChange();
  }

  void _scrollRowsToStart() {
    for (final c in [_row1Scroll, _row2Scroll]) {
      if (c.hasClients) {
        c.animateTo(
          0,
          duration: AppDurations.toggle,
          curve: AppCurves.toggle,
        );
      }
    }
  }

  void _emitChange() {
    widget.onFilterChanged(
      _selectedOverall,
      _selectedBodyPart,
      _selectedOutcome,
    );
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        SizedBox(
          height: _chipRowHeight,
          child: AnimatedSwitcher(
            duration: AppDurations.toggle,
            switchInCurve: AppCurves.toggle,
            switchOutCurve: AppCurves.toggle,
            child: _isExpanded ? _buildExpandedRow1() : _buildDefaultRow1(),
          ),
        ),
        const SizedBox(height: AppGrid.grid8),
        SizedBox(
          height: _chipRowHeight,
          child: AnimatedSwitcher(
            duration: AppDurations.toggle,
            switchInCurve: AppCurves.toggle,
            switchOutCurve: AppCurves.toggle,
            child: _isExpanded ? _buildOutcomesRow() : _buildBodyPartsRow(),
          ),
        ),
      ],
    );
  }

  // ── Row builders ──

  Widget _buildDefaultRow1() {
    return _chipList(
      key: const ValueKey('row1-default'),
      controller: _row1Scroll,
      chips: [
        for (final chip in widget.overallChips)
          _OverallChipTile(
            chip: chip,
            selected: false,
            onTap: () => _onOverallTap(chip.label),
          ),
      ],
    );
  }

  Widget _buildExpandedRow1() {
    final tiles = <Widget>[];

    if (_selectedOverall != null) {
      final selectedChip = widget.overallChips.firstWhere(
        (c) => c.label == _selectedOverall,
        orElse: () => CategoryChip(label: _selectedOverall!),
      );
      tiles.add(_OverallChipTile(
        chip: selectedChip,
        selected: true,
        onTap: () => _onOverallTap(selectedChip.label),
      ));
    }

    if (_selectedBodyPart != null) {
      tiles.add(_BodyPartChipTile(
        label: _selectedBodyPart!,
        selected: true,
        onTap: () => _onBodyPartTap(_selectedBodyPart!),
      ));
    }

    for (final label in widget.bodyPartChips) {
      if (label == _selectedBodyPart) continue;
      tiles.add(_BodyPartChipTile(
        label: label,
        selected: false,
        onTap: () => _onBodyPartTap(label),
      ));
    }

    return _chipList(
      key: const ValueKey('row1-expanded'),
      controller: _row1Scroll,
      chips: tiles,
    );
  }

  Widget _buildBodyPartsRow() {
    return _chipList(
      key: const ValueKey('row2-bodyparts'),
      controller: _row2Scroll,
      chips: [
        for (final label in widget.bodyPartChips)
          _BodyPartChipTile(
            label: label,
            selected: false,
            onTap: () => _onBodyPartTap(label),
          ),
      ],
    );
  }

  Widget _buildOutcomesRow() {
    final tiles = <Widget>[];
    if (_selectedOutcome != null) {
      tiles.add(_OutcomeChipTile(
        label: _selectedOutcome!,
        selected: true,
        onTap: () => _onOutcomeTap(_selectedOutcome!),
      ));
    }
    for (final label in widget.outcomeChips) {
      if (label == _selectedOutcome) continue;
      tiles.add(_OutcomeChipTile(
        label: label,
        selected: false,
        onTap: () => _onOutcomeTap(label),
      ));
    }
    return _chipList(
      key: const ValueKey('row2-outcomes'),
      controller: _row2Scroll,
      chips: tiles,
    );
  }

  Widget _chipList({
    required Key key,
    required ScrollController controller,
    required List<Widget> chips,
  }) {
    return ListView.separated(
      key: key,
      controller: controller,
      scrollDirection: Axis.horizontal,
      itemCount: chips.length,
      separatorBuilder: (_, __) => const SizedBox(width: AppGrid.grid8),
      itemBuilder: (_, i) => chips[i],
    );
  }
}

// ── Private chip tiles ──

class _OverallChipTile extends StatelessWidget {
  final CategoryChip chip;
  final bool selected;
  final VoidCallback onTap;

  const _OverallChipTile({
    required this.chip,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBadge(
      label: chip.label,
      leadingIcon: selected ? AppIcons.close : chip.iconAsset,
      type: selected ? BadgeType.filled : BadgeType.outline,
      color: selected ? AppColors.brand : AppColors.textPrimary,
      onTap: onTap,
    );
  }
}

class _BodyPartChipTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _BodyPartChipTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBadge(
      label: label,
      leadingIcon: selected ? AppIcons.close : null,
      type: selected ? BadgeType.filled : BadgeType.outline,
      color: selected ? AppColors.brand : AppColors.textPrimary,
      onTap: onTap,
    );
  }
}

class _OutcomeChipTile extends StatelessWidget {
  final String label;
  final bool selected;
  final VoidCallback onTap;

  const _OutcomeChipTile({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return AppBadge(
      label: label,
      leadingIcon: selected ? AppIcons.close : null,
      type: selected ? BadgeType.filled : BadgeType.outline,
      color: selected ? AppColors.brand : AppColors.textPrimary,
      onTap: onTap,
    );
  }
}
