import 'grid.dart';

/// Design tokens: Corner radius.
/// Source of truth — mirrors Figma "Corner Radius" collection.
/// All values derived from rem except [pill] which is a fixed large value.
class AppRadius {
  AppRadius._();

  /// 0rem → 0px — sharp corners
  static const double none = 0;

  /// 0.5rem → 8px — subtle rounding
  static final double sm = 0.5.rem;

  /// 1rem → 16px — standard rounding
  static final double md = 1.rem;

  /// 1.5rem → 24px — prominent rounding
  static final double lg = 1.5.rem;

  /// 2.5rem → 40px — large rounding
  static final double xl = 2.5.rem;

  /// Fixed 999px — fully rounded / pill shape
  static const double pill = 999;
}
