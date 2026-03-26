import 'package:flutter/material.dart';
import '../foundation/colors.dart';
import '../foundation/opacity.dart';
import '../foundation/radius.dart';

// ── Enums ──

enum ToggleSize { sm, md, lg }

// ── Size configuration ──

class _ToggleSizeConfig {
  final double trackWidth;
  final double trackHeight;
  final double thumbSize;

  const _ToggleSizeConfig({
    required this.trackWidth,
    required this.trackHeight,
    required this.thumbSize,
  });

  static final Map<ToggleSize, _ToggleSizeConfig> _map = {
    ToggleSize.sm: const _ToggleSizeConfig(
      trackWidth: 52,
      trackHeight: 20,
      thumbSize: 24,
    ),
    ToggleSize.md: const _ToggleSizeConfig(
      trackWidth: 68,
      trackHeight: 28,
      thumbSize: 32,
    ),
    ToggleSize.lg: const _ToggleSizeConfig(
      trackWidth: 84,
      trackHeight: 36,
      thumbSize: 40,
    ),
  };

  static _ToggleSizeConfig of(ToggleSize size) => _map[size]!;
}

// ── Color resolution ──

class _ResolvedToggleColors {
  final Color trackColor;
  final Color thumbColor;
  final Color thumbBorder;

  const _ResolvedToggleColors({
    required this.trackColor,
    required this.thumbColor,
    required this.thumbBorder,
  });
}

_ResolvedToggleColors _resolveToggleColors({
  required bool isOn,
  required Color color,
}) {
  if (isOn) {
    return _ResolvedToggleColors(
      trackColor: color,
      thumbColor: AppColors.surface,
      thumbBorder: color,
    );
  }

  // Off state
  return _ResolvedToggleColors(
    trackColor: AppColors.surfaceBorder,
    thumbColor: AppColors.surface,
    thumbBorder: AppColors.grey700,
  );
}

// ── AppToggle ──

/// Atom: toggle switch with pill track and oversized squircle thumb.
///
/// The thumb has a static 3D border effect. Only colors change between on/off.
///
/// State control modes:
/// - Parent-controlled: pass [value] and handle [onChanged]
/// - Self-toggle: set [selfToggle] to true
class AppToggle extends StatefulWidget {
  /// Current toggle state (parent-controlled mode).
  /// - null (default): no parent control, see [selfToggle].
  /// - true / false.
  final bool? value;

  /// If true, the toggle manages its own state on tap/drag.
  /// Cannot be used together with [value].
  final bool selfToggle;

  /// Called when the toggle state changes.
  final ValueChanged<bool>? onChanged;

  /// Toggle size: sm, md, lg.
  final ToggleSize size;

  /// Accent color for the "on" state track and thumb border.
  final Color color;

  /// Disables interaction and reduces opacity to 0.4.
  final bool isDisabled;

  const AppToggle({
    super.key,
    this.value,
    this.selfToggle = false,
    this.onChanged,
    this.size = ToggleSize.md,
    this.color = AppColors.brand,
    this.isDisabled = false,
  }) : assert(
         !(selfToggle && value != null),
         'Cannot use both selfToggle and value. Use one or the other.',
       );

  @override
  State<AppToggle> createState() => _AppToggleState();
}

class _AppToggleState extends State<AppToggle>
    with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late CurvedAnimation _position;
  bool _selfValue = false;

  bool get _interactive => !widget.isDisabled;

  bool get _currentValue {
    if (widget.selfToggle) return _selfValue;
    return widget.value ?? false;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: const Duration(milliseconds: 250),
      vsync: this,
    );
    _position = CurvedAnimation(
      parent: _controller,
      curve: Curves.easeInOut,
    );
    if (_currentValue) _controller.value = 1.0;
  }

  @override
  void dispose() {
    _position.dispose();
    _controller.dispose();
    super.dispose();
  }

  @override
  void didUpdateWidget(covariant AppToggle oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.selfToggle && oldWidget.selfToggle) {
      _selfValue = false;
    }
    _animateToValue();
  }

  void _animateToValue() {
    if (_currentValue) {
      _controller.forward();
    } else {
      _controller.reverse();
    }
  }

  void _toggle() {
    final next = !_currentValue;
    if (widget.selfToggle) {
      setState(() => _selfValue = next);
    }
    widget.onChanged?.call(next);
    _animateToValue();
  }

  void _onDragUpdate(DragUpdateDetails details) {
    final sizeConfig = _ToggleSizeConfig.of(widget.size);
    final thumbTravel = sizeConfig.trackWidth - sizeConfig.thumbSize;
    _controller.value += details.primaryDelta! / thumbTravel;
  }

  void _onDragEnd(DragEndDetails details) {
    final newValue = _controller.value > 0.5;
    if (newValue != _currentValue) {
      _toggle();
    } else {
      _animateToValue();
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizeConfig = _ToggleSizeConfig.of(widget.size);
    final colors = _resolveToggleColors(
      isOn: _currentValue,
      color: widget.color,
    );
    final contentOpacity = widget.isDisabled ? AppOpacity.disabled : AppOpacity.default_;

    // Thumb 3D border — static, never changes
    const double thumbBorderTop = 1.0;
    const double thumbBorderSide = 2.0;
    const double thumbBorderBottom = 4.0;

    final totalWidth = sizeConfig.trackWidth;
    final totalHeight = sizeConfig.thumbSize + thumbBorderTop + thumbBorderBottom;

    return Semantics(
      toggled: _currentValue,
      child: GestureDetector(
        onTap: _interactive ? _toggle : null,
        onHorizontalDragUpdate: _interactive ? _onDragUpdate : null,
        onHorizontalDragEnd: _interactive ? _onDragEnd : null,
        child: Opacity(
          opacity: contentOpacity,
          child: AnimatedBuilder(
            animation: _position,
            builder: (context, child) {
              return CustomPaint(
                painter: _TogglePainter(
                  position: _position.value,
                  trackColor: colors.trackColor,
                  thumbColor: colors.thumbColor,
                  thumbBorder: colors.thumbBorder,
                  trackWidth: sizeConfig.trackWidth,
                  trackHeight: sizeConfig.trackHeight,
                  thumbSize: sizeConfig.thumbSize,
                  thumbRadius: AppRadius.sm,
                  thumbBorderTop: thumbBorderTop,
                  thumbBorderSide: thumbBorderSide,
                  thumbBorderBottom: thumbBorderBottom,
                ),
                child: SizedBox(
                  width: totalWidth,
                  height: totalHeight,
                ),
              );
            },
          ),
        ),
      ),
    );
  }
}

// ── Custom painter for toggle ──

class _TogglePainter extends CustomPainter {
  final double position;
  final Color trackColor;
  final Color thumbColor;
  final Color thumbBorder;
  final double trackWidth;
  final double trackHeight;
  final double thumbSize;
  final double thumbRadius;
  final double thumbBorderTop;
  final double thumbBorderSide;
  final double thumbBorderBottom;

  _TogglePainter({
    required this.position,
    required this.trackColor,
    required this.thumbColor,
    required this.thumbBorder,
    required this.trackWidth,
    required this.trackHeight,
    required this.thumbSize,
    required this.thumbRadius,
    required this.thumbBorderTop,
    required this.thumbBorderSide,
    required this.thumbBorderBottom,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // The thumb (including its side borders) fits within trackWidth.
    final thumbOuterWidth = thumbSize + (thumbBorderSide * 2);
    final thumbTravel = trackWidth - thumbOuterWidth;
    final thumbOverflow = (thumbSize - trackHeight) / 2;

    // 1. Draw track (pill) — no border, just a fill
    //    Shift down by half the 3D border so the pill centers in total height.
    final trackTop = thumbOverflow + (thumbBorderBottom / 2);
    final trackRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(0, trackTop, trackWidth, trackHeight),
      const Radius.circular(AppRadius.pill),
    );
    canvas.drawRRect(trackRect, Paint()..color = trackColor);

    // 2. Draw thumb (squircle with static 3D border)
    final thumbOuterLeft = thumbTravel * position;
    const thumbOuterTop = 0.0;

    // 2a. Border ring via drawDRRect
    final outerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        thumbOuterLeft,
        thumbOuterTop,
        thumbOuterWidth,
        thumbSize + thumbBorderTop + thumbBorderBottom,
      ),
      Radius.circular(thumbRadius + thumbBorderSide),
    );
    final innerRect = RRect.fromRectAndRadius(
      Rect.fromLTWH(
        thumbOuterLeft + thumbBorderSide,
        thumbOuterTop + thumbBorderTop,
        thumbSize,
        thumbSize,
      ),
      Radius.circular(thumbRadius),
    );
    canvas.drawDRRect(outerRect, innerRect, Paint()..color = thumbBorder);

    // 2b. Thumb face
    canvas.drawRRect(innerRect, Paint()..color = thumbColor);
  }

  @override
  bool shouldRepaint(_TogglePainter old) =>
      position != old.position ||
      trackColor != old.trackColor ||
      thumbColor != old.thumbColor ||
      thumbBorder != old.thumbBorder ||
      trackWidth != old.trackWidth ||
      trackHeight != old.trackHeight ||
      thumbSize != old.thumbSize ||
      thumbRadius != old.thumbRadius ||
      thumbBorderTop != old.thumbBorderTop ||
      thumbBorderSide != old.thumbBorderSide ||
      thumbBorderBottom != old.thumbBorderBottom;
}
