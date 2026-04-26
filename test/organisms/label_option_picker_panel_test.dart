import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';
import 'package:flutter_intra/frontend/design_system/organisms/client_account/label_option_picker_panel.dart';
import 'package:flutter_intra/frontend/design_system/organisms/client_account/label_option_picker_types.dart';

const _columnOptions = [
  LabelOption(id: 'chest', label: 'Chest'),
  LabelOption(id: 'back', label: 'Back'),
  LabelOption(id: 'legs', label: 'Legs'),
  LabelOption(id: 'shoulders', label: 'Shoulders'),
];

const _grid2Options = [
  LabelOption(id: 'upper', label: 'Upper'),
  LabelOption(id: 'lower', label: 'Lower'),
  LabelOption(id: 'push', label: 'Push'),
  LabelOption(id: 'pull', label: 'Pull'),
];

Widget build({
  String title = 'Body Segments',
  List<LabelOption> options = _columnOptions,
  String? selectedId,
  ValueChanged<LabelOption>? onSelected,
  LabelPickerLayout layout = LabelPickerLayout.column,
}) {
  return MaterialApp(
    home: Scaffold(
      body: LabelOptionPickerPanel(
        title: title,
        options: options,
        selectedId: selectedId,
        onSelected: onSelected ?? (_) {},
        layout: layout,
      ),
    ),
  );
}

void main() {
  group('LabelOptionPickerPanel rendering', () {
    testWidgets('renders the title text', (tester) async {
      await tester.pumpWidget(build(title: 'Body Segments'));
      await tester.pumpAndSettle();

      expect(find.text('Body Segments'), findsOneWidget);
    });

    testWidgets('column layout renders all N SchemeOptionRow widgets',
        (tester) async {
      await tester.pumpWidget(build(
        options: _columnOptions,
        layout: LabelPickerLayout.column,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(SchemeOptionRow), findsNWidgets(_columnOptions.length));
    });

    testWidgets('grid2 layout renders all N SchemeOptionRow widgets',
        (tester) async {
      await tester.pumpWidget(build(
        options: _grid2Options,
        layout: LabelPickerLayout.grid2,
      ));
      await tester.pumpAndSettle();

      expect(find.byType(SchemeOptionRow), findsNWidgets(_grid2Options.length));
    });
  });

  group('LabelOptionPickerPanel selection', () {
    testWidgets('selectedId drives which row shows as selected', (tester) async {
      await tester.pumpWidget(build(
        options: _columnOptions,
        selectedId: 'back',
        layout: LabelPickerLayout.column,
      ));
      await tester.pumpAndSettle();

      final rows = tester.widgetList<SchemeOptionRow>(
        find.byType(SchemeOptionRow),
      ).toList();

      expect(rows[0].isSelected, isFalse); // chest
      expect(rows[1].isSelected, isTrue);  // back
      expect(rows[2].isSelected, isFalse); // legs
      expect(rows[3].isSelected, isFalse); // shoulders
    });

    testWidgets(
        'tapping a row in column layout fires onSelected with the correct LabelOption',
        (tester) async {
      LabelOption? selected;
      await tester.pumpWidget(build(
        options: _columnOptions,
        layout: LabelPickerLayout.column,
        onSelected: (o) => selected = o,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Legs'));
      await tester.pump();

      expect(selected, isNotNull);
      expect(selected!.id, 'legs');
      expect(selected!.label, 'Legs');
    });

    testWidgets(
        'tapping a row in grid2 layout fires onSelected with the correct LabelOption',
        (tester) async {
      LabelOption? selected;
      await tester.pumpWidget(build(
        options: _grid2Options,
        layout: LabelPickerLayout.grid2,
        onSelected: (o) => selected = o,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Pull'));
      await tester.pump();

      expect(selected, isNotNull);
      expect(selected!.id, 'pull');
      expect(selected!.label, 'Pull');
    });
  });

  group('LabelOptionPickerPanel animation', () {
    testWidgets('panel mounts and animates to visible without errors',
        (tester) async {
      await tester.pumpWidget(build());
      await tester.pumpAndSettle();

      expect(find.byType(LabelOptionPickerPanel), findsOneWidget);
      expect(find.text('Body Segments'), findsOneWidget);
    });
  });
}
