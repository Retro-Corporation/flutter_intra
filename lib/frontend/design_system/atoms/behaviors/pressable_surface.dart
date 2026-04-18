import 'package:flutter/material.dart';
import '../../foundation/motion/curves.dart';
import '../../foundation/motion/durations.dart';
import '../../foundation/press/three_d_press_geometry.dart';
import 'three_d_press_painter.dart';

/// Controls which press geometry [PressableSurface] uses.
enum PressableStyle { outline }

/// Atom behavior: a pressable surface that renders the 3D press effect.
///
/// Owns its own press state — including an [AnimationController] that
/// animates between the unpressed and pressed [PressGeometry] using
/// [AppDurations.press] / [AppCurves.press]. Every visual value enters
/// through the constructor (DIP); callers pass [backgroundColor],
/// [borderColor], and [borderRadius] — this widget decides nothing about color.
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

class _PressableSurfaceState extends State<PressableSurface>
    with SingleTickerProviderStateMixin {
  late final AnimationController _pressController = AnimationController(
    vsync: this,
    duration: AppDurations.press,
  );
  late final CurvedAnimation _pressAnimation = CurvedAnimation(
    parent: _pressController,
    curve: AppCurves.press,
  );

  @override
  void dispose() {
    _pressAnimation.dispose();
    _pressController.dispose();
    super.dispose();
  }

  // Press feel: snap-in, fade-out. Tap-down jumps to pressed; release animates.
  void _onTapDown(TapDownDetails _) => _pressController.value = 1.0;

  void _onTapUp(TapUpDetails _) {
    _pressController.reverse();
    widget.onTap?.call();
  }

  void _onTapCancel() => _pressController.reverse();

  PressGeometry _geometryFor({required bool pressed}) {
    return switch (widget.style) {
      PressableStyle.outline => PressGeometry.outline(pressed: pressed),
    };
  }

  @override
  Widget build(BuildContext context) {
    final geoUnpressed = _geometryFor(pressed: false);
    final geoPressed = _geometryFor(pressed: true);
    final interactive = widget.isInteractive && widget.onTap != null;

    return GestureDetector(
      onTapDown: interactive ? _onTapDown : null,
      onTapUp: interactive ? _onTapUp : null,
      onTapCancel: interactive ? _onTapCancel : null,
      child: AnimatedBuilder(
        animation: _pressAnimation,
        child: widget.child,
        builder: (context, child) {
          final geo = PressGeometry.lerp(
            geoUnpressed,
            geoPressed,
            _pressAnimation.value,
          );
          return CustomPaint(
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
                bottom:
                    (geo.reservedVertical - geo.visualTop - geo.faceOffset)
                        .clamp(0.0, double.infinity),
              ),
              child: child,
            ),
          );
        },
      ),
    );
  }
}
