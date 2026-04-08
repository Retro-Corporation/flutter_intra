import 'dart:math' as math;
import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/color/color_utils.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/space/stroke.dart';

// ── Enums ──

enum PathButtonShape {
  circle,
  triangle,
  roundedSquare;

  /// Face diameter for this shape.
  double get faceSize => switch (this) {
    circle        => AppGrid.grid60,
    triangle      => AppGrid.grid92,
    roundedSquare => AppGrid.grid60,
  };

  /// Outer size = face + (ringGap + ringStroke) on each side.
  double get outerSize => faceSize + (ringGap + AppStroke.ring) * 2;

  /// Gap between ring inner edge and face outer edge.
  double get ringGap => switch (this) {
    triangle => AppGrid.grid8 / math.cos(math.pi / 6) + AppGrid.grid4,
    _        => AppGrid.grid8,
  };

  /// Face corner radius.
  double get faceCornerRadius => switch (this) {
    circle        => AppRadius.none,
    triangle      => AppRadius.md,
    roundedSquare => AppRadius.md,
  };

  /// Ring corner radius.
  double get ringCornerRadius => switch (this) {
    circle        => AppRadius.none,
    triangle      => AppRadius.lg,
    roundedSquare => AppRadius.lg,
  };

  /// Max pulse expansion in pixels during breathing animation.
  double get pulseExpand => switch (this) {
    triangle => AppGrid.grid8,
    _        => AppGrid.grid4,
  };

  /// Ring start offset for segment placement.
  double startOffset(double totalLength) => switch (this) {
    circle => totalLength * 0.75,
    _      => 0.0,
  };
}

enum PathButtonState {
  active,
  completed,
  locked;

  /// Whether this state allows tap interaction.
  bool get isInteractive => this != locked;

  /// Whether this state shows the breathing pulse.
  bool get isPulsing => this == active;

  /// Resolve the 3D shadow color for this state.
  Color shadowColor(Color accent) => switch (this) {
    locked => resolve900(accent),
    _      => resolve700(accent),
  };

  /// Resolve the main face color for this state.
  Color faceColor(Color accent) => switch (this) {
    locked => AppColors.background,
    _      => accent,
  };

  /// Resolve a ring segment's color, with locked override.
  Color resolveSegmentColor(SegmentStatus status, Color accent) => switch (this) {
    locked => AppColors.grey850,
    _      => status.color(accent),
  };
}

enum SegmentStatus {
  completed,
  current,
  upcoming;

  /// Resolve color for this segment status.
  Color color(Color accentColor) => switch (this) {
    completed => accentColor,
    current   => AppColors.textPrimary,
    upcoming  => AppColors.grey700,
  };
}

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

// ── Path-button-specific geometry ──

/// Gap between ring segments as a fraction of total perimeter.
const double kGapFraction = 0.06;

/// 3D border: top inset (flush).
final double pathBorderTop = AppGrid.grid0;

/// 3D border: side inset.
final double pathBorderSide = AppStroke.md;

/// 3D border: bottom inset (creates 3D depth).
final double pathBorderBottom = AppStroke.xxl;

// ── Triangle path builder ──

/// Builds a rounded equilateral triangle path starting at 12 o'clock.
Path buildTrianglePath(double cx, double cy, double halfSize, double cornerRadius) {
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
