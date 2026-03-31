import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../foundation/stroke.dart';
import 'path_button_geometry.dart';

// ── PathButtonRenderer ──

class PathButtonRenderer extends CustomPainter {
  final PathButtonShape shape;
  final PathButtonState state;
  final List<PathButtonSegment> segments;
  final Color color;
  final double pulseExpansion;
  final bool pressed;
  final double visualTop;
  final double visualBottom;

  PathButtonRenderer({
    required this.shape,
    required this.state,
    required this.segments,
    required this.color,
    required this.pulseExpansion,
    required this.pressed,
    required this.visualTop,
    required this.visualBottom,
  });

  // ── Derived geometry (computed from shape) ──

  double get faceSize => shape.faceSize;
  double get outerSize => shape.outerSize;
  double get pulseExpand => shape.pulseExpand;

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    // Rest center for both face and ring (before press offset)
    final restCenterY = pulseExpand + outerSize / 2;
    // Press-adjusted center — face AND ring move together
    final centerY = restCenterY + visualTop;

    final faceHalf = faceSize / 2;
    final shadowColor = state.shadowColor(color);

    // ── 1. Draw 3D shadow (behind main face) ──
    if (!pressed) {
      _drawShadow(canvas, cx, restCenterY, faceHalf, shadowColor);
    }

    // ── 2. Draw main face ──
    final mainFaceColor = state.faceColor(color);
    _drawFace(canvas, cx: cx, cy: centerY, faceColor: mainFaceColor);

    // ── 3. Draw segmented ring (moves with face) ──
    // When unpressed, the shadow inside the ring gap makes the face look
    // shifted up. Offset the ring down by half the border so it visually
    // centers on the face+shadow unit. When pressed (no shadow), ring and
    // face share the exact same center.
    final ringCenterY = pressed ? centerY : centerY + pathBorderBottom / 2;
    _drawSegmentedRing(canvas, cx, ringCenterY);
  }

  /// Draws the 3D border behind the face.
  void _drawShadow(Canvas canvas, double cx, double restCenterY, double faceHalf, Color shadowColor) {
    final paint = Paint()..color = shadowColor;
    final shadowShift = pathBorderBottom - pathBorderSide;
    final shadowExpand = pathBorderSide;

    switch (shape) {
      case PathButtonShape.circle:
        final borderPath = Path()
          ..addOval(Rect.fromCircle(
            center: Offset(cx, restCenterY + shadowShift),
            radius: faceHalf + shadowExpand,
          ))
          ..addOval(Rect.fromCircle(
            center: Offset(cx, restCenterY),
            radius: faceHalf,
          ));
        borderPath.fillType = PathFillType.evenOdd;
        canvas.drawPath(borderPath, paint);

      case PathButtonShape.triangle:
        final triShift = 2 * (pathBorderBottom - pathBorderSide) / 3;
        final triExpand = 2 * (pathBorderSide + triShift / 2) / math.sqrt(3);
        final outerPath = buildTrianglePath(
          cx, restCenterY + triShift,
          faceHalf + triExpand,
          shape.faceCornerRadius,
        );
        final innerPath = buildTrianglePath(
          cx, restCenterY,
          faceHalf,
          shape.faceCornerRadius,
        );
        final borderPath = Path()
          ..addPath(outerPath, Offset.zero)
          ..addPath(innerPath, Offset.zero);
        borderPath.fillType = PathFillType.evenOdd;
        canvas.drawPath(borderPath, paint);

      case PathButtonShape.roundedSquare:
        final faceRect = Rect.fromCenter(
          center: Offset(cx, restCenterY),
          width: faceSize,
          height: faceSize,
        );
        final outerRect = Rect.fromLTRB(
          faceRect.left - pathBorderSide,
          faceRect.top - pathBorderTop,
          faceRect.right + pathBorderSide,
          faceRect.bottom + pathBorderBottom,
        );
        final outerR = RRect.fromRectAndRadius(
          outerRect,
          Radius.circular(shape.faceCornerRadius + pathBorderSide),
        );
        final innerR = RRect.fromRectAndRadius(
          faceRect,
          Radius.circular(shape.faceCornerRadius),
        );
        canvas.drawDRRect(outerR, innerR, paint);
    }
  }

  void _drawFace(
    Canvas canvas, {
    required double cx,
    required double cy,
    required Color faceColor,
  }) {
    final faceHalf = faceSize / 2;
    final paint = Paint()..color = faceColor;

    switch (shape) {
      case PathButtonShape.circle:
        canvas.drawCircle(Offset(cx, cy), faceHalf, paint);
      case PathButtonShape.roundedSquare:
        final rect = Rect.fromCenter(
          center: Offset(cx, cy),
          width: faceSize,
          height: faceSize,
        );
        canvas.drawRRect(
          RRect.fromRectAndRadius(rect, Radius.circular(shape.faceCornerRadius)),
          paint,
        );
      case PathButtonShape.triangle:
        final path = buildTrianglePath(cx, cy, faceHalf, shape.faceCornerRadius);
        canvas.drawPath(path, paint);
    }
  }

  void _drawSegmentedRing(Canvas canvas, double cx, double cy) {
    final ringHalf = (faceSize / 2) + shape.ringGap + (AppStroke.ring / 2) + (pulseExpansion * pulseExpand);

    final ringPath = _shapePath(cx, cy, ringHalf);
    final metrics = ringPath.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;

    final totalLength = metric.length;
    final segCount = segments.length.clamp(1, 5);

    // Single segment = full continuous ring, no gap
    if (segCount == 1) {
      final segColor = state.resolveSegmentColor(segments[0].status, color);
      final paint = Paint()
        ..color = segColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppStroke.ring
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(ringPath, paint);
      return;
    }

    final gapLen = totalLength * kGapFraction;
    final usableLength = totalLength - gapLen * segCount;

    // Segment[0] (wellness at 12 o'clock) is 30% smaller than the others.
    final otherCount = segCount - 1;
    final base = usableLength / (otherCount + 0.7);
    final wellnessLen = base * 0.7;
    final otherLen = base;

    final topOffset = shape.startOffset(totalLength);
    final startBase = topOffset - wellnessLen / 2;

    var cursor = startBase;
    for (int i = 0; i < segCount; i++) {
      final thisLen = i == 0 ? wellnessLen : otherLen;

      final segColor = state.resolveSegmentColor(segments[i].status, color);

      final extractedPath = _extractPathWrapped(metric, totalLength, cursor, thisLen);
      final paint = Paint()
        ..color = segColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = AppStroke.ring
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(extractedPath, paint);

      cursor += thisLen + gapLen;
    }
  }

  Path _shapePath(double cx, double cy, double halfSize) {
    switch (shape) {
      case PathButtonShape.circle:
        return Path()
          ..addOval(Rect.fromCenter(
            center: Offset(cx, cy),
            width: halfSize * 2,
            height: halfSize * 2,
          ));

      case PathButtonShape.roundedSquare:
        final r = shape.ringCornerRadius.clamp(0.0, halfSize);
        final h = halfSize;
        final path = Path();
        path.moveTo(cx, cy - h);
        path.lineTo(cx + h - r, cy - h);
        path.arcToPoint(Offset(cx + h, cy - h + r), radius: Radius.circular(r));
        path.lineTo(cx + h, cy + h - r);
        path.arcToPoint(Offset(cx + h - r, cy + h), radius: Radius.circular(r));
        path.lineTo(cx - h + r, cy + h);
        path.arcToPoint(Offset(cx - h, cy + h - r), radius: Radius.circular(r));
        path.lineTo(cx - h, cy - h + r);
        path.arcToPoint(Offset(cx - h + r, cy - h), radius: Radius.circular(r));
        path.lineTo(cx, cy - h);
        path.close();
        return path;

      case PathButtonShape.triangle:
        return buildTrianglePath(cx, cy, halfSize, shape.ringCornerRadius);
    }
  }

  Path _extractPathWrapped(ui.PathMetric metric, double totalLength, double start, double length) {
    var s = start % totalLength;
    if (s < 0) s += totalLength;

    final end = s + length;

    if (end <= totalLength) {
      return metric.extractPath(s, end);
    }

    final path = Path();
    path.addPath(metric.extractPath(s, totalLength), Offset.zero);
    path.addPath(metric.extractPath(0, end - totalLength), Offset.zero);
    return path;
  }

  @override
  bool shouldRepaint(PathButtonRenderer old) =>
      shape != old.shape ||
      state != old.state ||
      color != old.color ||
      pulseExpansion != old.pulseExpansion ||
      pressed != old.pressed ||
      visualTop != old.visualTop ||
      visualBottom != old.visualBottom ||
      !listEquals(
        segments.map((s) => s.status).toList(),
        old.segments.map((s) => s.status).toList(),
      );
}
