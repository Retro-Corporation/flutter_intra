import 'package:flutter/material.dart';
import '../../foundation/color/colors.dart';
import 'field_state.dart';
import 'validator_mixin.dart';

/// Mixin: standard text-field molecule lifecycle.
///
/// Wires the text controller listener, optional focus listener (for the
/// card variant's border color), and exposes a shared [cardBorderColor]
/// derived from [effectiveState] + focus.
///
/// Builds on top of [ValidatorMixin] — the widget must expose the 3
/// ValidatorMixin getters plus the 3 below.
mixin FormFieldMixin<T extends StatefulWidget> on State<T>, ValidatorMixin<T> {
  /// The widget's text controller.
  TextEditingController get widgetController;

  /// The widget's focus node.
  FocusNode get widgetFocusNode;

  /// Whether this molecule needs focus tracking. Typically
  /// `widget.variant == InputVariant.card` — flat variants delegate
  /// focus styling to the atom and do not need a listener.
  bool get shouldTrackFocus;

  bool _isFocused = false;

  /// Whether the focus node currently has focus. Only meaningful when
  /// [shouldTrackFocus] is true.
  bool get isFocused => _isFocused;

  @override
  void initState() {
    super.initState();
    widgetController.addListener(_handleTextChanged);
    if (shouldTrackFocus) {
      widgetFocusNode.addListener(_handleFocusChanged);
    }
  }

  @override
  void dispose() {
    widgetController.removeListener(_handleTextChanged);
    if (shouldTrackFocus) {
      widgetFocusNode.removeListener(_handleFocusChanged);
    }
    super.dispose();
  }

  void _handleTextChanged() {
    setState(() {});
    runValidator(widgetController.text);
  }

  void _handleFocusChanged() {
    setState(() => _isFocused = widgetFocusNode.hasFocus);
  }

  /// Card variant border color. Non-default state always wins; otherwise
  /// focused → brand, else → surfaceBorder.
  Color get cardBorderColor {
    if (effectiveState != FieldState.defaultState) return effectiveState.border;
    return _isFocused ? AppColors.brand : AppColors.surfaceBorder;
  }
}
