import 'package:flutter/material.dart';
import '../atoms/text.dart';
import '../foundation/padding.dart';
import '../foundation/typography.dart';
import 'field_state.dart';

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

  const AppFormField({
    super.key,
    this.label,
    this.helperText,
    this.state = FieldState.defaultState,
    this.maxLength,
    this.minLength,
    this.currentLength = 0,
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
          AppText(
            label!,
            style: AppTypography.bodySmall.semiBold,
            color: labelColor,
          ),
          SizedBox(height: AppPadding.rem025),
        ],

        // ── Input slot ──
        child,

        // ── Helper row ──
        if (showHelperRow) ...[
          SizedBox(height: AppPadding.rem025),
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
