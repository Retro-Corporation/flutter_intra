import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../foundation/space/stroke.dart';
import 'path_button_geometry.dart';

// ── Shape draw delegates ──

/// Drawing strategy for a PathButtonShape.
/// Each subclass encapsulates the shadow, face, and ring-path
/// logic for one shape — keeping the renderer shape-agnostic.
sealed class ShapeDrawDelegate {
  const ShapeDrawDelegate();

  /// Draw the 3D border behind the face.
  void drawShadow(Canvas canvas, PathButtonShape shape,
      double cx, double cy, double faceHalf, Paint paint);

  /// Draw the main face.
  void drawFace(Canvas canvas, PathButtonShape shape,
      double cx, double cy, double faceSize, Paint paint);

  /// Build the closed ring path at the given half-size.
  Path buildRingPath(PathButtonShape shape,
      double cx, double cy, double halfSize);
}

final class _CircleDrawDelegate extends ShapeDrawDelegate {
  const _CircleDrawDelegate();

  @override
  void drawShadow(Canvas canvas, PathButtonShape shape,
      double cx, double cy, double faceHalf, Paint paint) {
    final shadowShift = pathBorderBottom - pathBorderSide;
    final shadowExpand = pathBorderSide;
    final borderPath = Path()
      ..addOval(Rect.fromCircle(
        center: Offset(cx, cy + shadowShift),
        radius: faceHalf + shadowExpand,
      ))
      ..addOval(Rect.fromCircle(
        center: Offset(cx, cy),
        radius: faceHalf,
      ));
    borderPath.fillType = PathFillType.evenOdd;
    canvas.drawPath(borderPath, paint);
  }

  @override
  void drawFace(Canvas canvas, PathButtonShape shape,
      double cx, double cy, double faceSize, Paint paint) {
    canvas.drawCircle(Offset(cx, cy), faceSize / 2, paint);
  }

  @override
  Path buildRingPath(PathButtonShape shape,
      double cx, double cy, double halfSize) {
    return Path()
      ..addOval(Rect.fromCenter(
        center: Offset(cx, cy),
        width: halfSize * 2,
        height: halfSize * 2,
      ));
  }
}

final class _TriangleDrawDelegate extends ShapeDrawDelegate {
  const _TriangleDrawDelegate();

  @override
  void drawShadow(Canvas canvas, PathButtonShape shape,
      double cx, double cy, double faceHalf, Paint paint) {
    final triShift = 2 * (pathBorderBottom - pathBorderSide) / 3;
    final triExpand = 2 * (pathBorderSide + triShift / 2) / math.sqrt(3);
    final outerPath = buildTrianglePath(
      cx, cy + triShift,
      faceHalf + triExpand,
      shape.faceCornerRadius,
    );
    final innerPath = buildTrianglePath(
      cx, cy,
      faceHalf,
      shape.faceCornerRadius,
    );
    final borderPath = Path()
      ..addPath(outerPath, Offset.zero)
      ..addPath(innerPath, Offset.zero);
    borderPath.fillType = PathFillType.evenOdd;
    canvas.drawPath(borderPath, paint);
  }

  @override
  void drawFace(Canvas canvas, PathButtonShape shape,
      double cx, double cy, double faceSize, Paint paint) {
    final path = buildTrianglePath(cx, cy, faceSize / 2, shape.faceCornerRadius);
    canvas.drawPath(path, paint);
  }

  @override
  Path buildRingPath(PathButtonShape shape,
      double cx, double cy, double halfSize) {
    return buildTrianglePath(cx, cy, halfSize, shape.ringCornerRadius);
  }
}

final class _RoundedSquareDrawDelegate extends ShapeDrawDelegate {
  const _RoundedSquareDrawDelegate();

  @override
  void drawShadow(Canvas canvas, PathButtonShape shape,
      double cx, double cy, double faceHalf, Paint paint) {
    final faceSize = shape.faceSize;
    final faceRect = Rect.fromCenter(
      center: Offset(cx, cy),
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

  @override
  void drawFace(Canvas canvas, PathButtonShape shape,
      double cx, double cy, double faceSize, Paint paint) {
    final rect = Rect.fromCenter(
      center: Offset(cx, cy),
      width: faceSize,
      height: faceSize,
    );
    canvas.drawRRect(
      RRect.fromRectAndRadius(rect, Radius.circular(shape.faceCornerRadius)),
      paint,
    );
  }

  @override
  Path buildRingPath(PathButtonShape shape,
      double cx, double cy, double halfSize) {
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
  }
}

// ── Enum → delegate wiring (single exhaustive switch) ──

extension on PathButtonShape {
  ShapeDrawDelegate get drawDelegate => switch (this) {
    PathButtonShape.circle        => const _CircleDrawDelegate(),
    PathButtonShape.triangle      => const _TriangleDrawDelegate(),
    PathButtonShape.roundedSquare => const _RoundedSquareDrawDelegate(),
  };
}

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
    final delegate = shape.drawDelegate;
    final cx = size.width / 2;
    // Rest center for both face and ring (before press offset)
    final restCenterY = pulseExpand + outerSize / 2;
    // Press-adjusted center — face AND ring move together
    final centerY = restCenterY + visualTop;

    final faceHalf = faceSize / 2;
    final shadowColor = state.shadowColor(color);

    // ── 1. Draw 3D shadow (behind main face) ──
    if (!pressed) {
      delegate.drawShadow(
        canvas, shape, cx, restCenterY, faceHalf,
        Paint()..color = shadowColor,
      );
    }

    // ── 2. Draw main face ──
    final mainFaceColor = state.faceColor(color);
    delegate.drawFace(
      canvas, shape, cx, centerY, faceSize,
      Paint()..color = mainFaceColor,
    );

    // ── 3. Draw segmented ring (moves with face) ──
    // When unpressed, the shadow inside the ring gap makes the face look
    // shifted up. Offset the ring down by half the border so it visually
    // centers on the face+shadow unit. When pressed (no shadow), ring and
    // face share the exact same center.
    final ringCenterY = pressed ? centerY : centerY + pathBorderBottom / 2;
    _drawSegmentedRing(canvas, cx, ringCenterY, delegate);
  }

  void _drawSegmentedRing(Canvas canvas, double cx, double cy, ShapeDrawDelegate delegate) {
    final ringHalf = (faceSize / 2) + shape.ringGap + (AppStroke.ring / 2) + (pulseExpansion * pulseExpand);

    final ringPath = delegate.buildRingPath(shape, cx, cy, ringHalf);
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
      _segmentStatusChanged(segments, old.segments);

  static bool _segmentStatusChanged(
    List<PathButtonSegment> a,
    List<PathButtonSegment> b,
  ) {
    if (identical(a, b)) return false;
    if (a.length != b.length) return true;
    for (int i = 0; i < a.length; i++) {
      if (a[i].status != b[i].status) return true;
    }
    return false;
  }
}
