import 'package:flutter/material.dart';
import '../../design_system.dart';

/// Template: Add Exercise page.
///
/// Owns the search controller, search focus node, and the selection list.
/// Composes the header, search bar, category filter, exercise section rows,
/// and the floating "+ Add (N)" submit button. Never navigates or calls a
/// service — the parent handles navigation via [onCardTap] returning a
/// `Future<String?>` and all other interactions through callbacks.
class AddExerciseTemplate extends StatefulWidget {
  final List<ExerciseSectionData> sections;
  final List<CategoryChip> overallChips;
  final List<String> bodyPartChips;
  final List<String> outcomeChips;
  final bool isLoading;
  final VoidCallback onBack;
  final VoidCallback onCreateNew;

  /// Called when an exercise card is tapped. The parent performs the
  /// navigation to the Exercise Detail page and returns the exercise id
  /// if one was added (or `null` if not). The template then appends the
  /// id to its internal selection list.
  final Future<String?> Function(String exerciseId) onCardTap;

  final void Function(List<String> selectedIds) onAddPressed;
  final void Function(String query) onSearchChanged;
  final void Function(String? overall, String? bodyPart, String? outcome)
      onFilterChanged;

  const AddExerciseTemplate({
    super.key,
    required this.sections,
    required this.overallChips,
    required this.bodyPartChips,
    required this.outcomeChips,
    required this.isLoading,
    required this.onBack,
    required this.onCreateNew,
    required this.onCardTap,
    required this.onAddPressed,
    required this.onSearchChanged,
    required this.onFilterChanged,
  });

  @override
  State<AddExerciseTemplate> createState() => _AddExerciseTemplateState();
}

class _AddExerciseTemplateState extends State<AddExerciseTemplate> {
  late final TextEditingController _searchController;
  late final FocusNode _searchFocusNode;
  final List<String> _selectedExerciseIds = [];

  @override
  void initState() {
    super.initState();
    _searchController = TextEditingController();
    _searchFocusNode = FocusNode();
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  bool get _allSectionsEmpty =>
      widget.sections.isEmpty ||
      widget.sections.every((s) => s.items.isEmpty);

  Future<void> _handleCardTap(String exerciseId) async {
    final String? addedId = await widget.onCardTap(exerciseId);
    if (!mounted) return;
    if (addedId != null) {
      setState(() => _selectedExerciseIds.add(addedId));
    }
  }

  Widget get _categoriesLabel =>
      AppText('Categories', style: AppTypography.body.bold);

  Widget get _filter => CategoryFilterOrganism(
        overallChips: widget.overallChips,
        bodyPartChips: widget.bodyPartChips,
        outcomeChips: widget.outcomeChips,
        onFilterChanged: widget.onFilterChanged,
      );

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppGrid.grid16,
        AppGrid.grid8,
        AppGrid.grid16,
        AppGrid.grid8,
      ),
      child: Row(
        children: [
          GestureDetector(
            onTap: widget.onBack,
            behavior: HitTestBehavior.opaque,
            child: const Padding(
              padding: EdgeInsets.all(AppGrid.grid8),
              child: AppIcon(AppIcons.arrowBack),
            ),
          ),
          const SizedBox(width: AppGrid.grid12),
          Expanded(
            child: AppText(
              'Add Exercise',
              style: AppTypography.proHeading6.bold,
            ),
          ),
          AppButton(
            label: 'Create New',
            leadingIcon: AppIcons.add,
            type: ButtonType.outline,
            size: ButtonSize.md,
            onPressed: widget.onCreateNew,
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.fromLTRB(
        AppGrid.grid16,
        0,
        AppGrid.grid16,
        AppGrid.grid12,
      ),
      child: AppSearchBar(
        controller: _searchController,
        focusNode: _searchFocusNode,
        onChanged: widget.onSearchChanged,
      ),
    );
  }

  Widget _buildContent() {
    const contentPadding = EdgeInsets.fromLTRB(
      AppGrid.grid16,
      0,
      AppGrid.grid16,
      AppGrid.grid16,
    );

    if (widget.isLoading) {
      return SingleChildScrollView(
        padding: contentPadding,
        keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _categoriesLabel,
            const SizedBox(height: AppGrid.grid8),
            _filter,
            const SizedBox(height: AppGrid.grid16),
            const AddExerciseSkeletonOrganism(),
          ],
        ),
      );
    }

    if (_allSectionsEmpty) {
      return Padding(
        padding: contentPadding,
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            _categoriesLabel,
            const SizedBox(height: AppGrid.grid8),
            _filter,
            const SizedBox(height: AppGrid.grid16),
            Expanded(
              child: EmptyExerciseList(onAddExercise: widget.onCreateNew),
            ),
          ],
        ),
      );
    }

    return SingleChildScrollView(
      padding: contentPadding,
      keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          _categoriesLabel,
          const SizedBox(height: AppGrid.grid8),
          _filter,
          const SizedBox(height: AppGrid.grid16),
          for (final section in widget.sections) ...[
            ExerciseSectionRowOrganism(
              title: section.title,
              layout: section.layout,
              items: section.items,
              iconPath: section.iconPath,
              selectedIds: _selectedExerciseIds,
              onCardTap: _handleCardTap,
            ),
            const SizedBox(height: AppGrid.grid16),
          ],
        ],
      ),
    );
  }

  Widget _buildAddButtonFooter() {
    final int count = _selectedExerciseIds.length;
    final bool isActive = count > 0;
    return Padding(
      padding: const EdgeInsets.all(AppGrid.grid16),
      child: AnimatedSlide(
        offset: isActive ? Offset.zero : const Offset(0, 0.08),
        duration: AppDurations.toggle,
        curve: AppCurves.toggle,
        child: AnimatedSwitcher(
          duration: AppDurations.toggle,
          switchInCurve: AppCurves.toggle,
          switchOutCurve: AppCurves.toggle,
          transitionBuilder: (child, animation) =>
              FadeTransition(opacity: animation, child: child),
          child: AppButton(
            key: ValueKey<int>(count),
            label: 'Add ($count)',
            leadingIcon: AppIcons.add,
            type: ButtonType.filled,
            size: ButtonSize.lg,
            color: AppColors.brand,
            isDisabled: !isActive,
            onPressed: () => widget.onAddPressed(_selectedExerciseIds),
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            _buildHeader(),
            _buildSearch(),
            Expanded(child: _buildContent()),
            _buildAddButtonFooter(),
          ],
        ),
      ),
    );
  }
}
