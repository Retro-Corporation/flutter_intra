import 'package:flutter/material.dart';

/// Mixin: press state management for interactive atoms without toggle.
///
/// Provides [pressed] and GestureDetector handlers.
/// Subclass implements [isInteractive] and [onTapAction].
mixin PressStateMixin<T extends StatefulWidget> on State<T> {
  bool _pressed = false;
  bool get pressed => _pressed;

  /// Whether the widget currently accepts taps.
  bool get isInteractive;

  /// Called after press release — each atom implements its own action.
  void onTapAction();

  void handleTapDown(TapDownDetails _) => setState(() => _pressed = true);

  void handleTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
    onTapAction();
  }

  void handleTapCancel() => setState(() => _pressed = false);
}
