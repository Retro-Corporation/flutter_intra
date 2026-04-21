import 'package:flutter/services.dart';

/// `TextInputFormatter` that shapes raw keystrokes into an `MM:SS` mask.
///
/// As the user types digits, a colon is auto-inserted once three or more
/// digits are present. Up to four digits total:
///
///     ""       →  ""
///     "3"      →  "3"
///     "30"     →  "30"
///     "300"    →  "3:00"
///     "1000"   →  "10:00"
///     "3a:5x"  →  "3:5" (non-digit chars stripped)
///     "30:555" →  "30:55" (trailing digit beyond cap dropped)
///
/// The caret is pinned to the end of the formatted text on every edit — for
/// a four-character-max field this is simpler and less error-prone than
/// trying to preserve fine-grained cursor position.
///
/// **Does not enforce a minimum value.** The shape-only constraint allows
/// transient in-progress input ("0", ":0", "00:00") while the user is
/// still typing. Clamping to [kMinHoldSeconds] happens outside the
/// formatter, on focus loss / commit — typically a focus-node listener in
/// the owning template.
class HoldDurationFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'[^0-9]'), '');
    final capped = digits.length > 4 ? digits.substring(0, 4) : digits;
    final formatted = switch (capped.length) {
      0 => '',
      1 || 2 => capped,
      3 => '${capped[0]}:${capped.substring(1)}',
      _ => '${capped.substring(0, 2)}:${capped.substring(2)}',
    };
    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
