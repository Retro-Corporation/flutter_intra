import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('AppDropdown — flat style', () {
    testWidgets('flat style renders with AppColors.surface background', (tester) async {
      await tester.pumpWidget(wrap(
        AppDropdown(
          style: AppDropdownStyle.flat,
          variant: AppDropdownVariant.plain,
          value: null,
          placeholder: 'Select an option',
          onTap: () {},
        ),
      ));

      final container = tester.widget<Container>(find.byType(Container).first);
      final decoration = container.decoration as BoxDecoration;
      expect(decoration.color, AppColors.surface);
    });

    testWidgets('onTap fires when flat dropdown tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(wrap(
        AppDropdown(
          style: AppDropdownStyle.flat,
          variant: AppDropdownVariant.plain,
          value: null,
          placeholder: 'Select an option',
          onTap: () => tapped = true,
        ),
      ));

      await tester.tap(find.byType(GestureDetector));
      expect(tapped, isTrue);
    });

    testWidgets('shows placeholder text when value is null', (tester) async {
      await tester.pumpWidget(wrap(
        AppDropdown(
          style: AppDropdownStyle.flat,
          variant: AppDropdownVariant.plain,
          value: null,
          placeholder: 'Select an option',
          onTap: () {},
        ),
      ));

      expect(find.text('Select an option'), findsOneWidget);
    });

    testWidgets('shows value text when value is provided', (tester) async {
      await tester.pumpWidget(wrap(
        AppDropdown(
          style: AppDropdownStyle.flat,
          variant: AppDropdownVariant.plain,
          value: 'Weekly',
          placeholder: 'Select an option',
          onTap: () {},
        ),
      ));

      expect(find.text('Weekly'), findsOneWidget);
    });

    testWidgets('color param is not required for AppDropdownStyle.flat — widget creates without error', (tester) async {
      await tester.pumpWidget(wrap(
        AppDropdown(
          style: AppDropdownStyle.flat,
          variant: AppDropdownVariant.plain,
          value: null,
          placeholder: 'Select an option',
          onTap: () {},
          // color intentionally omitted
        ),
      ));

      expect(tester.takeException(), isNull);
    });
  });
}
