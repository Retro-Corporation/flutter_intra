import 'package:flutter/animation.dart';

import 'curves.dart';

/// Design tokens: Breathing animation weights + sequence builder.
/// Source of truth — all breathing/pulse animations reference these values.
///
/// Weights are proportional (sum = 100). They distribute the total
/// breath duration ([AppDurations.pathPulse]) across four phases:
/// inhale → hold open → exhale → hold closed.
///
/// For non-breathing animation types (heartbeat, bounce, etc.)
/// create a dedicated foundation file — do not add them here.
class AppBreath {
  AppBreath._();

  // ── Phase weights ──
  // Proportional time allocation for each phase of the breath cycle.

  /// 40 — inhale expansion (0 → 1).
  static const double inhale = 40;

  /// 10 — hold at max expansion.
  static const double holdOpen = 10;

  /// 40 — exhale contraction (1 → 0).
  static const double exhale = 40;

  /// 10 — hold at rest.
  static const double holdClosed = 10;

  // ── Sequence builder ──

  /// Builds the standard 4-phase breathing [TweenSequence].
  ///
  /// Curves come from [AppCurves.breathInhale] / [AppCurves.breathExhale].
  /// Pair with [AppDurations.pathPulse] on the [AnimationController] and
  /// call `controller.repeat()` for a continuous loop.
  static TweenSequence<double> sequence() => TweenSequence<double>([
        TweenSequenceItem(
          tween: Tween(begin: 0.0, end: 1.0)
              .chain(CurveTween(curve: AppCurves.breathInhale)),
          weight: inhale,
        ),
        TweenSequenceItem(
          tween: ConstantTween(1.0),
          weight: holdOpen,
        ),
        TweenSequenceItem(
          tween: Tween(begin: 1.0, end: 0.0)
              .chain(CurveTween(curve: AppCurves.breathExhale)),
          weight: exhale,
        ),
        TweenSequenceItem(
          tween: ConstantTween(0.0),
          weight: holdClosed,
        ),
      ]);
}
