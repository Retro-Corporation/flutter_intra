import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/padding.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/type/typography.dart';
import '../../icons/app_icons.dart';
import '../../icons/icon_sizes.dart';
import '../behaviors/pressable_surface.dart';
import '../primitives/text.dart';

/// Atom: dedicated "Continue with Google" button.
///
/// Exists as a separate atom from [AppButton] because the Google G mark is a
/// multi-color SVG. [AppButton] pipes its `leadingIcon` through [AppIcon],
/// which applies a single-color filter and would flatten the brand mark.
/// Rendering the SVG directly via [SvgPicture.asset] preserves the colors.
///
/// Visual: outline treatment at medium size — dark background, subtle border,
/// white label — mirroring the other outline buttons on the sign-up screen.
/// 3D press feedback comes from [PressableSurface] (shared atom behavior).
class AppGoogleSignInButton extends StatelessWidget {
  /// Fired when the user taps the button. Null disables interaction.
  final VoidCallback? onPressed;

  const AppGoogleSignInButton({super.key, this.onPressed});

  @override
  Widget build(BuildContext context) {
    return Semantics(
      button: true,
      enabled: onPressed != null,
      label: 'Continue with Google',
      child: PressableSurface(
        style: PressableStyle.outline,
        backgroundColor: AppColors.background,
        borderColor: AppColors.surfaceBorder,
        borderRadius: AppRadius.sm,
        onTap: onPressed,
        child: ConstrainedBox(
          constraints: const BoxConstraints(minHeight: AppGrid.grid44),
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.rem1,
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                SvgPicture.asset(
                  AppIcons.googleG,
                  width: IconSizes.md,
                  height: IconSizes.md,
                ),
                const SizedBox(width: AppGrid.grid8),
                AppText(
                  'Continue with Google',
                  style: AppTypography.body.semiBold,
                  color: AppColors.textPrimary,
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
