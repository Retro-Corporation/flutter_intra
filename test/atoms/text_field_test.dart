import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  Widget buildTestTextField({
    String? hintText,
    TextEditingController? controller,
    FocusNode? focusNode,
    ValueChanged<String>? onChanged,
    bool obscureText = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: AppTextField(
            hintText: hintText,
            controller: controller,
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
      await tester.pumpWidget(buildTestTextField(hintText: 'Email'));

      expect(find.text('Email'), findsOneWidget);
    });

    testWidgets('default border uses surfaceBorder color',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestTextField(hintText: 'Search'));

      final textField = tester.widget<TextField>(find.byType(TextField));
      final decoration = textField.decoration!;
      final enabledBorder = decoration.enabledBorder as OutlineInputBorder;

      expect(enabledBorder.borderSide.color, AppColors.surfaceBorder);
      expect(enabledBorder.borderSide.width, 1.0);
    });

    testWidgets('focused border uses brand color',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestTextField(hintText: 'Name'));

      final textField = tester.widget<TextField>(find.byType(TextField));
      final decoration = textField.decoration!;
      final focusedBorder = decoration.focusedBorder as OutlineInputBorder;

      expect(focusedBorder.borderSide.color, AppColors.brand);
      expect(focusedBorder.borderSide.width, 1.0);
    });

    testWidgets('accepts external controller and displays its text',
        (WidgetTester tester) async {
      final controller = TextEditingController(text: 'hello');

      await tester.pumpWidget(buildTestTextField(controller: controller));

      expect(find.text('hello'), findsOneWidget);

      controller.dispose();
    });

    testWidgets('onChanged callback fires when text is entered',
        (WidgetTester tester) async {
      String? changedValue;

      await tester.pumpWidget(
        buildTestTextField(onChanged: (value) => changedValue = value),
      );

      await tester.enterText(find.byType(TextField), 'test input');
      await tester.pump();

      expect(changedValue, 'test input');
    });
  });
}
