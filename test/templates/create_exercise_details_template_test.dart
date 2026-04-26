import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

// ── Mock data ────────────────────────────────────────────────────────────────

const _bodySegments = [
  LabelOption(id: 'core', label: 'Core'),
  LabelOption(id: 'hips', label: 'Hips'),
];

const _outcomes = [
  LabelOption(id: 'strength', label: 'Strength'),
  LabelOption(id: 'mobility', label: 'Mobility'),
];

const _equipment = [
  EquipmentOption(id: 'eq1', label: 'Dumbbells',  categoryId: 'weights'),
  EquipmentOption(id: 'eq2', label: 'BOSU Ball',  categoryId: 'balance'),
];

const _categories = [
  EquipmentFilterCategory(id: 'weights', label: 'Weights'),
  EquipmentFilterCategory(id: 'balance', label: 'Balance'),
];

const _hints = {
  0: ['S1', 'S2', 'S3'],
  1: ['F1', 'F2', 'F3'],
  2: ['P1', 'P2', 'P3'],
  3: ['Details hint 1', 'Details hint 2', 'Details hint 3'],
};

// ── Builder ──────────────────────────────────────────────────────────────────

Widget buildTemplate({
  VoidCallback? onAddNewEquipment,
  ValueChanged<ExerciseDetailsData>? onSubmit,
}) {
  return MaterialApp(
    home: CreateExerciseDetailsTemplate(
      bodySegments: _bodySegments,
      outcomes: _outcomes,
      equipment: _equipment,
      equipmentCategories: _categories,
      tabHintMessages: _hints,
      onAddNewEquipment: onAddNewEquipment ?? () {},
      onSubmit: onSubmit ?? (_) {},
    ),
  );
}

// Pump the template inside an 800×1200 surface so the full-height
// withFilters equipment picker fits on-screen. The picker is a fixed
// Positioned child of the template's Stack (not in the form's scroll
// view), so it can't be scrolled into view.
Future<void> pumpTemplate(
  WidgetTester tester, {
  VoidCallback? onAddNewEquipment,
  ValueChanged<ExerciseDetailsData>? onSubmit,
}) async {
  await tester.binding.setSurfaceSize(const Size(800, 1200));
  addTearDown(() => tester.binding.setSurfaceSize(null));
  await tester.pumpWidget(buildTemplate(
    onAddNewEquipment: onAddNewEquipment,
    onSubmit: onSubmit,
  ));
  await tester.pump();
}

// ── Finders ──────────────────────────────────────────────────────────────────

Finder get _nameField      => find.widgetWithText(AppTextFieldMolecule, 'Exercise name');
Finder get _bodyDropdown   => find.widgetWithText(AppDropdown, 'Body segment');
Finder get _outcomeDropdown => find.widgetWithText(AppDropdown, 'Outcome goals');
Finder get _equipmentDropdown => find.widgetWithText(AppDropdown, 'Equipment');
Finder get _saveButton     => find.widgetWithText(AppButton, 'Save & complete');
Finder get _bodyPicker     => find.byType(LabelOptionPickerPanel);
Finder get _equipmentPicker => find.byType(EquipmentPickerPanel);

// ── Helper: fill all 4 fields ─────────────────────────────────────────────
// Pickers now live as Positioned children of a Stack (not inside the form's
// SingleChildScrollView), so `ensureVisible` on a picker option walks up to
// the panel's own internal SingleChildScrollView.
//
// Relies on the group-level 800×1200 surface so the equipment picker
// (withFilters variant, ~370px tall) fits fully on screen without overflow.

Future<void> fillAllFields(WidgetTester tester) async {
  // Name
  await tester.ensureVisible(_nameField);
  await tester.pump();
  await tester.enterText(_nameField, 'Shoulder Press');
  await tester.pump();

  // Pickers stay open after selection — tap the InfoCarousel (above the form)
  // between selections to dismiss via the backdrop Listener.
  Future<void> closeOpenPicker() async {
    await tester.tap(find.byType(InfoCarousel));
    await tester.pump();
  }

  // Body segment
  await tester.ensureVisible(_bodyDropdown);
  await tester.pump();
  await tester.tap(_bodyDropdown);
  await tester.pump();
  await tester.tap(find.text('Core'));
  await tester.pump();
  await closeOpenPicker();

  // Outcome
  await tester.ensureVisible(_outcomeDropdown);
  await tester.pump();
  await tester.tap(_outcomeDropdown);
  await tester.pump();
  await tester.tap(find.text('Strength'));
  await tester.pump();
  await closeOpenPicker();

  // Equipment
  await tester.ensureVisible(_equipmentDropdown);
  await tester.pump();
  await tester.tap(_equipmentDropdown);
  await tester.pump();
  await tester.tap(find.text('Dumbbells'));
  // EquipmentPickerPanel defers onSelected by AppDurations.toggle so the user
  // sees the highlight before firing the callback — advance past that delay.
  await tester.pump(const Duration(milliseconds: 300));
  await closeOpenPicker();
}

// ── Tests ────────────────────────────────────────────────────────────────────

void main() {
  group('CreateExerciseDetailsTemplate', () {

    // ── Lifecycle ────────────────────────────────────────────────────────────

    testWidgets('disposes controller and focus node without leak on unmount',
        (tester) async {
      await pumpTemplate(tester);
      // Replacing the widget tree calls dispose on the State.
      // If TextEditingController or FocusNode are not disposed, Flutter's
      // test framework emits an assertion failure here.
      await tester.pumpWidget(const MaterialApp(home: SizedBox()));
      // If no exception thrown, dispose was clean.
    });

    // ── Default render ───────────────────────────────────────────────────────

    testWidgets('Details tab is active by default and shows all 4 fields',
        (tester) async {
      await pumpTemplate(tester);

      expect(_nameField,          findsOneWidget);
      expect(_bodyDropdown,       findsOneWidget);
      expect(_outcomeDropdown,    findsOneWidget);
      expect(_equipmentDropdown,  findsOneWidget);
      expect(_saveButton,         findsOneWidget);
    });

    // ── Non-Details tabs ─────────────────────────────────────────────────────

    testWidgets('non-Details tabs show Coming soon placeholder, not the form',
        (tester) async {
      await pumpTemplate(tester);

      await tester.tap(find.text('Starting'));
      await tester.pump();

      expect(find.text('Coming soon'), findsOneWidget);
      expect(_nameField, findsNothing);
    });

    // ── Picker open ───────────────────────────────────────────────────────────

    testWidgets('tapping Body segment dropdown opens LabelOptionPickerPanel',
        (tester) async {
      await pumpTemplate(tester);

      await tester.tap(_bodyDropdown);
      await tester.pump();

      expect(_bodyPicker, findsOneWidget);
      final panel = tester.widget<LabelOptionPickerPanel>(_bodyPicker);
      expect(panel.layout, LabelPickerLayout.grid2);
    });

    testWidgets('tapping Outcome dropdown opens LabelOptionPickerPanel with column layout',
        (tester) async {
      await pumpTemplate(tester);

      await tester.tap(_outcomeDropdown);
      await tester.pump();

      expect(_bodyPicker, findsOneWidget);
      final panel = tester.widget<LabelOptionPickerPanel>(_bodyPicker);
      expect(panel.layout, LabelPickerLayout.column);
    });

    testWidgets('tapping Equipment dropdown opens EquipmentPickerPanel',
        (tester) async {
      await pumpTemplate(tester);

      await tester.tap(_equipmentDropdown);
      await tester.pump();

      expect(_equipmentPicker, findsOneWidget);
    });

    // ── Picker toggle / dismiss ───────────────────────────────────────────────

    testWidgets('tapping same dropdown again closes picker', (tester) async {
      await pumpTemplate(tester);

      await tester.tap(_bodyDropdown);
      await tester.pump();
      expect(_bodyPicker, findsOneWidget);

      await tester.tap(_bodyDropdown);
      await tester.pump();
      expect(_bodyPicker, findsNothing);
    });

    testWidgets('only one picker is open at a time', (tester) async {
      await pumpTemplate(tester);

      // Open body segment picker
      await tester.tap(_bodyDropdown);
      await tester.pump();
      expect(_bodyPicker, findsOneWidget);

      // Close body picker by tapping its dropdown again
      await tester.tap(_bodyDropdown);
      await tester.pump();
      expect(_bodyPicker, findsNothing);

      // Open outcome picker
      await tester.tap(_outcomeDropdown);
      await tester.pump();

      final panels = tester.widgetList<LabelOptionPickerPanel>(_bodyPicker).toList();
      expect(panels.length, 1);
      expect(panels.first.title, 'Outcome Goals');
    });

    testWidgets('focusing the name field closes any open picker', (tester) async {
      await pumpTemplate(tester);

      await tester.tap(_bodyDropdown);
      await tester.pump();
      expect(_bodyPicker, findsOneWidget);

      // Tap the name field — this focuses it, triggering _onNameFocusChange
      await tester.tap(_nameField);
      await tester.pump();
      expect(_bodyPicker, findsNothing);
    });

    testWidgets('switching tabs closes any open picker', (tester) async {
      await pumpTemplate(tester);

      await tester.tap(_bodyDropdown);
      await tester.pump();
      expect(_bodyPicker, findsOneWidget);

      await tester.tap(find.text('Starting'));
      await tester.pump();
      expect(_bodyPicker, findsNothing);
    });

    // ── Selection ────────────────────────────────────────────────────────────

    testWidgets('selecting an option in body picker keeps picker open and stores selection',
        (tester) async {
      await pumpTemplate(tester);

      await tester.tap(_bodyDropdown);
      await tester.pump();

      await tester.tap(find.text('Core'));
      await tester.pump();

      // Picker stays open after selection
      expect(_bodyPicker, findsOneWidget);
      // Dropdown now shows the selected label, not the placeholder
      expect(find.widgetWithText(AppDropdown, 'Core'), findsOneWidget);
    });

    testWidgets('selecting equipment category chip does NOT close the picker',
        (tester) async {
      await pumpTemplate(tester);

      await tester.tap(_equipmentDropdown);
      await tester.pump();
      expect(_equipmentPicker, findsOneWidget);

      // Tap a category chip — picker must remain open
      await tester.tap(find.text('Balance'));
      await tester.pump();
      expect(_equipmentPicker, findsOneWidget);
    });

    testWidgets('tapping Add New Equipment closes picker and fires callback',
        (tester) async {
      var fired = false;
      await pumpTemplate(tester, onAddNewEquipment: () => fired = true);

      await tester.tap(_equipmentDropdown);
      await tester.pump();
      expect(_equipmentPicker, findsOneWidget);

      await tester.tap(find.text('Add New Equipment'));
      await tester.pump();

      expect(_equipmentPicker, findsNothing);
      expect(fired, isTrue);
    });

    // ── Backdrop & direct swap (new overlay behaviors) ───────────────────────

    testWidgets('tapping the backdrop closes an open picker',
        (tester) async {
      await pumpTemplate(tester);

      await tester.tap(_bodyDropdown);
      await tester.pump();
      expect(_bodyPicker, findsOneWidget);

      // Tap on the InfoCarousel row — non-interactive, above the form.
      // The translucent backdrop Listener catches pointer-down and closes.
      await tester.tap(find.byType(InfoCarousel));
      await tester.pump();
      expect(_bodyPicker, findsNothing);
    });

    // ── Save & complete ───────────────────────────────────────────────────────

    testWidgets('Save & complete is disabled when no fields are set', (tester) async {
      await pumpTemplate(tester);

      final button = tester.widget<AppButton>(_saveButton);
      expect(button.isDisabled, isTrue);
    });

    testWidgets('Save & complete is enabled when only name is filled',
        (tester) async {
      await pumpTemplate(tester);

      await tester.enterText(_nameField, 'Shoulder Press');
      await tester.pump();

      final button = tester.widget<AppButton>(_saveButton);
      expect(button.isDisabled, isFalse);
    });

    testWidgets('Save & complete is enabled when all 4 fields are set',
        (tester) async {
      await pumpTemplate(tester);

      await fillAllFields(tester);

      final button = tester.widget<AppButton>(_saveButton);
      expect(button.isDisabled, isFalse);
    });

    testWidgets('Save with only a name submits nulls for picker fields',
        (tester) async {
      ExerciseDetailsData? captured;
      await pumpTemplate(tester, onSubmit: (d) => captured = d);

      await tester.enterText(_nameField, 'Shoulder Press');
      await tester.pump();
      await tester.tap(_saveButton);
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!.name, 'Shoulder Press');
      expect(captured!.bodySegmentId, isNull);
      expect(captured!.outcomeId, isNull);
      expect(captured!.equipmentId, isNull);
    });

    testWidgets('Save & complete fires onSubmit with correct ExerciseDetailsData',
        (tester) async {
      ExerciseDetailsData? captured;
      await pumpTemplate(tester, onSubmit: (d) => captured = d);

      await fillAllFields(tester);
      await tester.tap(_saveButton);
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!.name,            'Shoulder Press');
      expect(captured!.bodySegmentId,   'core');
      expect(captured!.outcomeId,        'strength');
      expect(captured!.equipmentId,      'eq1');
    });

    // ── Tab hint messages ─────────────────────────────────────────────────────

    testWidgets('switching tabs shows the correct hint messages for that tab',
        (tester) async {
      await pumpTemplate(tester);

      // Details tab (index 3) is default — hint 1 should be visible
      expect(find.text('Details hint 1'), findsOneWidget);

      await tester.tap(find.text('Starting'));
      await tester.pump();

      expect(find.text('S1'), findsOneWidget);
      expect(find.text('Details hint 1'), findsNothing);
    });
  });
}
