import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/color/color_utils.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/opacity.dart';
import '../../foundation/space/padding.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/space/stroke.dart';
import '../../foundation/press/three_d_press_geometry.dart';
import '../../foundation/type/typography.dart';
import '../../icons/icon_sizes.dart';
import '../primitives/icon.dart';
import '../behaviors/interactive_atom_mixin.dart';
import '../primitives/text.dart';
import '../behaviors/three_d_press_painter.dart';
import 'button_types.dart';

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

  /// Exhaustive switch — compiler errors if a new ButtonSize case is added
  /// without a corresponding branch. Replaces the old Map lookup.
  static _ButtonSizeConfig of(ButtonSize size) {
    return switch (size) {
      ButtonSize.sm => _sm,
      ButtonSize.md => _md,
      ButtonSize.lg => _lg,
    };
  }

  static final _sm = _ButtonSizeConfig(
    height: AppGrid.grid36,
    paddingX: AppPadding.rem075,
    typeStyle: AppTypography.bodySmall,
    iconSize: IconSizes.md,
    gap: AppGrid.grid4,
    borderRadius: AppRadius.sm,
  );

  static final _md = _ButtonSizeConfig(
    height: AppGrid.grid44,
    paddingX: AppPadding.rem1,
    typeStyle: AppTypography.body,
    iconSize: IconSizes.md,
    gap: AppGrid.grid8,
    borderRadius: AppRadius.sm,
  );

  static final _lg = _ButtonSizeConfig(
    height: AppGrid.grid52,
    paddingX: AppPadding.rem15,
    typeStyle: AppTypography.bodyLarge,
    iconSize: IconSizes.lg,
    gap: AppGrid.grid8,
    borderRadius: AppRadius.md,
  );
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

  /// Dispatch — exhaustive switch forces compile-time handling of every type.
  factory _ResolvedColors.of(
    ButtonType type,
    Color color, {
    required bool pressed,
    required bool active,
  }) {
    return switch (type) {
      ButtonType.filled  => _ResolvedColors.filled(color, active: active),
      ButtonType.outline => _ResolvedColors.outline(color, active: active),
      ButtonType.ghost   => _ResolvedColors.ghost(color, pressed: pressed),
    };
  }

  /// Filled: solid background, auto-contrast foreground, 700-shadow border.
  factory _ResolvedColors.filled(Color color, {required bool active}) {
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
  }

  /// Outline: transparent background, colored border, 900-shadow.
  factory _ResolvedColors.outline(Color color, {required bool active}) {
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
  }

  /// Ghost: no border, subtle press tint.
  factory _ResolvedColors.ghost(Color color, {required bool pressed}) {
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
    final colors = _ResolvedColors.of(
      widget.type,
      widget.color,
      pressed: pressed,
      active: isActive,
    );

    final radius = sizeConfig.borderRadius;
    final padX = sizeConfig.paddingX;

    final geo = switch (widget.type) {
      ButtonType.filled  => PressGeometry.filled(pressed: pressed),
      ButtonType.outline => PressGeometry.outline(pressed: pressed),
      ButtonType.ghost   => PressGeometry.ghost(),
    };

    // Widget size is fixed — always the token height. Never changes.
    final height = sizeConfig.height;
    final width = _iconOnly ? height : 0.0;

    return GestureDetector(
      onTapDown: isInteractive ? handleTapDown : null,
      onTapUp: isInteractive ? handleTapUp : null,
      onTapCancel: isInteractive ? handleTapCancel : null,
      child: CustomPaint(
        painter: ThreeDPressPainter(
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
