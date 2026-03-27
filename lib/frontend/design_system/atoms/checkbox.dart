import 'package:flutter/material.dart';
import '../foundation/colors.dart';
import '../foundation/color_utils.dart';
import '../foundation/grid.dart';
import '../foundation/opacity.dart';
import '../foundation/radius.dart';
import '../foundation/three_d_press_geometry.dart';
import '../icons/app_icons.dart';
import 'icon.dart';
import 'interactive_atom_mixin.dart';

// ── Enums ──

enum CheckboxSize { sm, md, lg }

// ── Size configuration ──

class _CheckboxSizeConfig {
  final double size;
  final double iconSize;

  const _CheckboxSizeConfig({required this.size, required this.iconSize});

  static final Map<CheckboxSize, _CheckboxSizeConfig> _map = {
    CheckboxSize.sm: _CheckboxSizeConfig(size: AppGrid.grid24, iconSize: 14),
    CheckboxSize.md: _CheckboxSizeConfig(size: AppGrid.grid28, iconSize: 16),
    CheckboxSize.lg: _CheckboxSizeConfig(size: AppGrid.grid32, iconSize: 18),
  };

  static _CheckboxSizeConfig of(CheckboxSize size) => _map[size]!;
}

// ── Color resolution ──

class _ResolvedColors {
  final Color background;
  final Color border;
  final Color icon;

  const _ResolvedColors({
    required this.background,
    required this.border,
    required this.icon,
  });
}


_ResolvedColors _resolveColors(
  bool isFilled,
  Color color, {
  bool pressed = false,
}) {
  if (isFilled) {
    return _ResolvedColors(
      background: color,
      border: resolve700(color),
      icon: AppColors.textPrimary,
    );
  }

  // Unchecked
  return _ResolvedColors(
    background: Colors.transparent,
    border: AppColors.textPrimary,
    icon: Colors.transparent,
  );
}

// ── AppCheckbox ──

/// Atom: checkbox with 3D border press effect.
///
/// Icon-only — compose with [AppText] in a [Row] for labeled checkboxes.
///
/// Supports three visual states: unchecked, checked, indeterminate.
///
/// State control modes:
/// - Parent-controlled: pass [selected] and handle [onChanged]
/// - Self-toggle: set [selfToggle] to true
class AppCheckbox extends StatefulWidget {
  /// Whether the checkbox is selected (parent-controlled mode).
  /// - null (default): no parent control, see [selfToggle].
  /// - true/false: parent controls selected state externally.
  final bool? selected;

  /// If true, the checkbox toggles its own state on tap.
  /// Cycles: unchecked → checked → unchecked.
  /// Cannot be used together with [selected].
  final bool selfToggle;

  /// Called when the checkbox state changes.
  final ValueChanged<bool>? onChanged;

  /// Checkbox size: sm (24px), md (28px), lg (32px).
  final CheckboxSize size;

  /// Accent color for checked/indeterminate state.
  final Color color;

  /// Visual override — shows indeterminate icon instead of check.
  /// Only visual; does not affect toggle logic.
  final bool isIndeterminate;

  /// Disables interaction and reduces opacity to 0.4.
  final bool isDisabled;

  const AppCheckbox({
    super.key,
    this.selected,
    this.selfToggle = false,
    this.onChanged,
    this.size = CheckboxSize.md,
    this.color = AppColors.brand,
    this.isIndeterminate = false,
    this.isDisabled = false,
  }) : assert(
         !(selfToggle && selected != null),
         'Cannot use both selfToggle and selected. Use one or the other.',
       );

  @override
  State<AppCheckbox> createState() => _AppCheckboxState();
}

class _AppCheckboxState extends State<AppCheckbox>
    with InteractiveAtomMixin {
  @override
  bool get isInteractive => !widget.isDisabled;

  @override
  bool get isSelfToggle => widget.selfToggle;

  @override
  bool? get parentValue => widget.selected;

  @override
  void notifyToggleChanged(bool value) => widget.onChanged?.call(value);

  @override
  void didUpdateWidget(covariant AppCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    resetSelfToggleIfNeeded(oldWidget.selfToggle);
  }

  @override
  Widget build(BuildContext context) {
    final sizeConfig = _CheckboxSizeConfig.of(widget.size);

    final showFilled = isActive || widget.isIndeterminate;

    final colors = _resolveColors(
      showFilled,
      widget.color,
      pressed: pressed,
    );
    final contentOpacity = widget.isDisabled ? AppOpacity.disabled : AppOpacity.default_;

    final geo = showFilled
        ? PressGeometry.filled(pressed: pressed)
        : PressGeometry.outline(pressed: pressed);

    final totalWidth = sizeConfig.size + (geo.layoutSide * 2);
    final totalHeight = sizeConfig.size + PressGeometry.depth;

    return Semantics(
      checked: isActive,
      child: GestureDetector(
        onTapDown: isInteractive ? handleTapDown : null,
        onTapUp: isInteractive ? handleTapUp : null,
        onTapCancel: isInteractive ? handleTapCancel : null,
        child: Opacity(
          opacity: contentOpacity,
          child: CustomPaint(
            painter: _CheckboxPainter(
              backgroundColor: colors.background,
              borderColor: colors.border,
              borderRadius: AppRadius.sm,
              borderTop: geo.visualTop,
              borderBottom: geo.visualBottom,
              borderSide: geo.visualSide,
              faceOffset: geo.faceOffset,
              faceSideInset: geo.layoutSide,
              borderSideOffset: showFilled
                  ? 0.0
                  : (pressed ? 1.5 : 0.0),
              showBorder: geo.showBorder,
            ),
            child: SizedBox(
              width: totalWidth,
              height: totalHeight,
              child: Padding(
                padding: EdgeInsets.only(
                  left: geo.layoutSide,
                  right: geo.layoutSide,
                  top: geo.visualTop + geo.faceOffset,
                  bottom: (geo.visualBottom - geo.faceOffset).clamp(
                    0.0,
                    double.infinity,
                  ),
                ),
                child: Center(
                  child: showFilled
                      ? AppIcon(
                          widget.isIndeterminate
                              ? AppIcons.minus
                              : AppIcons.check,
                          size: sizeConfig.iconSize,
                          color: colors.icon,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Custom painter for 3D checkbox ──

class _CheckboxPainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final double borderTop;
  final double borderBottom;
  final double borderSide;
  final double faceOffset;
  final double faceSideInset;
  final double borderSideOffset;
  final bool showBorder;

  _CheckboxPainter({
    required this.backgroundColor,
    required this.borderColor,
    required this.borderRadius,
    required this.borderTop,
    required this.borderBottom,
    required this.borderSide,
    required this.faceOffset,
    required this.faceSideInset,
    required this.borderSideOffset,
    required this.showBorder,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw border ring
    if (showBorder && (borderBottom > 0 || borderSide > 0 || borderTop > 0)) {
      final outerRRect = RRect.fromRectAndRadius(
        Rect.fromLTRB(
          borderSideOffset,
          faceOffset,
          size.width - borderSideOffset,
          size.height,
        ),
        Radius.circular(borderRadius),
      );
      final borderInnerRadius = (borderRadius - borderSide).clamp(
        0.0,
        double.infinity,
      );
      final borderInnerRRect = RRect.fromRectAndRadius(
        Rect.fromLTRB(
          borderSideOffset + borderSide,
          faceOffset + borderTop,
          size.width - borderSideOffset - borderSide,
          size.height - borderBottom,
        ),
        Radius.circular(borderInnerRadius),
      );
      final borderPaint = Paint()..color = borderColor;
      canvas.drawDRRect(outerRRect, borderInnerRRect, borderPaint);
    }

    // 2. Draw the checkbox face
    //    faceOffset shifts the face down without thickening the border.
    final effectiveSideInset = borderSideOffset > 0
        ? borderSideOffset + borderSide
        : faceSideInset;
    final faceRect = Rect.fromLTRB(
      effectiveSideInset,
      borderTop + faceOffset,
      size.width - effectiveSideInset,
      size.height - borderBottom,
    );
    final faceRadius = (borderRadius - effectiveSideInset).clamp(
      0.0,
      double.infinity,
    );
    final faceRRect = RRect.fromRectAndRadius(
      faceRect,
      Radius.circular(faceRadius),
    );
    final facePaint = Paint()..color = backgroundColor;
    canvas.drawRRect(faceRRect, facePaint);
  }

  @override
  bool shouldRepaint(_CheckboxPainter old) =>
      backgroundColor != old.backgroundColor ||
      borderColor != old.borderColor ||
      borderRadius != old.borderRadius ||
      borderTop != old.borderTop ||
      borderBottom != old.borderBottom ||
      borderSide != old.borderSide ||
      faceOffset != old.faceOffset ||
      faceSideInset != old.faceSideInset ||
      borderSideOffset != old.borderSideOffset ||
      showBorder != old.showBorder;
}
