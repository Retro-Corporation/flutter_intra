import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../atoms/inputs/text_field.dart';
import '../../atoms/inputs/text_field_3d.dart';
import '../behaviors/field_state.dart';
import '../behaviors/form_field_mixin.dart';
import '../behaviors/validator_mixin.dart';
import 'form_field.dart';
import 'form_field_variant.dart';

/// Molecule: phone number field with automatic `(XXX) XXX-XXXX` formatting
/// and 10-digit validation.
///
/// Mirrors [AppPasswordField] — same mixin chain, same [AppFormField] wrapper,
/// same [InputVariant] (flat/card) support. No suffix widget needed.
///
/// Receive-only for controller and focus node — the template above owns them.
class AppPhoneField extends StatefulWidget {
  final String? label;
  final String? helperText;
  final String? hintText;
  final FieldState state;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;

  /// Visual style. Defaults to [InputVariant.flat].
  final InputVariant variant;

  /// Optional validator — overrides the built-in 10-digit check.
  /// Returns null for success, or an error string.
  final String? Function(String)? validator;

  /// Whether this field is required — shows a red asterisk next to the label.
  final bool isRequired;

  const AppPhoneField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.label,
    this.helperText,
    this.hintText,
    this.state = FieldState.defaultState,
    this.onChanged,
    this.variant = InputVariant.flat,
    this.validator,
    this.isRequired = false,
  });

  @override
  State<AppPhoneField> createState() => _AppPhoneFieldState();
}

class _AppPhoneFieldState extends State<AppPhoneField>
    with ValidatorMixin, FormFieldMixin {
  /// Built-in validator: empty → no error; < 10 digits → error; 10 digits → valid.
  String? _defaultValidator(String value) {
    final digits = value.replaceAll(RegExp(r'\D'), '');
    if (digits.isEmpty) return null;
    if (digits.length < 10) return 'Please enter a valid 10-digit phone number';
    return null;
  }

  @override
  String? Function(String)? get widgetValidator =>
      widget.validator ?? _defaultValidator;

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
      isRequired: widget.isRequired,
      child: AppTextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        hintText: widget.hintText,
        onChanged: widget.onChanged,
        keyboardType: TextInputType.phone,
        inputFormatters: [_PhoneNumberFormatter()],
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
      isRequired: widget.isRequired,
      child: AppTextField3D(
        controller: widget.controller,
        focusNode: widget.focusNode,
        hintText: widget.hintText,
        onChanged: widget.onChanged,
        keyboardType: TextInputType.phone,
        inputFormatters: [_PhoneNumberFormatter()],
        borderColor: cardBorderColor,
        enabled: !isDisabled,
      ),
    );
  }
}

// ─────────────────────────────────────────────────────────────────────────────
// Formatter — private to this file (CCP: formatting logic changes with the field)
// ─────────────────────────────────────────────────────────────────────────────

class _PhoneNumberFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    final digits = newValue.text.replaceAll(RegExp(r'\D'), '');
    final capped = digits.length > 10 ? digits.substring(0, 10) : digits;

    final String formatted;
    if (capped.isEmpty) {
      formatted = '';
    } else if (capped.length <= 3) {
      formatted = '($capped';
    } else if (capped.length <= 6) {
      formatted = '(${capped.substring(0, 3)}) ${capped.substring(3)}';
    } else {
      formatted =
          '(${capped.substring(0, 3)}) ${capped.substring(3, 6)}-${capped.substring(6)}';
    }

    return TextEditingValue(
      text: formatted,
      selection: TextSelection.collapsed(offset: formatted.length),
    );
  }
}
