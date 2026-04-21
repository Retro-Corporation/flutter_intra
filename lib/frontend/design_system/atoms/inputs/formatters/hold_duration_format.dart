/// Pure helpers for hold-duration rendering + parsing. No Flutter dependency.
///
/// The hold field stores a total-seconds integer but is edited/displayed in
/// two string forms:
///
///   * `toMmss(seconds)` → `"MM:SS"` — zero-padded, fixed width. Used as the
///     text-field value so the caret sits in a predictable place.
///   * `formatHoldDisplay(seconds)` → human-friendly — strips redundant
///     zeros and appends the implied unit. Used for read-card labels and
///     scheme pill strings.
///
///   30  → "30sec"
///   60  → "1min"
///   145 → "2:25min"
///
/// `parseHoldInput` accepts partial MM:SS input — `"10:"`, `":30"`, `"2:5"`
/// — returning `null` only when the string is not shaped like MM:SS at all.

/// Minimum hold duration. Values below this are rejected by
/// `HoldDurationFormatter` — they're not a realistic prescription and
/// typing `00:00` is almost always an in-progress edit the formatter
/// should resist committing.
const int kMinHoldSeconds = 5;

/// Human-facing display format. See file header for examples.
String formatHoldDisplay(int seconds) {
  if (seconds < 60) return '${seconds}sec';
  final m = seconds ~/ 60;
  final s = seconds % 60;
  if (s == 0) return '${m}min';
  return '$m:${s.toString().padLeft(2, '0')}min';
}

/// Text-field storage format — always two digits per side, always a colon.
String toMmss(int seconds) {
  final m = seconds ~/ 60;
  final s = seconds % 60;
  return '${m.toString().padLeft(2, '0')}:${s.toString().padLeft(2, '0')}';
}

/// Parse a MM:SS string into total seconds. Returns null if the shape is
/// not recognisable as MM:SS. Accepts empty segments (e.g. `":30"` → 30s,
/// `"10:"` → 600s).
int? parseHoldInput(String mmss) {
  final colonIndex = mmss.indexOf(':');
  if (colonIndex < 0) return null;
  final left = mmss.substring(0, colonIndex);
  final right = mmss.substring(colonIndex + 1);
  final minutes = left.isEmpty ? 0 : int.tryParse(left);
  final seconds = right.isEmpty ? 0 : int.tryParse(right);
  if (minutes == null || seconds == null) return null;
  return minutes * 60 + seconds;
}
