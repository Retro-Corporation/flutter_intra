/// Design token: OTP cell visual states.
///
/// Lives next to [OtpCell] — these change together (CCP).
enum OtpCellState {
  /// Empty slot — unfocused, no digit.
  empty,

  /// Focused slot — keyboard is active on this cell.
  focused,

  /// Filled slot — contains a digit, unfocused.
  filled,

  /// Error state — filled cell in an invalid code.
  error,
}
