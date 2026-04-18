import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/opacity.dart';
import '../../foundation/motion/curves.dart';
import '../../foundation/motion/durations.dart';
import '../../foundation/press/three_d_press_geometry.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/space/stroke.dart';
import '../behaviors/three_d_press_painter.dart';
import '../behaviors/three_d_surface.dart';
import 'toggle_types.dart';

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

  /// Exhaustive switch — compiler errors if a new ToggleSize case is added
  /// without a corresponding branch. Replaces the old Map lookup.
  static _ToggleSizeConfig of(ToggleSize size) {
    return switch (size) {
      ToggleSize.sm => _sm,
      ToggleSize.md => _md,
      ToggleSize.lg => _lg,
    };
  }

  static const _sm = _ToggleSizeConfig(
    trackWidth: AppGrid.grid52,
    trackHeight: AppGrid.grid20,
    thumbSize: AppGrid.grid24,
  );
  static const _md = _ToggleSizeConfig(
    trackWidth: AppGrid.grid68,
    trackHeight: AppGrid.grid28,
    thumbSize: AppGrid.grid32,
  );
  static const _lg = _ToggleSizeConfig(
    trackWidth: AppGrid.grid84,
    trackHeight: AppGrid.grid36,
    thumbSize: AppGrid.grid40,
  );
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
  return const _ResolvedToggleColors(
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

  Widget _wrapDisabled({required Widget child}) {
    if (!widget.isDisabled) return child;
    return Opacity(opacity: AppOpacity.disabled, child: child);
  }

  bool get _currentValue {
    if (widget.selfToggle) return _selfValue;
    return widget.value ?? false;
  }

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      duration: AppDurations.toggle,
      vsync: this,
    );
    _position = CurvedAnimation(
      parent: _controller,
      curve: AppCurves.toggle,
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
    // Thumb 3D border — static, never changes
    final thumbGeo = PressGeometry.static(
      top: AppStroke.xs,
      side: AppStroke.md,
      bottom: AppStroke.xl,
    );

    final totalWidth = sizeConfig.trackWidth;
    final totalHeight =
        sizeConfig.thumbSize + thumbGeo.visualTop + thumbGeo.visualBottom;

    // Thumb outer extents (including its 3D side borders).
    final thumbOuterWidth = sizeConfig.thumbSize + (thumbGeo.visualSide * 2);
    final thumbTravel = sizeConfig.trackWidth - thumbOuterWidth;

    // Track sits behind the thumb. Vertically centered within the total
    // height, accounting for the thumb's taller-than-track overflow and
    // the asymmetric top/bottom 3D borders on the thumb.
    final thumbOverflow = (sizeConfig.thumbSize - sizeConfig.trackHeight) / 2;
    final trackTop = thumbOverflow + (thumbGeo.visualBottom / 2);

    return Semantics(
      toggled: _currentValue,
      child: GestureDetector(
        onTap: _interactive ? _toggle : null,
        onHorizontalDragUpdate: _interactive ? _onDragUpdate : null,
        onHorizontalDragEnd: _interactive ? _onDragEnd : null,
        child: _wrapDisabled(
          child: SizedBox(
            width: totalWidth,
            height: totalHeight,
            child: Stack(
              children: [
                // Track — plain pill fill behind the thumb.
                Positioned(
                  left: 0,
                  top: trackTop,
                  width: sizeConfig.trackWidth,
                  height: sizeConfig.trackHeight,
                  child: DecoratedBox(
                    decoration: BoxDecoration(
                      color: colors.trackColor,
                      borderRadius: const BorderRadius.all(
                        Radius.circular(AppRadius.pill),
                      ),
                    ),
                  ),
                ),
                // Thumb — visual-only 3D surface, position animated.
                AnimatedBuilder(
                  animation: _position,
                  builder: (context, _) {
                    return Positioned(
                      left: thumbTravel * _position.value,
                      top: 0,
                      width: thumbOuterWidth,
                      height: totalHeight,
                      child: ThreeDSurface(
                        painter: ThreeDPressPainter(
                          backgroundColor: colors.thumbColor,
                          borderColor: colors.thumbBorder,
                          borderRadius: AppRadius.sm + thumbGeo.visualSide,
                          borderTop: thumbGeo.visualTop,
                          borderBottom: thumbGeo.visualBottom,
                          borderSide: thumbGeo.visualSide,
                          faceOffset: thumbGeo.faceOffset,
                          faceSideInset: thumbGeo.layoutSide,
                          showBorder: true,
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
