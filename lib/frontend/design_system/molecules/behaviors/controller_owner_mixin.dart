import 'package:flutter/material.dart';

/// Mixin: create-or-accept a [TextEditingController], wire a listener,
/// dispose if owned.
///
/// Also tracks two text metrics derived from the controller:
/// - [currentLength] — number of characters in the field.
/// - [hasText] — whether the field contains any text.
///
/// Molecules use this as a fallback for standalone use (catalog, isolation
/// testing). The primary path is receiving a controller from a template.
mixin ControllerOwnerMixin<T extends StatefulWidget> on State<T> {
  late TextEditingController controller;
  bool _ownsController = false;
  late VoidCallback _listener;

  // ── Text metrics (derived from controller) ──
  int _currentLength = 0;
  int get currentLength => _currentLength;

  bool _hasText = false;
  bool get hasText => _hasText;

  /// The widget's optional external controller, if provided.
  TextEditingController? get externalController;

  /// Called whenever the controller's text changes.
  void onTextChanged();

  void _updateTextMetrics() {
    _currentLength = controller.text.length;
    _hasText = controller.text.isNotEmpty;
  }

  /// Creates or accepts the controller and wires the listener.
  /// Pass [initialText] for fields that need a starting value
  /// (e.g. number field seeding from widget.value).
  void initController({String initialText = ''}) {
    final ext = externalController;
    if (ext != null) {
      controller = ext;
    } else {
      controller = TextEditingController(text: initialText);
      _ownsController = true;
    }
    _updateTextMetrics();
    _listener = () {
      _updateTextMetrics();
      onTextChanged();
    };
    controller.addListener(_listener);
  }

  /// Removes the listener and disposes if owned.
  void disposeController() {
    controller.removeListener(_listener);
    if (_ownsController) controller.dispose();
  }
}
