import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/color/color_utils.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/opacity.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/press/three_d_press_geometry.dart';
import '../../icons/app_icons.dart';
import '../primitives/icon.dart';
import '../behaviors/interactive_atom_mixin.dart';
import '../behaviors/three_d_press_painter.dart';
import 'checkbox_types.dart';

// ── Size configuration ──

class _CheckboxSizeConfig {
  final double size;
  final double iconSize;

  const _CheckboxSizeConfig({required this.size, required this.iconSize});

  /// Exhaustive switch — compiler errors if a new CheckboxSize case is added
  /// without a corresponding branch. Replaces the old Map lookup.
  static _CheckboxSizeConfig of(CheckboxSize size) {
    return switch (size) {
      CheckboxSize.sm => _sm,
      CheckboxSize.md => _md,
      CheckboxSize.lg => _lg,
    };
  }

  // Icon sizes are optical values hand-tuned per checkbox size for visual
  // balance inside the 3D border. They intentionally do not align with the
  // IconSizes token scale (8/16/24/32).
  static const _sm = _CheckboxSizeConfig(size: AppGrid.grid24, iconSize: 14);
  static const _md = _CheckboxSizeConfig(size: AppGrid.grid28, iconSize: 16);
  static const _lg = _CheckboxSizeConfig(size: AppGrid.grid32, iconSize: 18);
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
  return const _ResolvedColors(
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

  Widget _wrapDisabled({required Widget child}) {
    if (!widget.isDisabled) return child;
    return Opacity(opacity: AppOpacity.disabled, child: child);
  }

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
        child: _wrapDisabled(
          child: CustomPaint(
            painter: ThreeDPressPainter(
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
