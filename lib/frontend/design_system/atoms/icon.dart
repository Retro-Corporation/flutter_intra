import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../foundation/colors.dart';
import '../icons/icon_sizes.dart';

/// Atom: renders an SVG icon at the correct size with color tinting.
/// Uses [BoxFit.contain] so non-square viewBoxes are never stretched.
class AppIcon extends StatelessWidget {
  /// Asset path from [AppIcons], e.g. `AppIcons.home`.
  final String icon;

  /// Bounding-box size. Defaults to [IconSizes.md] (16px).
  final double? size;

  /// Tint color. Defaults to [AppColors.textPrimary] (white).
  final Color? color;

  const AppIcon(
    this.icon, {
    super.key,
    this.size,
    this.color,
  });

  @override
  Widget build(BuildContext context) {
    final s = size ?? IconSizes.md;
    return SizedBox(
      width: s,
      height: s,
      child: SvgPicture.asset(
        icon,
        fit: BoxFit.contain,
        colorFilter: ColorFilter.mode(
          color ?? AppColors.textPrimary,
          BlendMode.srcIn,
        ),
      ),
    );
  }
}
