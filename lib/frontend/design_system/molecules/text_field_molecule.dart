import 'package:flutter/material.dart';
import '../design_system.dart';

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

class _AppTextFieldMoleculeState extends State<AppTextFieldMolecule> {
  late TextEditingController _controller;
  bool _ownsController = false;
  int _currentLength = 0;

  // Validator-driven state
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
    // Parent-set state takes priority unless it's defaultState and validator
    // has an opinion.
    final effectiveState = widget.state != FieldState.defaultState
        ? widget.state
        : (_validatorState ?? widget.state);

    final effectiveHelper = _validatorMessage ?? widget.helperText;
    final borderColor = FieldStateColors.border(effectiveState);
    final isDisabled = effectiveState == FieldState.disabled;

    return AppFormField(
      label: widget.label,
      helperText: effectiveHelper,
      state: effectiveState,
      maxLength: widget.maxLength,
      currentLength: _currentLength,
      child: AppTextField(
        controller: _controller,
        focusNode: widget.focusNode,
        hintText: widget.hintText,
        onChanged: widget.onChanged,
        onSubmitted: widget.onSubmitted,
        keyboardType: widget.keyboardType,
        maxLength: widget.maxLength,
        leadingIcon: widget.leadingIcon,
        borderColor: borderColor,
        focusedBorderColor: borderColor,
        textColor: FieldStateColors.text(effectiveState),
        hintColor: FieldStateColors.hint(effectiveState),
        enabled: !isDisabled,
      ),
    );
  }
}
