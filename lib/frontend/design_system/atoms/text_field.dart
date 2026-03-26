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
/// Visual defaults:
/// - Default border: [AppColors.surfaceBorder]
/// - Focused border: [AppColors.brand]
///
/// Shows a clear (close) icon when text is present (unless [showClearIcon]
/// is false or a custom [suffixWidget] is provided).
///
/// Manages its own [TextEditingController] and [FocusNode] by default,
/// but accepts optional external overrides.
class AppTextField extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;
  final bool obscureText;

  // ── New props for molecule composition ──

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

  /// Custom suffix widget (replaces the default clear icon).
  final Widget? suffixWidget;

  /// Whether to show the built-in clear icon. Ignored when [suffixWidget]
  /// is provided. Defaults to true.
  final bool showClearIcon;

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
    this.hintText,
    this.controller,
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
    this.showClearIcon = true,
    this.maxLines = 1,
    this.minLines,
    this.borderRadius,
    this.maxLength,
    this.inputFormatters,
  });

  @override
  State<AppTextField> createState() => _AppTextFieldState();
}

class _AppTextFieldState extends State<AppTextField> {
  late final TextEditingController _controller;
  late final FocusNode _focusNode;
  bool _ownsController = false;
  bool _ownsFocusNode = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    if (widget.focusNode != null) {
      _focusNode = widget.focusNode!;
    } else {
      _focusNode = FocusNode();
      _ownsFocusNode = true;
    }
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_ownsController) _controller.dispose();
    if (_ownsFocusNode) _focusNode.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final radius = widget.borderRadius ?? AppRadius.sm;
    final bColor = widget.borderColor ?? AppColors.surfaceBorder;
    final fColor = widget.focusedBorderColor ?? AppColors.brand;

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
      color: widget.textColor,
    );

    final hintStyle = AppTypography.body.regular.copyWith(
      color: widget.hintColor ?? AppColors.textSecondary,
    );

    // Resolve suffix: custom widget > clear icon > nothing
    Widget? suffix;
    if (widget.suffixWidget != null) {
      suffix = widget.suffixWidget;
    } else if (widget.showClearIcon && _hasText) {
      suffix = GestureDetector(
        onTap: _clear,
        child: Padding(
          padding: EdgeInsets.only(right: AppPadding.inputPaddingH),
          child: AppIcon(
            AppIcons.close,
            size: IconSizes.md,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    // Resolve prefix (leading icon)
    Widget? prefix;
    if (widget.leadingIcon != null) {
      prefix = Padding(
        padding: EdgeInsets.only(left: AppPadding.inputPaddingH),
        child: AppIcon(
          widget.leadingIcon!,
          size: IconSizes.md,
          color: widget.leadingIconColor ?? AppColors.textSecondary,
        ),
      );
    }

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      enabled: widget.enabled,
      maxLines: widget.maxLines,
      minLines: widget.minLines,
      maxLength: widget.maxLength,
      inputFormatters: widget.inputFormatters,
      style: textStyle,
      cursorColor: AppColors.brand,
      // Hide the built-in counter — molecules render their own.
      buildCounter: (context,
              {required currentLength,
              required isFocused,
              required maxLength}) =>
          null,
      decoration: InputDecoration(
        hintText: widget.hintText,
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
        suffixIcon: suffix,
        suffixIconConstraints: const BoxConstraints(),
      ),
    );
  }
}
