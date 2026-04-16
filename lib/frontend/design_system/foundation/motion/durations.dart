/// Design tokens: Animation durations.
/// Source of truth — all timed animations reference these values.
///
/// Organized by motion category so new tokens slot into the right group.
/// When adding a duration: pick the category, name it for what it animates.
class AppDurations {
  AppDurations._();

  // ── Interactive feedback ──
  // Direct response to a user action (tap, toggle, press).

  /// 250ms — toggle thumb slide, nav panel transition.
  static const Duration toggle = Duration(milliseconds: 250);

  /// 100ms — 3D press feedback (face drop on tap-down, spring back on tap-up).
  static const Duration press = Duration(milliseconds: 100);

  // ── Breathing / ambient ──
  // Looping or continuous motion with no user trigger,
  // including the settle duration to wind the loop down.

  /// 2000ms — full breathing pulse cycle (expand → hold → contract → hold).
  static const Duration pathPulse = Duration(milliseconds: 2000);

  /// 300ms — pulse settle back to zero after tap.
  static const Duration pathPulseStop = Duration(milliseconds: 300);

  // ── Settle / resolve ──
  // Animation winding down to a rest state (non-breathing).
}
