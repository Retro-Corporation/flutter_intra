import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/opacity.dart';
import '../../foundation/type/typography.dart';
import '../../icons/app_icons.dart';
import '../../icons/icon_sizes.dart';
import 'icon.dart';
import 'shimmer.dart';
import 'avatar_types.dart';

// ── Size configuration ──

class _AvatarSizeConfig {
  final double diameter;
  final double iconSize;
  final TypeStyle initialsType;

  const _AvatarSizeConfig({
    required this.diameter,
    required this.iconSize,
    required this.initialsType,
  });

  /// Exhaustive switch — compiler errors if a new AvatarSize case is added
  /// without a corresponding branch. Replaces the old Map lookup.
  static _AvatarSizeConfig of(AvatarSize size) {
    return switch (size) {
      AvatarSize.xs => _xs,
      AvatarSize.sm => _sm,
      AvatarSize.md => _md,
      AvatarSize.lg => _lg,
      AvatarSize.xl => _xl,
    };
  }

  static final _xs = _AvatarSizeConfig(
    diameter: AppGrid.grid24,
    iconSize: IconSizes.sm,
    initialsType: AppTypography.overline,
  );
  static final _sm = _AvatarSizeConfig(
    diameter: AppGrid.grid32,
    iconSize: IconSizes.md,
    initialsType: AppTypography.caption,
  );
  static final _md = _AvatarSizeConfig(
    diameter: AppGrid.grid48,
    iconSize: IconSizes.lg,
    initialsType: AppTypography.body,
  );
  static final _lg = _AvatarSizeConfig(
    diameter: AppGrid.grid60,
    iconSize: IconSizes.lg,
    initialsType: AppTypography.proHeading6,
  );
  static final _xl = _AvatarSizeConfig(
    diameter: AppGrid.grid100,
    iconSize: IconSizes.xl,
    initialsType: AppTypography.heading3,
  );
}

// ── AppAvatar ──

/// Atom: circular avatar with optional badge dots at four corners.
///
/// Content patterns:
/// - image: `AppAvatar(content: AvatarImage(NetworkImage('https://...')))`
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
    return switch (widget.content) {
      AvatarInitials(:final initials) => '$initials avatar',
      AvatarImage() => 'User avatar',
      null => 'Avatar',
    };
  }

  // ── Circle ──

  Widget _buildCircle(_AvatarSizeConfig config) {
    final child = switch (widget.content) {
      AvatarImage(:final image) => _imageError
          ? _buildFallback(config)
          : Image(
              image: image,
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
            ),
      AvatarInitials(:final initials) => _buildInitials(initials, config),
      null => _buildPersonIcon(config),
    };

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
          style: config.initialsType.bold,
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
