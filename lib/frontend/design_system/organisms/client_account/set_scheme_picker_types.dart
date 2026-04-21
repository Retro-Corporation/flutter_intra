import '../../atoms/inputs/formatters/hold_duration_format.dart';

/// A single selectable scheme option — the canonical triple the user applies
/// to every exercise on the page.
///
/// [reps] and [sets] are integers. [holdSeconds] is stored as total seconds
/// and rendered via `formatHoldDisplay` so the implied unit (`sec` vs `min`
/// vs `m:ss min`) comes from the value itself — no separate unit field.
class SetScheme {
  final String id;
  final int reps;
  final int holdSeconds;
  final int sets;

  const SetScheme({
    required this.id,
    required this.reps,
    required this.holdSeconds,
    required this.sets,
  });

  /// Display label used by picker rows and the scheme button.
  /// Format matches Figma: `"3 / 30sec x 2"`, `"6 / 1min x 4"`,
  /// `"9 / 2:25min x 4"`.
  String get label => '$reps / ${formatHoldDisplay(holdSeconds)} x $sets';
}

/// A named group of [SetScheme] options rendered under a section header.
class SetSchemeGroup {
  final String name;
  final List<SetScheme> schemes;

  const SetSchemeGroup({required this.name, required this.schemes});
}
