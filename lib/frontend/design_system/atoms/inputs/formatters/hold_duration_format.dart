/// Pure helpers for hold-duration rendering + parsing. No Flutter dependency.
///
/// The hold field stores a total-seconds integer but is edited/displayed in
/// two string forms:
///
///   * `toDisplayMmss(seconds)` → `"M:SS"` — no leading zero on minutes.
///     Used as the text-field value on blur/seed.
///   * `toMmss(seconds)` → `"MM:SS"` — zero-padded. Kept for legacy callers.
///   * `formatHoldDisplay(seconds)` → human-friendly — strips redundant
///     zeros and appends the implied unit. Used for read-card labels and
///     scheme pill strings.
///
///   30  → "30sec"
///   60  → "1min"
///   145 → "2:25min"
///
/// `parseHoldInput` accepts partial MM:SS input or a bare integer (treated as
/// minutes): `"3"` → 180 s, `"10:"` → 600 s, `":30"` → 30 s, `"2:5"` → 125 s.

/// Minimum hold duration. Values below this are clamped on focus loss.
const int kMinHoldSeconds = 5;

/// Human-facing display format. See file header for examples.
String formatHoldDisplay(int seconds) {
  if (seconds < 60) return '${seconds}sec';
  final m = seconds ~/ 60;
  final s = seconds % 60;
  if (s == 0) return '${m}min';
  return '$m:${s.toString().padLeft(2, '0')}min';
}

/// Text-field display format — no leading zero on minutes: "3:00", "0:45", "33:05".
String toDisplayMmss(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '$m:${s.toString().padLeft(2, '0')}';
}

/// Text-field storage format — always two digits per side, always a colon.
/// Kept for any callers that require fixed-width output.
String toMmss(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

/// Parse a duration string into total seconds.
///
/// Accepts:
/// - Bare integer → treated as minutes: `"3"` → 180 s, `"33"` → 1980 s
/// - MM:SS (or M:SS / MM:S): `"3:30"` → 210 s, `":45"` → 45 s, `"2:"` → 120 s
///
/// Returns null only when the input cannot be interpreted at all.
int? parseHoldInput(String input) {
  final trimmed = input.trim();
  final colonIndex = trimmed.indexOf(':');
  if (colonIndex < 0) {
    // No colon — treat bare integer as minutes
    final minutes = int.tryParse(trimmed);
    if (minutes == null) return null;
    return minutes * 60;
  }
  final left = trimmed.substring(0, colonIndex);
  final right = trimmed.substring(colonIndex + 1);
  final minutes = left.isEmpty ? 0 : int.tryParse(left);
  final seconds = right.isEmpty ? 0 : int.tryParse(right);
  if (minutes == null || seconds == null) return null;
  return minutes * 60 + seconds;
}
