/// Which kind of work an exercise prescribes — determines which primary
/// metric field renders on the edit card.
///
/// Set at creation time by the database/product, not by a UI toggle. The
/// card reads this and renders exactly one of: a Rep integer field, or a
/// Hold MM:SS duration field. The two are mutually exclusive — an exercise
/// is either rep-based or hold-based for its lifetime.
enum ExerciseType { rep, hold }
