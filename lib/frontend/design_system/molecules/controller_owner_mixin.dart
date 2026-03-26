import 'package:flutter/material.dart';

/// Mixin: create-or-accept a [TextEditingController], wire a listener,
/// dispose if owned.
///
/// Molecules use this as a fallback for standalone use (catalog, isolation
/// testing). The primary path is receiving a controller from a template.
mixin ControllerOwnerMixin<T extends StatefulWidget> on State<T> {
  late TextEditingController controller;
  bool _ownsController = false;

  /// The widget's optional external controller, if provided.
  TextEditingController? get externalController;

  /// Called whenever the controller's text changes.
  void onTextChanged();

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
    controller.addListener(onTextChanged);
  }

  /// Removes the listener and disposes if owned.
  void disposeController() {
    controller.removeListener(onTextChanged);
    if (_ownsController) controller.dispose();
  }
}
