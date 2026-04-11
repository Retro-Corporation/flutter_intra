import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/color/color_utils.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/opacity.dart';
import '../../foundation/press/three_d_press_geometry.dart';
import '../behaviors/interactive_atom_mixin.dart';
import '../behaviors/three_d_press_painter.dart';
import 'radio_types.dart';

// ── Size configuration ──

class _RadioSizeConfig {
  final double size;
  final double dotSize;

  const _RadioSizeConfig({
    required this.size,
    required this.dotSize,
  });

  /// Exhaustive switch — compiler errors if a new RadioSize case is added
  /// without a corresponding branch. Replaces the old Map lookup.
  static _RadioSizeConfig of(RadioSize size) {
    return switch (size) {
      RadioSize.sm => _sm,
      RadioSize.md => _md,
      RadioSize.lg => _lg,
    };
  }

  // Dot sizes are optical values hand-tuned per radio size for visual
  // balance inside the 3D border. They intentionally do not align with the
  // IconSizes token scale (8/16/24/32).
  static final _sm = _RadioSizeConfig(size: AppGrid.grid24, dotSize: 10);
  static final _md = _RadioSizeConfig(size: AppGrid.grid28, dotSize: 11);
  static final _lg = _RadioSizeConfig(size: AppGrid.grid32, dotSize: 13);
}

// ── Color resolution ──


// ── AppRadio ──

/// Atom: radio button with 3D border press effect.
///
/// Circular — compose with [AppText] in a [Row] for labeled radios.
///
/// State control modes:
/// - Parent-controlled: pass [selected] and handle [onChanged]
/// - Self-toggle: set [selfToggle] to true
class AppRadio extends StatefulWidget {
  /// Whether the radio is selected (parent-controlled mode).
  /// - null (default): no parent control, see [selfToggle].
  /// - true/false: parent controls selected state externally.
  final bool? selected;

  /// If true, the radio toggles its own state on tap.
  /// Cannot be used together with [selected].
  final bool selfToggle;

  /// Called when the radio state changes.
  final ValueChanged<bool>? onChanged;

  /// Radio size: sm (24px), md (28px), lg (32px).
  final RadioSize size;

  /// Accent color for selected state.
  final Color color;

  /// Disables interaction and reduces opacity to 0.4.
  final bool isDisabled;

  const AppRadio({
    super.key,
    this.selected,
    this.selfToggle = false,
    this.onChanged,
    this.size = RadioSize.md,
    this.color = AppColors.brand,
    this.isDisabled = false,
  }) : assert(
         !(selfToggle && selected != null),
         'Cannot use both selfToggle and selected. Use one or the other.',
       );

  @override
  State<AppRadio> createState() => _AppRadioState();
}

class _AppRadioState extends State<AppRadio>
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
  void didUpdateWidget(covariant AppRadio oldWidget) {
    super.didUpdateWidget(oldWidget);
    resetSelfToggleIfNeeded(oldWidget.selfToggle);
  }

  @override
  Widget build(BuildContext context) {
    final sizeConfig = _RadioSizeConfig.of(widget.size);
    final contentOpacity = widget.isDisabled ? AppOpacity.disabled : AppOpacity.default_;

    final geo = PressGeometry.outline(pressed: pressed);

    // ── Colors ──
    final Color backgroundColor;
    final Color borderColor;

    if (isActive) {
      backgroundColor = widget.color;
      borderColor = resolve700(widget.color);
    } else {
      backgroundColor = Colors.transparent;
      borderColor = AppColors.textPrimary;
    }

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
            painter: ThreeDPressPainter(
              backgroundColor: backgroundColor,
              borderColor: borderColor,
              borderRadius: totalWidth / 2,
              borderTop: geo.visualTop,
              borderBottom: geo.visualBottom,
              borderSide: geo.visualSide,
              faceOffset: geo.faceOffset,
              faceSideInset: geo.visualSide,
              showBorder: true,
              contentPainter: isActive
                  ? (canvas, faceRect) => _paintDot(
                        canvas,
                        faceRect,
                        sizeConfig.dotSize,
                      )
                  : null,
            ),
            child: SizedBox(
              width: totalWidth,
              height: totalHeight,
            ),
          ),
        ),
      ),
    );
  }

  /// Paints the radio selection dot centered on [faceRect].
  void _paintDot(Canvas canvas, Rect faceRect, double dotSize) {
    final dotPaint = Paint()..color = AppColors.textPrimary;
    canvas.drawCircle(faceRect.center, dotSize / 2, dotPaint);
  }
}
