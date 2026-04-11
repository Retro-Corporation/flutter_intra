import 'package:flutter/material.dart';
import '../../atoms/primitives/icon.dart';
import '../../atoms/inputs/text_field.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/padding.dart';
import '../../icons/app_icons.dart';
import '../../icons/icon_sizes.dart';
import '../behaviors/controller_owner_mixin.dart';
import '../behaviors/field_state.dart';
import 'form_field.dart';
import '../behaviors/validator_mixin.dart';

/// Molecule: standard text field with label, helper text, and state support.
///
/// Composes [AppFormField] + [AppTextField].
class AppTextFieldMolecule extends StatefulWidget {
  final String? label;
  final String? helperText;
  final String? hintText;
  final FieldState state;
  final int? maxLength;
  final String? leadingIcon;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;
  final TextInputType? keyboardType;

  /// Optional validator. When provided, the molecule auto-manages state:
  /// returns null for success, or an error message string for error.
  /// The returned string replaces [helperText] when in error state.
  final String? Function(String)? validator;

  const AppTextFieldMolecule({
    super.key,
    this.label,
    this.helperText,
    this.hintText,
    this.state = FieldState.defaultState,
    this.maxLength,
    this.leadingIcon,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.keyboardType,
    this.validator,
  });

  @override
  State<AppTextFieldMolecule> createState() => _AppTextFieldMoleculeState();
}

class _AppTextFieldMoleculeState extends State<AppTextFieldMolecule>
    with ControllerOwnerMixin, ValidatorMixin {
  @override
  TextEditingController? get externalController => widget.controller;

  @override
  String? Function(String)? get widgetValidator => widget.validator;

  @override
  FieldState get widgetState => widget.state;

  @override
  String? get widgetHelperText => widget.helperText;

  @override
  void onTextChanged() {
    setState(() {});
    runValidator(controller.text);
  }

  @override
  void initState() {
    super.initState();
    initController();
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }

  void _clear() {
    controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    final borderColor = effectiveState.border;
    final isDefault = effectiveState == FieldState.defaultState;
    final isDisabled = effectiveState == FieldState.disabled;

    // Clear icon — shown when text is present.
    Widget? suffix;
    if (hasText) {
      suffix = GestureDetector(
        onTap: _clear,
        child: const Padding(
          padding: EdgeInsets.only(right: AppPadding.inputPaddingH),
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
      currentLength: currentLength,
      child: AppTextField(
        controller: controller,
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
}
