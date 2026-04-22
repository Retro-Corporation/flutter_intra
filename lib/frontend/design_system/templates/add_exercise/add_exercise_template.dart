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
      padding: const EdgeInsets.symmetric(horizontal: AppGrid.grid16),
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
              style: AppTypography.bodyLarge.bold,
            ),
          ),
          AppButton(
            label: 'Create New',
            leadingIcon: AppIcons.add,
            type: ButtonType.outline,
            size: ButtonSize.md,
            color: AppColors.textPrimary,
            onPressed: widget.onCreateNew,
          ),
        ],
      ),
    );
  }

  Widget _buildSearch() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppGrid.grid16),
      child: AppSearchBar(
        controller: _searchController,
        focusNode: _searchFocusNode,
        variant: SearchBarVariant.card,
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
            const SizedBox(height: AppGrid.grid24),
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
            const SizedBox(height: AppGrid.grid24),
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
          const SizedBox(height: AppGrid.grid24),
          for (int i = 0; i < widget.sections.length; i++) ...[
            ExerciseSectionRowOrganism(
              title: widget.sections[i].title,
              layout: widget.sections[i].layout,
              items: widget.sections[i].items,
              iconPath: widget.sections[i].iconPath,
              selectedIds: _selectedExerciseIds,
              onCardTap: _handleCardTap,
            ),
            if (i < widget.sections.length - 1)
              const SizedBox(height: AppGrid.grid20),
          ],
        ],
      ),
    );
  }

  /// Floating Add button. Absent entirely when the cart is empty — slides and
  /// fades in on first selection, out on last deselection. Count changes
  /// cross-fade via the `ValueKey<int>(count)`.
  Widget _buildAddButtonFooter() {
    final int count = _selectedExerciseIds.length;
    return AnimatedSwitcher(
      duration: AppDurations.toggle,
      switchInCurve: AppCurves.toggle,
      switchOutCurve: AppCurves.toggle,
      transitionBuilder: (child, animation) => FadeTransition(
        opacity: animation,
        child: SlideTransition(
          position: Tween<Offset>(
            begin: const Offset(0, 0.2),
            end: Offset.zero,
          ).animate(animation),
          child: child,
        ),
      ),
      child: count == 0
          ? const SizedBox.shrink()
          : AppButton(
              key: ValueKey<int>(count),
              label: 'Add ($count)',
              leadingIcon: AppIcons.add,
              type: ButtonType.filled,
              size: ButtonSize.md,
              color: AppColors.brand,
              onPressed: () => widget.onAddPressed(_selectedExerciseIds),
            ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              Column(
                children: [
                  _buildHeader(),
                  const SizedBox(height: AppGrid.grid24),
                  _buildSearch(),
                  const SizedBox(height: AppGrid.grid24),
                  Expanded(child: _buildContent()),
                ],
              ),
              Positioned(
                left: AppGrid.grid16,
                right: AppGrid.grid16,
                bottom: AppGrid.grid16,
                child: _buildAddButtonFooter(),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
