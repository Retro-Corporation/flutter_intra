import 'grid.dart';

/// Design tokens: Padding / layout spacing.
/// Source of truth — mirrors Figma "Spacing" collection.
/// Semantic padding tokens that reference the [AppGrid].
class AppPadding {
  AppPadding._();

  // ── Rem-scaled padding tokens ──

  /// 0rem → 0px
  static final double none = AppGrid.grid0;

  /// 0.25rem → 4px — tight inner spacing
  static final double quarter = AppGrid.grid4;

  /// 0.5rem → 8px — small component padding
  static final double half = AppGrid.grid8;

  /// 0.75rem → 12px — medium component padding
  static final double threeQuarter = AppGrid.grid12;

  /// 1rem → 16px — standard card/component padding
  static final double one = AppGrid.grid16;

  /// 1.5rem → 24px — page padding
  static final double oneAndHalf = AppGrid.grid24;

  /// 2rem → 32px — section padding
  static final double two = AppGrid.grid32;

  /// 3rem → 48px — large section gaps
  static final double three = 3.rem;

  // ── Component-specific aliases ──

  static final double pagePadding = oneAndHalf;
  static final double cardPadding = one;
  static final double sectionGap = one;
  static final double inputPaddingH = one;
  static final double inputPaddingV = threeQuarter;
}
