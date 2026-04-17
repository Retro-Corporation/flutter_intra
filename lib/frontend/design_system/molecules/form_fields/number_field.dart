import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../atoms/primitives/icon.dart';
import '../../atoms/inputs/text_field.dart';
import '../../atoms/inputs/text_field_3d.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/opacity.dart';
import '../../foundation/space/padding.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/space/stroke.dart';
import '../../icons/app_icons.dart';
import '../../icons/icon_sizes.dart';
import '../behaviors/field_state.dart';
import 'form_field.dart';
import 'form_field_variant.dart';
import 'number_field_types.dart';

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
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<int>? onChanged;

  /// Minimum allowed value (inclusive).
  final int? min;

  /// Maximum allowed value (inclusive).
  final int? max;

  /// Where to place the +/- buttons. Defaults to [StepperLayout.inside].
  final StepperLayout stepperLayout;

  /// Visual style. Defaults to [InputVariant.flat] — no existing callers break.
  final InputVariant variant;

  const AppNumberField({
    super.key,
    required this.controller,
    required this.focusNode,
    this.label,
    this.helperText,
    this.hintText,
    this.state = FieldState.defaultState,
    this.maxLength,
    this.onChanged,
    this.min,
    this.max,
    this.stepperLayout = StepperLayout.inside,
    this.variant = InputVariant.flat,
  });

  @override
  State<AppNumberField> createState() => _AppNumberFieldState();
}

class _AppNumberFieldState extends State<AppNumberField> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    if (widget.variant == InputVariant.card) {
      widget.focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    if (widget.variant == InputVariant.card) {
      widget.focusNode.removeListener(_onFocusChanged);
    }
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  void _onFocusChanged() =>
      setState(() => _isFocused = widget.focusNode.hasFocus);

  int? get _currentValue => int.tryParse(widget.controller.text);

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
    widget.controller.text = v.toString();
    widget.controller.selection = TextSelection.collapsed(
      offset: widget.controller.text.length,
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
      width: AppGrid.grid44,
      height: AppGrid.grid44,
      padding: padding ?? EdgeInsets.zero,
    );
  }

  Color get _cardBorderColor {
    if (widget.state != FieldState.defaultState) return widget.state.border;
    return _isFocused ? AppColors.brand : AppColors.surfaceBorder;
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.variant) {
      InputVariant.flat => _buildFlat(),
      InputVariant.card => _buildCard(),
    };
  }

  Widget _buildFlat() {
    final effectiveState = widget.state;
    final borderColor = effectiveState.border;
    final isDefault = effectiveState == FieldState.defaultState;
    final isDisabled = effectiveState == FieldState.disabled;
    final focusedColor = isDefault ? null : borderColor;
    final iconColor =
        isDisabled ? AppColors.grey600 : AppColors.textSecondary;

    return switch (widget.stepperLayout) {
      StepperLayout.inside  => _buildFlatInsideLayout(borderColor, focusedColor, isDisabled, iconColor),
      StepperLayout.outside => _buildFlatOutsideLayout(borderColor, focusedColor, isDisabled, iconColor),
    };
  }

  Widget _buildFlatInsideLayout(Color borderColor, Color? focusedColor, bool isDisabled, Color iconColor) {
    final stepperButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStepperButton(
          icon: AppIcons.minus,
          onTap: isDisabled ? null : _decrement,
          color: iconColor,
        ),
        Container(
          width: AppStroke.xs,
          height: AppGrid.grid44,
          color: AppColors.surfaceBorder,
        ),
        _buildStepperButton(
          icon: AppIcons.add,
          onTap: isDisabled ? null : _increment,
          color: iconColor,
          padding: const EdgeInsets.only(
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
      child: AppTextField(
        controller: widget.controller,
        focusNode: widget.focusNode,
        hintText: widget.hintText,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d-]'))],
        maxLength: widget.maxLength,
        borderColor: borderColor,
        focusedBorderColor: focusedColor,
        textColor: widget.state.text,
        hintColor: widget.state.hint,
        enabled: !isDisabled,
        suffixWidget: stepperButtons,
      ),
    );
  }

  Widget _buildFlatOutsideLayout(Color borderColor, Color? focusedColor, bool isDisabled, Color iconColor) {
    Widget outsideButton({
      required String icon,
      required VoidCallback? onTap,
    }) {
      return _StepperPressButton(
        icon: icon,
        onTap: onTap,
        iconColor: iconColor,
        width: AppGrid.grid44,
        height: AppGrid.grid44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: borderColor, width: AppStroke.xs),
        ),
      );
    }

    return AppFormField(
      label: widget.label,
      helperText: widget.helperText,
      state: widget.state,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: AppTextField(
              controller: widget.controller,
              focusNode: widget.focusNode,
              hintText: widget.hintText,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d-]')),
              ],
              maxLength: widget.maxLength,
              borderColor: borderColor,
              focusedBorderColor: focusedColor,
              textColor: widget.state.text,
              hintColor: widget.state.hint,
              enabled: !isDisabled,
            ),
          ),
          const SizedBox(width: AppPadding.rem025),
          outsideButton(
            icon: AppIcons.minus,
            onTap: isDisabled ? null : _decrement,
          ),
          const SizedBox(width: AppPadding.rem025),
          outsideButton(
            icon: AppIcons.add,
            onTap: isDisabled ? null : _increment,
          ),
        ],
      ),
    );
  }

  Widget _buildCard() {
    final isDisabled = widget.state == FieldState.disabled;
    final iconColor = isDisabled ? AppColors.grey600 : AppColors.textSecondary;

    return switch (widget.stepperLayout) {
      StepperLayout.inside  => _buildCardInsideLayout(isDisabled, iconColor),
      StepperLayout.outside => _buildCardOutsideLayout(isDisabled, iconColor),
    };
  }

  Widget _buildCardInsideLayout(bool isDisabled, Color iconColor) {
    final stepperButtons = Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        _buildStepperButton(
          icon: AppIcons.minus,
          onTap: isDisabled ? null : _decrement,
          color: iconColor,
        ),
        Container(
          width: AppStroke.xs,
          height: AppGrid.grid44,
          color: AppColors.surfaceBorder,
        ),
        _buildStepperButton(
          icon: AppIcons.add,
          onTap: isDisabled ? null : _increment,
          color: iconColor,
          padding: const EdgeInsets.only(
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
      child: AppTextField3D(
        controller: widget.controller,
        focusNode: widget.focusNode,
        hintText: widget.hintText,
        keyboardType: TextInputType.number,
        inputFormatters: [FilteringTextInputFormatter.allow(RegExp(r'[\d-]'))],
        maxLength: widget.maxLength,
        borderColor: _cardBorderColor,
        enabled: !isDisabled,
        suffixWidget: stepperButtons,
      ),
    );
  }

  Widget _buildCardOutsideLayout(bool isDisabled, Color iconColor) {
    Widget outsideButton({
      required String icon,
      required VoidCallback? onTap,
    }) {
      return _StepperPressButton(
        icon: icon,
        onTap: onTap,
        iconColor: iconColor,
        width: AppGrid.grid44,
        height: AppGrid.grid44,
        decoration: BoxDecoration(
          color: AppColors.surface,
          borderRadius: BorderRadius.circular(AppRadius.sm),
          border: Border.all(color: AppColors.surfaceBorder, width: AppStroke.xs),
        ),
      );
    }

    return AppFormField(
      label: widget.label,
      helperText: widget.helperText,
      state: widget.state,
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Expanded(
            child: AppTextField3D(
              controller: widget.controller,
              focusNode: widget.focusNode,
              hintText: widget.hintText,
              keyboardType: TextInputType.number,
              inputFormatters: [
                FilteringTextInputFormatter.allow(RegExp(r'[\d-]')),
              ],
              maxLength: widget.maxLength,
              borderColor: _cardBorderColor,
              enabled: !isDisabled,
            ),
          ),
          const SizedBox(width: AppPadding.rem025),
          outsideButton(
            icon: AppIcons.minus,
            onTap: isDisabled ? null : _decrement,
          ),
          const SizedBox(width: AppPadding.rem025),
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

    BoxDecoration? effectiveDecoration;
    if (widget.decoration != null) {
      final baseColor = widget.decoration!.color ?? AppColors.surface;
      effectiveDecoration = widget.decoration!.copyWith(
        color: showPress
            ? Color.alphaBlend(
                AppColors.textPrimary.withValues(alpha: AppOpacity.ghostPressed),
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
                    color: AppColors.textPrimary.withValues(alpha: AppOpacity.ghostPressed),
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
