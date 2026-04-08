import 'package:flutter/material.dart';

/// Design tokens: Color palette
/// Source of truth — mirrors Figma color tokens.
/// Hybrid naming: semantic aliases for components + raw 50-900 scale palette.
class AppColors {
  AppColors._();

  // ── Semantic tokens (use these in components) ──

  // Backgrounds
  static const background = Color(0xFF0E0E10);
  static const surface = Color(0xFF19191B);
  static const surfaceBorder = Color(0xFF4D4D4D);

  // Brand
  static const brand = orange500;
  static const brandLight = orange100;
  static const brandSubtle = orange50;
  static const brandDark = orange700;

  // Text
  static const textPrimary = Color(0xFFFFFFFF);
  static const textSecondary = grey500;
  static const textInverse = Color(0xFF000000);

  // Semantic
  static const error = red500;
  static const info = blue500;
  static const success = green500;
  static const warning = yellow500;

  // Gradients
  static const brandGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [orange500, orange700],
  );

  static const errorGradient = LinearGradient(
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
    colors: [red500, red700],
  );

  /// Shadow definitions: (primary, 700-shadow, 900-shadow).
  /// Single source of truth — both shadow maps derive from this list.
  /// Adding a new brand color = add one entry here. Both maps update.
  static const _shadowDefs = <(Color, Color, Color)>[
    (orange500, orange700, orange900),
    (red500,    red700,    red900),
    (blue500,   blue700,   blue900),
    (green500,  green700,  green900),
    (yellow500, yellow700, yellow900),
    (purple500, purple700, purple900),
    (grey500,   grey700,   grey900),
    (textPrimary, grey300, grey700),
  ];

  /// Maps primary palette colors to their 700 (shadow) variant.
  /// Used as the border/shadow color in the 3D press effect — a slightly
  /// darker shade that sits behind the face to create depth.
  static final Map<Color, Color> shadow700 = {
    for (final (primary, s700, _) in _shadowDefs) primary: s700,
  };

  /// Maps primary palette colors to their 900 (deep shadow) variant.
  /// Used as the border color for outline-style 3D components where the
  /// border needs stronger contrast against the dark background.
  static final Map<Color, Color> shadow900 = {
    for (final (primary, _, s900) in _shadowDefs) primary: s900,
  };

  // ── Raw palette ──

  // Grey
  static const grey50 = Color(0xFFE6E6E6);
  static const grey100 = Color(0xFFDEDEDE);
  static const grey200 = Color(0xFFD9D9D9);
  static const grey300 = Color(0xFFCCCCCC);
  static const grey500 = Color(0xFF999999);
  static const grey600 = Color(0xFF808080);
  static const grey700 = Color(0xFF4D4D4D);
  static const grey800 = Color(0xFF333333);
  static const grey850 = Color(0xFF1F1F23);
  static const grey900 = Color(0xFF1A1A1A);

  // Orange
  static const orange50 = Color(0xFFFFEADE);
  static const orange100 = Color(0xFFFF9F63);
  static const orange500 = Color(0xFFF57800);
  static const orange700 = Color(0xFFCC6400);
  static const orange900 = Color(0xFFB85A00);

  // Blue
  static const blue500 = Color(0xFF0090C2);
  static const blue700 = Color(0xFF006A8F);
  static const blue900 = Color(0xFF00445C);

  // Red
  static const red500 = Color(0xFFFF1420);
  static const red700 = Color(0xFF8A2428);
  static const red900 = Color(0xFF61191C);

  // Green
  static const green500 = Color(0xFF369F23);
  static const green700 = Color(0xFF297A1A);
  static const green900 = Color(0xFF1B5011);

  // Purple
  static const purple500 = Color(0xFFBE57F9);
  static const purple700 = Color(0xFF9049BB);
  static const purple900 = Color(0xFF743998);

  // Yellow
  static const yellow500 = Color(0xFFFFB829);
  static const yellow700 = Color(0xFFC28100);
  static const yellow900 = Color(0xFF8F5F00);
}
