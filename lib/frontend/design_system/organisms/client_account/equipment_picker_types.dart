/// A single selectable equipment option shown in [EquipmentPickerPanel].
class EquipmentOption {
  final String id;
  final String label;

  /// Optional category id — matches [EquipmentFilterCategory.id].
  /// Used by templates to pre-filter the options list by selected category.
  final String? categoryId;

  const EquipmentOption({
    required this.id,
    required this.label,
    this.categoryId,
  });
}

/// Variant that controls which layout [EquipmentPickerPanel] renders.
///
/// - [simple]: label-only option rows — current behaviour, unchanged.
/// - [withFilters]: adds a category chip row, thumbnail rows, a subtitle
///   label, and a dashed-border "Add New Equipment" footer.
enum EquipmentPickerVariant { simple, withFilters }

/// A single selectable category shown in the filter chip row of
/// [EquipmentPickerPanel] when variant == [EquipmentPickerVariant.withFilters].
class EquipmentFilterCategory {
  final String id;
  final String label;

  const EquipmentFilterCategory({required this.id, required this.label});
}
