import 'package:flutter/material.dart';
import '../atoms/text_field.dart';
import 'controller_owner_mixin.dart';
import 'field_state.dart';
import 'form_field.dart';
import 'validator_mixin.dart';

/// Molecule: multiline text area with label, helper text, and optional
/// auto-grow.
///
/// - Fixed mode (default): shows exactly [maxLines] rows.
/// - Auto-grow mode: starts at [minLines] and expands up to [maxLines].
class AppTextArea extends StatefulWidget {
  final String? label;
  final String? helperText;
  final String? hintText;
  final FieldState state;
  final int? maxLength;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;

  /// Minimum visible lines (used when [autoGrow] is true).
  final int minLines;

  /// Maximum visible lines.
  final int maxLines;

  /// When true, the field starts at [minLines] height and grows to
  /// [maxLines] as the user types. When false, it stays at [maxLines].
  final bool autoGrow;

  /// Optional validator — returns null for success, or an error string.
  final String? Function(String)? validator;

  const AppTextArea({
    super.key,
    this.label,
    this.helperText,
    this.hintText,
    this.state = FieldState.defaultState,
    this.maxLength,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.minLines = 3,
    this.maxLines = 5,
    this.autoGrow = false,
    this.validator,
  });

  @override
  State<AppTextArea> createState() => _AppTextAreaState();
}

class _AppTextAreaState extends State<AppTextArea>
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

  @override
  Widget build(BuildContext context) {
    final borderColor = FieldStateColors.border(effectiveState);
    final isDefault = effectiveState == FieldState.defaultState;
    final isDisabled = effectiveState == FieldState.disabled;

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
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        minLines: widget.autoGrow ? widget.minLines : widget.maxLines,
        borderColor: borderColor,
        focusedBorderColor: isDefault ? null : borderColor,
        textColor: FieldStateColors.text(effectiveState),
        hintColor: FieldStateColors.hint(effectiveState),
        enabled: !isDisabled,
      ),
    );
  }
}
