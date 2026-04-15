import 'package:flutter/material.dart';
import '../../foundation/press/three_d_press_geometry.dart';
import 'three_d_press_painter.dart';

/// Controls which press geometry [PressableSurface] uses.
enum PressableStyle { outline }

/// Atom behavior: a pressable surface that renders the 3D press effect.
///
/// Owns its own [bool _pressed] state — no mixin contract needed.
/// Every visual value enters through the constructor (DIP).
/// Callers pass [backgroundColor], [borderColor], and [borderRadius];
/// this widget decides nothing about color.
///
/// Lives in [atoms/behaviors/] alongside [ThreeDPressPainter] for the same
/// reason — it is shared widget infrastructure, not a sibling atom.
class PressableSurface extends StatefulWidget {
  final Widget child;
  final VoidCallback? onTap;
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final BorderRadius? borderRadiusGeometry;
  final bool isInteractive;
  final PressableStyle style;

  const PressableSurface({
    super.key,
    required this.child,
    required this.backgroundColor,
    required this.borderColor,
    required this.borderRadius,
    this.borderRadiusGeometry,
    this.onTap,
    this.isInteractive = true,
    this.style = PressableStyle.outline,
  });

  @override
  State<PressableSurface> createState() => _PressableSurfaceState();
}

class _PressableSurfaceState extends State<PressableSurface> {
  bool _pressed = false;

  void _onTapDown(TapDownDetails _) => setState(() => _pressed = true);

  void _onTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
    widget.onTap?.call();
  }

  void _onTapCancel() => setState(() => _pressed = false);

  @override
  Widget build(BuildContext context) {
    final geo = switch (widget.style) {
      PressableStyle.outline => PressGeometry.outline(pressed: _pressed),
    };
    final interactive = widget.isInteractive && widget.onTap != null;

    return GestureDetector(
      onTapDown: interactive ? _onTapDown : null,
      onTapUp: interactive ? _onTapUp : null,
      onTapCancel: interactive ? _onTapCancel : null,
      child: CustomPaint(
        painter: ThreeDPressPainter(
          backgroundColor: widget.backgroundColor,
          borderColor: widget.borderColor,
          borderRadius: widget.borderRadius,
          borderRadiusGeometry: widget.borderRadiusGeometry,
          borderTop: geo.visualTop,
          borderBottom: geo.visualBottom,
          borderSide: geo.visualSide,
          faceOffset: geo.faceOffset,
          faceSideInset: geo.layoutSide,
          showBorder: geo.showBorder,
        ),
        child: Padding(
          padding: EdgeInsets.only(
            left: geo.layoutSide,
            right: geo.layoutSide,
            top: geo.visualTop + geo.faceOffset,
            bottom: (geo.reservedVertical - geo.visualTop - geo.faceOffset)
                .clamp(0.0, double.infinity),
          ),
          child: widget.child,
        ),
      ),
    );
  }
}
