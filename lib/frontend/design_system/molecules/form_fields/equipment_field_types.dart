/// Equipment field variant — determines which input control is rendered.
enum EquipmentFieldType {
  /// Numeric input (3D card variant) with unit suffix appended on blur.
  numbered,

  /// Dropdown selector (3D outline) that opens an equipment picker panel.
  selectable,

  /// Read-only flat display — non-interactive, shows a fixed string.
  staticDisplay,
}
