import 'package:flutter/material.dart';
import '../design_system.dart';

// ── Overlay state ────────────────────────────────────────────────────────────

sealed class _ActiveOverlay {
  const _ActiveOverlay();
}

class _OverlayNone extends _ActiveOverlay {
  const _OverlayNone();
}

class _OverlayFrequency extends _ActiveOverlay {
  const _OverlayFrequency();
}

class _OverlayRestTimer extends _ActiveOverlay {
  const _OverlayRestTimer();
}

class _OverlaySetScheme extends _ActiveOverlay {
  const _OverlaySetScheme();
}

class _OverlayEquipment extends _ActiveOverlay {
  final String exerciseId;
  const _OverlayEquipment(this.exerciseId);
}

// ── Mock data ─────────────────────────────────────────────────────────────────

class _MockExercise {
  final String id;
  final double score;
  final Color scoreColor;
  final ScoreBadgeVariant scoreVariant;
  final String exerciseName;
  final String muscleGroup;
  final String reps;
  final String setCount;
  final String equipment;
  final List<String?> thumbnails;
  final String equipmentLabel;
  final EquipmentFieldType equipmentType;
  final List<EquipmentOption> equipmentOptions;
  final String equipmentUnit;

  const _MockExercise({
    required this.id,
    required this.score,
    required this.scoreColor,
    required this.scoreVariant,
    required this.exerciseName,
    required this.muscleGroup,
    required this.reps,
    required this.setCount,
    required this.equipment,
    required this.thumbnails,
    required this.equipmentLabel,
    required this.equipmentType,
    required this.equipmentOptions,
    this.equipmentUnit = 'lb',
  });
}

// ── Coming soon placeholder ───────────────────────────────────────────────────

class _ComingSoonPlaceholder extends StatelessWidget {
  const _ComingSoonPlaceholder();

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 240,
      child: Center(
        child: AppText(
          'Coming soon',
          style: AppTypography.bodyLarge.regular,
          color: AppColors.textSecondary,
        ),
      ),
    );
  }
}

// ── Template ──────────────────────────────────────────────────────────────────

/// Template: Exercise Plan page.
///
/// Owns all [TextEditingController]s and [FocusNode]s for the page.
/// Collects field values and hands them off — never calls services or
/// triggers navigation directly.
class ExercisePlanTemplate extends StatefulWidget {
  const ExercisePlanTemplate({super.key});

  @override
  State<ExercisePlanTemplate> createState() => _ExercisePlanTemplateState();
}

class _ExercisePlanTemplateState extends State<ExercisePlanTemplate> {
  // ── Plan-level controllers ──
  late final TextEditingController _frequencyAmountController;
  late final FocusNode _frequencyAmountFocus;
  late final TextEditingController _restTimerAmountController;
  late final FocusNode _restTimerAmountFocus;

  // ── Plan-level value state ──
  FrequencyUnit _frequencyUnit = FrequencyUnit.weekly;
  DurationUnit _restTimerUnit = DurationUnit.seconds;
  String? _selectedSchemeId;
  late List<SetSchemeGroup> _schemeGroups;

  // ── Per-exercise controller maps (keyed by exercise id) ──
  final Map<String, TextEditingController> _repControllers = {};
  final Map<String, FocusNode> _repFocusNodes = {};
  final Map<String, TextEditingController> _setsControllers = {};
  final Map<String, FocusNode> _setsFocusNodes = {};
  final Map<String, TextEditingController?> _equipmentNumericControllers = {};
  final Map<String, FocusNode?> _equipmentNumericFocusNodes = {};
  final Map<String, int> _flowIndices = {};
  final Map<String, String?> _selectedEquipmentIds = {};

  // ── Page state ──
  int _activeTabIndex = 1;
  bool _isSelectMode = false;
  bool _isEditMode = false;
  final Set<String> _expandedExerciseIds = {};
  final Set<String> _selectedExerciseIds = {};
  List<_MockExercise> _exercises = [];
  bool _isLoading = true;
  _ActiveOverlay _activeOverlay = const _OverlayNone();

  @override
  void initState() {
    super.initState();
    _frequencyAmountController = TextEditingController();
    _frequencyAmountFocus = FocusNode();
    _restTimerAmountController = TextEditingController();
    _restTimerAmountFocus = FocusNode();
    _frequencyAmountController.addListener(_savePlan);
    _restTimerAmountController.addListener(_savePlan);
    _mockData();
    Future.delayed(const Duration(seconds: 1), () {
      if (mounted) setState(() => _isLoading = false);
    });
  }

  void _mockData() {
    _frequencyAmountController.text = '2';
    _frequencyUnit = FrequencyUnit.daily;
    _restTimerAmountController.text = '45';
    _restTimerUnit = DurationUnit.seconds;

    _schemeGroups = const [
      SetSchemeGroup(name: 'Strength', schemes: [
        SetScheme(id: 'strength_1', label: '3-6 × 4 - Controlled'),
        SetScheme(id: 'strength_2', label: '1min x 4'),
      ]),
      SetSchemeGroup(name: 'Hypertrophy', schemes: [
        SetScheme(id: 'hypertrophy_1', label: '8-12 × 3'),
        SetScheme(id: 'hypertrophy_2', label: '2:30min × 4'),
      ]),
      SetSchemeGroup(name: 'Endurance', schemes: [
        SetScheme(id: 'endurance_1', label: '15 × 2'),
        SetScheme(id: 'endurance_2', label: '4min × 4'),
      ]),
    ];
    _selectedSchemeId = 'strength_1';

    _exercises = [
      _MockExercise(
        id: 'ex_1',
        score: 2.4,
        scoreColor: AppColors.brand,
        scoreVariant: ScoreBadgeVariant.trendUp,
        exerciseName: 'Shoulder Press',
        muscleGroup: 'Shoulder flexion',
        reps: '3-6',
        setCount: '4',
        equipment: 'Dumbell 15lb',
        thumbnails: const [null, null, null, null],
        equipmentLabel: 'Dumbell',
        equipmentType: EquipmentFieldType.numbered,
        equipmentOptions: const [
          EquipmentOption(id: 'dumbell_10', label: '10 lb'),
          EquipmentOption(id: 'dumbell_15', label: '15 lb'),
          EquipmentOption(id: 'dumbell_20', label: '20 lb'),
        ],
      ),
      _MockExercise(
        id: 'ex_2',
        score: 2.4,
        scoreColor: AppColors.textSecondary,
        scoreVariant: ScoreBadgeVariant.plain,
        exerciseName: 'Bicep Curl',
        muscleGroup: 'Shoulder flexion',
        reps: '3-6',
        setCount: '4',
        equipment: 'Dumbell 15lb',
        thumbnails: const [null, null, null, null, null],
        equipmentLabel: 'Dumbell',
        equipmentType: EquipmentFieldType.numbered,
        equipmentOptions: const [
          EquipmentOption(id: 'dumbell_10', label: '10 lb'),
          EquipmentOption(id: 'dumbell_15', label: '15 lb'),
        ],
      ),
      _MockExercise(
        id: 'ex_3',
        score: 2.4,
        scoreColor: AppColors.textSecondary,
        scoreVariant: ScoreBadgeVariant.plain,
        exerciseName: 'Lateral Raise',
        muscleGroup: 'Shoulder flexion',
        reps: '3-6',
        setCount: '4',
        equipment: 'Dumbell 15lb',
        thumbnails: const [null, null, null, null],
        equipmentLabel: 'Dumbell',
        equipmentType: EquipmentFieldType.numbered,
        equipmentOptions: const [
          EquipmentOption(id: 'dumbell_10', label: '10 lb'),
          EquipmentOption(id: 'dumbell_15', label: '15 lb'),
          EquipmentOption(id: 'dumbell_20', label: '20 lb'),
          EquipmentOption(id: 'dumbell_25', label: '25 lb'),
        ],
      ),
    ];

    for (final ex in _exercises) {
      _initControllersForExercise(ex.id,
          initialReps: ex.reps, initialSets: ex.setCount);
    }
  }

  void _initControllersForExercise(String id,
      {String initialReps = '', String initialSets = ''}) {
    _repControllers[id] = TextEditingController(text: initialReps)
      ..addListener(_savePlan);
    _repFocusNodes[id] = FocusNode();
    _setsControllers[id] = TextEditingController(text: initialSets)
      ..addListener(_savePlan);
    _setsFocusNodes[id] = FocusNode();
    _equipmentNumericControllers[id] = null;
    _equipmentNumericFocusNodes[id] = null;
    _flowIndices[id] = 0;
    _selectedEquipmentIds[id] = null;
  }

  void _disposeControllersForExercise(String id) {
    _repControllers.remove(id)?.dispose();
    _repFocusNodes.remove(id)?.dispose();
    _setsControllers.remove(id)?.dispose();
    _setsFocusNodes.remove(id)?.dispose();
    _equipmentNumericControllers.remove(id)?.dispose();
    _equipmentNumericFocusNodes.remove(id)?.dispose();
  }

  @override
  void dispose() {
    _frequencyAmountController.dispose();
    _frequencyAmountFocus.dispose();
    _restTimerAmountController.dispose();
    _restTimerAmountFocus.dispose();
    for (final ex in _exercises) {
      _disposeControllersForExercise(ex.id);
    }
    super.dispose();
  }

  // ── Helper methods ────────────────────────────────────────────────────────

  String? _buildFrequencyLabel() {
    final amount = _frequencyAmountController.text.trim();
    if (amount.isEmpty) return null;
    final unit = switch (_frequencyUnit) {
      FrequencyUnit.daily => 'day',
      FrequencyUnit.weekly => 'week',
      FrequencyUnit.monthly => 'month',
    };
    return '${amount}x - $unit';
  }

  String? _buildRestTimerLabel() {
    final amount = _restTimerAmountController.text.trim();
    if (amount.isEmpty) return null;
    final unit = switch (_restTimerUnit) {
      DurationUnit.seconds => 'sec',
      DurationUnit.min => 'min',
    };
    return '$amount $unit';
  }

  String? _getSchemeLabel() {
    if (_selectedSchemeId == null) return null;
    for (final group in _schemeGroups) {
      for (final scheme in group.schemes) {
        if (scheme.id == _selectedSchemeId) return scheme.label;
      }
    }
    return null;
  }

  void _openOverlay(_ActiveOverlay overlay) =>
      setState(() => _activeOverlay = overlay);

  void _dismissOverlay() =>
      setState(() => _activeOverlay = const _OverlayNone());

  void _savePlan() => debugPrint('save triggered');

  void _onCardTap(String id) {
    if (_isSelectMode) {
      setState(() {
        _selectedExerciseIds.contains(id)
            ? _selectedExerciseIds.remove(id)
            : _selectedExerciseIds.add(id);
      });
    } else if (_isEditMode) {
      setState(() {
        _expandedExerciseIds.contains(id)
            ? _expandedExerciseIds.remove(id)
            : _expandedExerciseIds.add(id);
      });
    }
  }

  void _onDeleteExercise(String id) {
    setState(() {
      _exercises.removeWhere((e) => e.id == id);
      _expandedExerciseIds.remove(id);
      _selectedExerciseIds.remove(id);
      _disposeControllersForExercise(id);
    });
  }

  void _onAddExercise() => debugPrint('add exercise pressed');

  // ── Build ─────────────────────────────────────────────────────────────────

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Stack(
          children: [
            Column(
              children: [
                ExercisePlanPageHeader(
                  clientName: 'Roger Bergson',
                  clientEmail: 'Tavoncpowell@gmail.com',
                  score: 3.5,
                  scoreColor: AppColors.brand,
                  scoreVariant: ScoreBadgeVariant.plain,
                  tabs: const [
                    SubTabBarTab(label: 'Overview'),
                    SubTabBarTab(label: 'Exercise'),
                    SubTabBarTab(label: 'Capacity'),
                    SubTabBarTab(label: 'Exposure'),
                  ],
                  activeTabIndex: _activeTabIndex,
                  onBack: () => debugPrint('back pressed'),
                  onTabChanged: (i) => setState(() => _activeTabIndex = i),
                ),
                Expanded(
                  child: SingleChildScrollView(
                    child: Column(
                      children: [
                        _buildPlanSettings(),
                        _buildTabContent(),
                      ],
                    ),
                  ),
                ),
              ],
            ),
            ..._buildOverlays(),
          ],
        ),
      ),
    );
  }

  // ── Plan settings ─────────────────────────────────────────────────────────

  Widget _buildPlanSettings() {
    return Padding(
      padding: const EdgeInsets.all(AppPadding.rem1),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Row 1: frequency + rest timer
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const AppIcon(AppIcons.calendar),
                        const SizedBox(width: AppGrid.grid8),
                        AppText(
                          'Frequency',
                          style: AppTypography.body.regular,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppGrid.grid8),
                    AppDropdown(
                      style: AppDropdownStyle.outline,
                      variant: AppDropdownVariant.plain,
                      value: _buildFrequencyLabel(),
                      placeholder: 'Choose frequency',
                      onTap: () => _openOverlay(const _OverlayFrequency()),
                      isOpen: _activeOverlay is _OverlayFrequency,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppGrid.grid12),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const AppIcon(AppIcons.timer),
                        const SizedBox(width: AppGrid.grid8),
                        AppText(
                          'Rest timer',
                          style: AppTypography.body.regular,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppGrid.grid8),
                    AppDropdown(
                      style: AppDropdownStyle.outline,
                      variant: AppDropdownVariant.plain,
                      value: _buildRestTimerLabel(),
                      placeholder: 'Set timer',
                      onTap: () => _openOverlay(const _OverlayRestTimer()),
                      isOpen: _activeOverlay is _OverlayRestTimer,
                    ),
                  ],
                ),
              ),
            ],
          ),

          const SizedBox(height: AppGrid.grid16),

          // Row 2: set scheme + select/edit buttons
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        const AppIcon(AppIcons.crown),
                        const SizedBox(width: AppGrid.grid8),
                        AppText(
                          'Set scheme',
                          style: AppTypography.body.regular,
                          color: AppColors.textSecondary,
                        ),
                      ],
                    ),
                    const SizedBox(height: AppGrid.grid8),
                    AppButton(
                      type: ButtonType.filled,
                      color: AppColors.brand,
                      label: _getSchemeLabel() ?? 'Select set scheme',
                      onPressed: () => _openOverlay(const _OverlaySetScheme()),
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppGrid.grid8),
              FilterButton(
                state: _isSelectMode
                    ? FilterButtonState.sorted
                    : FilterButtonState.idle,
                icon: AppIcons.select,
                label: 'Select',
                labelBelow: false,
                onTap: () => setState(() {
                  _isSelectMode = !_isSelectMode;
                  if (!_isSelectMode) _selectedExerciseIds.clear();
                }),
              ),
              const SizedBox(width: AppGrid.grid8),
              FilterButton(
                state: _isEditMode
                    ? FilterButtonState.sorted
                    : FilterButtonState.idle,
                icon: AppIcons.edit,
                label: 'Edit',
                labelBelow: false,
                onTap: () => setState(() {
                  _isEditMode = !_isEditMode;
                  if (!_isEditMode) _expandedExerciseIds.clear();
                }),
              ),
            ],
          ),
        ],
      ),
    );
  }

  // ── Tab content ───────────────────────────────────────────────────────────

  Widget _buildTabContent() {
    return switch (_activeTabIndex) {
      1 => _buildExerciseTab(),
      _ => const _ComingSoonPlaceholder(),
    };
  }

  Widget _buildExerciseTab() {
    if (_isLoading) {
      return Padding(
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.rem1),
        child: Column(
          children: [
            const Padding(
              padding: EdgeInsets.only(bottom: AppGrid.grid12),
              child: ExerciseCardSkeleton(),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: AppGrid.grid12),
              child: ExerciseCardSkeleton(),
            ),
            const Padding(
              padding: EdgeInsets.only(bottom: AppGrid.grid12),
              child: ExerciseCardSkeleton(),
            ),
          ],
        ),
      );
    }

    if (_exercises.isEmpty) {
      return SizedBox(
        height: 400,
        child: EmptyExerciseList(onAddExercise: _onAddExercise),
      );
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: AppPadding.rem1),
      child: Column(
        children: [
          for (final ex in _exercises)
            Padding(
              padding: const EdgeInsets.only(bottom: AppGrid.grid12),
              child: _buildExerciseCard(ex),
            ),
          if (_isEditMode)
            Padding(
              padding: const EdgeInsets.only(bottom: AppGrid.grid16),
              child: AppButton(
                type: ButtonType.ghost,
                label: '+ Add Exercise',
                onPressed: _onAddExercise,
              ),
            ),
        ],
      ),
    );
  }

  // ── Exercise cards ────────────────────────────────────────────────────────

  Widget _buildExerciseCard(_MockExercise ex) {
    final isExpanded = _isEditMode && _expandedExerciseIds.contains(ex.id);
    return AnimatedSize(
      duration: AppDurations.toggle,
      curve: Curves.easeInOut,
      child: isExpanded
          ? ExerciseCardEdit(
              thumbnails: ex.thumbnails,
              currentIndex: _flowIndices[ex.id] ?? 0,
              onIndexChanged: (i) => setState(() => _flowIndices[ex.id] = i),
              score: ex.score,
              scoreColor: ex.scoreColor,
              scoreVariant: ex.scoreVariant,
              exerciseName: ex.exerciseName,
              muscleGroup: ex.muscleGroup,
              repController: _repControllers[ex.id]!,
              repFocusNode: _repFocusNodes[ex.id]!,
              setsController: _setsControllers[ex.id]!,
              setsFocusNode: _setsFocusNodes[ex.id]!,
              equipmentLabel: ex.equipmentLabel,
              equipmentType: ex.equipmentType,
              equipmentController: _equipmentNumericControllers[ex.id],
              equipmentFocusNode: _equipmentNumericFocusNodes[ex.id],
              equipmentUnit: ex.equipmentUnit,
              selectedEquipmentValue: _selectedEquipmentIds[ex.id],
              onEquipmentDropdownTap: () =>
                  _openOverlay(_OverlayEquipment(ex.id)),
              isEquipmentDropdownOpen: switch (_activeOverlay) {
                _OverlayEquipment(exerciseId: final id) => id == ex.id,
                _ => false,
              },
              onDelete: () => _onDeleteExercise(ex.id),
              onSwap: () => debugPrint('swap pressed for ${ex.id}'),
            )
          : _buildSelectableReadCard(ex),
    );
  }

  Widget _buildSelectableReadCard(_MockExercise ex) {
    final isSelected = _isSelectMode && _selectedExerciseIds.contains(ex.id);
    return Container(
      decoration: isSelected
          ? BoxDecoration(
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.brand, width: AppStroke.md),
            )
          : null,
      child: ExerciseCardRead(
        score: ex.score,
        scoreColor: ex.scoreColor,
        scoreVariant: ex.scoreVariant,
        exerciseName: ex.exerciseName,
        muscleGroup: ex.muscleGroup,
        reps: ex.reps,
        setCount: ex.setCount,
        equipment: ex.equipment,
        onTap: () => _onCardTap(ex.id),
      ),
    );
  }

  // ── Overlays ──────────────────────────────────────────────────────────────

  List<Widget> _buildOverlays() {
    final overlay = _activeOverlay;
    if (overlay is _OverlayNone) return [];

    final Widget panel = switch (overlay) {
      _OverlayNone() => const SizedBox.shrink(),
      _OverlayFrequency() => FrequencyPickerPanel(
          amountController: _frequencyAmountController,
          amountFocusNode: _frequencyAmountFocus,
          selectedUnit: _frequencyUnit,
          onUnitChanged: (u) => setState(() => _frequencyUnit = u),
        ),
      _OverlayRestTimer() => RestTimerPickerPanel(
          amountController: _restTimerAmountController,
          amountFocusNode: _restTimerAmountFocus,
          selectedUnit: _restTimerUnit,
          onUnitChanged: (u) => setState(() => _restTimerUnit = u),
        ),
      _OverlaySetScheme() => SetSchemePickerPanel(
          groups: _schemeGroups,
          selectedId: _selectedSchemeId,
          onSelected: (s) => setState(() {
            _selectedSchemeId = s.id;
            _dismissOverlay();
          }),
          onCreateNew: () => debugPrint('create new scheme pressed'),
        ),
      _OverlayEquipment(exerciseId: final id) => EquipmentPickerPanel(
          title: _exercises.firstWhere((e) => e.id == id).equipmentLabel,
          options: _exercises.firstWhere((e) => e.id == id).equipmentOptions,
          selectedId: _selectedEquipmentIds[id],
          onSelected: (opt) => setState(() {
            _selectedEquipmentIds[id] = opt.id;
            _dismissOverlay();
          }),
        ),
    };

    return [
      Positioned.fill(
        child: Align(
          alignment: const Alignment(0, -0.1),
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppPadding.rem1),
            child: TapRegion(
              onTapOutside: (_) => _dismissOverlay(),
              child: panel,
            ),
          ),
        ),
      ),
    ];
  }
}
