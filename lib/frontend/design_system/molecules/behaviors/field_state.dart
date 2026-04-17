import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';

/// Visual state for form-field molecules.
///
/// Each case carries its own color tokens for borders, labels, helper text,
/// input text, and hint text. Adding a new state requires only a new enum
/// case — no switches or maps to edit elsewhere.
// TODO(Julian): Decide how to handle the triple-duty overload of
// FieldState.defaultState. This comment flags the issue for your review —
// no code change until you pick a path.
//
// THE PROBLEM
// -----------
// FieldState.defaultState currently carries three distinct meanings in the
// same value, and nothing distinguishes them to callers or to the code that
// reads them:
//
//   1. "Caller didn't pass anything"   — it's the constructor default on
//                                         every input-molecule `state` param.
//   2. "Defer to validator output"     — validator_mixin.dart checks
//                                         `widgetState != FieldState.defaultState`
//                                         to decide whether the validator's
//                                         success/error result should win.
//   3. "Render the neutral visual look" — the actual resting-state colors.
//
// Consequence: a caller who explicitly writes `state: FieldState.defaultState`
// is indistinguishable from a caller who passed nothing. If a feature ever
// needs to force the neutral look while suppressing the validator, there is
// no way to express that today.
//
// This is not a bug. The system works. It's a cohesion smell that was
// flagged in the Level 2 reconstruction audit and re-flagged in Level 3.
//
// OPTIONS
// -------
// A) Document as intentional, close the ticket.
//    No code change. Add a doc comment here stating that defaultState
//    intentionally represents both the constructor default and the neutral
//    visual state. Zero risk, zero churn.
//
// B) Make the `state` param nullable in every input molecule.
//    (Recommended in the Level 3 audit.)
//    - `FieldState state = FieldState.defaultState` becomes `FieldState? state`
//      in text_field_molecule, password_field, text_area, number_field,
//      form_field (and search_bar if applicable).
//    - validator_mixin.dart's `effectiveState` simplifies from
//        `widgetState != FieldState.defaultState ? widgetState : (_validatorState ?? widgetState)`
//      to
//        `widgetState ?? _validatorState ?? FieldState.defaultState`.
//    - The three meanings separate cleanly:
//        null                       → "caller didn't set anything, validator wins"
//        FieldState.defaultState    → "caller explicitly wants neutral, ignore validator"
//        any other case             → "caller forces this look"
//    - ~15 lines across 5 files. Reversible. No catalog edits required.
//
// C) Convert FieldState from an enhanced enum to a sealed class hierarchy.
//    - Each variant becomes its own type (DefaultFieldState, FocusedFieldState,
//      ErrorFieldState, etc.), enabling variant-specific data later
//      (e.g. ErrorFieldState carrying its own error message instead of
//      validator_mixin tracking it in a parallel _validatorMessage field).
//    - 3–4x the lines. Loses enum's free identity-equality. Speculative —
//      no current variant needs heterogeneous data.
//
// See /Users/tavonpowell/.claude/plans/fizzy-rolling-scott.md
// (DEV 3 — Task 2) for full context.
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
