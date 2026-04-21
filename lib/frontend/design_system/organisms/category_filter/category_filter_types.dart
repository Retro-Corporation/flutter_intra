import 'package:flutter/foundation.dart';

/// Identifies which row of the CategoryFilterOrganism is semantically active.
/// Used internally for layout logic — not part of the callback API.
enum CategoryFilterType {
  overallBodySegments,
  bodyLocations,
  outcomes,
}

/// Data model for a chip in the "overall" row (row 1 in default state).
/// Unlike body parts and outcomes, overall chips may carry a leading icon.
@immutable
class CategoryChip {
  final String label;
  final String? iconAsset;

  const CategoryChip({required this.label, this.iconAsset});

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is CategoryChip &&
          other.label == label &&
          other.iconAsset == iconAsset);

  @override
  int get hashCode => Object.hash(label, iconAsset);
}
