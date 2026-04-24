import 'package:flutter/material.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

/// A top-row navigation molecule: a back button followed by a horizontal
/// progress bar that fills the remaining width.
///
/// Used as the canonical top row for progress-driven step pages
/// (e.g. [ProgressStepTemplate] in the Create Exercise flow).
///
/// The molecule does not own or compute the progress value — the caller
/// passes a [progress] between 0.0 and 1.0. The molecule is stateless.
class BackAndProgressBarMolecule extends StatelessWidget {
  /// Progress value in the range 0.0–1.0.
  final double progress;

  /// Fired when the user taps the back button.
  final VoidCallback onBack;

  const BackAndProgressBarMolecule({
    super.key,
    required this.progress,
    required this.onBack,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        AppButton(
          leadingIcon: AppIcons.arrowBack,
          type: ButtonType.ghost,
          size: ButtonSize.md,
          color: AppColors.textPrimary,
          onPressed: onBack,
        ),
        const SizedBox(width: AppGrid.grid8),
        Expanded(child: AppProgressBar(value: progress)),
      ],
    );
  }
}
