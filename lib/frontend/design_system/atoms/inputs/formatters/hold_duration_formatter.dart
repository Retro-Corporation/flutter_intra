import 'package:flutter/services.dart';

/// `TextInputFormatter` that softly cleans duration input without forcing a colon.
///
/// While the user types, the field is permissive:
/// - Strips any character that is not a digit or colon.
/// - Allows at most one colon.
/// - Without a colon: caps at 2 digits (e.g. "33").
/// - With a colon: caps each side at 2 digits (e.g. "33:59").
///
/// The caret is pinned to the end on every edit.
///
/// **No colon is auto-inserted.** The user types freely — "3", "33", "3:30"
/// are all valid in-progress states. On focus loss the owning template calls
/// `parseHoldInput` (bare digits → minutes) and `toDisplayMmss` to commit
/// a canonical "M:SS" value.
///
/// **Does not enforce a minimum value.** Clamping to [kMinHoldSeconds]
/// happens on focus loss in the owning template.
class HoldDurationFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final raw = newValue.text;
    final colonIndex = raw.indexOf(':');
    final String cleaned;
    if (colonIndex < 0) {
      // No colon yet — allow up to 2 digits
      final digits = raw.replaceAll(RegExp(r'[^0-9]'), '');
      cleaned = digits.length > 2 ? digits.substring(0, 2) : digits;
    } else {
      // Colon present — enforce MM:SS shape, cap each side at 2 digits
      final mm = raw.substring(0, colonIndex).replaceAll(RegExp(r'[^0-9]'), '');
      final ss = raw.substring(colonIndex + 1).replaceAll(RegExp(r'[^0-9]'), '');
      final mmCapped = mm.length > 2 ? mm.substring(0, 2) : mm;
      final ssCapped = ss.length > 2 ? ss.substring(0, 2) : ss;
      cleaned = '$mmCapped:$ssCapped';
    }
    return TextEditingValue(
      text: cleaned,
      selection: TextSelection.collapsed(offset: cleaned.length),
    );
  }
}
