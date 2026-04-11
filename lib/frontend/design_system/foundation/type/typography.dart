import 'package:flutter/material.dart';
import '../color/colors.dart';

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
/// Font: Inter. All sizes derived from rem (root = 16.0).
class AppTypography {
  AppTypography._();

  // ── Display ──

  /// 5.16rem → 82.56px — hero text
  static const display1 = TypeStyle(
    fontSize: 82.56,
    letterSpacing: -2.0,
    height: 1.1,
  );

  /// 4.3rem → 68.8px — large titles
  static const display2 = TypeStyle(
    fontSize: 68.8,
    letterSpacing: -1.5,
    height: 1.1,
  );

  // ── Headings ──

  /// 3.58rem → 57.28px
  static const heading1 = TypeStyle(
    fontSize: 57.28,
    letterSpacing: -1.2,
    height: 1.15,
  );

  /// 2.99rem → 47.84px
  static const heading2 = TypeStyle(
    fontSize: 47.84,
    letterSpacing: -1.0,
    height: 1.2,
  );

  /// 2.49rem → 39.84px
  static const heading3 = TypeStyle(
    fontSize: 39.84,
    letterSpacing: -0.8,
    height: 1.2,
  );

  /// 2.075rem → 33.2px
  static const heading4 = TypeStyle(
    fontSize: 33.2,
    letterSpacing: -0.6,
    height: 1.25,
  );

  /// 1.725rem → 27.6px
  static const heading5 = TypeStyle(
    fontSize: 27.6,
    letterSpacing: -0.4,
    height: 1.3,
  );

  /// 1.44rem → 23.04px
  static const proHeading6 = TypeStyle(
    fontSize: 23.04,
    letterSpacing: -0.3,
    height: 1.3,
  );

  // ── Body ──

  /// 1.2rem → 19.2px — large body text
  static const bodyLarge = TypeStyle(
    fontSize: 19.2,
    height: 1.5,
  );

  /// 1rem → 16px — base body text
  static const body = TypeStyle(
    fontSize: 16.0,
    height: 1.5,
  );

  /// 0.83rem → 13.28px — small body text
  static const bodySmall = TypeStyle(
    fontSize: 13.28,
    height: 1.5,
  );

  // ── Links (orange, with pressed state) ──

  /// 1.2rem → 19.2px — large link
  static const linkLarge = TypeStyle(
    fontSize: 19.2,
    height: 1.5,
    color: AppColors.brand,
  );

  /// 1rem → 16px — standard link
  static const link = TypeStyle(
    fontSize: 16.0,
    height: 1.5,
    color: AppColors.brand,
  );

  /// 0.83rem → 13.28px — small link
  static const linkSmall = TypeStyle(
    fontSize: 13.28,
    height: 1.5,
    color: AppColors.brand,
  );

  /// Link pressed state color
  static const linkPressedColor = AppColors.brandLight;

  // ── Utility styles (outside main scale) ──

  /// 0.69rem → 11.04px — section labels, badges
  static const caption = TypeStyle(
    fontSize: 11.04,
    letterSpacing: 1.2,
    color: AppColors.textSecondary,
  );

  /// 0.625rem → 10px — overlines, subtle labels
  static const overline = TypeStyle(
    fontSize: 10.0,
    letterSpacing: 2.0,
    color: AppColors.grey600,
  );
}
