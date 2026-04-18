import 'dart:ui' as ui;
import 'package:flutter/material.dart';
import '../../foundation/motion/breath.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/motion/curves.dart';
import '../../foundation/motion/durations.dart';
import '../../icons/icon_sizes.dart';
import '../primitives/icon.dart';
import 'path_button_geometry.dart';
import 'path_button_renderer.dart';
import '../behaviors/interactive_atom_mixin.dart';

// ── AppPathButton ──

class AppPathButton extends StatefulWidget {
  /// Shape variant for visual variety.
  final PathButtonShape shape;

  /// Current state: active (pulsing), completed (static), locked (disabled).
  final PathButtonState state;

  /// Icon asset path from [AppIcons]. Represents day type.
  final String icon;

  /// Ring segments. segments[0] = wellness, rendered at 12 o'clock.
  /// Length = number of events (1-5).
  final List<PathButtonSegment> segments;

  /// Called when tapped. Only fires for active and completed states.
  final VoidCallback? onPressed;

  /// Accent color for face and filled segments. Defaults to [AppColors.brand].
  final Color color;

  const AppPathButton({
    super.key,
    required this.shape,
    required this.state,
    required this.icon,
    required this.segments,
    this.onPressed,
    this.color = AppColors.brand,
  });

  @override
  State<AppPathButton> createState() => _AppPathButtonState();
}

class _AppPathButtonState extends State<AppPathButton>
    with TickerProviderStateMixin, InteractiveAtomMixin {
  late AnimationController _pulseController;
  late Animation<double> _breathAnimation;
  bool _pulseStopped = false;

  @override
  bool get isInteractive => widget.state.isInteractive;

  // Path button does not toggle — satisfy the mixin contract with no-ops.
  @override
  bool get isSelfToggle => false;

  @override
  bool? get parentValue => null;

  @override
  void notifyToggleChanged(bool _) {}

  @override
  void onAfterTap() {
    if (widget.state.isPulsing && !_pulseStopped) {
      _pulseStopped = true;
      _pulseController.animateTo(
        0.0,
        duration: AppDurations.pathPulseStop,
        curve: AppCurves.pathPulseStop,
      );
    }
    widget.onPressed?.call();
  }

  @override
  void initState() {
    super.initState();
    _pulseController = AnimationController(
      vsync: this,
      duration: AppDurations.pathPulse,
    );
    _breathAnimation = _pulseController.drive(AppBreath.sequence());
    if (widget.state.isPulsing) {
      _pulseController.repeat();
    }
  }

  @override
  void dispose() {
    _pulseController.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AppPathButton oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.state != oldWidget.state) {
      _pulseStopped = false;
      if (widget.state.isPulsing) {
        _pulseController.repeat();
      } else {
        _pulseController.stop();
        _pulseController.value = 0.0;
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final outerSize = widget.shape.outerSize;
    final pulseExpand = widget.shape.pulseExpand;

    // Widget height is fixed regardless of press state — the face drops
    // within this reserved envelope.
    final totalHeight = outerSize + pathBorderBottom;

    return Semantics(
      button: true,
      enabled: isInteractive,
      child: GestureDetector(
        onTapDown: isInteractive ? handleTapDown : null,
        onTapUp: isInteractive ? handleTapUp : null,
        onTapCancel: isInteractive ? handleTapCancel : null,
        child: AnimatedBuilder(
          animation: Listenable.merge([_breathAnimation, pressAnimation]),
          child: Center(
            child: AppIcon(
              widget.icon,
              size: IconSizes.lg,
              color: AppColors.textPrimary,
            ),
          ),
          builder: (context, child) {
            final pressT = pressAnimation.value;
            // Face slides from flush-top (unpressed) to bottom-of-envelope
            // (pressed). Same endpoints as before, now smoothly interpolated.
            final visualTop =
                ui.lerpDouble(pathBorderTop, pathBorderBottom, pressT)!;
            final visualBottom =
                ui.lerpDouble(pathBorderBottom, 0.0, pressT)!;

            return CustomPaint(
              painter: PathButtonRenderer(
                shape: widget.shape,
                state: widget.state,
                segments: widget.segments,
                color: widget.color,
                pulseExpansion: _breathAnimation.value,
                pressT: pressT,
                visualTop: visualTop,
                visualBottom: visualBottom,
              ),
              child: SizedBox(
                width: outerSize + (pulseExpand * 2),
                height: totalHeight + (pulseExpand * 2),
                child: Padding(
                  padding: EdgeInsets.only(
                    left: pulseExpand,
                    right: pulseExpand,
                    top: pulseExpand + visualTop,
                    bottom: pulseExpand + visualBottom,
                  ),
                  child: child,
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
