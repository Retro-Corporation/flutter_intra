import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/padding.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/space/stroke.dart';
import '../../foundation/type/typography.dart';
import '../../atoms/primitives/text.dart';
import '../../atoms/controls/button.dart';
import '../../atoms/controls/button_types.dart';

/// Molecule: confirmation dialog card.
///
/// A self-contained dark card with a two-line title block and two stacked
/// full-width buttons. Fires [onConfirm] or [onCancel] and does nothing else —
/// all navigation and business logic belong to the caller.
///
/// Intended to be hosted inside Flutter's [Dialog] widget via [showDialog].
/// The container decoration (background, radius) lives inside this molecule
/// so the card looks correct both in a dialog and in the catalog.
class AppConfirmationDialog extends StatelessWidget {
  /// Supporting line above the main title. E.g. "Do you want to"
  final String subtitle;

  /// Bold action line. E.g. "Sign Out?" or "Delete Your Account?"
  final String title;

  /// Label for the destructive confirm button.
  final String confirmLabel;

  /// Label for the safe cancel button.
  final String cancelLabel;

  /// Called when the confirm button is tapped.
  final VoidCallback onConfirm;

  /// Called when the cancel button is tapped.
  final VoidCallback onCancel;

  const AppConfirmationDialog({
    super.key,
    required this.subtitle,
    required this.title,
    required this.confirmLabel,
    required this.cancelLabel,
    required this.onConfirm,
    required this.onCancel,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.xl),
        border: Border.all(
          color: AppColors.textPrimary,
          width: AppStroke.md,
        ),
      ),
      padding: const EdgeInsets.all(AppPadding.cardPadding),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          const SizedBox(height: AppGrid.grid8),
          AppText(
            subtitle,
            style: AppTypography.body.bold,
            color: AppColors.textPrimary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppGrid.grid4),
          AppText(
            title,
            style: AppTypography.bodyLarge.bold,
            color: AppColors.textPrimary,
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: AppGrid.grid20),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              type: ButtonType.filled,
              size: ButtonSize.md,
              color: AppColors.error,
              label: confirmLabel,
              onPressed: onConfirm,
            ),
          ),
          const SizedBox(height: AppGrid.grid8),
          SizedBox(
            width: double.infinity,
            child: AppButton(
              type: ButtonType.filled,
              size: ButtonSize.md,
              color: AppColors.textPrimary,
              label: cancelLabel,
              onPressed: onCancel,
            ),
          ),
          const SizedBox(height: AppGrid.grid8),
        ],
      ),
    );
  }
}
