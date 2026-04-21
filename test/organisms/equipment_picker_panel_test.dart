import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';
import 'package:flutter_intra/frontend/design_system/organisms/client_account/equipment_picker_panel.dart';
import 'package:flutter_intra/frontend/design_system/organisms/client_account/equipment_picker_types.dart';

const _options = [
  EquipmentOption(id: 'barbell', label: 'Barbell'),
  EquipmentOption(id: 'dumbbell', label: 'Dumbbell'),
  EquipmentOption(id: 'cable', label: 'Cable'),
];

Widget build({
  String title = 'Related equipment',
  List<EquipmentOption> options = _options,
  String? selectedId,
  ValueChanged<EquipmentOption>? onSelected,
}) {
  return MaterialApp(
    home: Scaffold(
      body: EquipmentPickerPanel(
        title: title,
        options: options,
        selectedId: selectedId,
        onSelected: onSelected ?? (_) {},
      ),
    ),
  );
}

void main() {
  group('EquipmentPickerPanel rendering', () {
    testWidgets('renders the title', (tester) async {
      await tester.pumpWidget(build(title: 'Related equipment'));
      await tester.pumpAndSettle();

      expect(find.text('Related equipment'), findsOneWidget);
    });

    testWidgets('renders a row for every option', (tester) async {
      await tester.pumpWidget(build());
      await tester.pumpAndSettle();

      expect(find.byType(SchemeOptionRow), findsNWidgets(_options.length));
    });

    testWidgets('renders each option label', (tester) async {
      await tester.pumpWidget(build());
      await tester.pumpAndSettle();

      expect(find.text('Barbell'), findsOneWidget);
      expect(find.text('Dumbbell'), findsOneWidget);
      expect(find.text('Cable'), findsOneWidget);
    });
  });

  group('EquipmentPickerPanel selection', () {
    testWidgets('onSelected fires with the tapped option', (tester) async {
      EquipmentOption? selected;
      await tester.pumpWidget(build(onSelected: (o) => selected = o));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dumbbell'));
      await tester.pump();

      expect(selected, isNotNull);
      expect(selected!.id, 'dumbbell');
      expect(selected!.label, 'Dumbbell');
    });

    testWidgets('tapping first option fires onSelected with correct option', (tester) async {
      EquipmentOption? selected;
      await tester.pumpWidget(build(onSelected: (o) => selected = o));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Barbell'));
      await tester.pump();

      expect(selected!.id, 'barbell');
    });
  });

  group('EquipmentPickerPanel entry animation', () {
    testWidgets('animates to fully visible without errors', (tester) async {
      await tester.pumpWidget(build());
      // Pump through full animation duration
      await tester.pumpAndSettle();

      // Panel is rendered and visible after animation completes
      expect(find.byType(EquipmentPickerPanel), findsOneWidget);
      expect(find.text('Related equipment'), findsOneWidget);
    });
  });
}
