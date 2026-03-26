import 'package:flutter/material.dart';
import '../foundation/colors.dart';

/// Visual state for form-field molecules.
enum FieldState {
  defaultState,
  focused,
  error,
  success,
  disabled,
}

/// Resolves [FieldState] → design-system colors for borders, labels,
/// and helper text.
class FieldStateColors {
  FieldStateColors._();

  static Color border(FieldState state) {
    switch (state) {
      case FieldState.defaultState:
        return AppColors.surfaceBorder;
      case FieldState.focused:
        return AppColors.brand;
      case FieldState.error:
        return AppColors.red500;
      case FieldState.success:
        return AppColors.green500;
      case FieldState.disabled:
        return AppColors.grey700;
    }
  }

  static Color label(FieldState state) {
    switch (state) {
      case FieldState.defaultState:
      case FieldState.focused:
        return AppColors.textPrimary;
      case FieldState.error:
        return AppColors.red500;
      case FieldState.success:
        return AppColors.green500;
      case FieldState.disabled:
        return AppColors.grey600;
    }
  }

  static Color helper(FieldState state) {
    switch (state) {
      case FieldState.defaultState:
      case FieldState.focused:
        return AppColors.textSecondary;
      case FieldState.error:
        return AppColors.red500;
      case FieldState.success:
        return AppColors.green500;
      case FieldState.disabled:
        return AppColors.grey600;
    }
  }

  static Color text(FieldState state) {
    switch (state) {
      case FieldState.disabled:
        return AppColors.grey600;
      default:
        return AppColors.textPrimary;
    }
  }

  static Color hint(FieldState state) {
    switch (state) {
      case FieldState.disabled:
        return AppColors.grey700;
      default:
        return AppColors.textSecondary;
    }
  }
}
