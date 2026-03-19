import 'package:flutter/material.dart';
import '../design_system.dart';

/// Atom: single-line text field with two visual states.
///
/// - Default: [AppColors.surfaceBorder] border
/// - Focused: [AppColors.brand] border
///
/// Shows a clear (close) icon when text is present.
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

  const AppTextField({
    super.key,
    this.hintText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.obscureText = false,
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
    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: const BorderSide(
        color: AppColors.surfaceBorder,
        width: 1,
      ),
    );

    final focusedBorder = OutlineInputBorder(
      borderRadius: BorderRadius.circular(AppRadius.sm),
      borderSide: const BorderSide(
        color: AppColors.brand,
        width: 1,
      ),
    );

    return TextField(
      controller: _controller,
      focusNode: _focusNode,
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      keyboardType: widget.keyboardType,
      obscureText: widget.obscureText,
      style: AppTypography.body.regular,
      cursorColor: AppColors.brand,
      decoration: InputDecoration(
        hintText: widget.hintText,
        hintStyle: AppTypography.body.regular.copyWith(
          color: AppColors.textSecondary,
        ),
        filled: true,
        fillColor: AppColors.surface,
        border: border,
        enabledBorder: border,
        focusedBorder: focusedBorder,
        contentPadding: EdgeInsets.symmetric(
          horizontal: AppPadding.inputPaddingH,
          vertical: AppPadding.inputPaddingV,
        ),
        suffixIcon: _hasText
            ? GestureDetector(
                onTap: _clear,
                child: Padding(
                  padding: EdgeInsets.only(right: AppPadding.inputPaddingH),
                  child: AppIcon(
                    AppIcons.close,
                    size: IconSizes.md,
                    color: AppColors.textSecondary,
                  ),
                ),
              )
            : null,
        suffixIconConstraints: const BoxConstraints(),
      ),
    );
  }
}
