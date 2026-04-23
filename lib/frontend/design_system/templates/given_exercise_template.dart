import 'package:flutter/material.dart';

import '../design_system.dart';

/// Template: Given Exercise screen (Screen 08).
///
/// Display-only page layout — pure [StatelessWidget]. No controllers,
/// no focus nodes. All data and callbacks enter through the constructor.
/// Dispatches on [GivenExerciseState] to render the correct body and footer.
class GivenExerciseTemplate extends StatelessWidget {
  final PractitionerInfo practitioner;
  final GivenExerciseState state;

  /// Exercise list shown in the loaded state. Ignored in loading/error states.
  final List<ExerciseData> exercises;

  /// Progress bar fill value (0.0 – 1.0). Defaults to 1.0.
  final double progressValue;

  final VoidCallback onBack;
  final VoidCallback onSkipToHome;
  final VoidCallback onStartExercise;

  const GivenExerciseTemplate({
    super.key,
    required this.practitioner,
    required this.state,
    this.exercises = const [],
    this.progressValue = 1.0,
    required this.onBack,
    required this.onSkipToHome,
    required this.onStartExercise,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppPadding.rem15),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppGrid.grid16),

              // ── Top bar: back arrow + progress ──
              Row(
                children: [
                  GestureDetector(
                    onTap: onBack,
                    child: AppIcon(
                      AppIcons.arrowBack,
                      size: IconSizes.md,
                      color: AppColors.textPrimary,
                    ),
                  ),
                  const SizedBox(width: AppGrid.grid12),
                  Expanded(child: AppProgressBar(value: progressValue)),
                ],
              ),

              const SizedBox(height: AppGrid.grid24),

              // ── Practitioner header ──
              PractitionerHeader(
                avatarUrl: practitioner.avatarUrl,
                name: practitioner.name,
                clinic: practitioner.clinic,
              ),

              const SizedBox(height: AppGrid.grid20),

              // ── State-dependent body ──
              Expanded(
                child: switch (state) {
                  GivenExerciseState.loaded => ListView.separated(
                      itemCount: exercises.length,
                      separatorBuilder: (_, idx) =>
                          const SizedBox(height: AppGrid.grid12),
                      itemBuilder: (_, i) => ExerciseCardRead(
                        variant: ExerciseCardReadVariant.simple,
                        exerciseName: exercises[i].exerciseName,
                        repLabel: exercises[i].repLabel,
                        repValue: exercises[i].repValue,
                        setLabel: exercises[i].setLabel,
                        setValue: exercises[i].setValue,
                        equipmentLabel: exercises[i].equipmentLabel,
                        equipmentValue: exercises[i].equipmentValue,
                        onTap: () {
                          // TODO(Screen08): navigate to exercise detail
                        },
                      ),
                    ),
                  GivenExerciseState.loading => ListView.separated(
                      itemCount: 4,
                      separatorBuilder: (_, idx) =>
                          const SizedBox(height: AppGrid.grid12),
                      itemBuilder: (_, i) => const ExerciseCardSkeleton(
                        variant: ExerciseCardSkeletonVariant.simple,
                      ),
                    ),
                  GivenExerciseState.error => DashedBorderContainer(
                      borderColor: AppColors.textSecondary,
                      borderRadius: AppRadius.md,
                      child: Center(
                        child: AppText(
                          'No exercise found',
                          style: AppTypography.body.bold,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                },
              ),

              const SizedBox(height: AppGrid.grid16),

              // ── State-dependent footer ──
              switch (state) {
                GivenExerciseState.loaded ||
                GivenExerciseState.loading =>
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      AppButton(
                        label: 'Skip to homepage',
                        leadingIcon: AppIcons.homeFilled,
                        type: ButtonType.outline,
                        color: AppColors.textPrimary,
                        size: ButtonSize.md,
                        onPressed: onSkipToHome,
                      ),
                      const SizedBox(height: AppGrid.grid20),
                      AppButton(
                        label: 'Start exercise',
                        leadingIcon: AppIcons.crownFilled,
                        type: ButtonType.filled,
                        size: ButtonSize.md,
                        onPressed: onStartExercise,
                      ),
                    ],
                  ),
                GivenExerciseState.error => AppButton(
                    label: 'Skip to homepage',
                    leadingIcon: AppIcons.homeFilled,
                    type: ButtonType.filled,
                    size: ButtonSize.md,
                    onPressed: onSkipToHome,
                  ),
              },

              const SizedBox(height: AppGrid.grid40),
            ],
          ),
        ),
      ),
    );
  }
}
