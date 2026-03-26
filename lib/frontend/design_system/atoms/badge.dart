import 'package:flutter/material.dart';
import '../design_system.dart';

// ── Enums ──

enum BadgeType { filled, outline }

enum BadgeSize { xs, sm, md, lg }

// ── Avatar content ──

sealed class BadgeAvatar {
  const BadgeAvatar();
}

class BadgeAvatarImage extends BadgeAvatar {
  final String url;
  const BadgeAvatarImage(this.url);
}

class BadgeAvatarIcon extends BadgeAvatar {
  final String icon;
  const BadgeAvatarIcon(this.icon);
}

class BadgeAvatarInitials extends BadgeAvatar {
  final String initials;
  const BadgeAvatarInitials(this.initials);
}

// ── Size configuration ──

class _BadgeSizeConfig {
  final double height;
  final double paddingX;
  final TextStyle textStyle;
  final double iconSize;
  final double avatarSize;
  final double gap;

  const _BadgeSizeConfig({
    required this.height,
    required this.paddingX,
    required this.textStyle,
    required this.iconSize,
    required this.avatarSize,
    required this.gap,
  });

  static final Map<BadgeSize, _BadgeSizeConfig> _map = {
    BadgeSize.xs: _BadgeSizeConfig(
      height: 1.25.rem,
      paddingX: AppPadding.rem025,
      textStyle: AppTypography.caption,
      iconSize: IconSizes.sm,
      avatarSize: 0.875.rem,
      gap: AppGrid.grid4,
    ),
    BadgeSize.sm: _BadgeSizeConfig(
      height: 1.5.rem,
      paddingX: AppPadding.rem05,
      textStyle: AppTypography.bodySmall.semiBold,
      iconSize: IconSizes.sm,
      avatarSize: 1.rem,
      gap: AppGrid.grid4,
    ),
    BadgeSize.md: _BadgeSizeConfig(
      height: 2.rem,
      paddingX: AppPadding.rem075,
      textStyle: AppTypography.body.semiBold,
      iconSize: IconSizes.md,
      avatarSize: 1.25.rem,
      gap: AppGrid.grid8,
    ),
    BadgeSize.lg: _BadgeSizeConfig(
      height: 2.5.rem,
      paddingX: AppPadding.rem1,
      textStyle: AppTypography.bodyLarge.semiBold,
      iconSize: IconSizes.lg,
      avatarSize: 1.5.rem,
      gap: AppGrid.grid8,
    ),
  };

  static _BadgeSizeConfig of(BadgeSize size) => _map[size]!;
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


_ResolvedColors _resolveColors(BadgeType type, Color color) {
  switch (type) {
    case BadgeType.filled:
      final fg =
          ThemeData.estimateBrightnessForColor(color) == Brightness.light
              ? AppColors.textInverse
              : AppColors.textPrimary;
      return _ResolvedColors(
        background: color,
        foreground: fg,
        border: resolve700(color),
      );
    case BadgeType.outline:
      return _ResolvedColors(
        background: Colors.transparent,
        foreground: color,
        border: _outlineBorderColor,
      );
  }
}

// ── AppBadge ──

/// Atom: pill-shaped badge with configurable type, size, color, and content.
///
/// Content patterns:
/// - text only: `AppBadge(label: 'New')`
/// - icon + text: `AppBadge(leadingIcon: AppIcons.star, label: 'Featured')`
/// - icon only: `AppBadge(leadingIcon: AppIcons.crown)`
/// - avatar + text: `AppBadge(avatar: BadgeAvatarInitials('TP'), label: 'Tavon')`
class AppBadge extends StatelessWidget {
  /// Text label displayed in the badge.
  final String? label;

  /// Asset path from [AppIcons] for a leading icon (left of label).
  final String? leadingIcon;

  /// Asset path from [AppIcons] for a trailing icon (right of label).
  final String? trailingIcon;

  /// Avatar displayed at the leading position (before leadingIcon and label).
  final BadgeAvatar? avatar;

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
    this.avatar,
    this.type = BadgeType.filled,
    this.size = BadgeSize.md,
    this.color = AppColors.brand,
    this.onTap,
  }) : assert(
         label != null || leadingIcon != null || trailingIcon != null || avatar != null,
         'AppBadge requires at least a label, icon, or avatar',
       );

  @override
  Widget build(BuildContext context) {
    final sizeConfig = _BadgeSizeConfig.of(size);
    final colors = _resolveColors(type, color);

    final children = <Widget>[];

    // 1. Avatar (leftmost)
    if (avatar != null) {
      children.add(_buildAvatar(sizeConfig, colors));
    }

    // 2. Leading icon
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
        border: Border.all(color: colors.border, width: 1.5),
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

  Widget _buildAvatar(_BadgeSizeConfig sizeConfig, _ResolvedColors colors) {
    final dim = sizeConfig.avatarSize;

    return ClipOval(
      child: SizedBox(
        width: dim,
        height: dim,
        child: switch (avatar!) {
          BadgeAvatarImage(:final url) => Image.network(
              url,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => ColoredBox(
                color: colors.foreground.withValues(alpha: 0.2),
                child: Center(
                  child: AppIcon(
                    AppIcons.profile,
                    size: dim * 0.6,
                    color: colors.foreground,
                  ),
                ),
              ),
            ),
          BadgeAvatarIcon(:final icon) => ColoredBox(
              color: colors.foreground.withValues(alpha: 0.15),
              child: Center(
                child: AppIcon(icon, size: dim * 0.6, color: colors.foreground),
              ),
            ),
          BadgeAvatarInitials(:final initials) => ColoredBox(
              color: colors.foreground.withValues(alpha: 0.15),
              child: Center(
                child: Text(
                  initials.toUpperCase(),
                  style: TextStyle(
                    fontFamily: 'Inter',
                    fontSize: dim * 0.45,
                    fontWeight: FontWeight.w700,
                    color: colors.foreground,
                  ),
                ),
              ),
            ),
        },
      ),
    );
  }
}
