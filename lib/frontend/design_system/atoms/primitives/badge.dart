import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/color/color_utils.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/padding.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/space/stroke.dart';
import '../../foundation/type/typography.dart';
import '../../icons/icon_sizes.dart';
import 'icon.dart';
import 'text.dart';
import 'badge_types.dart';

// ── Size configuration ──

class _BadgeSizeConfig {
  final double height;
  final double paddingX;
  final TypeStyle typeStyle;
  final FontWeight fontWeight;
  final double iconSize;
  final double gap;

  const _BadgeSizeConfig({
    required this.height,
    required this.paddingX,
    required this.typeStyle,
    required this.fontWeight,
    required this.iconSize,
    required this.gap,
  });

  TextStyle get textStyle => TextStyle(
    fontFamily: 'Inter',
    fontSize: typeStyle.fontSize,
    fontWeight: fontWeight,
    letterSpacing: typeStyle.letterSpacing,
    height: typeStyle.height,
    color: typeStyle.color,
  );

  /// Exhaustive switch — compiler errors if a new BadgeSize case is added
  /// without a corresponding branch. Replaces the old Map lookup.
  static _BadgeSizeConfig of(BadgeSize size) {
    return switch (size) {
      BadgeSize.xs => _xs,
      BadgeSize.sm => _sm,
      BadgeSize.md => _md,
      BadgeSize.lg => _lg,
    };
  }

  static const _xs = _BadgeSizeConfig(
    height: AppGrid.grid20,
    paddingX: AppPadding.rem025,
    typeStyle: AppTypography.caption,
    fontWeight: FontWeight.w700,
    iconSize: IconSizes.sm,
    gap: AppGrid.grid4,
  );
  static const _sm = _BadgeSizeConfig(
    height: AppGrid.grid24,
    paddingX: AppPadding.rem05,
    typeStyle: AppTypography.bodySmall,
    fontWeight: FontWeight.w600,
    iconSize: IconSizes.sm,
    gap: AppGrid.grid4,
  );
  static const _md = _BadgeSizeConfig(
    height: AppGrid.grid32,
    paddingX: AppPadding.rem075,
    typeStyle: AppTypography.body,
    fontWeight: FontWeight.w600,
    iconSize: IconSizes.md,
    gap: AppGrid.grid8,
  );
  static const _lg = _BadgeSizeConfig(
    height: AppGrid.grid40,
    paddingX: AppPadding.rem1,
    typeStyle: AppTypography.bodyLarge,
    fontWeight: FontWeight.w600,
    iconSize: IconSizes.lg,
    gap: AppGrid.grid8,
  );
}

// ── Color resolution ──

class _ResolvedColors {
  final Color background;
  final Color foreground;
  final Color border;

  const _ResolvedColors({
    required this.background,
    required this.foreground,
    required this.border,
  });
}

/// Dark grey border for outline badges.
const _outlineBorderColor = AppColors.grey800;

_ResolvedColors _resolveFilled(Color color) {
  final fg = ThemeData.estimateBrightnessForColor(color) == Brightness.light
      ? AppColors.textInverse
      : AppColors.textPrimary;
  return _ResolvedColors(
    background: color,
    foreground: fg,
    border: resolve700(color),
  );
}

_ResolvedColors _resolveOutline(Color color) {
  return _ResolvedColors(
    background: Colors.transparent,
    foreground: color,
    border: _outlineBorderColor,
  );
}

// ── AppBadge ──

/// Atom: pill-shaped badge with configurable type, size, color, and content.
///
/// Content patterns:
/// - text only: `AppBadge(label: 'New')`
/// - icon + text: `AppBadge(leadingIcon: AppIcons.star, label: 'Featured')`
/// - icon only: `AppBadge(leadingIcon: AppIcons.crown)`
class AppBadge extends StatelessWidget {
  /// Text label displayed in the badge.
  final String? label;

  /// Asset path from [AppIcons] for a leading icon (left of label).
  final String? leadingIcon;

  /// Asset path from [AppIcons] for a trailing icon (right of label).
  final String? trailingIcon;

  /// Visual treatment: filled or outline.
  final BadgeType type;

  /// Badge size: xs (20px), sm (24px), md (32px), lg (40px).
  final BadgeSize size;

  /// Accent color from [AppColors]. Determines background, foreground, and
  /// border based on [type].
  final Color color;

  /// Optional tap callback. When null, badge is display-only.
  final VoidCallback? onTap;

  const AppBadge({
    super.key,
    this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.type = BadgeType.filled,
    this.size = BadgeSize.md,
    this.color = AppColors.brand,
    this.onTap,
  }) : assert(
         label != null || leadingIcon != null || trailingIcon != null,
         'AppBadge requires at least a label or icon',
       );

  @override
  Widget build(BuildContext context) {
    final sizeConfig = _BadgeSizeConfig.of(size);
    final colors = switch (type) {
      BadgeType.filled => _resolveFilled(color),
      BadgeType.outline => _resolveOutline(color),
    };

    final children = <Widget>[];

    // 1. Leading icon
    if (leadingIcon != null) {
      if (children.isNotEmpty) children.add(SizedBox(width: sizeConfig.gap));
      children.add(
        AppIcon(leadingIcon!, size: sizeConfig.iconSize, color: colors.foreground),
      );
    }

    // 3. Label
    if (label != null) {
      if (children.isNotEmpty) children.add(SizedBox(width: sizeConfig.gap));
      children.add(
        AppText(label!, style: sizeConfig.textStyle, color: colors.foreground),
      );
    }

    // 4. Trailing icon
    if (trailingIcon != null) {
      if (children.isNotEmpty) children.add(SizedBox(width: sizeConfig.gap));
      children.add(
        AppIcon(trailingIcon!, size: sizeConfig.iconSize, color: colors.foreground),
      );
    }

    Widget badge = Container(
      height: sizeConfig.height,
      padding: EdgeInsets.symmetric(horizontal: sizeConfig.paddingX),
      decoration: BoxDecoration(
        color: colors.background,
        borderRadius: BorderRadius.circular(AppRadius.pill),
        border: Border.all(color: colors.border, width: AppStroke.sm),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: children,
      ),
    );

    if (onTap != null) {
      badge = GestureDetector(onTap: onTap, child: badge);
    }

    return badge;
  }

}
