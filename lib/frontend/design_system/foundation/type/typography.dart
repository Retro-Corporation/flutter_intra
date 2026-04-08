import 'package:flutter/material.dart';
import '../color/colors.dart';
import '../space/grid.dart';

/// A type scale entry that exposes weight variants.
/// Usage: `AppTypography.heading1.bold` or `AppTypography.body.regular`
class TypeStyle {
  final double fontSize;
  final double? letterSpacing;
  final double? height;
  final Color color;

  const TypeStyle({
    required this.fontSize,
    this.letterSpacing,
    this.height,
    this.color = AppColors.textPrimary,
  });

  /// Weight: Black (w900)
  TextStyle get black => _build(FontWeight.w900);

  /// Weight: Bold (w700)
  TextStyle get bold => _build(FontWeight.w700);

  /// Weight: Semi Bold (w600)
  TextStyle get semiBold => _build(FontWeight.w600);

  /// Weight: Regular (w400)
  TextStyle get regular => _build(FontWeight.w400);

  /// Returns this style with [AppColors.textSecondary] as the text color.
  /// Usage: `AppTypography.body.secondary.regular`
  TypeStyle get secondary => TypeStyle(
        fontSize: fontSize,
        letterSpacing: letterSpacing,
        height: height,
        color: AppColors.textSecondary,
      );

  TextStyle _build(FontWeight weight) => TextStyle(
        fontFamily: 'Inter',
        fontSize: fontSize,
        fontWeight: weight,
        letterSpacing: letterSpacing,
        height: height,
        color: color,
      );
}

/// Design tokens: Typography scale.
/// Source of truth — mirrors Figma type styles.
/// Font: Inter. All sizes derived from rem.
class AppTypography {
  AppTypography._();

  // ── Display ──

  /// 5.16rem → 82.55px — hero text
  static final display1 = TypeStyle(
    fontSize: 5.16.rem,
    letterSpacing: -2.0,
    height: 1.1,
  );

  /// 4.3rem → 68.8px — large titles
  static final display2 = TypeStyle(
    fontSize: 4.3.rem,
    letterSpacing: -1.5,
    height: 1.1,
  );

  // ── Headings ──

  /// 3.58rem → 57.3px
  static final heading1 = TypeStyle(
    fontSize: 3.58.rem,
    letterSpacing: -1.2,
    height: 1.15,
  );

  /// 2.99rem → 47.8px
  static final heading2 = TypeStyle(
    fontSize: 2.99.rem,
    letterSpacing: -1.0,
    height: 1.2,
  );

  /// 2.49rem → 39.8px
  static final heading3 = TypeStyle(
    fontSize: 2.49.rem,
    letterSpacing: -0.8,
    height: 1.2,
  );

  /// 2.075rem → 33.2px
  static final heading4 = TypeStyle(
    fontSize: 2.075.rem,
    letterSpacing: -0.6,
    height: 1.25,
  );

  /// 1.725rem → 27.6px
  static final heading5 = TypeStyle(
    fontSize: 1.725.rem,
    letterSpacing: -0.4,
    height: 1.3,
  );

  /// 1.44rem → 23.04px
  static final proHeading6 = TypeStyle(
    fontSize: 1.44.rem,
    letterSpacing: -0.3,
    height: 1.3,
  );

  // ── Body ──

  /// 1.2rem → 19.2px — large body text
  static final bodyLarge = TypeStyle(
    fontSize: 1.2.rem,
    height: 1.5,
  );

  /// 1rem → 16px — base body text
  static final body = TypeStyle(
    fontSize: 1.rem,
    height: 1.5,
  );

  /// 0.83rem → 13.3px — small body text
  static final bodySmall = TypeStyle(
    fontSize: 0.83.rem,
    height: 1.5,
  );

  // ── Links (orange, with pressed state) ──

  /// 1.2rem → 19.2px — large link
  static final linkLarge = TypeStyle(
    fontSize: 1.2.rem,
    height: 1.5,
    color: AppColors.brand,
  );

  /// 1rem → 16px — standard link
  static final link = TypeStyle(
    fontSize: 1.rem,
    height: 1.5,
    color: AppColors.brand,
  );

  /// 0.83rem → 13.3px — small link
  static final linkSmall = TypeStyle(
    fontSize: 0.83.rem,
    height: 1.5,
    color: AppColors.brand,
  );

  /// Link pressed state color
  static const linkPressedColor = AppColors.brandLight;

  // ── Utility styles (outside main scale) ──

  /// 0.69rem → ~11px — section labels, badges
  static final caption = TypeStyle(
    fontSize: 0.69.rem,
    letterSpacing: 1.2,
    color: AppColors.textSecondary,
  );

  /// 0.625rem → 10px — overlines, subtle labels
  static final overline = TypeStyle(
    fontSize: 0.625.rem,
    letterSpacing: 2.0,
    color: AppColors.grey600,
  );
}
