import 'package:flutter/material.dart';
import '../../foundation/opacity.dart';
import 'three_d_press_painter.dart';

/// Atom behavior: the stateless scaffold for visual-only 3D surfaces.
///
/// Pairs with [ThreeDPressable]. Where [ThreeDPressable] wraps a
/// [GestureDetector] for tap-driven press state, [ThreeDSurface] omits the
/// gesture layer entirely — it renders the 3D look only.
///
/// Use [ThreeDSurface] when:
/// - The 3D effect is decorative (no tap response)
/// - Press state is driven by something other than taps on the surface
///   (e.g. drag via parent [GestureDetector], animation controller)
///
/// Callers own:
/// - Painter config (geometry via `PressGeometry.static` is typical)
/// - Any gesture handling at a parent layer
/// - Content sizing via [child]
class ThreeDSurface extends StatelessWidget {
  /// Caller-configured painter — every visual value flows through here.
  final ThreeDPressPainter painter;

  /// When true, wraps the painted content in a disabled-opacity [Opacity].
  final bool isDisabled;

  /// The content rendered on top of the painter (typically a sized layout).
  final Widget? child;

  const ThreeDSurface({
    super.key,
    required this.painter,
    this.isDisabled = false,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = CustomPaint(painter: painter, child: child);
    if (isDisabled) {
      result = Opacity(opacity: AppOpacity.disabled, child: result);
    }
    return result;
  }
}
