import 'package:flutter/material.dart';
import '../../atoms/primitives/text.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/padding.dart';
import '../../foundation/type/typography.dart';
import '../behaviors/field_state.dart';

// ─────────────────────────────────────────────────────────────────────────────
// Form field family — contract + visual tiers
// ─────────────────────────────────────────────────────────────────────────────
//
// A molecule belongs in `form_fields/` if and only if it satisfies all 5
// points of the MINIMUM CONTRACT:
//
//   1. Holds a typed value
//   2. Receives controller / focus externally
//   3. Reports changes upward via callback
//   4. Accepts an external state override
//   5. Resolves a single `effectiveState` from an authoritative source
//      (parent-set state wins unless `defaultState`; otherwise validator wins)
//
// Contract points #1–#4 live on each widget's constructor. Point #5 is
// abstracted into `ValidatorMixin` (molecules/behaviors/validator_mixin.dart);
// the lifecycle plumbing that drives it lives in `FormFieldMixin`
// (molecules/behaviors/form_field_mixin.dart).
//
// Every form field renders within the 6-TIER VISUAL SYSTEM:
//
//   Tier 1 — Required visual      state → border / text / hint color, disabled
//                                  → owned by `FieldState` (behaviors/field_state.dart)
//   Tier 2 — State feedback       error message replaces helper text
//                                  → owned by `ValidatorMixin.effectiveHelper`
//   Tier 3 — Identification       label, required indicator, helper text
//                                  → owned by this file (`AppFormField`)
//   Tier 4 — Constraint feedback  char counter (min / max)
//                                  → owned by this file (`AppFormField`)
//   Tier 5 — Input affordances    suffix widgets (clear, eye, stepper, etc.)
//                                  → per-molecule by design
//   Tier 6 — Variant dimensions   flat / card
//                                  → `InputVariant` enum + per-molecule switch;
//                                    card's focus-aware border lives in
//                                    `FormFieldMixin.cardBorderColor`
//
// ─────────────────────────────────────────────────────────────────────────────

/// Base molecule that wraps any input widget with a label, helper text,
/// and optional character count. Used by all text-field molecule variants
/// (except [AppSearchBar]).
class AppFormField extends StatelessWidget {
  /// Label displayed above the input.
  final String? label;

  /// Helper text displayed below the input.
  final String? helperText;

  /// Visual state that drives label, helper, and border colors.
  final FieldState state;

  /// Maximum character length — shows "current/max" counter.
  final int? maxLength;

  /// Minimum character length — shows "current/min" counter.
  /// Use for fields like passwords that require a minimum length.
  final int? minLength;

  /// Current character count (used with [maxLength] or [minLength]).
  final int currentLength;

  /// The input widget (e.g. an [AppTextField]).
  final Widget child;

  /// Whether this field is required — renders a red asterisk next to the label.
  /// Muted to the label color when [state] is [FieldState.disabled].
  final bool isRequired;

  const AppFormField({
    super.key,
    this.label,
    this.helperText,
    this.state = FieldState.defaultState,
    this.maxLength,
    this.minLength,
    this.currentLength = 0,
    this.isRequired = false,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    final labelColor = state.label;
    final helperColor = state.helper;
    final hasCount = maxLength != null || minLength != null;
    final showHelperRow = helperText != null || hasCount;

    // Build count string: "current/max" or "current/min"
    String? countText;
    if (maxLength != null) {
      countText = '$currentLength/$maxLength';
    } else if (minLength != null) {
      countText = '$currentLength/$minLength';
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        // ── Label ──
        if (label != null) ...[
          Row(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              AppText(
                label!,
                style: AppTypography.bodySmall.semiBold,
                color: labelColor,
              ),
              if (isRequired)
                AppText(
                  ' *',
                  style: AppTypography.bodySmall.semiBold,
                  color: state == FieldState.disabled
                      ? labelColor
                      : AppColors.error,
                ),
            ],
          ),
          const SizedBox(height: AppPadding.rem025),
        ],

        // ── Input slot ──
        child,

        // ── Helper row ──
        if (showHelperRow) ...[
          const SizedBox(height: AppPadding.rem025),
          Row(
            children: [
              if (helperText != null)
                Expanded(
                  child: AppText(
                    helperText!,
                    style: AppTypography.bodySmall.regular,
                    color: helperColor,
                  ),
                )
              else
                const Spacer(),
              if (countText != null)
                AppText(
                  countText,
                  style: AppTypography.bodySmall.regular,
                  color: helperColor,
                ),
            ],
          ),
        ],
      ],
    );
  }
}
