import 'dart:ui' show lerpDouble;
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../behaviors/three_d_press_painter.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/motion/curves.dart';
import '../../foundation/motion/durations.dart';
import '../../foundation/press/three_d_press_geometry.dart';
import '../../foundation/space/padding.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/type/typography.dart';

/// Atom: 3D raised text field with an interactive [ThreeDPressPainter] border.
///
/// Receive-only — requires a [controller] and [borderColor] from the molecule
/// or template above. Never creates, owns, or disposes a controller or focus node.
///
/// The border color is injected so the molecule can drive focus and field-state
/// colors without the atom knowing about either concern.
///
/// **Press interaction:** the face drops on tap-down and animates back up on
/// tap-up over [AppDurations.press]. Focus is communicated by [borderColor]
/// (injected by the molecule), not by face position.
///
/// Always uses [AppRadius.sm] (8px) — this is the defining visual of the 3D input style.
class AppTextField3D extends StatefulWidget {
  final TextEditingController controller;

  /// Border ring color. Molecule drives this: unfocused, focused, error, success, disabled.
  final Color borderColor;

  final FocusNode? focusNode;
  final String? hintText;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Custom suffix widget (e.g. clear icon, visibility toggle, stepper buttons).
  final Widget? suffixWidget;

  final bool enabled;
  final bool obscureText;
  final int maxLines;
  final int? minLines;
  final TextInputType? keyboardType;
  final List<TextInputFormatter>? inputFormatters;
  final int? maxLength;

  const AppTextField3D({
    super.key,
    required this.controller,
    required this.borderColor,
    this.focusNode,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.suffixWidget,
    this.enabled = true,
    this.obscureText = false,
    this.maxLines = 1,
    this.minLines,
    this.keyboardType,
    this.inputFormatters,
    this.maxLength,
  });

  @override
  State<AppTextField3D> createState() => _AppTextField3DState();
}

class _AppTextField3DState extends State<AppTextField3D>
    with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _progress;

  /// Cached geometries — `outline` factory values for unpressed (0.0) and
  /// pressed (1.0) states. Lerped per-frame by the animation.
  final _unpressed = PressGeometry.outline(pressed: false);
  final _pressed = PressGeometry.outline(pressed: true);

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: AppDurations.press,
    );
    _progress = CurvedAnimation(parent: _controller, curve: AppCurves.press);
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  void _onPointerDown(PointerDownEvent _) {
    if (!widget.enabled) return;
    _controller.forward();
  }

  void _onPointerEnd(PointerEvent _) {
    if (!widget.enabled) return;
    _controller.reverse();
  }

  @override
  Widget build(BuildContext context) {
    return Listener(
      // translucent: pointer events fire here AND propagate to the TextField below.
      // Listener works at the raw pointer-event level (not gesture arena), so it
      // fires reliably for any touch in the entire box — independent of the
      // TextField's internal gesture handling.
      behavior: HitTestBehavior.translucent,
      onPointerDown: _onPointerDown,
      onPointerUp: _onPointerEnd,
      onPointerCancel: _onPointerEnd,
      child: AnimatedBuilder(
        animation: _progress,
        builder: (context, child) {
          final t = _progress.value;
          // Lerp only the values that differ between pressed/unpressed:
          //   visualBottom: depth → xs (face shrinks bottom border on press)
          //   visualSide:   md → xs   (face shrinks side borders on press)
          //   faceOffset:   0 → lg    (face slides down)
          // visualTop, layoutSide, reservedVertical are constant across both states.
          final visualBottom =
              lerpDouble(_unpressed.visualBottom, _pressed.visualBottom, t)!;
          final visualSide =
              lerpDouble(_unpressed.visualSide, _pressed.visualSide, t)!;
          final faceOffset =
              lerpDouble(_unpressed.faceOffset, _pressed.faceOffset, t)!;

          return CustomPaint(
            painter: ThreeDPressPainter(
              backgroundColor: AppColors.surface,
              borderColor: widget.borderColor,
              borderRadius: AppRadius.sm,
              borderTop: _unpressed.visualTop,
              borderBottom: visualBottom,
              borderSide: visualSide,
              faceOffset: faceOffset,
              faceSideInset: _unpressed.layoutSide,
              showBorder: true,
            ),
            child: Padding(
              padding: EdgeInsets.only(
                left: _unpressed.layoutSide,
                right: _unpressed.layoutSide,
                top: _unpressed.visualTop + faceOffset,
                // Constant total reserved vertical — no layout shift on press.
                bottom: (_unpressed.reservedVertical -
                        _unpressed.visualTop -
                        faceOffset)
                    .clamp(0.0, double.infinity),
              ),
              child: child,
            ),
          );
        },
        // child is built once and reused across all animation frames.
        child: TextField(
          controller: widget.controller,
          focusNode: widget.focusNode,
          onChanged: widget.onChanged,
          onSubmitted: widget.onSubmitted,
          obscureText: widget.obscureText,
          maxLines: widget.maxLines,
          minLines: widget.minLines,
          keyboardType: widget.keyboardType,
          inputFormatters: widget.inputFormatters,
          maxLength: widget.maxLength,
          enabled: widget.enabled,
          style: AppTypography.body.regular,
          cursorColor: AppColors.brand,
          buildCounter: (context,
                  {required currentLength,
                  required isFocused,
                  required maxLength}) =>
              null,
          decoration: InputDecoration(
            hintText: widget.hintText,
            hintStyle: AppTypography.body.regular
                .copyWith(color: AppColors.textSecondary),
            border: InputBorder.none,
            enabledBorder: InputBorder.none,
            focusedBorder: InputBorder.none,
            disabledBorder: InputBorder.none,
            errorBorder: InputBorder.none,
            filled: false,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: AppPadding.inputPaddingH,
              vertical: AppPadding.inputPaddingV,
            ),
            suffixIcon: widget.suffixWidget,
            suffixIconConstraints: const BoxConstraints(),
          ),
        ),
      ),
    );
  }
}
