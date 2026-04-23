import 'package:flutter/material.dart';
import '../../design_system.dart';

/// Template: Exercise Detail page.
///
/// Three variants — [ExerciseDetailVariant.basic], [.set], [.template] — share
/// the same header, muscle-group pill, and footer pattern. The variant controls
/// the subtitle row, media area, and which Add buttons appear.
///
/// Owns [_currentIndex] (intrinsic carousel state). No controllers or focus
/// nodes — this template has no text input.
///
/// Never navigates or calls a service. The parent handles
/// `Navigator.pop(result)` via the callbacks.
class ExerciseDetailTemplate extends StatefulWidget {
  final ExerciseDetailVariant variant;

  /// Displayed as the page heading (e.g. "Exercise name", "Exercise set name").
  final String headerTitle;

  /// One item for [ExerciseDetailVariant.basic]; at least 3 for set/template.
  final List<ExerciseDetailItem> items;

  final VoidCallback onBack;

  /// Called with the ID of the currently-visible exercise.
  final void Function(String exerciseId) onAddExercise;

  /// Required when [variant] is [ExerciseDetailVariant.set].
  /// Called with the IDs of all items in the set.
  final void Function(List<String> exerciseIds)? onAddSet;

  /// Required when [variant] is [ExerciseDetailVariant.template].
  /// Called with the IDs of all items in the template.
  final void Function(List<String> exerciseIds)? onAddTemplate;

  const ExerciseDetailTemplate({
    super.key,
    required this.variant,
    required this.headerTitle,
    required this.items,
    required this.onBack,
    required this.onAddExercise,
    this.onAddSet,
    this.onAddTemplate,
  })  : assert(
          variant != ExerciseDetailVariant.set || onAddSet != null,
          'onAddSet is required for ExerciseDetailVariant.set',
        ),
        assert(
          variant != ExerciseDetailVariant.template || onAddTemplate != null,
          'onAddTemplate is required for ExerciseDetailVariant.template',
        ),
        assert(
          variant == ExerciseDetailVariant.basic || items.length >= 3,
          'set and template variants require at least 3 items',
        );

  @override
  State<ExerciseDetailTemplate> createState() => _ExerciseDetailTemplateState();
}

class _ExerciseDetailTemplateState extends State<ExerciseDetailTemplate> {
  int _currentIndex = 0;

  ExerciseDetailItem get _current => widget.items[_currentIndex];

  List<String> get _allIds => widget.items.map((e) => e.id).toList();

  void _handlePrimaryAdd() {
    switch (widget.variant) {
      case ExerciseDetailVariant.basic:
        widget.onAddExercise(widget.items[0].id);
      case ExerciseDetailVariant.set:
        widget.onAddExercise(_current.id);
      case ExerciseDetailVariant.template:
        widget.onAddTemplate!(_allIds);
    }
  }

  String get _primaryLabel => switch (widget.variant) {
        ExerciseDetailVariant.basic    => 'Add exercise',
        ExerciseDetailVariant.set      => 'Add exercise',
        ExerciseDetailVariant.template => 'Add template',
      };

  // ── Rows ──

  Widget _buildHeader() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppGrid.grid16),
      child: Row(
        children: [
          AppButton(
            leadingIcon: AppIcons.arrowBack,
            type: ButtonType.ghost,
            size: ButtonSize.md,
            color: AppColors.textPrimary,
            onPressed: widget.onBack,
          ),
          const SizedBox(width: AppGrid.grid8),
          Expanded(
            child: AppText(widget.headerTitle, style: AppTypography.bodyLarge.bold),
          ),
          const Opacity(
            opacity: AppOpacity.disabled,
            child: IgnorePointer(
              child: AppButton(
                leadingIcon: AppIcons.moreDots,
                type: ButtonType.ghost,
                size: ButtonSize.md,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildSubtitle() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppGrid.grid16),
      child: switch (widget.variant) {
        ExerciseDetailVariant.basic => _current.equipment != null
            ? _SubtitleText(label: 'Equipment:', value: _current.equipment!)
            : const SizedBox.shrink(),
        ExerciseDetailVariant.set ||
        ExerciseDetailVariant.template =>
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              AppText(
                _current.name,
                style: AppTypography.body.bold,
                color: AppColors.textPrimary,
              ),
              if (_current.equipment != null)
                _SubtitleText(
                  label: 'Equipment:',
                  value: _current.equipment!,
                ),
            ],
          ),
      },
    );
  }

  Widget _buildMuscleGroupPill() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppGrid.grid16),
      child: Container(
        height: AppGrid.grid32,
        width: double.infinity,
        decoration: BoxDecoration(
          border: Border.all(
            color: AppColors.textPrimary,
            width: AppStroke.xs,
          ),
          borderRadius: BorderRadius.circular(AppRadius.pill),
        ),
        alignment: Alignment.center,
        child: AppText(
          _current.muscleGroup,
          style: AppTypography.body.bold,
          color: AppColors.textPrimary,
        ),
      ),
    );
  }

  Widget _buildMediaArea() {
    return switch (widget.variant) {
      ExerciseDetailVariant.basic => const MediaHolder(size: MediaHolderSize.lg),
      ExerciseDetailVariant.set ||
      ExerciseDetailVariant.template =>
        ExerciseFlowCarousel(
          size: ExerciseFlowCarouselSize.lg,
          thumbnails: List.filled(widget.items.length, null),
          currentIndex: _currentIndex,
          onIndexChanged: (i) => setState(() => _currentIndex = i),
        ),
    };
  }

  Widget _buildFooter() {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppGrid.grid16),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (widget.variant == ExerciseDetailVariant.set) ...[
            SizedBox(
              width: double.infinity,
              child: AppButton(
                label: 'Add exercise set',
                leadingIcon: AppIcons.add,
                type: ButtonType.filled,
                size: ButtonSize.md,
                color: AppColors.textPrimary,
                onPressed: () => widget.onAddSet!(_allIds),
              ),
            ),
            const SizedBox(height: AppGrid.grid8),
          ],
          SizedBox(
            width: double.infinity,
            child: AppButton(
              label: _primaryLabel,
              leadingIcon: AppIcons.add,
              type: ButtonType.filled,
              size: ButtonSize.md,
              color: AppColors.brand,
              onPressed: _handlePrimaryAdd,
            ),
          ),
          const SizedBox(height: AppGrid.grid36),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: AppGrid.grid16),
            _buildHeader(),
            _buildSubtitle(),
            const SizedBox(height: AppGrid.grid12),
            _buildMuscleGroupPill(),
            const SizedBox(height: AppGrid.grid20),
            Expanded(
              child: Align(
                alignment: Alignment.topCenter,
                child: _buildMediaArea(),
              ),
            ),
            const SizedBox(height: AppGrid.grid8),
            _buildFooter(),
          ],
        ),
      ),
    );
  }
}

// ── File-private helpers ──

/// Renders "Label: value" with bold label and regular value inline.
/// Private to this file (CCP — only ExerciseDetailTemplate uses it).
class _SubtitleText extends StatelessWidget {
  final String label;
  final String value;

  const _SubtitleText({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          '$label ',
          style: AppTypography.body.bold,
          color: AppColors.textPrimary,
        ),
        AppText(
          value,
          style: AppTypography.body.bold,
          color: AppColors.textPrimary,
        ),
      ],
    );
  }
}
