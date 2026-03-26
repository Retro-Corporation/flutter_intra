import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../atoms/icon.dart';
import '../atoms/text_field.dart';
import '../foundation/colors.dart';
import '../foundation/grid.dart';
import '../foundation/padding.dart';
import '../foundation/radius.dart';
import '../icons/app_icons.dart';
import '../icons/icon_sizes.dart';
import 'controller_owner_mixin.dart';
import 'field_state.dart';
import 'form_field.dart';

/// Layout for the +/- stepper buttons.
enum StepperLayout {
  /// Buttons inside the text field border (as suffix icons).
  inside,

  /// Buttons outside the text field, to the right of it.
  outside,
}

/// Molecule: numeric input with +/- stepper buttons.
///
/// Two layout variants via [stepperLayout]:
/// - [StepperLayout.inside] — buttons sit inside the field as suffix icons.
/// - [StepperLayout.outside] — buttons sit outside, to the right of the field.
class AppNumberField extends StatefulWidget {
  final String? label;
  final String? helperText;
  final String? hintText;
  final FieldState state;
  final int? maxLength;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<int>? onChanged;

  /// Minimum allowed value (inclusive).
  final int? min;

  /// Maximum allowed value (inclusive).
  final int? max;

  /// Initial value.
  final int? value;

  /// Where to place the +/- buttons. Defaults to [StepperLayout.inside].
  final StepperLayout stepperLayout;

  const AppNumberField({
    super.key,
    this.label,
    this.helperText,
    this.hintText,
    this.state = FieldState.defaultState,
    this.maxLength,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.min,
    this.max,
    this.value,
    this.stepperLayout = StepperLayout.inside,
  });

  @override
  State<AppNumberField> createState() => _AppNumberFieldState();
}

class _AppNumberFieldState extends State<AppNumberField>
    with ControllerOwnerMixin {
  int _currentLength = 0;

  @override
  TextEditingController? get externalController => widget.controller;

  @override
  void onTextChanged() {
    setState(() {
      _currentLength = controller.text.length;
    });
  }

  @override
  void initState() {
    super.initState();
    initController(initialText: widget.value?.toString() ?? '');
    _currentLength = controller.text.length;
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }

  int? get _currentValue => int.tryParse(controller.text);

  void _increment() {
    final current = _currentValue ?? widget.min ?? 0;
    final next = current + 1;
    if (widget.max != null && next > widget.max!) return;
    _setValue(next);
  }

  void _decrement() {
    final current = _currentValue ?? widget.min ?? 0;
    final next = current - 1;
    if (widget.min != null && next < widget.min!) return;
    _setValue(next);
  }

  void _setValue(int v) {
    controller.text = v.toString();
    controller.selection = TextSelection.collapsed(
      offset: controller.text.length,
    );
    widget.onChanged?.call(v);
  }

  Widget _buildStepperButton({
    required String icon,
    required VoidCallback? onTap,
    required Color color,
    EdgeInsets? padding,
  }) {
    return _StepperPressButton(
      icon: icon,
      onTap: onTap,
      iconColor: color,
      // Fill the full height of the text field so the tap target & flash
      // area is a visible box, not just a thin strip around the icon.
      width: 2.75.rem,
      height: 2.75.rem,
      padding: padding ?? EdgeInsets.zero,
    );
  }

  @override
  Widget build(BuildContext context) {
    final effectiveState = widget.state;
    final borderColor = FieldStateColors.border(effectiveState);
    final isDisabled = effectiveState == FieldState.disabled;
    final iconColor =
        isDisabled ? AppColors.grey600 : AppColors.textSecondary;

    if (widget.stepperLayout == StepperLayout.outside) {
      return _buildOutsideLayout(borderColor, isDisabled, iconColor);
    }
    return _buildInsideLayout(borderColor, isDisabled, iconColor);
  }

  Widget _buildInsideLayout(Color borderColor, bool isDisabled, Color iconColor) {
    final stepperButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStepperButton(
          icon: AppIcons.minus,
          onTap: isDisabled ? null : _decrement,
          color: iconColor,
        ),
        Container(
          width: 1,
          height: 2.75.rem,
          color: AppColors.surfaceBorder,
        ),
        _buildStepperButton(
          icon: AppIcons.add,
          onTap: isDisabled ? null : _increment,
          color: iconColor,
          padding: EdgeInsets.only(
            left: AppPadding.rem025,
            right: AppPadding.inputPaddingH,
          ),
        ),
      ],
    );

    return AppFormField(
      label: widget.label,
      helperText: widget.helperText,
      state: widget.state,
      maxLength: widget.maxLength,
      currentLength: _currentLength,
      child: AppTextField(
        controller: controller,
        focusNode: widget.focusNode,
        hintText: widget.hintText,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d-]'))],
        maxLength: widget.maxLength,
        borderColor: borderColor,
        focusedBorderColor: borderColor,
        textColor: FieldStateColors.text(widget.state),
        hintColor: FieldStateColors.hint(widget.state),
        enabled: !isDisabled,
        suffixWidget: stepperButtons,
      ),
    );
  }

  Widget _buildOutsideLayout(Color borderColor, bool isDisabled, Color iconColor) {
    // Outside buttons are rendered as separate containers next to the field.
    Widget outsideButton({
      required String icon,
      required VoidCallback? onTap,
    }) {
      return _StepperPressButton(
        icon: icon,
        onTap: onTap,
        iconColor: iconColor,
        width: 2.75.rem,
        height: 2.75.rem,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: borderColor, width: 1),
        ),
      );
    }

    return AppFormField(
      label: widget.label,
      helperText: widget.helperText,
      state: widget.state,
      maxLength: widget.maxLength,
      currentLength: _currentLength,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: AppTextField(
              controller: controller,
              focusNode: widget.focusNode,
              hintText: widget.hintText,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d-]')),
              ],
              maxLength: widget.maxLength,
              borderColor: borderColor,
              focusedBorderColor: borderColor,
              textColor: FieldStateColors.text(widget.state),
              hintColor: FieldStateColors.hint(widget.state),
              enabled: !isDisabled,
            ),
          ),
          SizedBox(width: AppPadding.rem025),
          outsideButton(
            icon: AppIcons.minus,
            onTap: isDisabled ? null : _decrement,
          ),
          SizedBox(width: AppPadding.rem025),
          outsideButton(
            icon: AppIcons.add,
            onTap: isDisabled ? null : _increment,
          ),
        ],
      ),
    );
  }
}

// ---------------------------------------------------------------------------
// Private widget: stepper button with press-state feedback.
// ---------------------------------------------------------------------------

/// A +/- button that shows a subtle brightness flash on press.
///
/// Used by both inside and outside stepper layouts. The tap target is sized
/// to at least 44x44 px for comfortable tapping.
class _StepperPressButton extends StatefulWidget {
  final String icon;
  final VoidCallback? onTap;
  final Color iconColor;

  /// Explicit size — used by the outside layout.
  final double? width;
  final double? height;

  /// Box decoration — used by the outside layout for border + background.
  final BoxDecoration? decoration;

  /// Padding around the icon — used by the inside layout.
  final EdgeInsets padding;

  const _StepperPressButton({
    required this.icon,
    required this.onTap,
    required this.iconColor,
    this.width,
    this.height,
    this.decoration,
    this.padding = EdgeInsets.zero,
  });

  @override
  State<_StepperPressButton> createState() => _StepperPressButtonState();
}

class _StepperPressButtonState extends State<_StepperPressButton> {
  bool _pressed = false;

  void _handleTapDown(TapDownDetails _) {
    setState(() => _pressed = true);
  }

  void _handleTapUp(TapUpDetails _) {
    setState(() => _pressed = false);
    widget.onTap?.call();
  }

  void _handleTapCancel() {
    setState(() => _pressed = false);
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = widget.onTap != null;
    final showPress = _pressed && isEnabled;

    // Build the pressed decoration by blending a subtle white overlay.
    BoxDecoration? effectiveDecoration;
    if (widget.decoration != null) {
      final baseColor = widget.decoration!.color ?? AppColors.surface;
      effectiveDecoration = widget.decoration!.copyWith(
        color: showPress
            ? Color.alphaBlend(
                Colors.white.withValues(alpha: 0.08),
                baseColor,
              )
            : baseColor,
      );
    }

    return GestureDetector(
      behavior: HitTestBehavior.opaque,
      onTapDown: isEnabled ? _handleTapDown : null,
      onTapUp: isEnabled ? _handleTapUp : null,
      onTapCancel: isEnabled ? _handleTapCancel : null,
      child: Container(
        width: widget.width,
        height: widget.height,
        decoration: effectiveDecoration ??
            (showPress
                ? BoxDecoration(
                    color: Colors.white.withValues(alpha: 0.08),
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                  )
                : null),
        padding: widget.padding,
        child: Center(
          child: AppIcon(
            widget.icon,
            size: IconSizes.md,
            color: widget.iconColor,
          ),
        ),
      ),
    );
  }
}
