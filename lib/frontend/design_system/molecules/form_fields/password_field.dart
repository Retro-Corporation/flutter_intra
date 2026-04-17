import 'package:flutter/material.dart';
import '../../atoms/primitives/icon.dart';
import '../../atoms/inputs/text_field.dart';
import '../../atoms/inputs/text_field_3d.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/padding.dart';
import '../../icons/app_icons.dart';
import '../../icons/icon_sizes.dart';
import '../behaviors/field_state.dart';
import 'form_field.dart';
import 'form_field_variant.dart';
import '../behaviors/validator_mixin.dart';

/// Molecule: password field with visibility toggle, label, helper text,
/// and character count.
///
/// Supports [minLength] (e.g. minimum 7 characters) — passwords typically
/// have a minimum requirement, not a maximum.
class AppPasswordField extends StatefulWidget {
  final String? label;
  final String? helperText;
  final String? hintText;
  final FieldState state;

  /// Minimum character length — shows "current/min" counter.
  final int? minLength;

  /// Maximum character length — shows "current/max" counter.
  /// Most password fields use [minLength] instead.
  final int? maxLength;

  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;

  /// Visual style. Defaults to [InputVariant.flat] — no existing callers break.
  final InputVariant variant;

  /// Optional validator — returns null for success, or an error string.
  final String? Function(String)? validator;

  const AppPasswordField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.label,
    this.helperText,
    this.hintText,
    this.state = FieldState.defaultState,
    this.minLength,
    this.maxLength,
    this.onChanged,
    this.variant = InputVariant.flat,
    this.validator,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField>
    with ValidatorMixin {
  bool _obscured = true;
  bool _isFocused = false;

  @override
  String? Function(String)? get widgetValidator => widget.validator;

  @override
  FieldState get widgetState => widget.state;

  @override
  String? get widgetHelperText => widget.helperText;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    if (widget.variant == InputVariant.card) {
      widget.focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    if (widget.variant == InputVariant.card) {
      widget.focusNode.removeListener(_onFocusChanged);
    }
    super.dispose();
  }

  void _onTextChanged() {
    setState(() {});
    runValidator(widget.controller.text);
  }

  void _onFocusChanged() =>
      setState(() => _isFocused = widget.focusNode.hasFocus);

  Color get _cardBorderColor {
    if (effectiveState != FieldState.defaultState) return effectiveState.border;
    return _isFocused ? AppColors.brand : AppColors.surfaceBorder;
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.variant) {
      InputVariant.flat => _buildFlat(),
      InputVariant.card => _buildCard(),
    };
  }

  Widget _buildFlat() {
    final borderColor = effectiveState.border;
    final isDefault = effectiveState == FieldState.defaultState;
    final isDisabled = effectiveState == FieldState.disabled;

    final eyeIcon = GestureDetector(
      onTap: isDisabled ? null : () => setState(() => _obscured = !_obscured),
      child: Padding(
        padding: const EdgeInsets.only(right: AppPadding.inputPaddingH),
        child: AppIcon(
          _obscured ? AppIcons.eye : AppIcons.eyeOff,
          size: IconSizes.md,
          color: isDisabled ? AppColors.grey600 : AppColors.textSecondary,
        ),
      ),
    );

    return AppFormField(
      label: widget.label,
      helperText: effectiveHelper,
      state: effectiveState,
      minLength: widget.minLength,
      maxLength: widget.maxLength,
      currentLength: widget.controller.text.length,
      child: AppTextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        hintText: widget.hintText,
        onChanged: widget.onChanged,
        obscureText: _obscured,
        maxLength: widget.maxLength,
        borderColor: borderColor,
        focusedBorderColor: isDefault ? null : borderColor,
        textColor: effectiveState.text,
        hintColor: effectiveState.hint,
        enabled: !isDisabled,
        suffixWidget: eyeIcon,
      ),
    );
  }

  Widget _buildCard() {
    final isDisabled = effectiveState == FieldState.disabled;

    final eyeIcon = GestureDetector(
      onTap: isDisabled ? null : () => setState(() => _obscured = !_obscured),
      child: Padding(
        padding: const EdgeInsets.only(right: AppPadding.inputPaddingH),
        child: AppIcon(
          _obscured ? AppIcons.eye : AppIcons.eyeOff,
          size: IconSizes.md,
          color: isDisabled ? AppColors.grey600 : AppColors.textSecondary,
        ),
      ),
    );

    return AppFormField(
      label: widget.label,
      helperText: effectiveHelper,
      state: effectiveState,
      minLength: widget.minLength,
      maxLength: widget.maxLength,
      currentLength: widget.controller.text.length,
      child: AppTextField3D(
        controller: widget.controller,
        focusNode: widget.focusNode,
        hintText: widget.hintText,
        onChanged: widget.onChanged,
        obscureText: _obscured,
        maxLength: widget.maxLength,
        borderColor: _cardBorderColor,
        enabled: !isDisabled,
        suffixWidget: eyeIcon,
      ),
    );
  }
}
