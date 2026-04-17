/// Visual style variants for [AppSearchBar].
///
/// Search bar uses its own enum (not [InputVariant]) because the default shape
/// is a pill — distinct from the flat outlined style used by other inputs.
enum SearchBarVariant {
  /// Flat pill-shaped input — default. Uses [AppTextField] with [AppRadius.pill].
  pill,

  /// 3D raised card input. Uses [AppTextField3D] with [AppRadius.sm].
  ///
  /// Border color: [AppColors.surfaceBorder] (unfocused) → [AppColors.brand] (focused).
  card,
}
