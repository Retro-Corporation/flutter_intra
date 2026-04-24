/// Size variants for [MediaHolder].
///
/// - [sm]   → 332×408 — default; preserves all existing callers unchanged.
/// - [lg]   → 360×452 — used on Exercise Detail (basic single item and
///   as the carousel slot in set/template variants).
/// - [hero] → 360×360 — square; used on flow-boundary screens
///   (e.g. Create Exercise intro, Completed Exercise) to display
///   a 3D character illustration.
enum MediaHolderSize { sm, lg, hero }
