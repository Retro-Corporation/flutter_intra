import 'grid.dart';

/// Design tokens: Padding / layout spacing.
/// Source of truth — mirrors Figma "Spacing" collection.
/// Semantic padding tokens that reference the [AppGrid].
class AppPadding {
  AppPadding._();

  // ── Rem-scaled padding tokens ──

  /// 0rem → 0px
  static const double rem0 = AppGrid.grid0;

  /// 0.25rem → 4px — tight inner spacing
  static const double rem025 = AppGrid.grid4;

  /// 0.5rem → 8px — small component padding
  static const double rem05 = AppGrid.grid8;

  /// 0.75rem → 12px — medium component padding
  static const double rem075 = AppGrid.grid12;

  /// 1rem → 16px — standard card/component padding
  static const double rem1 = AppGrid.grid16;

  /// 1.5rem → 24px — page padding
  static const double rem15 = AppGrid.grid24;

  /// 2rem → 32px — section padding
  static const double rem2 = AppGrid.grid32;

  /// 3rem → 48px — large section gaps
  static const double rem3 = AppGrid.grid48;

  // ── Component-specific aliases ──

  static const double pagePadding = rem15;
  static const double cardPadding = rem1;
  static const double sectionGap = rem1;
  static const double inputPaddingH = rem1;
  static const double inputPaddingV = rem075;
}
