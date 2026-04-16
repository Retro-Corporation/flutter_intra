enum SortCategory { exerciseScore, alphabet }

enum SortOption {
  lowToHigh(SortCategory.exerciseScore, 'Low → high'),
  highToLow(SortCategory.exerciseScore, 'High → low'),
  aToZ(SortCategory.alphabet, 'Abc → xyz'),
  zToA(SortCategory.alphabet, 'Zyx → abc');

  const SortOption(this.category, this.label);
  final SortCategory category;
  final String label;
}

extension SortCategoryX on SortCategory {
  String get label => switch (this) {
    SortCategory.exerciseScore => 'Exercise score',
    SortCategory.alphabet      => 'Alphabet',
  };

  List<SortOption> get options =>
      SortOption.values.where((o) => o.category == this).toList();
}
