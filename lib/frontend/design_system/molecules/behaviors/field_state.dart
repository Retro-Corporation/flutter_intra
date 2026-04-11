import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';

/// Visual state for form-field molecules.
///
/// Each case carries its own color tokens for borders, labels, helper text,
/// input text, and hint text. Adding a new state requires only a new enum
/// case — no switches or maps to edit elsewhere.
enum FieldState {
  defaultState(
    border: AppColors.surfaceBorder,
    label: AppColors.textPrimary,
    helper: AppColors.textSecondary,
    text: AppColors.textPrimary,
    hint: AppColors.textSecondary,
  ),
  focused(
    border: AppColors.brand,
    label: AppColors.textPrimary,
    helper: AppColors.textSecondary,
    text: AppColors.textPrimary,
    hint: AppColors.textSecondary,
  ),
  error(
    border: AppColors.red500,
    label: AppColors.red500,
    helper: AppColors.red500,
    text: AppColors.textPrimary,
    hint: AppColors.textSecondary,
  ),
  success(
    border: AppColors.green500,
    label: AppColors.green500,
    helper: AppColors.green500,
    text: AppColors.textPrimary,
    hint: AppColors.textSecondary,
  ),
  disabled(
    border: AppColors.grey700,
    label: AppColors.grey600,
    helper: AppColors.grey600,
    text: AppColors.grey600,
    hint: AppColors.grey700,
  );

  const FieldState({
    required this.border,
    required this.label,
    required this.helper,
    required this.text,
    required this.hint,
  });

  final Color border;
  final Color label;
  final Color helper;
  final Color text;
  final Color hint;
}
