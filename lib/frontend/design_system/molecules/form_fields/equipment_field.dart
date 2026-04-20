import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../atoms/inputs/text_field_3d.dart';
import '../../atoms/primitives/static_display_field.dart';
import '../../atoms/primitives/text.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/padding.dart';
import '../../foundation/type/typography.dart';
import '../controls/app_dropdown.dart';
import '../controls/app_dropdown_types.dart';
import 'equipment_field_types.dart';

/// Molecule: unified equipment input that adapts to the equipment type.
///
/// Renders a label above a single input control whose presentation
/// is determined by [type]:
///
/// - [EquipmentFieldType.numbered]      → 3D numeric stepper field; formats
///   the value as "X [unit]" on blur and strips the suffix on focus.
/// - [EquipmentFieldType.selectable]    → 3D outline dropdown tap target;
///   parent handles opening the picker panel via [onDropdownTap].
/// - [EquipmentFieldType.staticDisplay] → flat read-only display box.
///
/// The molecule owns the focus listener that drives unit formatting for
/// the numbered variant. [controller] and [focusNode] are provided by the
/// template or organism — this molecule never creates them.
class EquipmentField extends StatefulWidget {
  final String label;
  final EquipmentFieldType type;

  // ── numbered ──────────────────────────────────────────────────────────
  final TextEditingController? controller;
  final FocusNode? focusNode;

  /// Unit suffix appended on blur: e.g. 'lb' or 'kg'. Comes from app settings.
  final String unit;

  // ── selectable ────────────────────────────────────────────────────────
  final String? selectedValue;
  final VoidCallback? onDropdownTap;
  final bool isDropdownOpen;

  // ── staticDisplay ─────────────────────────────────────────────────────
  final String? staticValue;

  const EquipmentField({
    super.key,
    required this.label,
    required this.type,
    this.controller,
    this.focusNode,
    this.unit = 'lb',
    this.selectedValue,
    this.onDropdownTap,
    this.isDropdownOpen = false,
    this.staticValue,
  });

  @override
  State<EquipmentField> createState() => _EquipmentFieldState();
}

class _EquipmentFieldState extends State<EquipmentField> {
  Color _borderColor = AppColors.surfaceBorder;

  @override
  void initState() {
    super.initState();
    widget.focusNode?.addListener(_onFocusChange);
  }

  @override
  void didUpdateWidget(EquipmentField old) {
    super.didUpdateWidget(old);
    if (old.focusNode != widget.focusNode) {
      old.focusNode?.removeListener(_onFocusChange);
      widget.focusNode?.addListener(_onFocusChange);
    }
  }

  @override
  void dispose() {
    widget.focusNode?.removeListener(_onFocusChange);
    super.dispose();
  }

  void _onFocusChange() {
    final controller = widget.controller;
    final focusNode = widget.focusNode;
    if (controller == null || focusNode == null) return;

    if (focusNode.hasFocus) {
      setState(() => _borderColor = AppColors.brand);
      // Strip unit suffix so digits-only input works cleanly.
      final text = controller.text;
      final stripped = text
          .replaceFirst(
            RegExp(
              r'\s*' + RegExp.escape(widget.unit) + r'$',
              caseSensitive: false,
            ),
            '',
          )
          .trim();
      if (stripped != text) {
        controller.text = stripped;
        controller.selection =
            TextSelection.collapsed(offset: stripped.length);
      }
    } else {
      setState(() => _borderColor = AppColors.surfaceBorder);
      // Append unit suffix when a valid integer is present.
      final text = controller.text.trim();
      if (text.isNotEmpty && int.tryParse(text) != null) {
        controller.text = '$text ${widget.unit}';
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        AppText(
          widget.label,
          style: AppTypography.bodySmall.semiBold,
          color: AppColors.textPrimary,
        ),
        const SizedBox(height: AppPadding.rem025),
        _buildField(),
      ],
    );
  }

  Widget _buildField() {
    return switch (widget.type) {
      EquipmentFieldType.numbered => AppTextField3D(
          controller: widget.controller!,
          focusNode: widget.focusNode,
          borderColor: _borderColor,
          keyboardType: TextInputType.number,
          inputFormatters: [FilteringTextInputFormatter.digitsOnly],
        ),
      EquipmentFieldType.selectable => AppDropdown(
          style: AppDropdownStyle.outline,
          variant: AppDropdownVariant.plain,
          value: widget.selectedValue,
          placeholder: 'Select equipment',
          onTap: widget.onDropdownTap ?? () {},
          isOpen: widget.isDropdownOpen,
        ),
      EquipmentFieldType.staticDisplay => AppStaticDisplayField(
          value: widget.staticValue ?? '',
        ),
    };
  }
}
