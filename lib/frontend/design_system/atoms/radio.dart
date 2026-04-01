import 'package:flutter/material.dart';
import '../foundation/colors.dart';
import '../foundation/color_utils.dart';
import '../foundation/grid.dart';
import '../foundation/opacity.dart';
import '../foundation/three_d_press_geometry.dart';
import 'interactive_atom_mixin.dart';

// ── Enums ──

enum RadioSize { sm, md, lg }

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
            painter: _RadioPainter(
              backgroundColor: backgroundColor,
              borderColor: borderColor,
              borderTop: geo.visualTop,
              borderBottom: geo.visualBottom,
              borderSide: geo.visualSide,
              faceOffset: geo.faceOffset,
              faceSideInset: geo.visualSide,
              showDot: isActive,
              dotColor: AppColors.textPrimary,
              dotSize: sizeConfig.dotSize,
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
}

// ── Custom painter for 3D radio ──

class _RadioPainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;
  final double borderTop;
  final double borderBottom;
  final double borderSide;
  final double faceOffset;
  final double faceSideInset;
  final bool showDot;
  final Color dotColor;
  final double dotSize;

  _RadioPainter({
    required this.backgroundColor,
    required this.borderColor,
    required this.borderTop,
    required this.borderBottom,
    required this.borderSide,
    required this.faceOffset,
    required this.faceSideInset,
    required this.showDot,
    required this.dotColor,
    required this.dotSize,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // Full circle radius
    final radius = size.width / 2;

    // 1. Draw border ring
    if (borderBottom > 0 || borderSide > 0 || borderTop > 0) {
      final outerRRect = RRect.fromRectAndRadius(
        Rect.fromLTRB(0, faceOffset, size.width, size.height),
        Radius.circular(radius),
      );
      final borderInnerRadius = (radius - borderSide).clamp(0.0, double.infinity);
      final borderInnerRRect = RRect.fromRectAndRadius(
        Rect.fromLTRB(
          borderSide,
          faceOffset + borderTop,
          size.width - borderSide,
          size.height - borderBottom,
        ),
        Radius.circular(borderInnerRadius),
      );
      final borderPaint = Paint()..color = borderColor;
      canvas.drawDRRect(outerRRect, borderInnerRRect, borderPaint);
    }

    // 2. Draw the radio face
    final faceRect = Rect.fromLTRB(
      faceSideInset,
      borderTop + faceOffset,
      size.width - faceSideInset,
      size.height - borderBottom,
    );
    final faceRadius = (radius - faceSideInset).clamp(0.0, double.infinity);
    final faceRRect = RRect.fromRectAndRadius(
      faceRect,
      Radius.circular(faceRadius),
    );
    final facePaint = Paint()..color = backgroundColor;
    canvas.drawRRect(faceRRect, facePaint);

    // 3. Draw inner dot when selected
    if (showDot) {
      final faceCenterX = faceRect.center.dx;
      final faceCenterY = faceRect.center.dy;
      final dotPaint = Paint()..color = dotColor;
      canvas.drawCircle(
        Offset(faceCenterX, faceCenterY),
        dotSize / 2,
        dotPaint,
      );
    }
  }

  @override
  bool shouldRepaint(_RadioPainter old) =>
      backgroundColor != old.backgroundColor ||
      borderColor != old.borderColor ||
      borderTop != old.borderTop ||
      borderBottom != old.borderBottom ||
      borderSide != old.borderSide ||
      faceOffset != old.faceOffset ||
      faceSideInset != old.faceSideInset ||
      showDot != old.showDot ||
      dotColor != old.dotColor ||
      dotSize != old.dotSize;
}
