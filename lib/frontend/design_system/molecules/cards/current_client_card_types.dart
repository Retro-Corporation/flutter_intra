/// Visual states for [CurrentClientCard].
///
/// Lives at the molecule layer — [ReviewStatus] is a visual/composition concept
/// (which card state drives which color). The atom [ScoreBadge] receives a
/// resolved [Color] and knows nothing about review domain states.
enum ReviewStatus { urgent, pendingReview, reviewed }
