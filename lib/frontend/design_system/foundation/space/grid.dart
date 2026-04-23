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

  static const double grid0 = 0;
  static const double grid4 = 0.25 * AppScale.root;
  static const double grid8 = 0.5 * AppScale.root;
  static const double grid12 = 0.75 * AppScale.root;
  static const double grid16 = 1 * AppScale.root;
  static const double grid20 = 1.25 * AppScale.root;
  static const double grid24 = 1.5 * AppScale.root;
  static const double grid28 = 1.75 * AppScale.root;
  static const double grid32 = 2 * AppScale.root;
  static const double grid36 = 2.25 * AppScale.root;
  static const double grid40 = 2.5 * AppScale.root;
  static const double grid44 = 2.75 * AppScale.root;
  static const double grid48 = 3 * AppScale.root;
  static const double grid52 = 3.25 * AppScale.root;
  static const double grid56 = 3.5 * AppScale.root;
  static const double grid60 = 3.75 * AppScale.root;
  static const double grid64 = 4 * AppScale.root;
  static const double grid68 = 4.25 * AppScale.root;
  static const double grid72 = 4.5 * AppScale.root;
  static const double grid76 = 4.75 * AppScale.root;
  static const double grid80 = 5 * AppScale.root;
  static const double grid84 = 5.25 * AppScale.root;
  static const double grid88 = 5.5 * AppScale.root;
  static const double grid92 = 5.75 * AppScale.root;
  static const double grid96 = 6 * AppScale.root;
  static const double grid100 = 6.25 * AppScale.root;
  static const double grid128 = 8 * AppScale.root;
  static const double grid160 = 10 * AppScale.root;
  static const double grid240 = 15 * AppScale.root;
  static const double grid332 = 20.75 * AppScale.root;  // 332px — MediaHolder sm width
  static const double grid360 = 22.5  * AppScale.root;  // 360px — MediaHolder lg width
  static const double grid408 = 25.5  * AppScale.root;  // 408px — MediaHolder sm height
  static const double grid452 = 28.25 * AppScale.root;  // 452px — MediaHolder lg height
}
