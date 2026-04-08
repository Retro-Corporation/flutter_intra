import 'package:flutter/material.dart';
import 'field_state.dart';

/// Mixin: run an optional validator on text changes, track resulting
/// [FieldState] and error message.
///
/// The widget must expose `validator`, `state`, and `helperText` via
/// the three abstract getters below.
mixin ValidatorMixin<T extends StatefulWidget> on State<T> {
  FieldState? _validatorState;
  String? _validatorMessage;

  /// The widget's optional validator function.
  String? Function(String)? get widgetValidator;

  /// The widget's parent-set FieldState.
  FieldState get widgetState;

  /// The widget's helper text.
  String? get widgetHelperText;

  /// Call from onTextChanged after updating any other state.
  void runValidator(String text) {
    if (widgetValidator == null) return;
    final result = widgetValidator!(text);
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

  /// Resolved state: parent-set state wins unless it's defaultState.
  FieldState get effectiveState =>
      widgetState != FieldState.defaultState
          ? widgetState
          : (_validatorState ?? widgetState);

  /// Resolved helper: validator message wins over widget helperText.
  String? get effectiveHelper => _validatorMessage ?? widgetHelperText;
}
