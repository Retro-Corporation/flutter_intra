import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../atoms/inputs/otp_cell.dart';
import '../../atoms/inputs/otp_cell_types.dart';

/// Molecule: OTP input row — a horizontal sequence of [OtpCell] atoms with
/// focus routing, auto-advance, and backspace handling.
///
/// **Receive-only:** [controllers] and [focusNodes] are owned and disposed
/// by the template above. This molecule wires the routing logic and reports
/// the collected code upward — it never creates or disposes the received nodes.
///
/// Error text below the row is the template's responsibility. This molecule
/// only drives [OtpCellState.error] on the cells themselves via [hasError].
class AppOtpField extends StatefulWidget {
  /// Controllers owned by the template. Length determines cell count.
  final List<TextEditingController> controllers;

  /// Focus nodes owned by the template. Must match [controllers] in length.
  final List<FocusNode> focusNodes;

  /// Fires on every keystroke with the current partial or complete code.
  final ValueChanged<String>? onChanged;

  /// Fires once when every cell is filled.
  final ValueChanged<String>? onCompleted;

  /// When true, all cells render with an error border.
  final bool hasError;

  const AppOtpField({
    super.key,
    required this.controllers,
    required this.focusNodes,
    this.onChanged,
    this.onCompleted,
    this.hasError = false,
  }) : assert(controllers.length == focusNodes.length,
            'controllers and focusNodes must be the same length');

  @override
  State<AppOtpField> createState() => _AppOtpFieldState();
}

class _AppOtpFieldState extends State<AppOtpField> {
  @override
  void initState() {
    super.initState();
    _wireKeyHandlers();
  }

  @override
  void didUpdateWidget(AppOtpField oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.focusNodes != widget.focusNodes) {
      _clearKeyHandlers(oldWidget.focusNodes);
      _wireKeyHandlers();
    }
  }

  @override
  void dispose() {
    _clearKeyHandlers(widget.focusNodes);
    super.dispose();
  }

  void _wireKeyHandlers() {
    for (var i = 0; i < widget.focusNodes.length; i++) {
      widget.focusNodes[i].onKeyEvent = _makeKeyHandler(i);
    }
  }

  void _clearKeyHandlers(List<FocusNode> nodes) {
    for (final fn in nodes) {
      fn.onKeyEvent = null;
    }
  }

  KeyEventResult Function(FocusNode, KeyEvent) _makeKeyHandler(int index) {
    return (node, event) {
      if (event is KeyDownEvent &&
          event.logicalKey == LogicalKeyboardKey.backspace &&
          widget.controllers[index].text.isEmpty &&
          index > 0) {
        widget.controllers[index - 1].clear();
        widget.focusNodes[index - 1].requestFocus();
        return KeyEventResult.handled;
      }
      return KeyEventResult.ignored;
    };
  }

  void _onCellChanged(int index, String value) {
    if (value.length == 1 && index < widget.controllers.length - 1) {
      widget.focusNodes[index + 1].requestFocus();
    }
    final code = widget.controllers.map((c) => c.text).join();
    widget.onChanged?.call(code);
    if (code.length == widget.controllers.length) {
      widget.onCompleted?.call(code);
    }
  }

  @override
  Widget build(BuildContext context) {
    final cellState = widget.hasError ? OtpCellState.error : OtpCellState.empty;

    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        for (var i = 0; i < widget.controllers.length; i++)
          OtpCell(
            controller: widget.controllers[i],
            focusNode: widget.focusNodes[i],
            state: cellState,
            onChanged: (v) => _onCellChanged(i, v),
          ),
      ],
    );
  }
}
