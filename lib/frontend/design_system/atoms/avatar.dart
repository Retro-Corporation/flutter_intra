import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';
import '../design_system.dart';

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

// ── Badge dot configuration ──

/// Configuration for a single badge dot overlay on the avatar.
///
/// Each dot can be a plain colored circle or display short text (a number, "+").
class AvatarBadgeDot {
  /// Dot background color. Parent decides semantics.
  final Color color;

  /// Optional text inside the dot: a number, "+", or short string.
  /// When null, dot is a plain colored circle.
  final String? text;

  const AvatarBadgeDot({
    required this.color,
    this.text,
  });
}

// ── Size configuration ──

class _AvatarSizeConfig {
  final double diameter;
  final double dotSize;
  final double dotFontSize;
  final double dotBorderWidth;
  final double iconSize;

  const _AvatarSizeConfig({
    required this.diameter,
    required this.dotSize,
    required this.dotFontSize,
    required this.dotBorderWidth,
    required this.iconSize,
  });

  /// Initials font size scales proportionally to diameter.
  double get initialsFontSize => diameter * 0.38;

  static final Map<AvatarSize, _AvatarSizeConfig> _map = {
    AvatarSize.xs: _AvatarSizeConfig(
      diameter: AppGrid.grid24,   // 24
      dotSize: 8,
      dotFontSize: 6,
      dotBorderWidth: 2,
      iconSize: IconSizes.sm,     // 8
    ),
    AvatarSize.sm: _AvatarSizeConfig(
      diameter: AppGrid.grid32,   // 32
      dotSize: 10,
      dotFontSize: 7,
      dotBorderWidth: 2,
      iconSize: IconSizes.md,     // 16
    ),
    AvatarSize.md: _AvatarSizeConfig(
      diameter: 3.rem,            // 48
      dotSize: 14,
      dotFontSize: 9,
      dotBorderWidth: 2,
      iconSize: IconSizes.lg,     // 24
    ),
    AvatarSize.lg: _AvatarSizeConfig(
      diameter: AppGrid.grid60,   // 60
      dotSize: 18,
      dotFontSize: 11,
      dotBorderWidth: 2,
      iconSize: IconSizes.lg,     // 24
    ),
    AvatarSize.xl: _AvatarSizeConfig(
      diameter: AppGrid.grid100,  // 100
      dotSize: 24,
      dotFontSize: 14,
      dotBorderWidth: 2,
      iconSize: IconSizes.xl,     // 32
    ),
  };

  static _AvatarSizeConfig of(AvatarSize size) => _map[size]!;
}

// ── Dot position helper ──

enum _DotPosition { topLeft, topRight, bottomLeft, bottomRight }

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

  /// Top-left badge: online status indicator.
  final AvatarBadgeDot? statusDot;

  /// Top-right badge: notification count.
  final AvatarBadgeDot? notificationDot;

  /// Bottom-left badge: achievement / rank level.
  final AvatarBadgeDot? achievementDot;

  /// Bottom-right badge: add user / action.
  final AvatarBadgeDot? actionDot;

  /// Background color used for the dot separation border.
  /// Should match the surface the avatar sits on.
  /// Defaults to [AppColors.background].
  final Color borderColor;

  /// Optional tap callback. When provided, enables press feedback.
  final VoidCallback? onTap;

  const AppAvatar({
    super.key,
    this.content,
    this.fallbackInitials,
    this.size = AvatarSize.md,
    this.isLoading = false,
    this.isDisabled = false,
    this.statusDot,
    this.notificationDot,
    this.achievementDot,
    this.actionDot,
    this.borderColor = AppColors.background,
    this.onTap,
  });

  @override
  State<AppAvatar> createState() => _AppAvatarState();
}

class _AppAvatarState extends State<AppAvatar> {
  bool _pressed = false;
  bool _imageError = false;

  bool get _interactive =>
      !widget.isDisabled && !widget.isLoading && widget.onTap != null;

  @override
  void didUpdateWidget(covariant AppAvatar oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Reset image error when content changes.
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
      child: Stack(
        clipBehavior: Clip.none,
        children: [
          // Avatar circle
          widget.isLoading
              ? _buildShimmer(config)
              : _buildCircle(config),

          // Badge dots
          if (widget.statusDot != null)
            _buildDot(widget.statusDot!, _DotPosition.topLeft, config),
          if (widget.notificationDot != null)
            _buildDot(widget.notificationDot!, _DotPosition.topRight, config),
          if (widget.achievementDot != null)
            _buildDot(widget.achievementDot!, _DotPosition.bottomLeft, config),
          if (widget.actionDot != null)
            _buildDot(widget.actionDot!, _DotPosition.bottomRight, config),
        ],
      ),
    );

    // Press feedback
    if (_interactive) {
      avatar = GestureDetector(
        onTapDown: (_) => setState(() => _pressed = true),
        onTapUp: (_) {
          setState(() => _pressed = false);
          widget.onTap?.call();
        },
        onTapCancel: () => setState(() => _pressed = false),
        child: AnimatedOpacity(
          duration: const Duration(milliseconds: 100),
          opacity: _pressed ? 0.7 : 1.0,
          child: avatar,
        ),
      );
    }

    // Disabled state
    if (widget.isDisabled) {
      avatar = Opacity(opacity: 0.4, child: avatar);
    }

    // Semantics
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
      highlightColor: const Color(0xFF2A2A2C),
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

  // ── Badge dots ──

  Widget _buildDot(
    AvatarBadgeDot dot,
    _DotPosition position,
    _AvatarSizeConfig config,
  ) {
    final diameter = config.diameter;
    final dotSize = config.dotSize;

    // TL, TR, BL get a white outer ring; BR does not.
    final hasOuterRing = position != _DotPosition.bottomRight;
    const outerRingWidth = 2.0;

    // Total size including the outer ring (if present).
    final totalSize = hasOuterRing ? dotSize + (outerRingWidth * 2) : dotSize;

    // Place dot center on the avatar circle edge at a 45° diagonal.
    // The radius of the avatar is diameter/2. At 45°, the point on the circle
    // edge is at (r - r*cos(45°), r - r*sin(45°)) from the top-left corner.
    // cos(45°) ≈ 0.707, so the offset from the edge is r*(1-0.707) = r*0.293.
    // We subtract half the total size to center the dot on that point.
    final offset = (diameter / 2) * 0.293 - (totalSize / 2);

    double? top, bottom, left, right;

    switch (position) {
      case _DotPosition.topLeft:
        top = offset;
        left = offset;
      case _DotPosition.topRight:
        top = offset;
        right = offset;
      case _DotPosition.bottomLeft:
        bottom = offset;
        left = offset;
      case _DotPosition.bottomRight:
        bottom = offset;
        right = offset;
    }

    // Determine text color for contrast against the dot color.
    final textColor =
        ThemeData.estimateBrightnessForColor(dot.color) == Brightness.light
            ? AppColors.textInverse
            : AppColors.textPrimary;

    // Inner colored dot with text.
    Widget dotWidget = Container(
      width: dotSize,
      height: dotSize,
      decoration: BoxDecoration(
        color: dot.color,
        shape: BoxShape.circle,
      ),
      child: dot.text != null
          ? Center(
              child: Text(
                dot.text!,
                style: TextStyle(
                  fontFamily: 'Inter',
                  fontSize: config.dotFontSize,
                  fontWeight: FontWeight.w700,
                  color: textColor,
                  height: 1,
                ),
                textAlign: TextAlign.center,
                maxLines: 1,
                overflow: TextOverflow.clip,
              ),
            )
          : null,
    );

    // Wrap TL, TR, BL with a white outer ring.
    if (hasOuterRing) {
      dotWidget = Container(
        width: totalSize,
        height: totalSize,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          border: Border.all(
            color: AppColors.textPrimary,
            width: outerRingWidth,
          ),
        ),
        child: Center(child: dotWidget),
      );
    }

    return Positioned(
      top: top,
      bottom: bottom,
      left: left,
      right: right,
      child: dotWidget,
    );
  }
}
