import 'package:flutter/material.dart';
import '../../design_system.dart';

/// Template: Create Exercise Details page.
///
/// Tabbed form where a practitioner fills in metadata (name, body segment,
/// outcome, equipment) for a newly recorded exercise and taps "Save & complete"
/// to persist.
///
/// Owns every [TextEditingController] and [FocusNode] on the page. Pickers are
/// rendered inside the template's own [Stack] (inside [Scaffold.body], under
/// the [Material] subtree so they inherit [DefaultTextStyle]). When a dropdown
/// is tapped, the template measures the trigger's global Y via a [GlobalKey] +
/// [RenderBox] and pins the picker below it via [Positioned]. A translucent
/// backdrop [Listener] layer handles tap-outside dismissal with trigger
/// hit-test exemption. Canonical reference: [ExercisePlanTemplate].
///
/// The Save & complete button is pinned outside the scroll area.
///
/// Reports upward only:
/// - [onSubmit] — fired with a complete [ExerciseDetailsData] on Save tap
/// - [onAddNewEquipment] — fired when the user taps "+ Add New Equipment"
///
/// Never calls a service or triggers navigation.
class CreateExerciseDetailsTemplate extends StatefulWidget {
  /// Options for the Body Segment picker.
  final List<LabelOption> bodySegments;

  /// Options for the Outcome Goals picker.
  final List<LabelOption> outcomes;

  /// Full equipment list — the template pre-filters this by [selectedCategoryId]
  /// before passing it to [EquipmentPickerPanel].
  final List<EquipmentOption> equipment;

  /// Category chips shown in the Equipment picker's filter row.
  final List<EquipmentFilterCategory> equipmentCategories;

  /// Optional thumbnail URLs keyed by equipment id. Currently reserved —
  /// passed through to [EquipmentPickerPanel] but not yet rendered.
  final Map<String, String>? equipmentThumbnails;

  /// Hint messages per tab index. Each entry must have exactly 3 strings.
  /// Passed to [InfoCarousel]; changing the list reference resets the timer.
  final Map<int, List<String>> tabHintMessages;

  /// Fired when the user taps "+ Add New Equipment" in the equipment picker.
  final VoidCallback onAddNewEquipment;

  /// Fired with the collected form data when the user taps "Save & complete"
  /// and all four fields are non-empty.
  final ValueChanged<ExerciseDetailsData> onSubmit;

  const CreateExerciseDetailsTemplate({
    super.key,
    required this.bodySegments,
    required this.outcomes,
    required this.equipment,
    required this.equipmentCategories,
    this.equipmentThumbnails,
    required this.tabHintMessages,
    required this.onAddNewEquipment,
    required this.onSubmit,
  });

  @override
  State<CreateExerciseDetailsTemplate> createState() =>
      _CreateExerciseDetailsTemplateState();
}

class _CreateExerciseDetailsTemplateState
    extends State<CreateExerciseDetailsTemplate> {
  // ── Controllers / focus nodes ──

  late final TextEditingController _nameController;
  late final FocusNode _nameFocusNode;

  // ── Trigger keys for position measurement ──

  final GlobalKey _bodySegmentTriggerKey = GlobalKey();
  final GlobalKey _outcomeTriggerKey = GlobalKey();
  final GlobalKey _equipmentTriggerKey = GlobalKey();

  // ── Layout state ──

  int _activeTabIndex = 3;
  OpenPicker _openPicker = OpenPicker.none;

  /// Y coordinate (Stack-local) of the open picker's top edge. Set when a
  /// picker opens; not continuously tracked — a stale anchor on scroll is
  /// acceptable since scrolling closes the picker via the backdrop.
  double _overlayAnchorTop = 0;

  // ── Field selection state ──

  String? _bodySegmentId;
  String? _outcomeId;
  String? _equipmentId;
  String? _equipmentCategoryId;

  // ── Lifecycle ──

  @override
  void initState() {
    super.initState();
    _nameController = TextEditingController();
    _nameFocusNode = FocusNode()..addListener(_onNameFocusChange);
  }

  void _onNameFocusChange() {
    if (_nameFocusNode.hasFocus) _closePicker();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _nameFocusNode
      ..removeListener(_onNameFocusChange)
      ..dispose();
    super.dispose();
  }

  // ── Helpers ──

  GlobalKey? _triggerKeyFor(OpenPicker picker) => switch (picker) {
        OpenPicker.bodySegment => _bodySegmentTriggerKey,
        OpenPicker.outcome => _outcomeTriggerKey,
        OpenPicker.equipment => _equipmentTriggerKey,
        OpenPicker.none => null,
      };

  void _togglePicker(OpenPicker target) {
    _nameFocusNode.unfocus();
    if (_openPicker == target) {
      setState(() => _openPicker = OpenPicker.none);
      return;
    }
    final safeTop = MediaQuery.of(context).padding.top;
    double top = _overlayAnchorTop;
    final key = _triggerKeyFor(target);
    if (key != null) {
      final box = key.currentContext?.findRenderObject() as RenderBox?;
      if (box != null) {
        final global = box.localToGlobal(Offset.zero);
        // Stack sits inside SafeArea(bottom: false); subtract safeTop so the
        // Positioned(top: ...) coordinate is Stack-local.
        top = global.dy + box.size.height + AppGrid.grid8 - safeTop;
      }
    }
    setState(() {
      _openPicker = target;
      _overlayAnchorTop = top;
    });
  }

  void _closePicker() {
    if (_openPicker != OpenPicker.none) {
      setState(() => _openPicker = OpenPicker.none);
    }
  }

  void _onTabChanged(int index) {
    setState(() {
      _activeTabIndex = index;
      _openPicker = OpenPicker.none;
    });
  }

  bool get _isFormComplete => _nameController.text.isNotEmpty;

  void _handleSubmit() {
    widget.onSubmit(
      ExerciseDetailsData(
        name: _nameController.text,
        bodySegmentId: _bodySegmentId,
        outcomeId: _outcomeId,
        equipmentId: _equipmentId,
      ),
    );
  }

  String? get _bodySegmentLabel =>
      widget.bodySegments.where((o) => o.id == _bodySegmentId).firstOrNull?.label;

  String? get _outcomeLabel =>
      widget.outcomes.where((o) => o.id == _outcomeId).firstOrNull?.label;

  String? get _equipmentLabel =>
      widget.equipment.where((o) => o.id == _equipmentId).firstOrNull?.label;

  List<EquipmentOption> get _filteredEquipment {
    final cat = _equipmentCategoryId;
    if (cat == null) return widget.equipment;
    return widget.equipment.where((e) => e.categoryId == cat).toList();
  }

  Widget _buildPickerPanel(OpenPicker picker) {
    return switch (picker) {
      OpenPicker.bodySegment => LabelOptionPickerPanel(
          key: const ValueKey('body-picker'),
          title: 'Body Segments',
          options: widget.bodySegments,
          selectedId: _bodySegmentId,
          layout: LabelPickerLayout.grid2,
          onSelected: (opt) {
            setState(() => _bodySegmentId = opt.id);
          },
        ),
      OpenPicker.outcome => LabelOptionPickerPanel(
          key: const ValueKey('outcome-picker'),
          title: 'Outcome Goals',
          options: widget.outcomes,
          selectedId: _outcomeId,
          layout: LabelPickerLayout.column,
          onSelected: (opt) {
            setState(() => _outcomeId = opt.id);
          },
        ),
      OpenPicker.equipment => EquipmentPickerPanel(
          key: const ValueKey('equipment-picker'),
          title: 'Equipment category',
          subtitle: 'Sub title',
          variant: EquipmentPickerVariant.withFilters,
          options: _filteredEquipment,
          selectedId: _equipmentId,
          onSelected: (opt) {
            setState(() => _equipmentId = opt.id);
          },
          categories: widget.equipmentCategories,
          selectedCategoryId: _equipmentCategoryId,
          onCategoryChanged: (cat) {
            setState(() => _equipmentCategoryId = cat?.id);
          },
          thumbnailByEquipmentId: widget.equipmentThumbnails,
          onAddNew: () {
            setState(() => _openPicker = OpenPicker.none);
            widget.onAddNewEquipment();
          },
        ),
      OpenPicker.none => const SizedBox.shrink(),
    };
  }

  /// Layer 1: translucent backdrop [Listener] — does not consume events, so a
  /// tap on another dropdown trigger both dismisses the open picker here AND
  /// opens the new one via the trigger's [AppDropdown.onTap].
  ///
  /// If the pointer-down lands on the currently-active trigger, skip the
  /// dismiss — the trigger's own onTap will toggle it closed on pointer-up.
  /// Without this skip, the backdrop would close first and the trigger would
  /// re-open on pointer-up.
  ///
  /// Layer 2: panel absorbs its own taps so the backdrop [Listener] doesn't
  /// receive pointer events from non-interactive panel areas.
  List<Widget> _buildPickerOverlays() {
    if (_openPicker == OpenPicker.none) return const [];
    return [
      Positioned.fill(
        child: Listener(
          behavior: HitTestBehavior.translucent,
          onPointerDown: (event) {
            final key = _triggerKeyFor(_openPicker);
            if (key != null) {
              final box = key.currentContext?.findRenderObject() as RenderBox?;
              if (box != null) {
                final local = box.globalToLocal(event.position);
                if (local.dx >= 0 &&
                    local.dy >= 0 &&
                    local.dx <= box.size.width &&
                    local.dy <= box.size.height) {
                  return;
                }
              }
            }
            _closePicker();
          },
          child: const SizedBox.expand(),
        ),
      ),
      Positioned(
        top: _overlayAnchorTop,
        left: AppPadding.pagePadding,
        right: AppPadding.pagePadding,
        child: GestureDetector(
          behavior: HitTestBehavior.opaque,
          onTap: () {},
          child: _buildPickerPanel(_openPicker),
        ),
      ),
    ];
  }

  // ── Build ──

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        bottom: false,
        child: Stack(
          children: [
            Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.pagePadding),
                  child: SubTabBar(
                    tabs: const [
                      SubTabBarTab(label: 'Starting'),
                      SubTabBarTab(label: 'Frames'),
                      SubTabBarTab(label: 'Preview'),
                      SubTabBarTab(label: 'Details'),
                    ],
                    activeIndex: _activeTabIndex,
                    onChanged: _onTabChanged,
                  ),
                ),
                const SizedBox(height: AppGrid.grid16),
                Padding(
                  padding: const EdgeInsets.symmetric(
                      horizontal: AppPadding.pagePadding),
                  child: InfoCarousel(
                    messages: widget.tabHintMessages[_activeTabIndex]!,
                  ),
                ),
                const SizedBox(height: AppGrid.grid24),
                Expanded(
                  child: SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                          horizontal: AppPadding.pagePadding),
                      child: _activeTabIndex == 3
                          ? _buildForm()
                          : Center(
                              child: AppText(
                                'Coming soon',
                                style: AppTypography.bodyLarge.bold,
                                color: AppColors.textSecondary,
                              ),
                            ),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.fromLTRB(
                    AppPadding.pagePadding,
                    AppGrid.grid12,
                    AppPadding.pagePadding,
                    AppPadding.pagePadding,
                  ),
                  child: SafeArea(
                    top: false,
                    child: SizedBox(
                      width: double.infinity,
                      child: AppButton(
                        label: 'Save & complete',
                        type: ButtonType.filled,
                        size: ButtonSize.md,
                        isDisabled: !_isFormComplete,
                        onPressed: _isFormComplete ? _handleSubmit : null,
                      ),
                    ),
                  ),
                ),
              ],
            ),
            ..._buildPickerOverlays(),
          ],
        ),
      ),
    );
  }

  Widget _buildForm() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        AppTextFieldMolecule(
          controller: _nameController,
          focusNode: _nameFocusNode,
          hintText: 'Exercise name',
          onChanged: (_) => setState(() {}),
        ),
        const SizedBox(height: AppGrid.grid24),

        // ── Body segment ──
        AppDropdown(
          key: _bodySegmentTriggerKey,
          style: AppDropdownStyle.flat,
          variant: AppDropdownVariant.plain,
          value: _bodySegmentLabel,
          placeholder: 'Body segment',
          isOpen: _openPicker == OpenPicker.bodySegment,
          onTap: () => _togglePicker(OpenPicker.bodySegment),
        ),
        const SizedBox(height: AppGrid.grid24),

        // ── Outcome goals ──
        AppDropdown(
          key: _outcomeTriggerKey,
          style: AppDropdownStyle.flat,
          variant: AppDropdownVariant.plain,
          value: _outcomeLabel,
          placeholder: 'Outcome goals',
          isOpen: _openPicker == OpenPicker.outcome,
          onTap: () => _togglePicker(OpenPicker.outcome),
        ),
        const SizedBox(height: AppGrid.grid24),

        // ── Equipment ──
        AppDropdown(
          key: _equipmentTriggerKey,
          style: AppDropdownStyle.flat,
          variant: AppDropdownVariant.plain,
          value: _equipmentLabel,
          placeholder: 'Equipment',
          isOpen: _openPicker == OpenPicker.equipment,
          onTap: () => _togglePicker(OpenPicker.equipment),
        ),
        const SizedBox(height: AppGrid.grid16),
      ],
    );
  }
}
