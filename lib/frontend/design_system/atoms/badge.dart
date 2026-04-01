import 'package:flutter/material.dart';
import '../foundation/colors.dart';
import '../foundation/color_utils.dart';
import '../foundation/grid.dart';
import '../foundation/padding.dart';
import '../foundation/radius.dart';
import '../foundation/stroke.dart';
import '../foundation/typography.dart';
import '../icons/icon_sizes.dart';
import 'icon.dart';
import 'text.dart';

// ── Enums ──

enum BadgeType {
  filled(_resolveFilled),
  outline(_resolveOutline);

  const BadgeType(this._resolve);
  final _ResolvedColors Function(Color) _resolve;
}

enum BadgeSize { xs, sm, md, lg }

// ── Size configuration ──

class _BadgeSizeConfig {
  final double height;
  final double paddingX;
  final TextStyle textStyle;
  final double iconSize;
  final double gap;

  const _BadgeSizeConfig({
    required this.height,
    required this.paddingX,
    required this.textStyle,
    required this.iconSize,
    required this.gap,
  });

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

  static final _xs = _BadgeSizeConfig(
    height: 1.25.rem,
    paddingX: AppPadding.rem025,
    textStyle: AppTypography.caption.bold,
    iconSize: IconSizes.sm,
    gap: AppGrid.grid4,
  );
  static final _sm = _BadgeSizeConfig(
    height: 1.5.rem,
    paddingX: AppPadding.rem05,
    textStyle: AppTypography.bodySmall.semiBold,
    iconSize: IconSizes.sm,
    gap: AppGrid.grid4,
  );
  static final _md = _BadgeSizeConfig(
    height: 2.rem,
    paddingX: AppPadding.rem075,
    textStyle: AppTypography.body.semiBold,
    iconSize: IconSizes.md,
    gap: AppGrid.grid8,
  );
  static final _lg = _BadgeSizeConfig(
    height: 2.5.rem,
    paddingX: AppPadding.rem1,
    textStyle: AppTypography.bodyLarge.semiBold,
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
    final colors = type._resolve(color);

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
