/// REM scaling system.
/// All measurements in the design system derive from a single root value.
/// Change [AppScale.root] to scale the entire UI proportionally.
class AppScale {
  AppScale._();

  /// Root base value (1rem). Default: 16.0 (matches web standard).
  /// All tokens multiply against this value.
  static const double root = 16.0;
}

/// Extension to convert rem multipliers to pixel values.
/// Usage: `1.5.rem` → 24.0 (at root = 16)
extension RemScale on num {
  double get rem => this * AppScale.root;
}

/// Design tokens: 4-point grid system.
/// Source of truth — mirrors Figma "8 point grid" collection.
/// All values derived from [AppScale.root] via rem.
class AppGrid {
  AppGrid._();

  static final double grid0 = 0.rem;
  static final double grid4 = 0.25.rem;
  static final double grid8 = 0.5.rem;
  static final double grid12 = 0.75.rem;
  static final double grid16 = 1.rem;
  static final double grid20 = 1.25.rem;
  static final double grid24 = 1.5.rem;
  static final double grid28 = 1.75.rem;
  static final double grid32 = 2.rem;
  static final double grid36 = 2.25.rem;
  static final double grid40 = 2.5.rem;
  static final double grid60 = 3.75.rem;
  static final double grid100 = 6.25.rem;
  static final double grid160 = 10.rem;
  static final double grid240 = 15.rem;
}
