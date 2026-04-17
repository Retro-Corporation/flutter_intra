import 'package:flutter/material.dart';
import '../../atoms/inputs/text_field.dart';
import '../../atoms/inputs/text_field_3d.dart';
import '../../foundation/color/colors.dart';
import '../behaviors/field_state.dart';
import 'form_field.dart';
import 'form_field_variant.dart';
import '../behaviors/validator_mixin.dart';

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
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;

  /// Minimum visible lines (used when [autoGrow] is true).
  final int minLines;

  /// Maximum visible lines.
  final int maxLines;

  /// When true, the field starts at [minLines] height and grows to
  /// [maxLines] as the user types. When false, it stays at [maxLines].
  final bool autoGrow;

  /// Visual style. Defaults to [InputVariant.flat] — no existing callers break.
  final InputVariant variant;

  /// Optional validator — returns null for success, or an error string.
  final String? Function(String)? validator;

  const AppTextArea({
    super.key,
    required this.controller,
    required this.focusNode,
    this.label,
    this.helperText,
    this.hintText,
    this.state = FieldState.defaultState,
    this.maxLength,
    this.onChanged,
    this.minLines = 3,
    this.maxLines = 5,
    this.autoGrow = false,
    this.variant = InputVariant.flat,
    this.validator,
  });

  @override
  State<AppTextArea> createState() => _AppTextAreaState();
}

class _AppTextAreaState extends State<AppTextArea> with ValidatorMixin {
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

    return AppFormField(
      label: widget.label,
      helperText: effectiveHelper,
      state: effectiveState,
      maxLength: widget.maxLength,
      currentLength: widget.controller.text.length,
      child: AppTextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        hintText: widget.hintText,
        onChanged: widget.onChanged,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        minLines: widget.autoGrow ? widget.minLines : widget.maxLines,
        borderColor: borderColor,
        focusedBorderColor: isDefault ? null : borderColor,
        textColor: effectiveState.text,
        hintColor: effectiveState.hint,
        enabled: !isDisabled,
      ),
    );
  }

  Widget _buildCard() {
    final isDisabled = effectiveState == FieldState.disabled;

    return AppFormField(
      label: widget.label,
      helperText: effectiveHelper,
      state: effectiveState,
      maxLength: widget.maxLength,
      currentLength: widget.controller.text.length,
      child: AppTextField3D(
        controller: widget.controller,
        focusNode: widget.focusNode,
        hintText: widget.hintText,
        onChanged: widget.onChanged,
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        minLines: widget.autoGrow ? widget.minLines : widget.maxLines,
        borderColor: _cardBorderColor,
        enabled: !isDisabled,
      ),
    );
  }
}
