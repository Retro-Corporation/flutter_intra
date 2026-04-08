/// Design tokens: Stroke / border widths.
/// Source of truth — mirrors Figma "Stroke" collection.
class AppStroke {
  AppStroke._();

  /// 1.0px — standard input borders, dividers
  static const double xs = 1.0;

  /// 1.5px — badge borders, emphasized outlines
  static const double sm = 1.5;

  /// 2.0px — loading indicators, progress strokes
  static const double md = 2.0;

  /// 3.0px — active state indicators, navigation accents
  static const double lg = 3.0;

  /// 4.0px
  static const double xl = 4.0;

  /// 5.0px
  static const double xxl = 5.0;

  /// 6.0px — ring segment strokes (path button)
  static const double ring = 6.0;
}
