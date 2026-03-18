import 'package:flutter/material.dart';
import '../design_system.dart';

// ── Enums ──

enum CheckboxValue { unchecked, checked, indeterminate }

enum CheckboxSize { sm, md, lg }

// ── Size configuration ──

class _CheckboxSizeConfig {
  final double size;
  final double iconSize;

  const _CheckboxSizeConfig({
    required this.size,
    required this.iconSize,
  });

  static final Map<CheckboxSize, _CheckboxSizeConfig> _map = {
    CheckboxSize.sm: const _CheckboxSizeConfig(size: 24, iconSize: 14),
    CheckboxSize.md: const _CheckboxSizeConfig(size: 28, iconSize: 16),
    CheckboxSize.lg: const _CheckboxSizeConfig(size: 32, iconSize: 18),
  };

  static _CheckboxSizeConfig of(CheckboxSize size) => _map[size]!;
}

// ── Color resolution ──

class _ResolvedColors {
  final Color background;
  final Color border;
  final Color icon;

  const _ResolvedColors({
    required this.background,
    required this.border,
    required this.icon,
  });
}

Color _resolve700(Color color) {
  return AppColors.shadow700[color] ?? _darken(color, 0.2);
}

Color _darken(Color color, double amount) {
  final hsl = HSLColor.fromColor(color);
  return hsl
      .withLightness((hsl.lightness - amount).clamp(0.0, 1.0))
      .toColor();
}

_ResolvedColors _resolveColors(
  CheckboxValue value,
  Color color, {
  bool pressed = false,
}) {
  final isCheckedOrIndeterminate =
      value == CheckboxValue.checked || value == CheckboxValue.indeterminate;

  if (isCheckedOrIndeterminate) {
    return _ResolvedColors(
      background: color,
      border: _resolve700(color),
      icon: AppColors.textPrimary,
    );
  }

  // Unchecked
  return _ResolvedColors(
    background: Colors.transparent,
    border: AppColors.textPrimary,
    icon: Colors.transparent,
  );
}

// ── AppCheckbox ──

/// Atom: checkbox with 3D border press effect.
///
/// Icon-only — compose with [AppText] in a [Row] for labeled checkboxes.
///
/// Supports three visual states: unchecked, checked, indeterminate.
///
/// State control modes:
/// - Parent-controlled: pass [value] and handle [onChanged]
/// - Self-toggle: set [selfToggle] to true
class AppCheckbox extends StatefulWidget {
  /// Current checkbox state (parent-controlled mode).
  /// - null (default): no parent control, see [selfToggle].
  /// - CheckboxValue.unchecked / checked / indeterminate.
  final CheckboxValue? value;

  /// If true, the checkbox toggles its own state on tap.
  /// Cycles: unchecked → checked → unchecked.
  /// Cannot be used together with [value].
  final bool selfToggle;

  /// Called when the checkbox state changes.
  final ValueChanged<CheckboxValue>? onChanged;

  /// Checkbox size: sm (24px), md (28px), lg (32px).
  final CheckboxSize size;

  /// Accent color for checked/indeterminate state.
  final Color color;

  /// Disables interaction and reduces opacity to 0.4.
  final bool isDisabled;

  const AppCheckbox({
    super.key,
    this.value,
    this.selfToggle = false,
    this.onChanged,
    this.size = CheckboxSize.md,
    this.color = AppColors.brand,
    this.isDisabled = false,
  }) : assert(
         !(selfToggle && value != null),
         'Cannot use both selfToggle and value. Use one or the other.',
       );

  @override
  State<AppCheckbox> createState() => _AppCheckboxState();
}

class _AppCheckboxState extends State<AppCheckbox> {
  bool _pressed = false;
  CheckboxValue _selfValue = CheckboxValue.unchecked;

  bool get _interactive => !widget.isDisabled;

  CheckboxValue get _currentValue {
    if (widget.selfToggle) return _selfValue;
    return widget.value ?? CheckboxValue.unchecked;
  }

  void _toggle() {
    final next = _currentValue == CheckboxValue.checked
        ? CheckboxValue.unchecked
        : CheckboxValue.checked;

    if (widget.selfToggle) {
      setState(() => _selfValue = next);
    }
    widget.onChanged?.call(next);
  }

  @override
  void didUpdateWidget(covariant AppCheckbox oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (!widget.selfToggle && oldWidget.selfToggle) {
      _selfValue = CheckboxValue.unchecked;
    }
  }

  @override
  Widget build(BuildContext context) {
    final sizeConfig = _CheckboxSizeConfig.of(widget.size);
    final colors = _resolveColors(_currentValue, widget.color, pressed: _pressed);
    final contentOpacity = widget.isDisabled ? 0.4 : 1.0;

    final isCheckedOrIndeterminate =
        _currentValue == CheckboxValue.checked ||
        _currentValue == CheckboxValue.indeterminate;

    // 3D border geometry — matches AppButton pattern
    final double layoutSide = 2.0;
    final double visualTop;
    final double visualBottom;
    final double visualSide;
    final double faceOffset;
    final bool showBorder;

    if (isCheckedOrIndeterminate) {
      // Filled style — like AppButton filled
      visualTop = _pressed ? 4.0 : 0.0;
      visualBottom = _pressed ? 0.0 : 4.0;
      visualSide = 2.0;
      faceOffset = 0.0;
      showBorder = !_pressed;
    } else {
      // Outline style — like AppButton outline
      visualTop = 1.0;
      visualBottom = _pressed ? 1.0 : 4.0;
      visualSide = _pressed ? 1.0 : 2.0;
      faceOffset = _pressed ? 3.0 : 0.0; // drop face 3px on press
      showBorder = true;
    }

    final totalWidth = sizeConfig.size + (layoutSide * 2);
    final totalHeight = sizeConfig.size + 4.0; // 4px for 3D depth

    return Semantics(
      checked: _currentValue == CheckboxValue.checked,
      child: GestureDetector(
        onTapDown: _interactive ? (_) => setState(() => _pressed = true) : null,
        onTapUp: _interactive
            ? (_) {
                setState(() => _pressed = false);
                _toggle();
              }
            : null,
        onTapCancel: _interactive ? () => setState(() => _pressed = false) : null,
        child: Opacity(
          opacity: contentOpacity,
          child: CustomPaint(
            painter: _CheckboxPainter(
              backgroundColor: colors.background,
              borderColor: colors.border,
              borderRadius: AppRadius.sm,
              borderTop: visualTop,
              borderBottom: visualBottom,
              borderSide: visualSide,
              faceOffset: faceOffset,
              faceSideInset: layoutSide,
              showBorder: showBorder,
            ),
            child: SizedBox(
              width: totalWidth,
              height: totalHeight,
              child: Padding(
                padding: EdgeInsets.only(
                  left: layoutSide,
                  right: layoutSide,
                  top: visualTop + faceOffset,
                  bottom: (visualBottom - faceOffset).clamp(0.0, double.infinity),
                ),
                child: Center(
                  child: isCheckedOrIndeterminate
                      ? AppIcon(
                          _currentValue == CheckboxValue.checked
                              ? AppIcons.check
                              : AppIcons.minus,
                          size: sizeConfig.iconSize,
                          color: colors.icon,
                        )
                      : null,
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ── Custom painter for 3D checkbox ──

class _CheckboxPainter extends CustomPainter {
  final Color backgroundColor;
  final Color borderColor;
  final double borderRadius;
  final double borderTop;
  final double borderBottom;
  final double borderSide;
  final double faceOffset;
  final double faceSideInset;
  final bool showBorder;

  _CheckboxPainter({
    required this.backgroundColor,
    required this.borderColor,
    required this.borderRadius,
    required this.borderTop,
    required this.borderBottom,
    required this.borderSide,
    required this.faceOffset,
    required this.faceSideInset,
    required this.showBorder,
  });

  @override
  void paint(Canvas canvas, Size size) {
    // 1. Draw border ring
    if (showBorder && (borderBottom > 0 || borderSide > 0 || borderTop > 0)) {
      final outerRRect = RRect.fromRectAndRadius(
        Rect.fromLTRB(0, faceOffset, size.width, size.height),
        Radius.circular(borderRadius),
      );
      final borderInnerRadius = (borderRadius - borderSide).clamp(0.0, double.infinity);
      final borderInnerRRect = RRect.fromRectAndRadius(
        Rect.fromLTRB(borderSide, faceOffset + borderTop, size.width - borderSide, size.height - borderBottom),
        Radius.circular(borderInnerRadius),
      );
      final borderPaint = Paint()..color = borderColor;
      canvas.drawDRRect(outerRRect, borderInnerRRect, borderPaint);
    }

    // 2. Draw the checkbox face
    //    faceOffset shifts the face down without thickening the border.
    final faceRect = Rect.fromLTRB(
      faceSideInset,
      borderTop + faceOffset,
      size.width - faceSideInset,
      size.height - borderBottom,
    );
    final faceRadius = (borderRadius - faceSideInset).clamp(0.0, double.infinity);
    final faceRRect = RRect.fromRectAndRadius(
      faceRect,
      Radius.circular(faceRadius),
    );
    final facePaint = Paint()..color = backgroundColor;
    canvas.drawRRect(faceRRect, facePaint);
  }

  @override
  bool shouldRepaint(_CheckboxPainter old) =>
      backgroundColor != old.backgroundColor ||
      borderColor != old.borderColor ||
      borderRadius != old.borderRadius ||
      borderTop != old.borderTop ||
      borderBottom != old.borderBottom ||
      borderSide != old.borderSide ||
      faceOffset != old.faceOffset ||
      faceSideInset != old.faceSideInset ||
      showBorder != old.showBorder;
}
