import 'package:flutter/material.dart';
import '../../foundation/motion/curves.dart';
import '../../foundation/motion/durations.dart';

/// Mixin: press state + bool self-toggle for interactive atoms.
///
/// Provides an animated [pressAnimation] (0.0 unpressed → 1.0 pressed) driven
/// by a controller the mixin owns. Consumers wrap their painter build in
/// `AnimatedBuilder(animation: pressAnimation)` and lerp the
/// [PressGeometry] between the unpressed and pressed instances.
///
/// The legacy [pressed] bool is retained and returns the current *target*
/// state (true between tap-down and release). It is intended for callers
/// that need to make discrete, non-visual decisions — not for visual state,
/// which should go through [pressAnimation] so it animates.
///
/// Requires [TickerProvider] — consumers include
/// `SingleTickerProviderStateMixin` alongside this mixin.
///
/// Tuning — timing/curve come from foundation tokens
/// ([AppDurations.press] / [AppCurves.press]); change them there to retune
/// every pressable atom in one place.
mixin InteractiveAtomMixin<T extends StatefulWidget>
    on State<T>, TickerProvider {
  // ── Press animation ──
  late final AnimationController _pressController = AnimationController(
    vsync: this,
    duration: AppDurations.press,
  );
  late final CurvedAnimation _pressAnimation = CurvedAnimation(
    parent: _pressController,
    curve: AppCurves.press,
  );

  /// Animation from 0.0 (unpressed) to 1.0 (pressed). Wrap painter builds
  /// in `AnimatedBuilder(animation: pressAnimation)` to animate geometry.
  Animation<double> get pressAnimation => _pressAnimation;

  /// Press *target* state — true between tap-down and release. Kept for
  /// discrete, non-visual decisions (e.g. deciding which [PressGeometry]
  /// factory family to use). Visual state should go through [pressAnimation].
  bool _pressed = false;
  bool get pressed => _pressed;

  // ── Toggle state ──
  bool _selfActive = false;
  bool get selfActive => _selfActive;

  /// Whether the widget currently accepts taps.
  bool get isInteractive;

  /// Whether the widget manages its own toggle state.
  bool get isSelfToggle;

  /// Parent-controlled value. null = no parent control.
  bool? get parentValue;

  /// Resolved active state: self-toggle wins when enabled, else parent.
  bool get isActive {
    if (isSelfToggle) return _selfActive;
    return parentValue ?? false;
  }

  /// Flip the toggle and notify.
  void toggle() {
    final next = !isActive;
    if (isSelfToggle) setState(() => _selfActive = next);
    notifyToggleChanged(next);
  }

  /// Fire the widget's callback (e.g. onChanged, onActiveChanged).
  void notifyToggleChanged(bool value);

  /// Hook for additional post-tap logic (e.g. button's onPressed).
  void onAfterTap() {}

  /// Call from didUpdateWidget when selfToggle mode changes.
  void resetSelfToggleIfNeeded(bool oldSelfToggle) {
    if (!isSelfToggle && oldSelfToggle) _selfActive = false;
  }

  @override
  void dispose() {
    _pressAnimation.dispose();
    _pressController.dispose();
    super.dispose();
  }

  // ── Tap handlers ──
  //
  // Press feel: snap-in, fade-out. Tap-down jumps straight to the pressed
  // geometry (instant acknowledgement of touch); tap-up / tap-cancel animate
  // the release back to rest over [AppDurations.press].
  void handleTapDown(TapDownDetails _) {
    _pressed = true;
    _pressController.value = 1.0;
  }

  void handleTapUp(TapUpDetails _) {
    _pressed = false;
    _pressController.reverse();
    toggle();
    onAfterTap();
  }

  void handleTapCancel() {
    _pressed = false;
    _pressController.reverse();
  }
}
