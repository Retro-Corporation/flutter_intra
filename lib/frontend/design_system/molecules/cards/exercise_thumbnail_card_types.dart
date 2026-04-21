/// Size variants for [ExerciseThumbnailCard].
///
/// Lives at the molecule layer — the small vs large choice drives both the
/// inner [Thumbnail] size and whether a label is rendered.
///
/// - [small]: 100×100 thumbnail, no label. Used for exercises and sets in
///   the "Saved" row on the Add Exercise page.
/// - [large]: 128×128 thumbnail with a centered label below. Used for
///   templates in the "Saved Templates" row on the same page.
enum ExerciseThumbnailCardSize { small, large }
