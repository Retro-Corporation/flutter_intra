import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../foundation/colors.dart';
import '../foundation/color_utils.dart';
import '../foundation/stroke.dart';
import 'path_button_geometry.dart';

// ── PathButtonRenderer ──

class PathButtonRenderer extends CustomPainter {
  final PathButtonShape shape;
  final PathButtonState state;
  final List<PathButtonSegment> segments;
  final Color color;
  final double faceSize;
  final double outerSize;
  final double pulseExpansion;
  final double pulseExpand;
  final bool pressed;
  final double visualTop;
  final double visualBottom;

  PathButtonRenderer({
    required this.shape,
    required this.state,
    required this.segments,
    required this.color,
    required this.faceSize,
    required this.outerSize,
    required this.pulseExpansion,
    required this.pulseExpand,
    required this.pressed,
    required this.visualTop,
    required this.visualBottom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final cx = size.width / 2;
    // Rest center for both face and ring (before press offset)
    final restCenterY = pulseExpand + outerSize / 2;
    // Press-adjusted center — face AND ring move together
    final centerY = restCenterY + visualTop;

    final faceHalf = faceSize / 2;
    final shadowColor = state == PathButtonState.locked
        ? resolve900(color)
        : resolve700(color);

    // ── 1. Draw 3D shadow (behind main face) ──
    if (!pressed) {
      _drawShadow(canvas, cx, restCenterY, faceHalf, shadowColor);
    }

    // ── 2. Draw main face ──
    final mainFaceColor = state == PathButtonState.locked
        ? AppColors.background
        : color;
    _drawFace(canvas, cx: cx, cy: centerY, faceColor: mainFaceColor);

    // ── 3. Draw segmented ring (moves with face) ──
    // When unpressed, the shadow inside the ring gap makes the face look
    // shifted up. Offset the ring down by half the border so it visually
    // centers on the face+shadow unit. When pressed (no shadow), ring and
    // face share the exact same center.
    final ringCenterY = pressed ? centerY : centerY + kBorderBottom / 2;
    _drawSegmentedRing(canvas, cx, ringCenterY);
  }

  /// Draws the 3D border behind the face.
  void _drawShadow(Canvas canvas, double cx, double restCenterY, double faceHalf, Color shadowColor) {
    final paint = Paint()..color = shadowColor;
    final shadowShift = kBorderBottom - kBorderSide;
    final shadowExpand = kBorderSide;

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
        final triShift = 2 * (kBorderBottom - kBorderSide) / 3;
        final triExpand = 2 * (kBorderSide + triShift / 2) / math.sqrt(3);
        final outerPath = buildTrianglePath(
          cx, restCenterY + triShift,
          faceHalf + triExpand,
          kTriangleFaceRadius,
        );
        final innerPath = buildTrianglePath(
          cx, restCenterY,
          faceHalf,
          kTriangleFaceRadius,
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
          faceRect.left - kBorderSide,
          faceRect.top - kBorderTop,
          faceRect.right + kBorderSide,
          faceRect.bottom + kBorderBottom,
        );
        final outerR = RRect.fromRectAndRadius(
          outerRect,
          Radius.circular(kSquareCornerRadius + kBorderSide),
        );
        final innerR = RRect.fromRectAndRadius(
          faceRect,
          const Radius.circular(kSquareCornerRadius),
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
          RRect.fromRectAndRadius(rect, const Radius.circular(kSquareCornerRadius)),
          paint,
        );
      case PathButtonShape.triangle:
        final path = buildTrianglePath(cx, cy, faceHalf, kTriangleFaceRadius);
        canvas.drawPath(path, paint);
    }
  }

  void _drawSegmentedRing(Canvas canvas, double cx, double cy) {
    final effectiveGap = shape == PathButtonShape.triangle
        ? kRingGap / math.cos(math.pi / 6) + 4.0
        : kRingGap;

    final ringHalf = (faceSize / 2) + effectiveGap + (AppStroke.ring / 2) + (pulseExpansion * pulseExpand);

    final ringCornerRadius = shape == PathButtonShape.triangle
        ? kTriangleRingRadius
        : kSquareRingRadius;
    final ringPath = _shapePath(cx, cy, ringHalf, ringCornerRadius);
    final metrics = ringPath.computeMetrics().toList();
    if (metrics.isEmpty) return;
    final metric = metrics.first;

    final totalLength = metric.length;
    final segCount = segments.length.clamp(1, 5);

    // Single segment = full continuous ring, no gap
    if (segCount == 1) {
      final segColor = state == PathButtonState.locked
          ? AppColors.grey850
          : segmentColor(segments[0].status, color);
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

    final topOffset = _startOffset(totalLength);
    final startBase = topOffset - wellnessLen / 2;

    var cursor = startBase;
    for (int i = 0; i < segCount; i++) {
      final thisLen = i == 0 ? wellnessLen : otherLen;

      final segColor = state == PathButtonState.locked
          ? AppColors.grey850
          : segmentColor(segments[i].status, color);

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

  Path _shapePath(double cx, double cy, double halfSize, double cornerRadius) {
    switch (shape) {
      case PathButtonShape.circle:
        return Path()
          ..addOval(Rect.fromCenter(
            center: Offset(cx, cy),
            width: halfSize * 2,
            height: halfSize * 2,
          ));

      case PathButtonShape.roundedSquare:
        final r = cornerRadius.clamp(0.0, halfSize);
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
        return buildTrianglePath(cx, cy, halfSize, cornerRadius);
    }
  }

  double _startOffset(double totalLength) {
    switch (shape) {
      case PathButtonShape.circle:
        return totalLength * 0.75;
      case PathButtonShape.roundedSquare:
      case PathButtonShape.triangle:
        return 0.0;
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

  /// Builds a rounded equilateral triangle path starting at 12 o'clock.
  static Path buildTrianglePath(double cx, double cy, double halfSize, double cornerRadius) {
    final topX = cx;
    final topY = cy - halfSize;
    final blX = cx - halfSize * math.cos(math.pi / 6);
    final blY = cy + halfSize * math.sin(math.pi / 6);
    final brX = cx + halfSize * math.cos(math.pi / 6);
    final brY = cy + halfSize * math.sin(math.pi / 6);

    List<double> tangents(double fromX, double fromY, double cX, double cY, double toX, double toY) {
      final dx1 = fromX - cX, dy1 = fromY - cY;
      final dx2 = toX - cX, dy2 = toY - cY;
      final len1 = math.sqrt(dx1 * dx1 + dy1 * dy1);
      final len2 = math.sqrt(dx2 * dx2 + dy2 * dy2);
      final t = cornerRadius / math.min(len1, len2);
      return [
        cX + dx1 * t, cY + dy1 * t,
        cX, cY,
        cX + dx2 * t, cY + dy2 * t,
      ];
    }

    final top = tangents(blX, blY, topX, topY, brX, brY);
    final br = tangents(topX, topY, brX, brY, blX, blY);
    final bl = tangents(brX, brY, blX, blY, topX, topY);

    final midX = 0.25 * top[0] + 0.5 * top[2] + 0.25 * top[4];
    final midY = 0.25 * top[1] + 0.5 * top[3] + 0.25 * top[5];

    final ctrl2X = (top[2] + top[4]) / 2;
    final ctrl2Y = (top[3] + top[5]) / 2;
    final ctrl1X = (top[0] + top[2]) / 2;
    final ctrl1Y = (top[1] + top[3]) / 2;

    final path = Path();
    path.moveTo(midX, midY);

    path.quadraticBezierTo(ctrl2X, ctrl2Y, top[4], top[5]);

    path.lineTo(br[0], br[1]);
    path.quadraticBezierTo(br[2], br[3], br[4], br[5]);

    path.lineTo(bl[0], bl[1]);
    path.quadraticBezierTo(bl[2], bl[3], bl[4], bl[5]);

    path.lineTo(top[0], top[1]);
    path.quadraticBezierTo(ctrl1X, ctrl1Y, midX, midY);

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(PathButtonRenderer old) =>
      shape != old.shape ||
      state != old.state ||
      color != old.color ||
      faceSize != old.faceSize ||
      outerSize != old.outerSize ||
      pulseExpansion != old.pulseExpansion ||
      pulseExpand != old.pulseExpand ||
      pressed != old.pressed ||
      visualTop != old.visualTop ||
      visualBottom != old.visualBottom ||
      !listEquals(
        segments.map((s) => s.status).toList(),
        old.segments.map((s) => s.status).toList(),
      );
}
