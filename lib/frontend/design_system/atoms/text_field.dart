import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../foundation/colors.dart';
import '../foundation/padding.dart';
import '../foundation/radius.dart';
import '../foundation/typography.dart';
import '../icons/app_icons.dart';
import '../icons/icon_sizes.dart';
import 'icon.dart';

/// Atom: text field with configurable borders, icons, and multiline support.
///
/// Receive-only — requires a [controller] from the molecule or template above.
/// Never creates, owns, or disposes a controller or focus node.
///
/// Visual defaults:
/// - Default border: [AppColors.surfaceBorder]
/// - Focused border: [AppColors.brand]
class AppTextField extends StatelessWidget {
  final TextEditingController controller;
  final String? hintText;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final bool obscureText;

  /// Override the default (unfocused) border color.
  final Color? borderColor;

  /// Override the focused border color.
  final Color? focusedBorderColor;

  /// Override the input text color.
  final Color? textColor;

  /// Override the hint text color.
  final Color? hintColor;

  /// Whether the field is interactive.
  final bool enabled;

  /// Optional leading icon path (e.g. [AppIcons.search]).
  final String? leadingIcon;

  /// Color for the leading icon.
  final Color? leadingIconColor;

  /// Custom suffix widget (e.g. clear icon, visibility toggle).
  final Widget? suffixWidget;

  /// Number of lines for the input. Set > 1 for multiline.
  final int maxLines;

  /// Minimum number of lines (used with [maxLines] for auto-grow).
  final int? minLines;

  /// Override border radius (e.g. [AppRadius.pill] for search bar).
  final double? borderRadius;

  /// Maximum character length.
  final int? maxLength;

  /// Input formatters (e.g. digits only for number fields).
  final List<TextInputFormatter>? inputFormatters;

  const AppTextField({
    super.key,
    required this.controller,
    this.hintText,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.obscureText = false,
    this.borderColor,
    this.focusedBorderColor,
    this.textColor,
    this.hintColor,
    this.enabled = true,
    this.leadingIcon,
    this.leadingIconColor,
    this.suffixWidget,
    this.maxLines = 1,
    this.minLines,
    this.borderRadius,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  Widget build(BuildContext context) {
    final radius = borderRadius ?? AppRadius.sm;
    final bColor = borderColor ?? AppColors.surfaceBorder;
    final fColor = focusedBorderColor ?? AppColors.brand;

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: bColor, width: 1),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: fColor, width: 1),
    );

    final disabledBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(radius),
      borderSide: BorderSide(color: bColor, width: 1),
    );

    final textStyle = AppTypography.body.regular.copyWith(
      color: textColor,
    );

    final hintStyle = AppTypography.body.regular.copyWith(
      color: hintColor ?? AppColors.textSecondary,
    );

    // Resolve prefix (leading icon)
    Widget? prefix;
    if (leadingIcon != null) {
      prefix = Padding(
        padding: EdgeInsets.only(left: AppPadding.inputPaddingH),
        child: AppIcon(
          leadingIcon!,
          size: IconSizes.md,
          color: leadingIconColor ?? AppColors.textSecondary,
        ),
      );
    }

    return TextField(
      controller: controller,
      focusNode: focusNode,
      onChanged: onChanged,
      onSubmitted: onSubmitted,
      keyboardType: keyboardType,
      obscureText: obscureText,
      enabled: enabled,
      maxLines: maxLines,
      minLines: minLines,
      maxLength: maxLength,
      inputFormatters: inputFormatters,
      style: textStyle,
      cursorColor: AppColors.brand,
      // Hide the built-in counter — molecules render their own.
      buildCounter: (context,
              {required currentLength,
              required isFocused,
              required maxLength}) =>
          null,
      decoration: InputDecoration(
        hintText: hintText,
        hintStyle: hintStyle,
        filled: true,
        fillColor: AppColors.surface,
        border: border,
        enabledBorder: border,
        focusedBorder: focusedBorder,
        disabledBorder: disabledBorder,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppPadding.inputPaddingH,
          vertical: AppPadding.inputPaddingV,
        ),
        prefixIcon: prefix,
        prefixIconConstraints: const BoxConstraints(),
        suffixIcon: suffixWidget,
        suffixIconConstraints: const BoxConstraints(),
      ),
    );
  }
}
