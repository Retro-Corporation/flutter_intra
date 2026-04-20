import 'package:flutter/widgets.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/radius.dart';
import '../../atoms/behaviors/dashed_border.dart';
import '../../molecules/display/icon_text_action.dart';
import '../../icons/app_icons.dart';

/// Molecule: empty state for the exercise list.
///
/// Fills its parent with a dashed border container and a centered
/// [IconTextAction] CTA. The entire container and the inner action
/// both fire [onAddExercise] — tapping anywhere triggers the callback.
class EmptyExerciseList extends StatelessWidget {
  final VoidCallback onAddExercise;

  const EmptyExerciseList({super.key, required this.onAddExercise});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onAddExercise,
      child: DashedBorderContainer(
        borderColor: AppColors.textSecondary,
        borderRadius: AppRadius.md,
        child: SizedBox.expand(
          child: Center(
            child: IconTextAction(
              iconPath: AppIcons.add,
              label: 'Add Exercise',
              onTap: onAddExercise,
            ),
          ),
        ),
      ),
    );
  }
}
