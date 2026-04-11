import 'package:flutter/material.dart';
import 'colors.dart';

/// Color resolution utilities for the 3D press effect.
///
/// Every interactive atom (button, checkbox, radio, etc.) uses a primary
/// accent color for its face and needs darker variants for the border/shadow
/// that creates the illusion of depth.
///
/// - [resolve700] returns the border color for **filled-style** components.
/// - [resolve900] returns the border color for **outline-style** components
///   where stronger contrast against the dark background is needed.
///
/// Both require the input color to exist in the design system palette.
/// If a color is not in the map, the app will crash — this is intentional.
/// It means a color was used that hasn't been added to the design system.

/// Returns the 700 (shadow) variant of a design system color.
Color resolve700(Color color) {
  assert(AppColors.shadow700.containsKey(color),
      '$color is not in AppColors.shadow700 — add it to _shadowDefs in colors.dart');
  return AppColors.shadow700[color]!;
}

/// Returns the 900 (deep shadow) variant of a design system color.
Color resolve900(Color color) {
  assert(AppColors.shadow900.containsKey(color),
      '$color is not in AppColors.shadow900 — add it to _shadowDefs in colors.dart');
  return AppColors.shadow900[color]!;
}
