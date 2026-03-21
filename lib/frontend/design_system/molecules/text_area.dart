import 'package:flutter/material.dart';
import '../design_system.dart';

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

class _AppTextAreaState extends State<AppTextArea> {
  late TextEditingController _controller;
  bool _ownsController = false;
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
        maxLength: widget.maxLength,
        maxLines: widget.maxLines,
        minLines: widget.autoGrow ? widget.minLines : widget.maxLines,
        borderColor: borderColor,
        focusedBorderColor: borderColor,
        textColor: FieldStateColors.text(effectiveState),
        hintColor: FieldStateColors.hint(effectiveState),
        enabled: !isDisabled,
        showClearIcon: false,
      ),
    );
  }
}
