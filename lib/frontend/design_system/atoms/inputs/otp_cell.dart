import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/space/stroke.dart';
import '../../foundation/type/typography.dart';
import 'otp_cell_types.dart';

/// Atom: single OTP digit cell — a styled single-character text field.
///
/// Wraps Flutter's [TextField] with design-system decoration.
/// Receive-only: [controller] and [focusNode] are owned by the molecule
/// above ([AppOtpField]). Focus routing, auto-advance, and backspace
/// handling are the molecule's responsibility — this atom only manages
/// its own visual rendering and character input.
///
/// [state] controls the border override:
/// - [OtpCellState.error] → [AppColors.error] border in all focus states.
/// - All other states → [AppColors.surfaceBorder] unfocused,
///   [AppColors.brand] focused (TextField native decoration).
class OtpCell extends StatelessWidget {
  /// Controller owned by the molecule above.
  final TextEditingController controller;

  /// Focus node owned by the molecule above.
  final FocusNode focusNode;

  /// Visual state. Only [OtpCellState.error] changes decoration;
  /// focus and filled visuals are handled by [TextField] natively.
  final OtpCellState state;

  /// Fired on each character change. Molecule uses this for auto-advance.
  final ValueChanged<String>? onChanged;

  const OtpCell({
    super.key,
    required this.controller,
    required this.focusNode,
    this.state = OtpCellState.empty,
    this.onChanged,
  });

  OutlineInputBorder _border(Color color) => OutlineInputBorder(
        borderRadius: BorderRadius.circular(AppRadius.md),
        borderSide: BorderSide(color: color, width: AppStroke.xs),
      );

  @override
  Widget build(BuildContext context) {
    final isError = state == OtpCellState.error;

    return SizedBox(
      width: AppGrid.grid48,
      height: AppGrid.grid52,
      child: TextField(
        controller: controller,
        focusNode: focusNode,
        textAlign: TextAlign.center,
        keyboardType: TextInputType.number,
        maxLength: 1,
        inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        onChanged: onChanged,
        style: AppTypography.body.bold.copyWith(color: AppColors.textPrimary),
        cursorColor: AppColors.brand,
        // Hide the built-in maxLength counter.
        buildCounter: (_, {required currentLength, required isFocused, maxLength}) => null,
        decoration: InputDecoration(
          filled: true,
          fillColor: AppColors.surface,
          contentPadding: EdgeInsets.zero,
          border: _border(isError ? AppColors.error : AppColors.surfaceBorder),
          enabledBorder: _border(isError ? AppColors.error : AppColors.surfaceBorder),
          focusedBorder: _border(isError ? AppColors.error : AppColors.brand),
          disabledBorder: _border(AppColors.surfaceBorder),
        ),
      ),
    );
  }
}
