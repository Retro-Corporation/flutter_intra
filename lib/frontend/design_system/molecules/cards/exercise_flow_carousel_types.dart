/// Size variants for [ExerciseFlowCarousel].
///
/// - [sm] — thumbnail strip (active 100×100 / inactive 76×76). Default.
///   Existing callers unchanged.
/// - [lg] — media carousel. Each slot renders [MediaHolder] at
///   [MediaHolderSize.lg] (360×452). Page width = AppGrid.grid360 + AppGrid.grid12
///   so neighbours peek slightly at the edge.
enum ExerciseFlowCarouselSize { sm, lg }
