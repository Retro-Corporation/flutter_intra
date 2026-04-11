/// Opacity tokens for interaction states.
///
/// These control how transparent a component becomes. Used by all interactive atoms.
abstract final class AppOpacity {
  /// Reduced visibility for disabled components.
  static const double disabled = 0.4;

  /// Subtle background tint when a ghost button is pressed.
  static const double ghostPressed = 0.1;
}
