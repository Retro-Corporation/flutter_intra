import 'package:flutter/widgets.dart';
import '../../atoms/primitives/avatar.dart';
import '../../atoms/primitives/avatar_types.dart';
import '../../atoms/primitives/icon.dart';
import '../../atoms/primitives/text.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/type/typography.dart';
import '../../icons/app_icons.dart';
import '../../icons/icon_sizes.dart';

/// Molecule: displays a practitioner's identity — avatar, name, and clinic.
///
/// Display-only. No interaction state, no validation, no controllers.
/// Composes [AppAvatar], [AppIcon], and [AppText] atoms.
class PractitionerHeader extends StatelessWidget {
  final String avatarUrl;
  final String name;
  final String clinic;

  const PractitionerHeader({
    super.key,
    required this.avatarUrl,
    required this.name,
    required this.clinic,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        AppAvatar(
          content: AvatarImage(NetworkImage(avatarUrl)),
          size: AvatarSize.lg,
        ),
        const SizedBox(width: AppGrid.grid12),
        Expanded(
          child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          mainAxisSize: MainAxisSize.min,
          children: [
            Row(
              children: [
                AppIcon(
                  AppIcons.doctorFilled,
                  size: IconSizes.md,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: AppGrid.grid4),
                Flexible(
                  child: AppText(
                    name,
                    style: AppTypography.bodyLarge.bold,
                    color: AppColors.textPrimary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
            const SizedBox(height: AppGrid.grid4),
            Row(
              children: [
                AppIcon(
                  AppIcons.clinicFilled,
                  size: IconSizes.md,
                  color: AppColors.textPrimary,
                ),
                const SizedBox(width: AppGrid.grid4),
                Flexible(
                  child: AppText(
                    clinic,
                    style: AppTypography.body.bold,
                    color: AppColors.textPrimary,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                  ),
                ),
              ],
            ),
          ],
          ),
        ),
      ],
    );
  }
}
