import 'package:flutter/widgets.dart';

/// Callback for painting additional content on the face surface.
///
/// Receives the computed [faceRect] so content can center itself
/// relative to the visible face (e.g., a radio dot).
typedef ContentPainter = void Function(Canvas canvas, Rect faceRect);

/// Shared painter for the 3D press effect used by Button, Checkbox, and Radio.
///
/// Renders a two-layer illusion:
/// 1. A border ring (drawn as a dRRect gap between outer and inner rounded rects).
/// 2. A face surface inset within the ring.
///
/// Optional [borderSideOffset] shifts the border ring horizontally (checkbox press).
/// Optional [contentPainter] draws additional content on the face (radio dot).
/// Optional [borderSideLeft] / [borderSideRight] override [borderSide] per edge
/// for asymmetric side borders (split-zone cards).
class ThreeDPressPainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final BorderRadius? borderRadiusGeometry;
  final double borderTop;
  final double borderBottom;
  final double borderSide;
  final double? borderSideLeft;
  final double? borderSideRight;
  final double faceOffset;
  final double faceSideInset;
  final bool showBorder;
  final double borderSideOffset;
  final ContentPainter? contentPainter;

  const ThreeDPressPainter({
    required this.backgroundColor,
    required this.borderColor,
    required this.borderRadius,
    this.borderRadiusGeometry,
    required this.borderTop,
    required this.borderBottom,
    required this.borderSide,
    this.borderSideLeft,
    this.borderSideRight,
    required this.faceOffset,
    required this.faceSideInset,
    required this.showBorder,
    this.borderSideOffset = 0.0,
    this.contentPainter,
  });

  /// Reduce each corner radius by per-side insets, clamping to zero.
  BorderRadius _insetCornersLR(
    BorderRadius br,
    double leftInset,
    double rightInset,
  ) {
    return BorderRadius.only(
      topLeft: Radius.circular(
          (br.topLeft.x - leftInset).clamp(0.0, double.infinity)),
      topRight: Radius.circular(
          (br.topRight.x - rightInset).clamp(0.0, double.infinity)),
      bottomLeft: Radius.circular(
          (br.bottomLeft.x - leftInset).clamp(0.0, double.infinity)),
      bottomRight: Radius.circular(
          (br.bottomRight.x - rightInset).clamp(0.0, double.infinity)),
    );
  }

  @override
  void paint(Canvas canvas, Size size) {
    final corners =
        borderRadiusGeometry ?? BorderRadius.circular(borderRadius);
    final effectiveLeft = borderSideLeft ?? borderSide;
    final effectiveRight = borderSideRight ?? borderSide;

    // 1. Draw border ring (only the border area, not the interior).
    //    Uses drawDRRect to paint the ring between outer and inner rects,
    //    leaving the gap between border and face transparent.
    if (showBorder &&
        (borderBottom > 0 || effectiveLeft > 0 || effectiveRight > 0 ||
            borderTop > 0)) {
      final outerRRect = RRect.fromRectAndCorners(
        Rect.fromLTRB(
          borderSideOffset,
          faceOffset,
          size.width - borderSideOffset,
          size.height,
        ),
        topLeft: corners.topLeft,
        topRight: corners.topRight,
        bottomLeft: corners.bottomLeft,
        bottomRight: corners.bottomRight,
      );
      final innerCorners = _insetCornersLR(corners, effectiveLeft, effectiveRight);
      final borderInnerRRect = RRect.fromRectAndCorners(
        Rect.fromLTRB(
          borderSideOffset + effectiveLeft,
          faceOffset + borderTop,
          size.width - borderSideOffset - effectiveRight,
          size.height - borderBottom,
        ),
        topLeft: innerCorners.topLeft,
        topRight: innerCorners.topRight,
        bottomLeft: innerCorners.bottomLeft,
        bottomRight: innerCorners.bottomRight,
      );
      final borderPaint = Paint()..color = borderColor;
      canvas.drawDRRect(outerRRect, borderInnerRRect, borderPaint);
    }

    // 2. Draw the face surface.
    //    When borderSideOffset is active (checkbox press), the face insets
    //    from the offset + border. Otherwise it uses the larger of
    //    faceSideInset and the border width on each side.
    final double faceLeft;
    final double faceRight;
    if (borderSideOffset > 0) {
      faceLeft = borderSideOffset + effectiveLeft;
      faceRight = borderSideOffset + effectiveRight;
    } else {
      faceLeft =
          effectiveLeft > faceSideInset ? effectiveLeft : faceSideInset;
      faceRight =
          effectiveRight > faceSideInset ? effectiveRight : faceSideInset;
    }
    final faceRect = Rect.fromLTRB(
      faceLeft,
      borderTop + faceOffset,
      size.width - faceRight,
      size.height - borderBottom,
    );
    final faceCorners = _insetCornersLR(corners, faceLeft, faceRight);
    final faceRRect = RRect.fromRectAndCorners(
      faceRect,
      topLeft: faceCorners.topLeft,
      topRight: faceCorners.topRight,
      bottomLeft: faceCorners.bottomLeft,
      bottomRight: faceCorners.bottomRight,
    );
    final facePaint = Paint()..color = backgroundColor;
    canvas.drawRRect(faceRRect, facePaint);

    // 3. Optional content (e.g., radio dot) painted on the face.
    contentPainter?.call(canvas, faceRect);
  }

  @override
  bool shouldRepaint(ThreeDPressPainter old) =>
      backgroundColor != old.backgroundColor ||
      borderColor != old.borderColor ||
      borderRadius != old.borderRadius ||
      borderRadiusGeometry != old.borderRadiusGeometry ||
      borderTop != old.borderTop ||
      borderBottom != old.borderBottom ||
      borderSide != old.borderSide ||
      borderSideLeft != old.borderSideLeft ||
      borderSideRight != old.borderSideRight ||
      faceOffset != old.faceOffset ||
      faceSideInset != old.faceSideInset ||
      showBorder != old.showBorder ||
      borderSideOffset != old.borderSideOffset ||
      contentPainter != old.contentPainter;
}
