import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';
import 'package:flutter_intra/frontend/design_system/molecules/controls/labeled_checkbox.dart';

void main() {
  Widget build({
    required String label,
    required bool isChecked,
    required ValueChanged<bool> onChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: LabeledCheckbox(
            label: label,
            isChecked: isChecked,
            onChanged: onChanged,
          ),
        ),
      ),
    );
  }

  group('LabeledCheckbox rendering', () {
    testWidgets('renders label text', (WidgetTester tester) async {
      await tester.pumpWidget(build(
        label: 'Accept terms',
        isChecked: false,
        onChanged: (_) {},
      ));

      expect(find.text('Accept terms'), findsOneWidget);
    });

    testWidgets('renders AppCheckbox', (WidgetTester tester) async {
      await tester.pumpWidget(build(
        label: 'Accept terms',
        isChecked: false,
        onChanged: (_) {},
      ));

      expect(find.byType(AppCheckbox), findsOneWidget);
    });

    testWidgets('checked state passes selected:true to AppCheckbox',
        (WidgetTester tester) async {
      await tester.pumpWidget(build(
        label: 'Accept terms',
        isChecked: true,
        onChanged: (_) {},
      ));

      final checkbox = tester.widget<AppCheckbox>(find.byType(AppCheckbox));
      expect(checkbox.selected, isTrue);
    });

    testWidgets('unchecked state passes selected:false to AppCheckbox',
        (WidgetTester tester) async {
      await tester.pumpWidget(build(
        label: 'Accept terms',
        isChecked: false,
        onChanged: (_) {},
      ));

      final checkbox = tester.widget<AppCheckbox>(find.byType(AppCheckbox));
      expect(checkbox.selected, isFalse);
    });
  });

  group('LabeledCheckbox interaction', () {
    testWidgets('tapping unchecked row calls onChanged with true',
        (WidgetTester tester) async {
      final values = <bool>[];
      await tester.pumpWidget(
          build(label: 'Test', isChecked: false, onChanged: values.add));
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();
      expect(values, [true]);
    });

    testWidgets('tapping checked row calls onChanged with false',
        (WidgetTester tester) async {
      final values = <bool>[];
      await tester.pumpWidget(
          build(label: 'Test', isChecked: true, onChanged: values.add));
      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();
      expect(values, [false]);
    });
  });

  group('LabeledCheckbox layout', () {
    testWidgets('long label does not overflow (Expanded wraps)',
        (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 200,
              child: LabeledCheckbox(
                label:
                    'A very long label that should wrap within the available width without overflowing',
                isChecked: false,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      await tester.pump();
      // No overflow exception means the Expanded widget is correctly constraining
      // the label text within the available width.
      expect(tester.takeException(), isNull);
    });
  });
}
