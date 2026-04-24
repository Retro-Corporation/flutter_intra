import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('LabeledToggle', () {
    testWidgets('renders label text', (tester) async {
      await tester.pumpWidget(wrap(
        LabeledToggle(label: 'Alerts', value: false, onChanged: (_) {}),
      ));
      expect(find.text('Alerts'), findsOneWidget);
    });

    testWidgets('renders AppToggle', (tester) async {
      await tester.pumpWidget(wrap(
        LabeledToggle(label: 'Alerts', value: false, onChanged: (_) {}),
      ));
      expect(find.byType(AppToggle), findsOneWidget);
    });

    testWidgets('reflects value true', (tester) async {
      await tester.pumpWidget(wrap(
        LabeledToggle(label: 'Alerts', value: true, onChanged: (_) {}),
      ));
      final toggle = tester.widget<AppToggle>(find.byType(AppToggle));
      expect(toggle.value, isTrue);
    });

    testWidgets('reflects value false', (tester) async {
      await tester.pumpWidget(wrap(
        LabeledToggle(label: 'Alerts', value: false, onChanged: (_) {}),
      ));
      final toggle = tester.widget<AppToggle>(find.byType(AppToggle));
      expect(toggle.value, isFalse);
    });

    testWidgets('fires onChanged when toggled', (tester) async {
      bool? received;
      await tester.pumpWidget(wrap(
        LabeledToggle(
          label: 'Alerts',
          value: false,
          onChanged: (v) => received = v,
        ),
      ));
      await tester.tap(find.byType(AppToggle));
      expect(received, isNotNull);
    });

    testWidgets('long label does not overflow in constrained width', (tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: SizedBox(
              width: 300,
              child: LabeledToggle(
                label: 'A very long notification label that should wrap gracefully',
                value: true,
                onChanged: (_) {},
              ),
            ),
          ),
        ),
      );
      expect(tester.takeException(), isNull);
    });
  });
}
