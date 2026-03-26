import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../foundation/colors.dart';
import '../foundation/grid.dart';
import '../foundation/opacity.dart';
import '../foundation/typography.dart';
import '../icons/app_icons.dart';
import '../icons/icon_sizes.dart';
import 'icon.dart';

// ── Enums ──

enum AvatarSize { xs, sm, md, lg, xl }

// ── Avatar content ──

sealed class AvatarContent {
  const AvatarContent();
}

class AvatarImage extends AvatarContent {
  final String url;
  const AvatarImage(this.url);
}

class AvatarInitials extends AvatarContent {
  final String initials;
  const AvatarInitials(this.initials);
}

// ── Size configuration ──

class _AvatarSizeConfig {
  final double diameter;
  final double iconSize;
  final double initialsFontSize;

  const _AvatarSizeConfig({
    required this.diameter,
    required this.iconSize,
    required this.initialsFontSize,
  });

  static final Map<AvatarSize, _AvatarSizeConfig> _map = {
    AvatarSize.xs: _AvatarSizeConfig(
      diameter: AppGrid.grid24,
      iconSize: IconSizes.sm,
      initialsFontSize: AppTypography.overline.fontSize!,
    ),
    AvatarSize.sm: _AvatarSizeConfig(
      diameter: AppGrid.grid32,
      iconSize: IconSizes.md,
      initialsFontSize: AppTypography.caption.fontSize!,
    ),
    AvatarSize.md: _AvatarSizeConfig(
      diameter: 3.rem,
      iconSize: IconSizes.lg,
      initialsFontSize: AppTypography.body.fontSize,
    ),
    AvatarSize.lg: _AvatarSizeConfig(
      diameter: AppGrid.grid60,
      iconSize: IconSizes.lg,
      initialsFontSize: AppTypography.proHeading6.fontSize,
    ),
    AvatarSize.xl: _AvatarSizeConfig(
      diameter: AppGrid.grid100,
      iconSize: IconSizes.xl,
      initialsFontSize: AppTypography.heading3.fontSize,
    ),
  };

  static _AvatarSizeConfig of(AvatarSize size) => _map[size]!;
}

// ── AppAvatar ──

/// Atom: circular avatar with optional badge dots at four corners.
///
/// Content patterns:
/// - image: `AppAvatar(content: AvatarImage('https://...'))`
/// - initials: `AppAvatar(content: AvatarInitials('TP'))`
/// - fallback icon: `AppAvatar()` (person icon)
///
/// Badge dot positions:
/// - [statusDot] → top-left (online status)
/// - [notificationDot] → top-right (notification count)
/// - [achievementDot] → bottom-left (rank/level)
/// - [actionDot] → bottom-right (add user)
class AppAvatar extends StatefulWidget {
  /// Avatar content. When null, shows a default person icon.
  final AvatarContent? content;

  /// Fallback initials shown when an [AvatarImage] fails to load.
  /// If null and image fails, falls back to a person icon.
  final String? fallbackInitials;

  /// Avatar size.
  final AvatarSize size;

  /// Shows a shimmer placeholder when true.
  final bool isLoading;

  /// Reduces opacity to 0.4 when true.
  final bool isDisabled;

  const AppAvatar({
    super.key,
    this.content,
    this.fallbackInitials,
    this.size = AvatarSize.md,
    this.isLoading = false,
    this.isDisabled = false,
  });

  @override
  State<AppAvatar> createState() => _AppAvatarState();
}

class _AppAvatarState extends State<AppAvatar> {
  bool _imageError = false;

  @override
  void didUpdateWidget(covariant AppAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.content != oldWidget.content) {
      _imageError = false;
    }
  }

  @override
  Widget build(BuildContext context) {
    final config = _AvatarSizeConfig.of(widget.size);

    Widget avatar = SizedBox(
      width: config.diameter,
      height: config.diameter,
      child: widget.isLoading
          ? _buildShimmer(config)
          : _buildCircle(config),
    );

    if (widget.isDisabled) {
      avatar = Opacity(opacity: AppOpacity.disabled, child: avatar);
    }

    return Semantics(
      image: true,
      label: _semanticLabel,
      child: avatar,
    );
  }

  String get _semanticLabel {
    final content = widget.content;
    if (content is AvatarInitials) return '${content.initials} avatar';
    if (content is AvatarImage) return 'User avatar';
    return 'Avatar';
  }

  // ── Circle ──

  Widget _buildCircle(_AvatarSizeConfig config) {
    Widget? child;

    final content = widget.content;

    if (content is AvatarImage && !_imageError) {
      child = Image.network(
        content.url,
        fit: BoxFit.cover,
        width: config.diameter,
        height: config.diameter,
        errorBuilder: (_, error, stack) {
          // Schedule rebuild with fallback on next frame.
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _imageError = true);
          });
          // Show fallback immediately in this frame.
          return _buildFallback(config);
        },
      );
    } else if (content is AvatarInitials) {
      child = _buildInitials(content.initials, config);
    } else if (content is AvatarImage && _imageError) {
      child = _buildFallback(config);
    } else {
      // null content → person icon
      child = _buildPersonIcon(config);
    }

    return ClipOval(
      child: SizedBox(
        width: config.diameter,
        height: config.diameter,
        child: child,
      ),
    );
  }

  /// Fallback chain: fallbackInitials → person icon.
  Widget _buildFallback(_AvatarSizeConfig config) {
    if (widget.fallbackInitials != null && widget.fallbackInitials!.isNotEmpty) {
      return _buildInitials(widget.fallbackInitials!, config);
    }
    return _buildPersonIcon(config);
  }

  Widget _buildInitials(String initials, _AvatarSizeConfig config) {
    return ColoredBox(
      color: AppColors.surface,
      child: Center(
        child: Text(
          initials.toUpperCase(),
          style: TextStyle(
            fontFamily: 'Inter',
            fontSize: config.initialsFontSize,
            fontWeight: FontWeight.w700,
            color: AppColors.textPrimary,
          ),
        ),
      ),
    );
  }

  Widget _buildPersonIcon(_AvatarSizeConfig config) {
    return ColoredBox(
      color: AppColors.surface,
      child: Center(
        child: AppIcon(
          AppIcons.profileFilled,
          size: config.iconSize,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }

  // ── Shimmer ──

  Widget _buildShimmer(_AvatarSizeConfig config) {
    return Shimmer.fromColors(
      baseColor: AppColors.surface,
      highlightColor: AppColors.surface,
      child: Container(
        width: config.diameter,
        height: config.diameter,
        decoration: const BoxDecoration(
          color: AppColors.surface,
          shape: BoxShape.circle,
        ),
      ),
    );
  }

}
