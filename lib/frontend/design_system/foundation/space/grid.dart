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
/// All values derived from [AppScale.root] (16.0) via rem.
class AppGrid {
  AppGrid._();

  static const double grid0 = 0;           // 0rem
  static const double grid4 = 4.0;         // 0.25rem
  static const double grid8 = 8.0;         // 0.5rem
  static const double grid12 = 12.0;       // 0.75rem
  static const double grid16 = 16.0;       // 1rem
  static const double grid20 = 20.0;       // 1.25rem
  static const double grid24 = 24.0;       // 1.5rem
  static const double grid28 = 28.0;       // 1.75rem
  static const double grid32 = 32.0;       // 2rem
  static const double grid36 = 36.0;       // 2.25rem
  static const double grid40 = 40.0;       // 2.5rem
  static const double grid44 = 44.0;       // 2.75rem
  static const double grid48 = 48.0;       // 3rem
  static const double grid52 = 52.0;       // 3.25rem
  static const double grid56 = 56.0;       // 3.5rem
  static const double grid60 = 60.0;       // 3.75rem
  static const double grid64 = 64.0;       // 4rem
  static const double grid68 = 68.0;       // 4.25rem
  static const double grid72 = 72.0;       // 4.5rem
  static const double grid76 = 76.0;       // 4.75rem
  static const double grid80 = 80.0;       // 5rem
  static const double grid84 = 84.0;       // 5.25rem
  static const double grid88 = 88.0;       // 5.5rem
  static const double grid92 = 92.0;       // 5.75rem
  static const double grid96 = 96.0;       // 6rem
  static const double grid100 = 100.0;     // 6.25rem
  static const double grid160 = 160.0;     // 10rem
  static const double grid240 = 240.0;     // 15rem
}
