import 'package:flutter/material.dart';
import '../foundation/colors.dart';
import '../foundation/color_utils.dart';
import '../foundation/grid.dart';
import '../foundation/opacity.dart';
import '../foundation/padding.dart';
import '../foundation/radius.dart';
import '../foundation/stroke.dart';
import '../foundation/three_d_press_geometry.dart';
import '../foundation/typography.dart';
import '../icons/icon_sizes.dart';
import 'icon.dart';
import 'interactive_atom_mixin.dart';
import 'text.dart';

// ── Enums ──

enum ButtonType { filled, outline, ghost }

enum ButtonSize { sm, md, lg }

// ── Size configuration ──

class _ButtonSizeConfig {
  final double height;
  final double paddingX;
  final TypeStyle typeStyle;
  final double iconSize;
  final double gap;
  final double borderRadius;

  const _ButtonSizeConfig({
    required this.height,
    required this.paddingX,
    required this.typeStyle,
    required this.iconSize,
    required this.gap,
    required this.borderRadius,
  });

  static final Map<ButtonSize, _ButtonSizeConfig> _map = {
    ButtonSize.sm: _ButtonSizeConfig(
      height: 2.25.rem,
      paddingX: AppPadding.rem075,
      typeStyle: AppTypography.bodySmall,
      iconSize: IconSizes.md,
      gap: AppGrid.grid4,
      borderRadius: AppRadius.sm,
    ),
    ButtonSize.md: _ButtonSizeConfig(
      height: 2.75.rem,
      paddingX: AppPadding.rem1,
      typeStyle: AppTypography.body,
      iconSize: IconSizes.md,
      gap: AppGrid.grid8,
      borderRadius: AppRadius.sm,
    ),
    ButtonSize.lg: _ButtonSizeConfig(
      height: 3.25.rem,
      paddingX: AppPadding.rem15,
      typeStyle: AppTypography.bodyLarge,
      iconSize: IconSizes.lg,
      gap: AppGrid.grid8,
      borderRadius: AppRadius.md,
    ),
  };

  static _ButtonSizeConfig of(ButtonSize size) => _map[size]!;
}

// ── Color resolution ──

class _ResolvedColors {
  final Color background;
  final Color foreground;
  final Color border;
  final Color shadow;

  const _ResolvedColors({
    required this.background,
    required this.foreground,
    required this.border,
    required this.shadow,
  });
}


_ResolvedColors _resolveColors(
  ButtonType type,
  Color color, {
  bool pressed = false,
  bool active = false,
}) {
  switch (type) {
    case ButtonType.filled:
      if (active) {
        return _ResolvedColors(
          background: AppColors.surface,
          foreground: color,
          border: Colors.transparent,
          shadow: resolve700(color),
        );
      }
      final fg =
          ThemeData.estimateBrightnessForColor(color) == Brightness.light
              ? AppColors.textInverse
              : AppColors.textPrimary;
      return _ResolvedColors(
        background: color,
        foreground: fg,
        border: Colors.transparent,
        shadow: resolve700(color),
      );
    case ButtonType.outline:
      if (active) {
        return _ResolvedColors(
          background: AppColors.grey850,
          foreground: color,
          border: color,
          shadow: color,
        );
      }
      final border900 = resolve900(color);
      return _ResolvedColors(
        background: AppColors.background,
        foreground: color,
        border: border900,
        shadow: border900,
      );
    case ButtonType.ghost:
      return _ResolvedColors(
        background: pressed ? color.withValues(alpha: AppOpacity.ghostPressed) : Colors.transparent,
        foreground: color,
        border: Colors.transparent,
        shadow: Colors.transparent,
      );
  }
}


// ── AppButton ──

/// Atom: reusable button with configurable type, size, and color.
///
/// Separates visual treatment ([ButtonType]) from color.
/// All token values come from the foundation layer.
///
/// Content patterns:
/// - text only: `AppButton(label: 'Save')`
/// - icon only: `AppButton(leadingIcon: AppIcons.add)`
/// - leading icon + text: `AppButton(leadingIcon: AppIcons.add, label: 'Add')`
/// - text + trailing icon: `AppButton(label: 'Next', trailingIcon: AppIcons.arrowRight)`
class AppButton extends StatefulWidget {
  /// Text label displayed in the button.
  final String? label;

  /// Asset path from [AppIcons] for a leading icon.
  final String? leadingIcon;

  /// Asset path from [AppIcons] for a trailing icon.
  final String? trailingIcon;

  /// Visual treatment: filled, outline, or ghost.
  final ButtonType type;

  /// Button size: sm (36px), md (44px), or lg (52px).
  final ButtonSize size;

  /// Accent color from [AppColors]. Determines background, foreground, and
  /// border based on [type].
  final Color color;

  /// Shows a loading spinner and disables interaction.
  final bool isLoading;

  /// Disables the button and reduces content opacity.
  final bool isDisabled;

  /// Whether the button is in its active (toggled-on) state.
  /// - null (default): no active state behavior, button works normally.
  /// - true/false: parent controls active state externally.
  /// Cannot be used together with [selfToggle].
  final bool? isActive;

  /// If true, the button toggles its own active state on tap.
  /// [onActiveChanged] is still called to notify the parent.
  /// Cannot be used together with [isActive].
  final bool selfToggle;

  /// Called when the active state changes.
  /// For parent-controlled mode, update your state variable here.
  /// For self-toggle mode, use this to react to changes.
  final ValueChanged<bool>? onActiveChanged;

  /// Called when the button is tapped (ignored when disabled or loading).
  final VoidCallback? onPressed;

  /// Override corner radius from size config. When null, uses size default.
  final double? radiusOverride;

  /// Override horizontal padding from size config. When null, uses size default.
  final double? paddingOverride;

  /// Override button height from size config. When null, uses size default.
  final double? heightOverride;

  /// Override button min width. When null, uses default (0 or square for icon-only).
  final double? widthOverride;

  const AppButton({
    super.key,
    this.label,
    this.leadingIcon,
    this.trailingIcon,
    this.type = ButtonType.filled,
    this.size = ButtonSize.md,
    this.color = AppColors.brand,
    this.isLoading = false,
    this.isDisabled = false,
    this.isActive,
    this.selfToggle = false,
    this.onActiveChanged,
    this.onPressed,
    this.radiusOverride,
    this.paddingOverride,
    this.heightOverride,
    this.widthOverride,
  }) : assert(
         label != null || leadingIcon != null || trailingIcon != null,
         'AppButton requires at least a label or an icon',
       ),
       assert(
         !(selfToggle && isActive != null),
         'Cannot use both selfToggle and isActive. Use one or the other.',
       );

  @override
  State<AppButton> createState() => _AppButtonState();
}

class _AppButtonState extends State<AppButton>
    with InteractiveAtomMixin {
  @override
  bool get isInteractive => !widget.isDisabled && !widget.isLoading;

  @override
  bool get isSelfToggle => widget.selfToggle;

  @override
  bool? get parentValue => widget.isActive;

  @override
  void notifyToggleChanged(bool value) =>
      widget.onActiveChanged?.call(value);

  @override
  void onAfterTap() => widget.onPressed?.call();

  bool get _iconOnly =>
      widget.label == null &&
      (widget.leadingIcon != null || widget.trailingIcon != null);

  @override
  void didUpdateWidget(covariant AppButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    resetSelfToggleIfNeeded(oldWidget.selfToggle);
  }

  @override
  Widget build(BuildContext context) {
    final sizeConfig = _ButtonSizeConfig.of(widget.size);

    return Semantics(
      button: true,
      enabled: isInteractive,
      label: widget.label,
      child: _buildButton(sizeConfig),
    );
  }

  Widget _buildButton(_ButtonSizeConfig sizeConfig) {
    final colors = _resolveColors(
      widget.type,
      widget.color,
      pressed: pressed,
      active: isActive,
    );

    final radius = widget.radiusOverride ?? sizeConfig.borderRadius;
    final padX = widget.paddingOverride ?? sizeConfig.paddingX;

    final PressGeometry geo;
    if (widget.type == ButtonType.filled) {
      geo = PressGeometry.filled(pressed: pressed);
    } else if (widget.type == ButtonType.outline) {
      geo = PressGeometry.outline(pressed: pressed);
    } else {
      geo = PressGeometry.ghost();
    }

    // Widget size is fixed — always the token height. Never changes.
    final height = widget.heightOverride ?? sizeConfig.height;
    final width = widget.widthOverride ?? (_iconOnly ? height : 0.0);

    return GestureDetector(
      onTapDown: isInteractive ? handleTapDown : null,
      onTapUp: isInteractive ? handleTapUp : null,
      onTapCancel: isInteractive ? handleTapCancel : null,
      child: CustomPaint(
        painter: _ButtonPainter(
          backgroundColor: colors.background,
          borderColor: colors.shadow,
          borderRadius: radius,
          borderTop: geo.visualTop,
          borderBottom: geo.visualBottom,
          borderSide: geo.visualSide,
          faceOffset: geo.faceOffset,
          faceSideInset: geo.layoutSide,
          showBorder: geo.showBorder,
        ),
        child: ConstrainedBox(
          constraints: BoxConstraints(
            minHeight: height,
            maxHeight: height,
            minWidth: width,
          ),
          child: Padding(
            padding: EdgeInsets.only(
              left: (_iconOnly ? 0 : padX) + geo.layoutSide,
              right: (_iconOnly ? 0 : padX) + geo.layoutSide,
              top: geo.visualTop + geo.faceOffset,
              bottom: (geo.visualBottom - geo.faceOffset).clamp(0.0, double.infinity),
            ),
            child: Center(
              widthFactor: 1.0,
              heightFactor: 1.0,
              child: _buildContent(sizeConfig, colors),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildContent(
    _ButtonSizeConfig sizeConfig,
    _ResolvedColors colors,
  ) {
    final contentOpacity = widget.isDisabled ? AppOpacity.disabled : AppOpacity.default_;

    final children = <Widget>[];

    if (widget.leadingIcon != null) {
      children.add(
        AppIcon(widget.leadingIcon!, size: sizeConfig.iconSize, color: colors.foreground),
      );
    }

    if (widget.label != null) {
      if (children.isNotEmpty) {
        children.add(SizedBox(width: sizeConfig.gap));
      }
      children.add(
        AppText(
          widget.label!,
          style: sizeConfig.typeStyle.semiBold,
          color: colors.foreground,
        ),
      );
    }

    if (widget.trailingIcon != null) {
      if (children.isNotEmpty) {
        children.add(SizedBox(width: sizeConfig.gap));
      }
      children.add(
        AppIcon(widget.trailingIcon!, size: sizeConfig.iconSize, color: colors.foreground),
      );
    }

    Widget content = Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      children: children,
    );

    if (widget.isLoading) {
      content = Stack(
        alignment: Alignment.center,
        children: [
          Opacity(opacity: 0, child: content),
          SizedBox(
            width: sizeConfig.iconSize,
            height: sizeConfig.iconSize,
            child: CircularProgressIndicator.adaptive(
              strokeWidth: AppStroke.md,
              valueColor: AlwaysStoppedAnimation<Color>(colors.foreground),
            ),
          ),
        ],
      );
    }

    return Opacity(
      opacity: contentOpacity,
      child: content,
    );
  }
}

// ── Custom painter for 3D button ──

class _ButtonPainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final double borderTop;
  final double borderBottom;
  final double borderSide;
  final double faceOffset;
  final double faceSideInset;
  final bool showBorder;

  _ButtonPainter({
    required this.backgroundColor,
    required this.borderColor,
    required this.borderRadius,
    required this.borderTop,
    required this.borderBottom,
    required this.borderSide,
    required this.faceOffset,
    required this.faceSideInset,
    required this.showBorder,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw border ring (only the border area, not the interior).
    //    Uses drawDRRect to paint the ring between outer and inner rects,
    //    leaving the gap between border and face transparent.
    if (showBorder && (borderBottom > 0 || borderSide > 0 || borderTop > 0)) {
      final outerRRect = RRect.fromRectAndRadius(
        Rect.fromLTRB(0, faceOffset, size.width, size.height),
        Radius.circular(borderRadius),
      );
      final borderInnerRadius = (borderRadius - borderSide).clamp(0.0, double.infinity);
      final borderInnerRRect = RRect.fromRectAndRadius(
        Rect.fromLTRB(borderSide, faceOffset + borderTop, size.width - borderSide, size.height - borderBottom),
        Radius.circular(borderInnerRadius),
      );
      final borderPaint = Paint()..color = borderColor;
      canvas.drawDRRect(outerRRect, borderInnerRRect, borderPaint);
    }

    // 2. Draw the button face.
    //    faceSideInset keeps horizontal position constant regardless of border width.
    //    faceOffset shifts the face down without thickening the border.
    final faceRect = Rect.fromLTRB(
      faceSideInset,
      borderTop + faceOffset,
      size.width - faceSideInset,
      size.height - borderBottom,
    );
    final faceRadius = (borderRadius - faceSideInset).clamp(0.0, double.infinity);
    final faceRRect = RRect.fromRectAndRadius(
      faceRect,
      Radius.circular(faceRadius),
    );
    final facePaint = Paint()..color = backgroundColor;
    canvas.drawRRect(faceRRect, facePaint);
  }

  @override
  bool shouldRepaint(_ButtonPainter old) =>
      backgroundColor != old.backgroundColor ||
      borderColor != old.borderColor ||
      borderRadius != old.borderRadius ||
      borderTop != old.borderTop ||
      borderBottom != old.borderBottom ||
      borderSide != old.borderSide ||
      faceOffset != old.faceOffset ||
      faceSideInset != old.faceSideInset ||
      showBorder != old.showBorder;
}
