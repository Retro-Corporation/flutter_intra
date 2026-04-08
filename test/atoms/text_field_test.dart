import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  Widget buildTestTextField({
    required TextEditingController controller,
    String? hintText,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    bool obscureText = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: AppTextField(
            controller: controller,
            hintText: hintText,
            focusNode: focusNode,
            onChanged: onChanged,
            obscureText: obscureText,
          ),
        ),
      ),
    );
  }

  group('AppTextField', () {
    testWidgets('renders with hint text', (WidgetTester tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestTextField(controller: controller, hintText: 'Email'),
      );

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('default border uses surfaceBorder color',
        (WidgetTester tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestTextField(controller: controller, hintText: 'Search'),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      final decoration = textField.decoration!;
      final enabledBorder = decoration.enabledBorder as OutlineInputBorder;

      expect(enabledBorder.borderSide.color, AppColors.surfaceBorder);
      expect(enabledBorder.borderSide.width, 1.0);
    });

    testWidgets('focused border uses brand color',
        (WidgetTester tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestTextField(controller: controller, hintText: 'Name'),
      );

      final textField = tester.widget<TextField>(find.byType(TextField));
      final decoration = textField.decoration!;
      final focusedBorder = decoration.focusedBorder as OutlineInputBorder;

      expect(focusedBorder.borderSide.color, AppColors.brand);
      expect(focusedBorder.borderSide.width, 1.0);
    });

    testWidgets('accepts controller and displays its text',
        (WidgetTester tester) async {
      final controller = TextEditingController(text: 'hello');
      addTearDown(controller.dispose);

      await tester.pumpWidget(
        buildTestTextField(controller: controller),
      );

      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('onChanged callback fires when text is entered',
        (WidgetTester tester) async {
      final controller = TextEditingController();
      addTearDown(controller.dispose);
      String? changedValue;

      await tester.pumpWidget(
        buildTestTextField(
          controller: controller,
          onChanged: (value) => changedValue = value,
        ),
      );

      await tester.enterText(find.byType(TextField), 'test input');
      await tester.pump();

      expect(changedValue, 'test input');
    });
  });
}
