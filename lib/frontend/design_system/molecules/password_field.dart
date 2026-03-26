import 'package:flutter/material.dart';
import '../atoms/icon.dart';
import '../atoms/text_field.dart';
import '../foundation/colors.dart';
import '../foundation/padding.dart';
import '../icons/app_icons.dart';
import '../icons/icon_sizes.dart';
import 'field_state.dart';
import 'form_field.dart';

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

class _AppPasswordFieldState extends State<AppPasswordField> {
  late TextEditingController _controller;
  bool _ownsController = false;
  bool _obscured = true;
  int _currentLength = 0;

  FieldState? _validatorState;
  String? _validatorMessage;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    _currentLength = _controller.text.length;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final text = _controller.text;
    setState(() {
      _currentLength = text.length;
    });
    _runValidator(text);
  }

  void _runValidator(String text) {
    if (widget.validator == null) return;
    final result = widget.validator!(text);
    setState(() {
      if (text.isEmpty) {
        _validatorState = null;
        _validatorMessage = null;
      } else if (result != null) {
        _validatorState = FieldState.error;
        _validatorMessage = result;
      } else {
        _validatorState = FieldState.success;
        _validatorMessage = null;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final effectiveState = widget.state != FieldState.defaultState
        ? widget.state
        : (_validatorState ?? widget.state);

    final effectiveHelper = _validatorMessage ?? widget.helperText;
    final borderColor = FieldStateColors.border(effectiveState);
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
      currentLength: _currentLength,
      child: AppTextField(
        controller: _controller,
        focusNode: widget.focusNode,
        hintText: widget.hintText,
        onChanged: widget.onChanged,
        obscureText: _obscured,
        maxLength: widget.maxLength,
        borderColor: borderColor,
        focusedBorderColor: borderColor,
        textColor: FieldStateColors.text(effectiveState),
        hintColor: FieldStateColors.hint(effectiveState),
        enabled: !isDisabled,
        suffixWidget: eyeIcon,
        showClearIcon: false,
      ),
    );
  }
}
