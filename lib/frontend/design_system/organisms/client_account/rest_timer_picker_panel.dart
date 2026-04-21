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
import 'rest_timer_picker_types.dart';

/// Organism: a panel for selecting a rest timer duration.
///
/// Mirrors [FrequencyPickerPanel] with Seconds/Min units and a 'Duration'
/// column label.
///
/// The unit sub-dropdown is rendered via [Overlay] so it floats above all
/// content without affecting layout. A full-screen transparent barrier closes
/// it when the user taps outside.
class RestTimerPickerPanel extends StatefulWidget {
  final TextEditingController amountController;
  final FocusNode amountFocusNode;
  final DurationUnit selectedUnit;
  final ValueChanged<DurationUnit> onUnitChanged;

  const RestTimerPickerPanel({
    super.key,
    required this.amountController,
    required this.amountFocusNode,
    required this.selectedUnit,
    required this.onUnitChanged,
  });

  @override
  State<RestTimerPickerPanel> createState() => _RestTimerPickerPanelState();
}

class _RestTimerPickerPanelState extends State<RestTimerPickerPanel>
    with SingleTickerProviderStateMixin {
  late final AnimationController _entryController;
  late final Animation<double> _fadeAnimation;
  late final Animation<Offset> _slideAnimation;

  bool _isUnitOpen = false;
  Color _amountBorderColor = AppColors.surfaceBorder;
  OverlayEntry? _unitOverlayEntry;

  final _panelKey = GlobalKey();
  final _durationButtonKey = GlobalKey();

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
  void didUpdateWidget(RestTimerPickerPanel oldWidget) {
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
    final durationBox =
        _durationButtonKey.currentContext?.findRenderObject() as RenderBox?;
    if (panelBox == null || durationBox == null) return;

    final panelOffset = panelBox.localToGlobal(Offset.zero);
    final durationOffset = durationBox.localToGlobal(Offset.zero);
    final top = panelOffset.dy + panelBox.size.height + AppGrid.grid20;
    final left = durationOffset.dx;
    final width = durationBox.size.width;

    _unitOverlayEntry = OverlayEntry(
      builder: (_) => Stack(
        children: [
          // Barrier — translucent Listener does not enter the gesture arena,
          // so a tap on another input (amount field, other panel's dropdown)
          // both dismisses this sub-dropdown and reaches its target in one tap.
          //
          // If the tap lands on the dropdown button itself, skip the close —
          // the button's own onTap toggles. Otherwise the barrier would close
          // first and the button would re-open on pointer-up.
          Positioned.fill(
            child: Listener(
              behavior: HitTestBehavior.translucent,
              onPointerDown: (event) {
                final buttonBox = _durationButtonKey.currentContext
                    ?.findRenderObject() as RenderBox?;
                if (buttonBox != null) {
                  final local = buttonBox.globalToLocal(event.position);
                  final size = buttonBox.size;
                  final onButton = local.dx >= 0 &&
                      local.dy >= 0 &&
                      local.dx <= size.width &&
                      local.dy <= size.height;
                  if (onButton) return;
                }
                _closeUnitDropdown();
              },
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
                      'Duration',
                      style: AppTypography.bodySmall.semiBold,
                      color: AppColors.textSecondary,
                    ),
                    SizedBox(height: AppGrid.grid8),
                    ...DurationUnit.values.map(
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
          child: IntrinsicHeight(
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.stretch,
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
                // Dash separator — invisible label + spacer mirrors the side
                // columns so the dash centers over the input row, not the full
                // column (which would be skewed by the label row above).
                Column(
                  children: [
                    Opacity(
                      opacity: 0,
                      child: AppText(
                        'A',
                        style: AppTypography.bodySmall.semiBold,
                      ),
                    ),
                    SizedBox(height: AppGrid.grid8),
                    Expanded(
                      child: Center(
                        child: AppText(
                          '–',
                          style: AppTypography.body.regular,
                          color: AppColors.textPrimary,
                        ),
                      ),
                    ),
                  ],
                ),
                SizedBox(width: AppGrid.grid16),
                // Duration column
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Duration',
                        style: AppTypography.bodySmall.semiBold,
                        color: AppColors.textSecondary,
                      ),
                      SizedBox(height: AppGrid.grid8),
                      AppDropdown(
                        key: _durationButtonKey,
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
