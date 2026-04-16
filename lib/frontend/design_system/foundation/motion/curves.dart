import 'package:flutter/animation.dart';

/// Design tokens: Animation curves.
/// Source of truth — all easing curves reference these values.
///
/// Organized by motion category (mirrors [AppDurations]).
/// When adding a curve: pick the category, name it for what it eases.
class AppCurves {
  AppCurves._();

  // ── Interactive feedback ──
  // Direct response to a user action (tap, toggle, press).

  /// Smooth ease-in-out for toggle thumb slide.
  static const Curve toggle = Curves.easeInOut;

  /// Ease-out for 3D press feedback (snappy press, smooth spring-back).
  static const Curve press = Curves.easeOut;

  // ── Breathing / ambient ──
  // Curves for looping or continuous ambient motion.

  /// Ease-out for breath inhale (expansion 0→1).
  static const Curve breathInhale = Curves.easeOut;

  /// Ease-in for breath exhale (contraction 1→0).
  static const Curve breathExhale = Curves.easeIn;

  /// Ease-out for pulse settle back to zero after tap.
  static const Curve pathPulseStop = Curves.easeOut;

  // ── Settle / resolve ──
  // Curves for animations winding down to a rest state (non-breathing).
}
