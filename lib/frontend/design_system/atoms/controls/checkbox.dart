import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/color/color_utils.dart';
import '../../foundation/motion/curves.dart';
import '../../foundation/motion/durations.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/press/three_d_press_geometry.dart';
import '../../icons/app_icons.dart';
import '../primitives/icon.dart';
import '../behaviors/interactive_atom_mixin.dart';
import '../behaviors/three_d_press_painter.dart';
import '../behaviors/three_d_pressable.dart';
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
    with SingleTickerProviderStateMixin, InteractiveAtomMixin {
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

    // Color endpoints — crossfaded by [stateT].
    const inactiveBg = Colors.transparent;
    const inactiveBorder = AppColors.textPrimary;
    final activeBg = widget.color;
    final activeBorder = resolve700(widget.color);

    // Geometry grid: 2 families (outline/filled) × 2 press states.
    // Bilinear lerp below: press-within-family → state-across-families.
    final geoInactiveUnpressed = PressGeometry.outline(pressed: false);
    final geoInactivePressed = PressGeometry.outline(pressed: true);
    final geoActiveUnpressed = PressGeometry.filled(pressed: false);
    final geoActivePressed = PressGeometry.filled(pressed: true);

    final totalWidth = sizeConfig.size + (geoInactiveUnpressed.layoutSide * 2);
    final totalHeight = sizeConfig.size + PressGeometry.depth;

    // Icon always renders; opacity is driven by [stateT] so it fades in/out.
    final iconChild = AppIcon(
      widget.isIndeterminate ? AppIcons.minus : AppIcons.check,
      size: sizeConfig.iconSize,
      color: AppColors.textPrimary,
    );

    return Semantics(
      checked: isActive,
      child: TweenAnimationBuilder<double>(
        tween: Tween<double>(end: showFilled ? 1.0 : 0.0),
        duration: AppDurations.toggle,
        curve: AppCurves.toggle,
        builder: (context, stateT, _) {
          return AnimatedBuilder(
            animation: pressAnimation,
            builder: (context, _) {
              final pressT = pressAnimation.value;
              // Bilinear: press inside each family, then state across families.
              final geoInactive = PressGeometry.lerp(
                geoInactiveUnpressed,
                geoInactivePressed,
                pressT,
              );
              final geoActive = PressGeometry.lerp(
                geoActiveUnpressed,
                geoActivePressed,
                pressT,
              );
              final geo = PressGeometry.lerp(geoInactive, geoActive, stateT);

              final backgroundColor =
                  Color.lerp(inactiveBg, activeBg, stateT)!;
              final borderColor =
                  Color.lerp(inactiveBorder, activeBorder, stateT)!;

              // borderSideOffset applies only to outline-pressed; filled is 0.
              // Fade it out as the state crosses toward active.
              final borderSideOffset = (1.0 - stateT) * 1.5 * pressT;

              return ThreeDPressable(
                isInteractive: isInteractive,
                isDisabled: widget.isDisabled,
                onTapDown: handleTapDown,
                onTapUp: handleTapUp,
                onTapCancel: handleTapCancel,
                painter: ThreeDPressPainter(
                  backgroundColor: backgroundColor,
                  borderColor: borderColor,
                  borderRadius: AppRadius.sm,
                  borderTop: geo.visualTop,
                  borderBottom: geo.visualBottom,
                  borderSide: geo.visualSide,
                  faceOffset: geo.faceOffset,
                  faceSideInset: geo.layoutSide,
                  borderSideOffset: borderSideOffset,
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
                      child: Opacity(opacity: stateT, child: iconChild),
                    ),
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}
