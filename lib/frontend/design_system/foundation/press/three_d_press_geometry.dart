import '../space/stroke.dart';

/// 3D press geometry tokens.
///
/// Single source of truth for the border insets, face offsets, and layout
/// constants that create the 3D press effect across button, checkbox, and radio.
///
/// [reservedVertical] is the total constant vertical padding this geometry
/// reserves (top + bottom), regardless of press state. [PressableSurface] uses
/// this to derive a constant bottom padding, preventing layout shift when the
/// press state changes — the same technique buttons and checkboxes use via
/// fixed-size [ConstrainedBox] / [SizedBox].
class PressGeometry {
  final double visualTop;
  final double visualBottom;
  final double visualSide;
  final double faceOffset;
  final double layoutSide;
  final bool showBorder;

  /// Total vertical space reserved by this geometry (top + bottom padding
  /// combined). Must be constant across pressed/unpressed states for the
  /// same geometry type to prevent layout shift.
  final double reservedVertical;

  const PressGeometry({
    required this.visualTop,
    required this.visualBottom,
    required this.visualSide,
    required this.faceOffset,
    required this.layoutSide,
    required this.showBorder,
    required this.reservedVertical,
  });

  /// Depth reserved for the 3D effect (bottom border when unpressed).
  static const double depth = AppStroke.xl;

  /// Filled style: border ring visible when unpressed, hidden when pressed.
  /// Face sits flush at top when unpressed, drops to bottom on press.
  ///
  /// reservedVertical = depth (constant: depth moves between top and bottom).
  factory PressGeometry.filled({required bool pressed}) {
    return PressGeometry(
      layoutSide: AppStroke.md,
      visualTop: pressed ? depth : 0.0,
      visualBottom: pressed ? 0.0 : depth,
      visualSide: AppStroke.md,
      faceOffset: 0.0,
      showBorder: !pressed,
      reservedVertical: depth,
    );
  }

  /// Outline style: border ring always visible.
  /// Face drops down on press via faceOffset.
  ///
  /// reservedVertical = depth + xs (1px top border always present + depth).
  factory PressGeometry.outline({required bool pressed}) {
    return PressGeometry(
      layoutSide: AppStroke.md,
      visualTop: AppStroke.xs,
      visualBottom: pressed ? AppStroke.xs : depth,
      visualSide: pressed ? AppStroke.xs : AppStroke.md,
      faceOffset: pressed ? AppStroke.lg : 0.0,
      showBorder: true,
      reservedVertical: depth + AppStroke.xs,
    );
  }

  /// Ghost style: no border, no 3D effect.
  factory PressGeometry.ghost() {
    return const PressGeometry(
      layoutSide: 0.0,
      visualTop: 0.0,
      visualBottom: 0.0,
      visualSide: 0.0,
      faceOffset: 0.0,
      showBorder: false,
      reservedVertical: 0.0,
    );
  }

  /// Static style: fixed 3D border ring, no press interaction.
  /// Used by components with a 3D look that don't respond to press
  /// (e.g. toggle thumb).
  factory PressGeometry.static({
    required double top,
    required double side,
    required double bottom,
  }) {
    return PressGeometry(
      visualTop: top,
      visualBottom: bottom,
      visualSide: side,
      faceOffset: 0.0,
      layoutSide: side,
      showBorder: true,
      reservedVertical: top + bottom,
    );
  }
}
