import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  Widget buildTestCheckbox({
    bool? selected,
    bool selfToggle = false,
    ValueChanged<bool>? onChanged,
    CheckboxSize size = CheckboxSize.md,
    Color color = AppColors.brand,
    bool isIndeterminate = false,
    bool isDisabled = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: AppCheckbox(
            selected: selected,
            selfToggle: selfToggle,
            onChanged: onChanged,
            size: size,
            color: color,
            isIndeterminate: isIndeterminate,
            isDisabled: isDisabled,
          ),
        ),
      ),
    );
  }

  // Helper to extract the _CheckboxPainter from the widget tree
  CustomPainter findPainter(WidgetTester tester) {
    final allCustomPaints = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
    final checkboxPaint = allCustomPaints.firstWhere(
      (cp) => cp.painter != null && cp.painter.runtimeType.toString() == 'ThreeDPressPainter',
    );
    return checkboxPaint.painter!;
  }

  // The check/minus icon is always in the tree, wrapped in an Opacity that
  // animates between 0.0 (unchecked) and 1.0 (checked/indeterminate).
  double iconOpacity(WidgetTester tester) {
    final opacity = tester.widget<Opacity>(
      find
          .ancestor(
            of: find.byType(AppIcon),
            matching: find.byType(Opacity),
          )
          .first,
    );
    return opacity.opacity;
  }

  group('AppCheckbox rendering', () {
    testWidgets(
      'Unchecked by default — icon is fully transparent',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestCheckbox());

        // Icon is always in tree; Opacity wrapper is 0.0 when unchecked.
        expect(iconOpacity(tester), 0.0);
      },
    );

    testWidgets(
      'Checked state shows check icon via AppIcon',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestCheckbox(selected: true));

        final iconFinder = find.byType(AppIcon);
        expect(iconFinder, findsOneWidget);

        final icon = tester.widget<AppIcon>(iconFinder);
        expect(icon.icon, AppIcons.check);
      },
    );

    testWidgets(
      'Indeterminate state shows minus icon via AppIcon',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestCheckbox(isIndeterminate: true));

        final iconFinder = find.byType(AppIcon);
        expect(iconFinder, findsOneWidget);

        final icon = tester.widget<AppIcon>(iconFinder);
        expect(icon.icon, AppIcons.minus);
      },
    );
  });

  group('AppCheckbox interaction', () {
    testWidgets(
      'Tap toggles state in selfToggle mode',
      (WidgetTester tester) async {
        final values = <bool>[];
        await tester.pumpWidget(buildTestCheckbox(
          selfToggle: true,
          onChanged: values.add,
        ));

        // Initially unchecked — icon opacity is 0
        expect(iconOpacity(tester), 0.0);

        // First tap → checked (settle to let the state animation complete)
        await tester.tap(find.byType(GestureDetector));
        await tester.pumpAndSettle();
        expect(iconOpacity(tester), 1.0);
        expect(values, [true]);

        // Second tap → unchecked
        await tester.tap(find.byType(GestureDetector));
        await tester.pumpAndSettle();
        expect(iconOpacity(tester), 0.0);
        expect(values, [true, false]);
      },
    );

    testWidgets(
      'Parent-controlled mode respects selected prop',
      (WidgetTester tester) async {
        // Start unchecked
        await tester.pumpWidget(buildTestCheckbox(selected: false));
        expect(iconOpacity(tester), 0.0);

        // Tap — state should NOT change (parent-controlled)
        await tester.tap(find.byType(GestureDetector));
        await tester.pumpAndSettle();
        expect(iconOpacity(tester), 0.0);

        // Rebuild with selected: true — now the icon fades in
        await tester.pumpWidget(buildTestCheckbox(selected: true));
        await tester.pumpAndSettle();
        expect(iconOpacity(tester), 1.0);
      },
    );

    testWidgets(
      'Disabled checkbox does not respond to taps',
      (WidgetTester tester) async {
        final values = <bool>[];
        await tester.pumpWidget(buildTestCheckbox(
          selfToggle: true,
          isDisabled: true,
          onChanged: values.add,
        ));

        // Tap — should not fire callback
        await tester.tap(find.byType(GestureDetector));
        await tester.pumpAndSettle();

        expect(values, isEmpty);
        // Should still be unchecked
        expect(iconOpacity(tester), 0.0);
      },
    );
  });

  group('AppCheckbox sizing', () {
    testWidgets(
      'Size variants render correct SizedBox dimensions',
      (WidgetTester tester) async {
        // sm: 24px face + 4px side insets = 28px wide, 24 + 4 = 28px tall
        await tester.pumpWidget(buildTestCheckbox(size: CheckboxSize.sm));
        var sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
        expect(sizedBox.width, 24 + 4.0); // size + 2*layoutSide
        expect(sizedBox.height, 24 + 4.0); // size + 4.0 depth

        // md: 28px face + 4px insets = 32px wide, 28 + 4 = 32px tall
        await tester.pumpWidget(buildTestCheckbox(size: CheckboxSize.md));
        await tester.pump();
        sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
        expect(sizedBox.width, 28 + 4.0);
        expect(sizedBox.height, 28 + 4.0);

        // lg: 32px face + 4px insets = 36px wide, 32 + 4 = 36px tall
        await tester.pumpWidget(buildTestCheckbox(size: CheckboxSize.lg));
        await tester.pump();
        sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
        expect(sizedBox.width, 32 + 4.0);
        expect(sizedBox.height, 32 + 4.0);
      },
    );
  });

  group('AppCheckbox color', () {
    testWidgets(
      'Color prop changes checked background color',
      (WidgetTester tester) async {
        // Checked with brand color
        await tester.pumpWidget(buildTestCheckbox(
          selected: true,
          color: AppColors.brand,
        ));
        var painter = findPainter(tester);
        expect((painter as dynamic).backgroundColor, AppColors.brand);

        // Checked with error color
        await tester.pumpWidget(buildTestCheckbox(
          selected: true,
          color: AppColors.error,
        ));
        await tester.pump();
        painter = findPainter(tester);
        expect((painter as dynamic).backgroundColor, AppColors.error);
      },
    );

    testWidgets(
      'Unchecked state has transparent background regardless of color',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestCheckbox(
          selected: false,
          color: AppColors.error,
        ));
        final painter = findPainter(tester);
        expect((painter as dynamic).backgroundColor, Colors.transparent);
      },
    );
  });

  group('AppCheckbox 3D border', () {
    testWidgets(
      'Checked default has 4px bottom border (3D depth)',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestCheckbox(selected: true));

        final painter = findPainter(tester);
        expect((painter as dynamic).borderBottom, 4.0);
        expect((painter as dynamic).borderTop, 0.0);
        expect((painter as dynamic).borderSide, 2.0);
      },
    );

    testWidgets(
      'Checked pressed flips border to top — no layout shift',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestCheckbox(selected: true));

        // Measure size before press
        final beforeBox = tester.renderObject<RenderBox>(
          find.byType(GestureDetector),
        );
        final beforeSize = beforeBox.size;

        // Press
        final gesture = await tester.press(find.byType(GestureDetector));
        await tester.pumpAndSettle();

        final painter = findPainter(tester);
        expect((painter as dynamic).borderTop, 4.0);
        expect((painter as dynamic).borderBottom, 0.0);
        expect((painter as dynamic).showBorder, false);

        // No layout shift
        final afterBox = tester.renderObject<RenderBox>(
          find.byType(GestureDetector),
        );
        expect(afterBox.size.width, beforeSize.width);
        expect(afterBox.size.height, beforeSize.height);

        await gesture.up();
        await tester.pump();
      },
    );

    testWidgets(
      'Unchecked pressed: 1px border all around (flat)',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestCheckbox(selected: false));

        final gesture = await tester.press(find.byType(GestureDetector));
        await tester.pumpAndSettle();

        final painter = findPainter(tester);
        expect((painter as dynamic).borderTop, 1.0);
        expect((painter as dynamic).borderBottom, 1.0);
        expect((painter as dynamic).borderSide, 1.0);

        await gesture.up();
        await tester.pump();
      },
    );
  });
}
