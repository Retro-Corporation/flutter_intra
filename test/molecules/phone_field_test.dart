import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

({TextEditingController controller, FocusNode focusNode}) _makeInput() {
  return (
    controller: TextEditingController(),
    focusNode: FocusNode(),
  );
}

void main() {
  group('AppPhoneField', () {
    testWidgets('renders with label and hint text', (tester) async {
      final input = _makeInput();
      addTearDown(() {
        input.controller.dispose();
        input.focusNode.dispose();
      });

      await tester.pumpWidget(_wrap(
        AppPhoneField(
          controller: input.controller,
          focusNode: input.focusNode,
          label: 'Phone number',
          hintText: 'Phone number',
        ),
      ));

      expect(find.text('Phone number'), findsWidgets);
    });

    testWidgets('typing 10 digits produces (XXX) XXX-XXXX format',
        (tester) async {
      final input = _makeInput();
      addTearDown(() {
        input.controller.dispose();
        input.focusNode.dispose();
      });

      await tester.pumpWidget(_wrap(
        AppPhoneField(
          controller: input.controller,
          focusNode: input.focusNode,
          hintText: 'Phone number',
        ),
      ));

      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '5551234567');
      await tester.pump();

      expect(input.controller.text, '(555) 123-4567');
    });

    testWidgets('non-digit characters are stripped', (tester) async {
      final input = _makeInput();
      addTearDown(() {
        input.controller.dispose();
        input.focusNode.dispose();
      });

      await tester.pumpWidget(_wrap(
        AppPhoneField(
          controller: input.controller,
          focusNode: input.focusNode,
          hintText: 'Phone number',
        ),
      ));

      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), 'abc555def123ghi4567');
      await tester.pump();

      expect(input.controller.text, '(555) 123-4567');
    });

    testWidgets('input is capped at 10 digits — 11th digit is ignored',
        (tester) async {
      final input = _makeInput();
      addTearDown(() {
        input.controller.dispose();
        input.focusNode.dispose();
      });

      await tester.pumpWidget(_wrap(
        AppPhoneField(
          controller: input.controller,
          focusNode: input.focusNode,
          hintText: 'Phone number',
        ),
      ));

      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '55512345678');
      await tester.pump();

      // Only 10 digits formatted — 11th digit dropped
      expect(input.controller.text, '(555) 123-4567');
    });

    testWidgets('empty value shows no error', (tester) async {
      final input = _makeInput();
      addTearDown(() {
        input.controller.dispose();
        input.focusNode.dispose();
      });

      await tester.pumpWidget(_wrap(
        AppPhoneField(
          controller: input.controller,
          focusNode: input.focusNode,
          hintText: 'Phone number',
        ),
      ));

      await tester.pump();

      expect(
        find.text('Please enter a valid 10-digit phone number'),
        findsNothing,
      );
    });

    testWidgets('partial input shows error message', (tester) async {
      final input = _makeInput();
      addTearDown(() {
        input.controller.dispose();
        input.focusNode.dispose();
      });

      await tester.pumpWidget(_wrap(
        AppPhoneField(
          controller: input.controller,
          focusNode: input.focusNode,
          hintText: 'Phone number',
        ),
      ));

      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '5551234');
      await tester.pump();

      expect(
        find.text('Please enter a valid 10-digit phone number'),
        findsOneWidget,
      );
    });

    testWidgets('complete 10-digit input shows no error', (tester) async {
      final input = _makeInput();
      addTearDown(() {
        input.controller.dispose();
        input.focusNode.dispose();
      });

      await tester.pumpWidget(_wrap(
        AppPhoneField(
          controller: input.controller,
          focusNode: input.focusNode,
          hintText: 'Phone number',
        ),
      ));

      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '5551234567');
      await tester.pump();

      expect(
        find.text('Please enter a valid 10-digit phone number'),
        findsNothing,
      );
    });

    testWidgets('disabled state renders field as non-interactive',
        (tester) async {
      final input = _makeInput();
      addTearDown(() {
        input.controller.dispose();
        input.focusNode.dispose();
      });

      await tester.pumpWidget(_wrap(
        AppPhoneField(
          controller: input.controller,
          focusNode: input.focusNode,
          hintText: 'Phone number',
          state: FieldState.disabled,
        ),
      ));

      final textField = tester.widget<TextField>(find.byType(TextField));
      expect(textField.enabled, isFalse);
    });

    testWidgets('custom validator overrides the built-in validator',
        (tester) async {
      final input = _makeInput();
      addTearDown(() {
        input.controller.dispose();
        input.focusNode.dispose();
      });

      await tester.pumpWidget(_wrap(
        AppPhoneField(
          controller: input.controller,
          focusNode: input.focusNode,
          hintText: 'Phone number',
          validator: (value) {
            final digits = value.replaceAll(RegExp(r'\D'), '');
            if (digits.isEmpty) return null;
            return 'Custom error';
          },
        ),
      ));

      await tester.tap(find.byType(TextField));
      await tester.enterText(find.byType(TextField), '5551234567');
      await tester.pump();

      // Custom validator fires for all non-empty values, even complete ones
      expect(find.text('Custom error'), findsOneWidget);
    });
  });
}
