import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';

import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/space/stroke.dart';
import '../../icons/icon_sizes.dart';
import 'nav_bar_item_types.dart';

class NavBarItem extends StatelessWidget {
  final String iconPath;
  final NavBarItemState state;
  final VoidCallback onTap;

  const NavBarItem({
    required this.iconPath,
    required this.state,
    required this.onTap,
    super.key,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: switch (state) {
        NavBarItemState.active => SizedBox(
            height: 56,
            child: Stack(
              children: [
                Container(
                  height: 56,
                  padding: EdgeInsets.symmetric(horizontal: AppGrid.grid24),
                  decoration: BoxDecoration(
                    color: AppColors.surface,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: AppColors.brand,
                      width: AppStroke.xs,
                    ),
                  ),
                  child: Center(
                    child: SvgPicture.asset(
                      iconPath,
                      width: IconSizes.md,
                      height: IconSizes.md,
                      fit: BoxFit.contain,
                      colorFilter: const ColorFilter.mode(
                        AppColors.brand,
                        BlendMode.srcIn,
                      ),
                    ),
                  ),
                ),
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  child: Center(
                    child: Container(
                      height: 4.0,
                      width: 40,
                      decoration: const BoxDecoration(
                        color: AppColors.brand,
                        borderRadius: BorderRadius.vertical(
                          top: Radius.circular(8),
                        ),
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        NavBarItemState.inactive => SizedBox(
            height: 56,
            child: Center(
              child: SvgPicture.asset(
                iconPath,
                width: IconSizes.md,
                height: IconSizes.md,
                fit: BoxFit.contain,
                colorFilter: const ColorFilter.mode(
                  AppColors.textSecondary,
                  BlendMode.srcIn,
                ),
              ),
            ),
          ),
      },
    );
  }
}
