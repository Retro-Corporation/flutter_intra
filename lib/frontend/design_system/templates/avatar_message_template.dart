import 'package:flutter/material.dart';

import '../foundation/color/colors.dart';
import '../foundation/space/grid.dart';
import '../foundation/space/padding.dart';
import '../foundation/type/typography.dart';
import '../atoms/controls/button.dart';
import '../atoms/controls/button_types.dart';
import '../atoms/primitives/media_holder.dart';
import '../atoms/primitives/media_holder_types.dart';
import '../atoms/primitives/text.dart';

/// Full-screen skeleton used on flow-boundary screens — an intro pitch or a
/// completion confirmation. Renders a 3D character illustration, a centered
/// heading, and two stacked full-width CTAs.
///
/// The template never navigates or calls a service. It reports taps upward
/// through [onPrimary] and [onSecondary].
class AvatarMessageTemplate extends StatelessWidget {
  /// Main heading displayed below the character illustration.
  final String heading;

  /// Label for the primary (filled) CTA.
  final String primaryLabel;

  /// Called when the primary CTA is tapped.
  final VoidCallback onPrimary;

  /// Optional leading icon asset path (from [AppIcons]) for the primary CTA.
  final String? primaryLeadingIcon;

  /// Overrides the default icon size for the primary leading icon.
  final double? primaryLeadingIconSize;

  /// Label for the secondary CTA.
  final String secondaryLabel;

  /// Visual treatment for the secondary CTA — typically [ButtonType.ghost]
  /// for a dismissive action or [ButtonType.outline] for an alternative
  /// navigation action.
  final ButtonType secondaryButtonType;

  /// Optional leading icon asset path (from [AppIcons]) for the secondary CTA.
  final String? secondaryLeadingIcon;

  /// Called when the secondary CTA is tapped.
  final VoidCallback onSecondary;

  const AvatarMessageTemplate({
    super.key,
    required this.heading,
    required this.primaryLabel,
    required this.onPrimary,
    this.primaryLeadingIcon,
    this.primaryLeadingIconSize,
    required this.secondaryLabel,
    required this.secondaryButtonType,
    this.secondaryLeadingIcon,
    required this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Spacer(),
              const Center(child: MediaHolder(size: MediaHolderSize.hero)),
              const SizedBox(height: AppGrid.grid32),
              AppText(
                heading,
                style: AppTypography.bodyLarge.bold,
                color: AppColors.textPrimary,
                textAlign: TextAlign.center,
              ),
              const Spacer(),
              AppButton(
                label: primaryLabel,
                type: ButtonType.filled,
                size: ButtonSize.md,
                leadingIcon: primaryLeadingIcon,
                leadingIconSize: primaryLeadingIconSize,
                onPressed: onPrimary,
              ),
              const SizedBox(height: AppGrid.grid12),
              AppButton(
                label: secondaryLabel,
                type: secondaryButtonType,
                size: ButtonSize.md,
                color: AppColors.textPrimary,
                leadingIcon: secondaryLeadingIcon,
                onPressed: onSecondary,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
