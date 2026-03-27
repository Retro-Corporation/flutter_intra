/// 3D press geometry tokens.
///
/// Single source of truth for the border insets, face offsets, and layout
/// constants that create the 3D press effect across button, checkbox, and radio.
class PressGeometry {
  final double visualTop;
  final double visualBottom;
  final double visualSide;
  final double faceOffset;
  final double layoutSide;
  final bool showBorder;

  const PressGeometry._({
    required this.visualTop,
    required this.visualBottom,
    required this.visualSide,
    required this.faceOffset,
    required this.layoutSide,
    required this.showBorder,
  });

  /// Depth reserved for the 3D effect (bottom border when unpressed).
  static const double depth = 4.0;

  /// Filled style: border ring visible when unpressed, hidden when pressed.
  /// Face sits flush at top when unpressed, drops to bottom on press.
  factory PressGeometry.filled({required bool pressed}) {
    return PressGeometry._(
      layoutSide: 2.0,
      visualTop: pressed ? depth : 0.0,
      visualBottom: pressed ? 0.0 : depth,
      visualSide: 2.0,
      faceOffset: 0.0,
      showBorder: !pressed,
    );
  }

  /// Outline style: border ring always visible.
  /// Face drops down on press via faceOffset.
  factory PressGeometry.outline({required bool pressed}) {
    return PressGeometry._(
      layoutSide: 2.0,
      visualTop: 1.0,
      visualBottom: pressed ? 1.0 : depth,
      visualSide: pressed ? 1.0 : 2.0,
      faceOffset: pressed ? 3.0 : 0.0,
      showBorder: true,
    );
  }

  /// Ghost style: no border, no 3D effect.
  factory PressGeometry.ghost() {
    return const PressGeometry._(
      layoutSide: 0.0,
      visualTop: 0.0,
      visualBottom: 0.0,
      visualSide: 0.0,
      faceOffset: 0.0,
      showBorder: false,
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
    return PressGeometry._(
      visualTop: top,
      visualBottom: bottom,
      visualSide: side,
      faceOffset: 0.0,
      layoutSide: side,
      showBorder: true,
    );
  }
}
