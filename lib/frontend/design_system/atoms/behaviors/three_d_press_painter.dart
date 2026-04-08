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
class ThreeDPressPainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final double borderTop;
  final double borderBottom;
  final double borderSide;
  final double faceOffset;
  final double faceSideInset;
  final bool showBorder;
  final double borderSideOffset;
  final ContentPainter? contentPainter;

  const ThreeDPressPainter({
    required this.backgroundColor,
    required this.borderColor,
    required this.borderRadius,
    required this.borderTop,
    required this.borderBottom,
    required this.borderSide,
    required this.faceOffset,
    required this.faceSideInset,
    required this.showBorder,
    this.borderSideOffset = 0.0,
    this.contentPainter,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw border ring (only the border area, not the interior).
    //    Uses drawDRRect to paint the ring between outer and inner rects,
    //    leaving the gap between border and face transparent.
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
      final borderInnerRadius =
          (borderRadius - borderSide).clamp(0.0, double.infinity);
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

    // 2. Draw the face surface.
    //    When borderSideOffset is active (checkbox press), the face insets
    //    from the offset + border. Otherwise it uses the standard faceSideInset.
    final effectiveSideInset = borderSideOffset > 0
        ? borderSideOffset + borderSide
        : faceSideInset;
    final faceRect = Rect.fromLTRB(
      effectiveSideInset,
      borderTop + faceOffset,
      size.width - effectiveSideInset,
      size.height - borderBottom,
    );
    final faceRadius =
        (borderRadius - effectiveSideInset).clamp(0.0, double.infinity);
    final faceRRect = RRect.fromRectAndRadius(
      faceRect,
      Radius.circular(faceRadius),
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
      borderTop != old.borderTop ||
      borderBottom != old.borderBottom ||
      borderSide != old.borderSide ||
      faceOffset != old.faceOffset ||
      faceSideInset != old.faceSideInset ||
      showBorder != old.showBorder ||
      borderSideOffset != old.borderSideOffset ||
      contentPainter != old.contentPainter;
}
