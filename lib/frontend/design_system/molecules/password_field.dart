import 'package:flutter/material.dart';
import '../atoms/icon.dart';
import '../atoms/text_field.dart';
import '../foundation/colors.dart';
import '../foundation/padding.dart';
import '../icons/app_icons.dart';
import '../icons/icon_sizes.dart';
import 'controller_owner_mixin.dart';
import 'field_state.dart';
import 'form_field.dart';
import 'validator_mixin.dart';

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

  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  /// Optional validator — returns null for success, or an error string.
  final String? Function(String)? validator;

  const AppPasswordField({
    super.key,
    this.label,
    this.helperText,
    this.hintText,
    this.state = FieldState.defaultState,
    this.minLength,
    this.maxLength,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.validator,
  });

  @override
  State<AppPasswordField> createState() => _AppPasswordFieldState();
}

class _AppPasswordFieldState extends State<AppPasswordField>
    with ControllerOwnerMixin, ValidatorMixin {
  bool _obscured = true;

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

  @override
  Widget build(BuildContext context) {
    final borderColor = FieldStateColors.border(effectiveState);
    final isDefault = effectiveState == FieldState.defaultState;
    final isDisabled = effectiveState == FieldState.disabled;

    final eyeIcon = GestureDetector(
      onTap: isDisabled ? null : () => setState(() => _obscured = !_obscured),
      child: Padding(
        padding: EdgeInsets.only(right: AppPadding.inputPaddingH),
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
      currentLength: currentLength,
      child: AppTextField(
        controller: controller,
        focusNode: widget.focusNode,
        hintText: widget.hintText,
        onChanged: widget.onChanged,
        obscureText: _obscured,
        maxLength: widget.maxLength,
        borderColor: borderColor,
        focusedBorderColor: isDefault ? null : borderColor,
        textColor: FieldStateColors.text(effectiveState),
        hintColor: FieldStateColors.hint(effectiveState),
        enabled: !isDisabled,
        suffixWidget: eyeIcon,
      ),
    );
  }
}
