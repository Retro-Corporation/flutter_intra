/// A single selectable scheme option.
class SetScheme {
  final String id;
  final String label;

  const SetScheme({required this.id, required this.label});
}

/// A named group of [SetScheme] options rendered under a section header.
class SetSchemeGroup {
  final String name;
  final List<SetScheme> schemes;

  const SetSchemeGroup({required this.name, required this.schemes});
}
