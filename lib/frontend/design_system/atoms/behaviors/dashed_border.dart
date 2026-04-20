import 'package:flutter/widgets.dart';

/// Internal painter. Walks a rounded-rect path and draws dashes.
class _DashedBorderPainter extends CustomPainter {
  final Color color;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;
  final double borderRadius;

  const _DashedBorderPainter({
    required this.color,
    required this.strokeWidth,
    required this.dashLength,
    required this.gapLength,
    required this.borderRadius,
  });

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = color
      ..strokeWidth = strokeWidth
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round;

    final rect = Rect.fromLTWH(
      strokeWidth / 2,
      strokeWidth / 2,
      size.width - strokeWidth,
      size.height - strokeWidth,
    );
    final rrect = RRect.fromRectAndRadius(rect, Radius.circular(borderRadius));

    // Build a path that follows the rounded rect perimeter
    final path = Path()..addRRect(rrect);
    final metrics = path.computeMetrics();

    for (final metric in metrics) {
      double distance = 0.0;
      bool drawing = true;
      while (distance < metric.length) {
        final remaining = metric.length - distance;
        final segmentLength = drawing
            ? (dashLength < remaining ? dashLength : remaining)
            : (gapLength < remaining ? gapLength : remaining);
        if (drawing) {
          canvas.drawPath(
            metric.extractPath(distance, distance + segmentLength),
            paint,
          );
        }
        distance += segmentLength;
        drawing = !drawing;
      }
    }
  }

  @override
  bool shouldRepaint(_DashedBorderPainter old) =>
      color != old.color ||
      strokeWidth != old.strokeWidth ||
      dashLength != old.dashLength ||
      gapLength != old.gapLength ||
      borderRadius != old.borderRadius;
}

/// Atom behavior: wraps [child] with a dashed rounded border.
///
/// Used by [EmptyExerciseList] and any other widget needing a dashed border.
/// All visual values enter through the constructor (DIP).
/// Lives in [atoms/behaviors/] — shared rendering infrastructure,
/// not a standalone atom.
class DashedBorderContainer extends StatelessWidget {
  final Widget child;
  final Color borderColor;
  final double borderRadius;
  final double strokeWidth;
  final double dashLength;
  final double gapLength;

  const DashedBorderContainer({
    super.key,
    required this.child,
    required this.borderColor,
    required this.borderRadius,
    this.strokeWidth = 1.0,
    this.dashLength = 6.0,
    this.gapLength = 4.0,
  });

  @override
  Widget build(BuildContext context) {
    return CustomPaint(
      painter: _DashedBorderPainter(
        color: borderColor,
        strokeWidth: strokeWidth,
        dashLength: dashLength,
        gapLength: gapLength,
        borderRadius: borderRadius,
      ),
      child: child,
    );
  }
}
