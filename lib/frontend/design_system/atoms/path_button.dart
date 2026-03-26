import 'dart:math' as math;
import 'dart:ui' as ui;
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import '../design_system.dart';
import 'color_utils.dart';

// ── Enums ──

enum PathButtonShape { circle, triangle, roundedSquare }

enum PathButtonState { active, completed, locked }

enum SegmentStatus { completed, current, upcoming }

// ── Segment model ──

class PathButtonSegment {
  /// Visual state: completed (orange), current (white), upcoming (grey).
  final SegmentStatus status;

  /// Event type identifier (flexible string, TBD).
  final String? eventType;

  const PathButtonSegment({
    required this.status,
    this.eventType,
  });
}

// ── Constants ──

const double _kRingStroke = 6.0; // Ring segment stroke width
const double _kRingGap = 8.0; // Gap between ring and face
const double _kGapFraction = 0.06; // Gap between segments as fraction of perimeter
const double _kIconSize = 24.0; // IconSizes.lg
// Max ring expansion in pixels during pulse (per-shape)
double _pulseExpandFor(PathButtonShape shape) {
  switch (shape) {
    case PathButtonShape.circle:
    case PathButtonShape.roundedSquare:
      return 4.0; // Subtle breathing
    case PathButtonShape.triangle:
      return 8.0; // Larger shape needs more expansion
  }
}

/// Breathing-style pulse: expand → hold → contract → hold.
/// Maps controller 0→1 to a full breath cycle.
final TweenSequence<double> _kBreathSequence = TweenSequence<double>([
  TweenSequenceItem(
    tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
    weight: 40, // inhale
  ),
  TweenSequenceItem(
    tween: ConstantTween(1.0),
    weight: 10, // hold open
  ),
  TweenSequenceItem(
    tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
    weight: 40, // exhale
  ),
  TweenSequenceItem(
    tween: ConstantTween(0.0),
    weight: 10, // hold closed
  ),
]);

// Triangle corner radii (face vs ring)
const double _kTriangleFaceRadius = 8.0;
const double _kTriangleRingRadius = 16.0;

// Square corner radius (face vs ring — ring is proportionally larger)
const double _kSquareCornerRadius = 12.0;
const double _kSquareRingRadius = 23.0; // 12 + 8 + 3 (face + gap + halfStroke)

// 3D border geometry
const double _kBorderTop = 0.0;
const double _kBorderSide = 2.0;
const double _kBorderBottom = 5.0;

// ── Per-shape face sizes (source of truth) ──

double _faceSizeFor(PathButtonShape shape) {
  switch (shape) {
    case PathButtonShape.circle:
      return 60.0;
    case PathButtonShape.triangle:
      return 90.0;
    case PathButtonShape.roundedSquare:
      return 60.0;
  }
}

double _outerSizeFor(PathButtonShape shape) {
  return _faceSizeFor(shape) + (_kRingGap + _kRingStroke) * 2;
}


Color _segmentColor(SegmentStatus status, Color accentColor) {
  switch (status) {
    case SegmentStatus.completed:
      return accentColor;
    case SegmentStatus.current:
      return AppColors.textPrimary;
    case SegmentStatus.upcoming:
      return AppColors.grey700;
  }
}

// ── AppPathButton ──

class AppPathButton extends StatefulWidget {
  /// Shape variant for visual variety.
  final PathButtonShape shape;

  /// Current state: active (pulsing), completed (static), locked (disabled).
  final PathButtonState state;

  /// Icon asset path from [AppIcons]. Represents day type.
  final String icon;

  /// Ring segments. segments[0] = wellness, rendered at 12 o'clock.
  /// Length = number of events (1-5).
  final List<PathButtonSegment> segments;

  /// Called when tapped. Only fires for active and completed states.
  final VoidCallback? onPressed;

  /// Accent color for face and filled segments. Defaults to [AppColors.brand].
  final Color color;

  const AppPathButton({
    super.key,
    required this.shape,
    required this.state,
    required this.icon,
    required this.segments,
    this.onPressed,
    this.color = AppColors.brand,
  });

  @override
  State<AppPathButton> createState() => _AppPathButtonState();
}

class _AppPathButtonState extends State<AppPathButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _breathAnimation;
  bool _pressed = false;
  bool _pulseStopped = false;

  bool get _interactive =>
      widget.state == PathButtonState.active ||
      widget.state == PathButtonState.completed;

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 2000), // Full breath cycle
    );
    _breathAnimation = _pulseController.drive(_kBreathSequence);
    if (widget.state == PathButtonState.active) {
      _pulseController.repeat(); // No reverse — sequence handles both directions
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AppPathButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      _pulseStopped = false;
      if (widget.state == PathButtonState.active) {
        _pulseController.repeat();
      } else {
        _pulseController.stop();
        _pulseController.value = 0.0;
      }
    }
  }

  void _onTapDown(TapDownDetails _) {
    setState(() => _pressed = true);
  }

  void _onTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
    if (widget.state == PathButtonState.active && !_pulseStopped) {
      _pulseStopped = true;
      _pulseController.animateTo(
        0.0,
        duration: const Duration(milliseconds: 300),
        curve: Curves.easeOut,
      );
    }
    widget.onPressed?.call();
  }

  void _onTapCancel() {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final outerSize = _outerSizeFor(widget.shape);
    final faceSize = _faceSizeFor(widget.shape);

    // ALL states get 3D borders — only press interaction differs
    final double visualTop;
    final double visualBottom;
    if (_pressed) {
      visualTop = _kBorderBottom;
      visualBottom = 0.0;
    } else {
      visualTop = _kBorderTop;
      visualBottom = _kBorderBottom;
    }

    final totalHeight = outerSize + _kBorderBottom;

    return Semantics(
      button: true,
      enabled: _interactive,
      child: GestureDetector(
        onTapDown: _interactive ? _onTapDown : null,
        onTapUp: _interactive ? _onTapUp : null,
        onTapCancel: _interactive ? _onTapCancel : null,
        child: AnimatedBuilder(
          animation: _breathAnimation,
          builder: (context, child) {
            final pulseExpand = _pulseExpandFor(widget.shape);
            return CustomPaint(
              painter: _PathButtonPainter(
                shape: widget.shape,
                state: widget.state,
                segments: widget.segments,
                color: widget.color,
                faceSize: faceSize,
                outerSize: outerSize,
                pulseExpansion: _breathAnimation.value,
                pulseExpand: pulseExpand,
                pressed: _pressed,
                visualTop: visualTop,
                visualBottom: visualBottom,
              ),
              child: SizedBox(
                width: outerSize + (pulseExpand * 2),
                height: totalHeight + (pulseExpand * 2),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: pulseExpand,
                    right: pulseExpand,
                    top: pulseExpand + visualTop,
                    bottom: pulseExpand + visualBottom,
                  ),
                  child: Center(
                    child: AppIcon(
                      widget.icon,
                      size: _kIconSize,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}

// ── Custom painter ──

class _PathButtonPainter extends CustomPainter {
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

  _PathButtonPainter({
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
    final ringCenterY = pressed ? centerY : centerY + _kBorderBottom / 2;
    _drawSegmentedRing(canvas, cx, ringCenterY);
  }

  /// Draws the 3D border behind the face. All shapes use sides=2, top=0, bottom=5.
  /// Each shape uses an even-odd fill or drawDRRect to punch out the face area,
  /// so the border and face look like one connected piece.
  void _drawShadow(Canvas canvas, double cx, double restCenterY, double faceHalf, Color shadowColor) {
    final paint = Paint()..color = shadowColor;
    // Shadow shift/expand: expand by _kBorderSide outward, shift down so
    // top border = 0 and bottom border = _kBorderBottom.
    final shadowShift = _kBorderBottom - _kBorderSide; // 3px down
    final shadowExpand = _kBorderSide; // 2px outward on each side

    switch (shape) {
      case PathButtonShape.circle:
        // Outer circle: enlarged + shifted down. Inner hole: matches face exactly.
        // Even-odd fill creates the border ring (sides≈2, top≈0, bottom=5).
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
        // Triangle edges are angled at 30° from vertical, so the perpendicular
        // border width differs from the radial expansion. Solving:
        //   side = expand * √3/2 − shift/2 = _kBorderSide (2px)
        //   bottom = expand * √3/2 + shift  = _kBorderBottom (5px)
        // Gives: shift = 2, expand = 2√3 ≈ 3.46
        final triShift = 2 * (_kBorderBottom - _kBorderSide) / 3;
        final triExpand = 2 * (_kBorderSide + triShift / 2) / math.sqrt(3);
        // Outer triangle: enlarged + shifted. Inner hole: matches face.
        final outerPath = _buildTrianglePath(
          cx, restCenterY + triShift,
          faceHalf + triExpand,
          _kTriangleFaceRadius,
        );
        final innerPath = _buildTrianglePath(
          cx, restCenterY,
          faceHalf,
          _kTriangleFaceRadius,
        );
        final borderPath = Path()
          ..addPath(outerPath, Offset.zero)
          ..addPath(innerPath, Offset.zero);
        borderPath.fillType = PathFillType.evenOdd;
        canvas.drawPath(borderPath, paint);

      case PathButtonShape.roundedSquare:
        // drawDRRect: outer expanded by (sides=2, top=0, bottom=5), inner = face.
        // Face radius is the design radius; outer radius is larger by border width.
        final faceRect = Rect.fromCenter(
          center: Offset(cx, restCenterY),
          width: faceSize,
          height: faceSize,
        );
        final outerRect = Rect.fromLTRB(
          faceRect.left - _kBorderSide,
          faceRect.top - _kBorderTop,
          faceRect.right + _kBorderSide,
          faceRect.bottom + _kBorderBottom,
        );
        final outerR = RRect.fromRectAndRadius(
          outerRect,
          Radius.circular(_kSquareCornerRadius + _kBorderSide),
        );
        final innerR = RRect.fromRectAndRadius(
          faceRect,
          const Radius.circular(_kSquareCornerRadius),
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
          RRect.fromRectAndRadius(rect, const Radius.circular(_kSquareCornerRadius)),
          paint,
        );
      case PathButtonShape.triangle:
        final path = _buildTrianglePath(cx, cy, faceHalf, _kTriangleFaceRadius);
        canvas.drawPath(path, paint);
    }
  }

  void _drawSegmentedRing(Canvas canvas, double cx, double cy) {
    // For circles and squares, the perpendicular gap between face edge and ring
    // inner edge equals _kRingGap directly. For triangles, the perpendicular
    // distance between parallel edges is scaled by cos(30°), so we compensate
    // to keep the visual gap consistent across all shapes.
    final effectiveGap = shape == PathButtonShape.triangle
        ? _kRingGap / math.cos(math.pi / 6) + 4.0 // geometry correction + 4px extra breathing room
        : _kRingGap;

    // Ring half-size: from face edge + gap, at the center of the ring stroke
    final ringHalf = (faceSize / 2) + effectiveGap + (_kRingStroke / 2) + (pulseExpansion * pulseExpand);

    // Generate the ring outline path — use shape-specific corner radii
    final ringCornerRadius = shape == PathButtonShape.triangle
        ? _kTriangleRingRadius
        : _kSquareRingRadius;
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
          : _segmentColor(segments[0].status, color);
      final paint = Paint()
        ..color = segColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _kRingStroke
        ..strokeCap = StrokeCap.round;
      canvas.drawPath(ringPath, paint);
      return;
    }

    final gapLen = totalLength * _kGapFraction;
    final usableLength = totalLength - gapLen * segCount;

    // Segment[0] (wellness at 12 o'clock) is 30% smaller than the others.
    // If N segments: wellness = base * 0.7, others = base.
    // Total: 0.7*base + (N-1)*base = usableLength → base = usableLength / (N - 0.3)
    final otherCount = segCount - 1;
    final base = usableLength / (otherCount + 0.7);
    final wellnessLen = base * 0.7;
    final otherLen = base;

    // Start offset: center segments[0] (wellness) at 12 o'clock
    final topOffset = _startOffset(totalLength);
    final startBase = topOffset - wellnessLen / 2;

    var cursor = startBase;
    for (int i = 0; i < segCount; i++) {
      final thisLen = i == 0 ? wellnessLen : otherLen;

      final segColor = state == PathButtonState.locked
          ? AppColors.grey850
          : _segmentColor(segments[i].status, color);

      final extractedPath = _extractPathWrapped(metric, totalLength, cursor, thisLen);
      final paint = Paint()
        ..color = segColor
        ..style = PaintingStyle.stroke
        ..strokeWidth = _kRingStroke
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
        // Manually build path starting at CENTER of top edge (12 o'clock)
        // This makes _startOffset return 0.0 — no ambiguity about addRRect start.
        final r = cornerRadius.clamp(0.0, halfSize);
        final h = halfSize;
        final path = Path();
        // Start at center of top edge
        path.moveTo(cx, cy - h);
        // → to top-right corner start
        path.lineTo(cx + h - r, cy - h);
        // Top-right arc
        path.arcToPoint(Offset(cx + h, cy - h + r), radius: Radius.circular(r));
        // ↓ right edge to bottom-right corner
        path.lineTo(cx + h, cy + h - r);
        // Bottom-right arc
        path.arcToPoint(Offset(cx + h - r, cy + h), radius: Radius.circular(r));
        // ← bottom edge to bottom-left corner
        path.lineTo(cx - h + r, cy + h);
        // Bottom-left arc
        path.arcToPoint(Offset(cx - h, cy + h - r), radius: Radius.circular(r));
        // ↑ left edge to top-left corner
        path.lineTo(cx - h, cy - h + r);
        // Top-left arc
        path.arcToPoint(Offset(cx - h + r, cy - h), radius: Radius.circular(r));
        // → back to center of top edge
        path.lineTo(cx, cy - h);
        path.close();
        return path;

      case PathButtonShape.triangle:
        return _buildTrianglePath(cx, cy, halfSize, cornerRadius);
    }
  }

  /// Computes the path-distance offset so segments[0] centers at 12 o'clock.
  /// Triangle and square paths are built starting at 12 o'clock, so offset = 0.
  /// Circle uses addOval which starts at 3 o'clock, so offset = 3/4.
  double _startOffset(double totalLength) {
    switch (shape) {
      case PathButtonShape.circle:
        return totalLength * 0.75;
      case PathButtonShape.roundedSquare:
      case PathButtonShape.triangle:
        // Both paths are manually built starting at 12 o'clock.
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

  static Path _buildTrianglePath(double cx, double cy, double halfSize, double cornerRadius) {
    // Vertices of equilateral triangle centered at (cx, cy)
    final topX = cx;
    final topY = cy - halfSize;
    final blX = cx - halfSize * math.cos(math.pi / 6);
    final blY = cy + halfSize * math.sin(math.pi / 6);
    final brX = cx + halfSize * math.cos(math.pi / 6);
    final brY = cy + halfSize * math.sin(math.pi / 6);

    // Compute tangent points for each corner.
    // For a corner at (cX,cY) with edges arriving from (fromX,fromY) and
    // leaving toward (toX,toY), the tangent points are at distance
    // cornerRadius along each edge from the vertex.
    List<double> tangents(double fromX, double fromY, double cX, double cY, double toX, double toY) {
      final dx1 = fromX - cX, dy1 = fromY - cY;
      final dx2 = toX - cX, dy2 = toY - cY;
      final len1 = math.sqrt(dx1 * dx1 + dy1 * dy1);
      final len2 = math.sqrt(dx2 * dx2 + dy2 * dy2);
      final t = cornerRadius / math.min(len1, len2);
      return [
        cX + dx1 * t, cY + dy1 * t, // start tangent (from-side)
        cX, cY, // control point (vertex)
        cX + dx2 * t, cY + dy2 * t, // end tangent (to-side)
      ];
    }

    // Top corner: from BL → top → BR
    final top = tangents(blX, blY, topX, topY, brX, brY);
    // Bottom-right corner: from top → BR → BL
    final br = tangents(topX, topY, brX, brY, blX, blY);
    // Bottom-left corner: from BR → BL → top
    final bl = tangents(brX, brY, blX, blY, topX, topY);

    // Split the top corner's quadratic bezier at t=0.5 to find 12 o'clock.
    // P0 = left tangent, P1 = top vertex (control), P2 = right tangent.
    // Midpoint M = 0.25*P0 + 0.5*P1 + 0.25*P2
    final midX = 0.25 * top[0] + 0.5 * top[2] + 0.25 * top[4];
    final midY = 0.25 * top[1] + 0.5 * top[3] + 0.25 * top[5];

    // Split bezier control points:
    // Second half (M → right tangent): control = (P1 + P2) / 2
    final ctrl2X = (top[2] + top[4]) / 2;
    final ctrl2Y = (top[3] + top[5]) / 2;
    // First half (left tangent → M): control = (P0 + P1) / 2
    final ctrl1X = (top[0] + top[2]) / 2;
    final ctrl1Y = (top[1] + top[3]) / 2;

    // Build path starting at 12 o'clock — eliminates jitter from sampling.
    final path = Path();
    path.moveTo(midX, midY);

    // Second half of top corner → right tangent
    path.quadraticBezierTo(ctrl2X, ctrl2Y, top[4], top[5]);

    // Right edge → bottom-right corner
    path.lineTo(br[0], br[1]);
    path.quadraticBezierTo(br[2], br[3], br[4], br[5]);

    // Bottom edge → bottom-left corner
    path.lineTo(bl[0], bl[1]);
    path.quadraticBezierTo(bl[2], bl[3], bl[4], bl[5]);

    // Left edge → first half of top corner → back to 12 o'clock
    path.lineTo(top[0], top[1]);
    path.quadraticBezierTo(ctrl1X, ctrl1Y, midX, midY);

    path.close();
    return path;
  }

  @override
  bool shouldRepaint(_PathButtonPainter old) =>
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
