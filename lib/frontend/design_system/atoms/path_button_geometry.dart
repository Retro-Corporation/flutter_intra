import 'package:flutter/material.dart';
import '../foundation/colors.dart';

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

// ── Shape geometry constants ──

/// Ring segment stroke width.
const double kRingStroke = 6.0;

/// Gap between ring inner edge and face outer edge.
const double kRingGap = 8.0;

/// Gap between ring segments as a fraction of total perimeter.
const double kGapFraction = 0.06;

/// Triangle face corner radius.
const double kTriangleFaceRadius = 8.0;

/// Triangle ring corner radius.
const double kTriangleRingRadius = 16.0;

/// Rounded square face corner radius.
const double kSquareCornerRadius = 12.0;

/// Rounded square ring corner radius (face + gap + halfStroke).
const double kSquareRingRadius = 23.0;

// ── 3D border geometry ──

/// Border inset at the top edge (0 = flush).
const double kBorderTop = 0.0;

/// Border inset on left and right sides.
const double kBorderSide = 2.0;

/// Border inset at the bottom edge (creates the 3D depth).
const double kBorderBottom = 5.0;

// ── Per-shape face sizes ──

/// Returns the face diameter for a given shape.
double faceSizeFor(PathButtonShape shape) {
  switch (shape) {
    case PathButtonShape.circle:
      return 60.0;
    case PathButtonShape.triangle:
      return 90.0;
    case PathButtonShape.roundedSquare:
      return 60.0;
  }
}

/// Returns the total outer size (face + ring gap + ring stroke on each side).
double outerSizeFor(PathButtonShape shape) {
  return faceSizeFor(shape) + (kRingGap + kRingStroke) * 2;
}

// ── Segment color resolution ──

/// Returns the color for a ring segment based on its status.
Color segmentColor(SegmentStatus status, Color accentColor) {
  switch (status) {
    case SegmentStatus.completed:
      return accentColor;
    case SegmentStatus.current:
      return AppColors.textPrimary;
    case SegmentStatus.upcoming:
      return AppColors.grey700;
  }
}
