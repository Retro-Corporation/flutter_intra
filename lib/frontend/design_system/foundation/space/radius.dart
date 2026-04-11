/// Design tokens: Corner radius.
/// Source of truth — mirrors Figma "Corner Radius" collection.
/// All values derived from rem (16.0) except [pill] which is a fixed large value.
class AppRadius {
  AppRadius._();

  /// 0rem → 0px — sharp corners
  static const double none = 0;

  /// 0.5rem → 8px — subtle rounding
  static const double sm = 8.0;

  /// 1rem → 16px — standard rounding
  static const double md = 16.0;

  /// 1.5rem → 24px — prominent rounding
  static const double lg = 24.0;

  /// 2.5rem → 40px — large rounding
  static const double xl = 40.0;

  /// Fixed 999px — fully rounded / pill shape
  static const double pill = 999;
}
