import 'package:flutter/material.dart';

/// Mixin: press state + bool self-toggle for interactive atoms.
///
/// Provides [pressed], [isActive], [toggle], and GestureDetector handlers.
/// Subclass implements [isInteractive], [isSelfToggle], [parentValue],
/// [notifyToggleChanged], and optionally [onAfterTap].
mixin InteractiveAtomMixin<T extends StatefulWidget> on State<T> {
  // ── Press state ──
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

  // ── Tap handlers ──
  void handleTapDown(TapDownDetails _) => setState(() => _pressed = true);

  void handleTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
    toggle();
    onAfterTap();
  }

  void handleTapCancel() => setState(() => _pressed = false);
}
