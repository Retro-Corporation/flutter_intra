/// Visual style variants for text-input molecules:
/// [AppTextFieldMolecule], [AppPasswordField], [AppTextArea], [AppNumberField].
///
/// [AppSearchBar] has its own [SearchBarVariant] because pill shape is specific
/// to search and not shared with the other input molecules.
enum InputVariant {
  /// Flat outlined input — default. Composes [AppTextField].
  flat,

  /// 3D raised card input. Composes [AppTextField3D].
  ///
  /// Border color: [AppColors.surfaceBorder] (unfocused) → [AppColors.brand] (focused).
  /// Non-default field states (error / success / disabled) take precedence and
  /// always show their own color regardless of focus.
  card,
}
