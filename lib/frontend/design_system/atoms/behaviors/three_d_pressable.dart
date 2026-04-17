import 'package:flutter/material.dart';
import '../../foundation/opacity.dart';
import 'three_d_press_painter.dart';

/// Atom behavior: the shared scaffold used by every interactive atom that
/// renders through [ThreeDPressPainter].
///
/// Composes three duplicated pieces:
/// - `GestureDetector` with `isInteractive`-aware `onTapDown`/`onTapUp`/`onTapCancel`
/// - Optional `Opacity` wrapper when `isDisabled` is true
/// - `CustomPaint` driven by a caller-supplied [ThreeDPressPainter]
///
/// Callers own:
/// - Press state (`InteractiveAtomMixin.pressed`) — passed in via painter config
/// - Semantics wrapping (placed outside this widget)
/// - Content sizing (`SizedBox`, `ConstrainedBox`, `Padding`, etc.) via [child]
///
/// Sibling to [PressableSurface]. [PressableSurface] owns its own press state
/// and fixed padding; [ThreeDPressable] is stateless and takes the painter
/// fully configured, so atoms that already use `InteractiveAtomMixin` can
/// delegate just the scaffold without losing control of the painter.
class ThreeDPressable extends StatelessWidget {
  /// Caller-configured painter — every visual value flows through here.
  final ThreeDPressPainter painter;

  /// When false, all gesture handlers are disconnected (null).
  final bool isInteractive;

  /// When true, wraps the painted content in a disabled-opacity [Opacity].
  /// Leave false if the atom handles disabled styling on the inner content
  /// itself (e.g. [AppButton] fades only its label/icon).
  final bool isDisabled;

  final GestureTapDownCallback? onTapDown;
  final GestureTapUpCallback? onTapUp;
  final GestureTapCancelCallback? onTapCancel;

  /// The content rendered on top of the painter (typically a sized layout).
  final Widget? child;

  const ThreeDPressable({
    super.key,
    required this.painter,
    this.isInteractive = true,
    this.isDisabled = false,
    this.onTapDown,
    this.onTapUp,
    this.onTapCancel,
    this.child,
  });

  @override
  Widget build(BuildContext context) {
    Widget result = CustomPaint(painter: painter, child: child);

    if (isDisabled) {
      result = Opacity(opacity: AppOpacity.disabled, child: result);
    }

    return GestureDetector(
      onTapDown: isInteractive ? onTapDown : null,
      onTapUp: isInteractive ? onTapUp : null,
      onTapCancel: isInteractive ? onTapCancel : null,
      child: result,
    );
  }
}
