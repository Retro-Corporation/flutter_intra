import 'package:flutter/material.dart';

/// Mixin: focus node create-or-accept + focus state tracking.
///
/// Mix into a [State] class to gain:
/// - [effectiveFocusNode] — uses the external node if provided, otherwise
///   lazily creates and owns one.
/// - [isFocused] — `true` while [effectiveFocusNode] has focus.
/// - [initFocusOwner] / [disposeFocusOwner] — lifecycle hooks.
///
/// Usage pattern (card variant only — skip for flat):
/// ```dart
/// @override
/// FocusNode? get externalFocusNode => widget.focusNode;
///
/// @override
/// void initState() {
///   super.initState();
///   if (widget.variant == InputVariant.card) initFocusOwner();
/// }
///
/// @override
/// void dispose() {
///   if (widget.variant == InputVariant.card) disposeFocusOwner();
///   super.dispose();
/// }
/// ```
mixin FocusOwnerMixin<T extends StatefulWidget> on State<T> {
  FocusNode? _ownedFocusNode;
  bool isFocused = false;

  /// Override to return the widget's external focus node (may be null).
  FocusNode? get externalFocusNode;

  /// The focus node in use — external if provided, otherwise a lazily-created
  /// owned node. Always valid after [initFocusOwner] is called.
  FocusNode get effectiveFocusNode =>
      externalFocusNode ?? (_ownedFocusNode ??= FocusNode());

  void _onFocusChange() =>
      setState(() => isFocused = effectiveFocusNode.hasFocus);

  /// Attaches the focus listener. Call from [State.initState].
  void initFocusOwner() =>
      effectiveFocusNode.addListener(_onFocusChange);

  /// Removes the focus listener and disposes any owned node.
  /// Call from [State.dispose] before `super.dispose()`.
  void disposeFocusOwner() {
    effectiveFocusNode.removeListener(_onFocusChange);
    _ownedFocusNode?.dispose();
    _ownedFocusNode = null;
  }
}
