import 'package:flutter/material.dart';
import '../../atoms/primitives/icon.dart';
import '../../atoms/inputs/text_field.dart';
import '../../atoms/inputs/text_field_3d.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/padding.dart';
import '../../icons/app_icons.dart';
import '../../icons/icon_sizes.dart';
import '../behaviors/field_state.dart';
import '../behaviors/form_field_mixin.dart';
import '../behaviors/validator_mixin.dart';
import 'form_field.dart';
import 'form_field_variant.dart';

/// Molecule: standard text field with label, helper text, and state support.
///
/// Composes [AppFormField] + [AppTextField] (flat) or [AppTextField3D] (card).
class AppTextFieldMolecule extends StatefulWidget {
  final String? label;
  final String? helperText;
  final String? hintText;
  final FieldState state;
  final int? maxLength;
  final String? leadingIcon;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;

  /// Visual style. Defaults to [InputVariant.flat] — no existing callers break.
  final InputVariant variant;

  /// Optional validator. When provided, the molecule auto-manages state:
  /// returns null for success, or an error message string for error.
  /// The returned string replaces [helperText] when in error state.
  final String? Function(String)? validator;

  /// Whether this field is required — shows a red asterisk next to the label.
  final bool isRequired;

  /// Whether to show the clear (✕) button when the field has text.
  /// Defaults to true to preserve existing behaviour.
  final bool showClearButton;

  const AppTextFieldMolecule({
    super.key,
    required this.controller,
    required this.focusNode,
    this.label,
    this.helperText,
    this.hintText,
    this.state = FieldState.defaultState,
    this.maxLength,
    this.leadingIcon,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.variant = InputVariant.flat,
    this.validator,
    this.isRequired = false,
    this.showClearButton = true,
  });

  @override
  State<AppTextFieldMolecule> createState() => _AppTextFieldMoleculeState();
}

class _AppTextFieldMoleculeState extends State<AppTextFieldMolecule>
    with ValidatorMixin, FormFieldMixin {
  @override
  String? Function(String)? get widgetValidator => widget.validator;

  @override
  FieldState get widgetState => widget.state;

  @override
  String? get widgetHelperText => widget.helperText;

  @override
  TextEditingController get widgetController => widget.controller;

  @override
  FocusNode get widgetFocusNode => widget.focusNode;

  @override
  bool get shouldTrackFocus => widget.variant == InputVariant.card;

  void _clear() {
    widget.controller.clear();
    widget.onChanged?.call('');
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

    Widget? suffix;
    if (widget.showClearButton && widget.controller.text.isNotEmpty) {
      suffix = GestureDetector(
        onTap: _clear,
        child: Padding(
          padding: const EdgeInsets.only(right: AppPadding.inputPaddingH),
          child: AppIcon(
            AppIcons.close,
            size: IconSizes.md,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return AppFormField(
      label: widget.label,
      helperText: effectiveHelper,
      state: effectiveState,
      maxLength: widget.maxLength,
      currentLength: widget.controller.text.length,
      isRequired: widget.isRequired,
      child: AppTextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        hintText: widget.hintText,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        keyboardType: widget.keyboardType,
        maxLength: widget.maxLength,
        leadingIcon: widget.leadingIcon,
        borderColor: borderColor,
        focusedBorderColor: isDefault ? null : borderColor,
        textColor: effectiveState.text,
        hintColor: effectiveState.hint,
        enabled: !isDisabled,
        suffixWidget: suffix,
      ),
    );
  }

  Widget _buildCard() {
    final isDisabled = effectiveState == FieldState.disabled;

    Widget? suffix;
    if (widget.showClearButton && widget.controller.text.isNotEmpty) {
      suffix = GestureDetector(
        onTap: _clear,
        child: Padding(
          padding: const EdgeInsets.only(right: AppPadding.inputPaddingH),
          child: AppIcon(
            AppIcons.close,
            size: IconSizes.md,
            color: AppColors.textSecondary,
          ),
        ),
      );
    }

    return AppFormField(
      label: widget.label,
      helperText: effectiveHelper,
      state: effectiveState,
      maxLength: widget.maxLength,
      currentLength: widget.controller.text.length,
      isRequired: widget.isRequired,
      child: AppTextField3D(
        controller: widget.controller,
        focusNode: widget.focusNode,
        hintText: widget.hintText,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        keyboardType: widget.keyboardType,
        maxLength: widget.maxLength,
        borderColor: cardBorderColor,
        enabled: !isDisabled,
        suffixWidget: suffix,
      ),
    );
  }
}
