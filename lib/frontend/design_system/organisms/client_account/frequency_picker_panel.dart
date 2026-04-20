import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import '../../atoms/inputs/text_field_3d.dart';
import '../../atoms/primitives/scheme_option_row.dart';
import '../../atoms/primitives/text.dart';
import '../../molecules/controls/app_dropdown.dart';
import '../../molecules/controls/app_dropdown_types.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/radius.dart';
import '../../foundation/type/typography.dart';
import '../../foundation/motion/durations.dart';
import '../../foundation/motion/curves.dart';
import 'frequency_picker_types.dart';

/// Organism: a panel for picking a frequency — an integer amount combined with
/// a unit (daily / weekly / monthly).
///
/// Owns no controllers or focus nodes — the template above supplies them.
/// Manages only intrinsic UI state:
///   - [_isUnitOpen] — whether the unit sub-dropdown is visible
///   - [_amountBorderColor] — tracks focus state of the amount field
///   - entry animation progress
///
/// The unit sub-dropdown is rendered via [Overlay] so it floats above all
/// content without affecting layout. A full-screen transparent barrier closes
/// it when the user taps outside.
///
/// Focus coordination is intrinsic to this panel: gaining focus on the amount
/// field closes the unit dropdown; opening the unit dropdown unfocuses the
/// amount field.
class FrequencyPickerPanel extends StatefulWidget {
  final TextEditingController amountController;
  final FocusNode amountFocusNode;
  final FrequencyUnit selectedUnit;
  final ValueChanged<FrequencyUnit> onUnitChanged;

  const FrequencyPickerPanel({
    super.key,
    required this.amountController,
    required this.amountFocusNode,
    required this.selectedUnit,
    required this.onUnitChanged,
  });

  @override
  State<FrequencyPickerPanel> createState() => _FrequencyPickerPanelState();
}

class _FrequencyPickerPanelState extends State<FrequencyPickerPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _isUnitOpen = false;
  Color _amountBorderColor = AppColors.surfaceBorder;
  OverlayEntry? _unitOverlayEntry;

  final _panelKey = GlobalKey();
  final _whenButtonKey = GlobalKey();

  @override
  void initState() {
    super.initState();
    _entryController = AnimationController(
      vsync: this,
      duration: AppDurations.toggle,
    );
    _fadeAnimation = CurvedAnimation(
      parent: _entryController,
      curve: AppCurves.toggle,
    );
    _slideAnimation = Tween<Offset>(
      begin: const Offset(0, 0.1),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _entryController,
      curve: AppCurves.toggle,
    ));
    _entryController.forward();
    widget.amountFocusNode.addListener(_onAmountFocusChanged);
  }

  @override
  void didUpdateWidget(FrequencyPickerPanel oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.selectedUnit != widget.selectedUnit) {
      // Deferred because didUpdateWidget fires during the parent's build phase.
      // Calling markNeedsBuild() synchronously here would crash — schedule it
      // for the next frame instead.
      WidgetsBinding.instance.addPostFrameCallback((_) {
        _unitOverlayEntry?.markNeedsBuild();
      });
    }
  }

  void _onAmountFocusChanged() {
    if (widget.amountFocusNode.hasFocus) {
      setState(() => _amountBorderColor = AppColors.brand);
      _closeUnitDropdown();
    } else {
      setState(() => _amountBorderColor = AppColors.surfaceBorder);
    }
  }

  void _openUnitDropdown() {
    widget.amountFocusNode.unfocus();
    setState(() => _isUnitOpen = true);
    WidgetsBinding.instance.addPostFrameCallback((_) => _showUnitOverlay());
  }

  void _showUnitOverlay() {
    _removeUnitOverlay();
    if (!mounted) return;

    final panelBox =
        _panelKey.currentContext?.findRenderObject() as RenderBox?;
    final whenBox =
        _whenButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (panelBox == null || whenBox == null) return;

    final panelOffset = panelBox.localToGlobal(Offset.zero);
    final whenOffset = whenBox.localToGlobal(Offset.zero);
    final top = panelOffset.dy + panelBox.size.height + AppGrid.grid20;
    final left = whenOffset.dx;
    final width = whenBox.size.width;

    _unitOverlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // Barrier — tapping anywhere outside closes the dropdown.
          Positioned.fill(
            child: GestureDetector(
              onTap: _closeUnitDropdown,
              behavior: HitTestBehavior.opaque,
              child: const SizedBox.expand(),
            ),
          ),
          // Sub-dropdown — floats above layout.
          Positioned(
            top: top,
            left: left,
            width: width,
            child: Material(
              color: Colors.transparent,
              child: Container(
                decoration: BoxDecoration(
                  color: AppColors.grey850,
                  border: Border.all(color: AppColors.textPrimary, width: 1),
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                ),
                padding: EdgeInsets.all(AppGrid.grid12),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppText(
                      'When',
                      style: AppTypography.bodySmall.semiBold,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: AppGrid.grid8),
                    ...FrequencyUnit.values.map(
                      (unit) => SchemeOptionRow(
                        label: unit.label,
                        isSelected: unit == widget.selectedUnit,
                        onTap: () => widget.onUnitChanged(unit),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
    Overlay.of(context).insert(_unitOverlayEntry!);
  }

  void _removeUnitOverlay() {
    _unitOverlayEntry?.remove();
    _unitOverlayEntry = null;
  }

  void _closeUnitDropdown() {
    _removeUnitOverlay();
    if (mounted) setState(() => _isUnitOpen = false);
  }

  @override
  void dispose() {
    _removeUnitOverlay();
    widget.amountFocusNode.removeListener(_onAmountFocusChanged);
    _entryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return FadeTransition(
      opacity: _fadeAnimation,
      child: SlideTransition(
        position: _slideAnimation,
        child: Container(
          key: _panelKey,
          decoration: BoxDecoration(
            color: AppColors.grey850,
            border: Border.all(color: AppColors.textPrimary, width: 1),
            borderRadius: BorderRadius.circular(AppRadius.md),
          ),
          padding: EdgeInsets.all(AppGrid.grid16),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              // Amount column
              SizedBox(
                width: AppGrid.grid80,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'Amount',
                      style: AppTypography.bodySmall.semiBold,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: AppGrid.grid8),
                    AppTextField3D(
                      controller: widget.amountController,
                      focusNode: widget.amountFocusNode,
                      borderColor: _amountBorderColor,
                      keyboardType: TextInputType.number,
                      inputFormatters: [
                        FilteringTextInputFormatter.digitsOnly,
                        _MinOneFormatter(),
                      ],
                    ),
                  ],
                ),
              ),
              SizedBox(width: AppGrid.grid16),
              // Dash separator
              Padding(
                padding: EdgeInsets.only(bottom: AppGrid.grid8),
                child: AppText(
                  '–',
                  style: AppTypography.body.regular,
                  color: AppColors.textPrimary,
                ),
              ),
              SizedBox(width: AppGrid.grid16),
              // When column
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText(
                      'When',
                      style: AppTypography.bodySmall.semiBold,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: AppGrid.grid8),
                    AppDropdown(
                      key: _whenButtonKey,
                      style: AppDropdownStyle.outline,
                      variant: AppDropdownVariant.plain,
                      value: widget.selectedUnit.label,
                      placeholder: '',
                      isOpen: _isUnitOpen,
                      onTap: _isUnitOpen
                          ? _closeUnitDropdown
                          : _openUnitDropdown,
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _MinOneFormatter extends TextInputFormatter {
  @override
  TextEditingValue formatEditUpdate(
    TextEditingValue oldValue,
    TextEditingValue newValue,
  ) {
    if (newValue.text.isEmpty) return newValue;
    final value = int.tryParse(newValue.text);
    if (value != null && value < 1) {
      return newValue.copyWith(text: '1');
    }
    return newValue;
  }
}
