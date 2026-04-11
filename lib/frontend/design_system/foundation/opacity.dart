/// Opacity tokens for interaction states.
///
/// These control how transparent a component becomes when disabled,
/// pressed, or in its default state. Used by all interactive atoms.
abstract final class AppOpacity {
  /// Full visibility — the normal state.
  static const double default_ = 1.0;

  /// Reduced visibility for disabled components.
  static const double disabled = 0.4;

  /// Subtle background tint when a ghost button is pressed.
  static const double ghostPressed = 0.1;
}
