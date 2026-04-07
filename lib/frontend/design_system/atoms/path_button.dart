import 'package:flutter/material.dart';
import '../foundation/colors.dart';
import '../foundation/durations.dart';
import '../icons/icon_sizes.dart';
import 'icon.dart';
import 'path_button_geometry.dart';
import 'path_button_renderer.dart';
import 'press_state_mixin.dart';

// ── Animation constants ──

/// Breathing-style pulse: expand → hold → contract → hold.
/// Maps controller 0→1 to a full breath cycle.
final TweenSequence<double> _kBreathSequence = TweenSequence<double>([
  TweenSequenceItem(
    tween: Tween(begin: 0.0, end: 1.0).chain(CurveTween(curve: Curves.easeOut)),
    weight: 40, // inhale
  ),
  TweenSequenceItem(
    tween: ConstantTween(1.0),
    weight: 10, // hold open
  ),
  TweenSequenceItem(
    tween: Tween(begin: 1.0, end: 0.0).chain(CurveTween(curve: Curves.easeIn)),
    weight: 40, // exhale
  ),
  TweenSequenceItem(
    tween: ConstantTween(0.0),
    weight: 10, // hold closed
  ),
]);

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
    with SingleTickerProviderStateMixin, PressStateMixin {
  late AnimationController _pulseController;
  late Animation<double> _breathAnimation;
  bool _pulseStopped = false;

  @override
  bool get isInteractive => widget.state.isInteractive;

  @override
  void onTapAction() {
    if (widget.state.isPulsing && !_pulseStopped) {
      _pulseStopped = true;
      _pulseController.animateTo(
        0.0,
        duration: AppDurations.pathPulseStop,
        curve: Curves.easeOut,
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
    _breathAnimation = _pulseController.drive(_kBreathSequence);
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

    final double visualTop;
    final double visualBottom;
    if (pressed) {
      visualTop = pathBorderBottom;
      visualBottom = 0.0;
    } else {
      visualTop = pathBorderTop;
      visualBottom = pathBorderBottom;
    }

    final totalHeight = outerSize + pathBorderBottom;

    return Semantics(
      button: true,
      enabled: isInteractive,
      child: GestureDetector(
        onTapDown: isInteractive ? handleTapDown : null,
        onTapUp: isInteractive ? handleTapUp : null,
        onTapCancel: isInteractive ? handleTapCancel : null,
        child: AnimatedBuilder(
          animation: _breathAnimation,
          builder: (context, child) {
            return CustomPaint(
              painter: PathButtonRenderer(
                shape: widget.shape,
                state: widget.state,
                segments: widget.segments,
                color: widget.color,
                pulseExpansion: _breathAnimation.value,
                pressed: pressed,
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
                  child: Center(
                    child: AppIcon(
                      widget.icon,
                      size: IconSizes.lg,
                      color: AppColors.textPrimary,
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
