import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/atoms/button.dart';

void main() {
  // Helper to wrap widget in MaterialApp for testing
  Widget buildTestButton({
    ButtonType type = ButtonType.filled,
    ButtonSize size = ButtonSize.md,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: AppButton(
            label: 'Test',
            type: type,
            size: size,
            onPressed: () {},
          ),
        ),
      ),
    );
  }

  // Helper to extract the _ButtonPainter from the widget tree
  CustomPainter findPainter(WidgetTester tester) {
    final allCustomPaints = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
    final buttonPaint = allCustomPaints.firstWhere(
      (cp) => cp.painter != null && cp.painter.runtimeType.toString() == '_ButtonPainter',
    );
    return buttonPaint.painter!;
  }

  group('3D button border effect', () {
    testWidgets(
      'Filled button default state has 4px bottom border',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestButton());

        final painter = findPainter(tester);

        // Access border fields via reflection-like dynamic access.
        // _ButtonPainter fields are not prefixed with _ so they are accessible
        // once we have the object, even though the class name is private.
        expect((painter as dynamic).borderBottom, 4.0);
        expect((painter as dynamic).borderSide, 2.0);
        expect((painter as dynamic).borderTop, 0.0);
      },
    );

    testWidgets(
      'Filled button background color unchanged on press',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestButton());

        // Get default background color
        final defaultPainter = findPainter(tester);
        final defaultBg = (defaultPainter as dynamic).backgroundColor as Color;

        // Press
        final gesture = await tester.press(find.byType(GestureDetector));
        await tester.pump();

        // Get pressed background color
        final pressedPainter = findPainter(tester);
        final pressedBg = (pressedPainter as dynamic).backgroundColor as Color;

        // Color must be identical — no darkening
        expect(pressedBg, defaultBg);

        await gesture.up();
        await tester.pump();
      },
    );

    testWidgets(
      'Filled button pressed state flips border to top — no layout shift',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestButton());

        // Get the default ConstrainedBox height before pressing
        final defaultCB = tester.widget<ConstrainedBox>(find.byType(ConstrainedBox).last);
        final defaultMinHeight = defaultCB.constraints.minHeight;

        // Simulate press (tap down without releasing)
        final gesture = await tester.press(find.byType(GestureDetector));
        await tester.pump();

        final painter = findPainter(tester);
        // Border flips: bottom→0, top→4, sides stay 2
        expect((painter as dynamic).borderTop, 4.0);
        expect((painter as dynamic).borderBottom, 0.0);
        expect((painter as dynamic).borderSide, 2.0);
        // Border rect should not be drawn (showBorder = false)
        expect((painter as dynamic).showBorder, false);

        // Widget height stays the same — no layout shift
        final pressedCB = tester.widget<ConstrainedBox>(find.byType(ConstrainedBox).last);
        final pressedMinHeight = pressedCB.constraints.minHeight;
        expect(pressedMinHeight, defaultMinHeight);

        // Clean up the gesture
        await gesture.up();
        await tester.pump();
      },
    );

    testWidgets(
      'Outline button pressed state keeps 1px border all around',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestButton(type: ButtonType.outline));

        // Simulate press
        final gesture = await tester.press(find.byType(GestureDetector));
        await tester.pump();

        final painter = findPainter(tester);
        expect((painter as dynamic).borderBottom, 1.0);
        expect((painter as dynamic).borderSide, 1.0);
        expect((painter as dynamic).borderTop, 1.0);

        // Clean up
        await gesture.up();
        await tester.pump();
      },
    );

    testWidgets(
      'Outline button does not crash on press',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestButton(type: ButtonType.outline));

        // This previously crashed with negative EdgeInsets (-2.0 bottom padding)
        final gesture = await tester.press(find.byType(GestureDetector));
        await tester.pump();

        // Verify widget still renders — find the label text
        expect(find.text('Test'), findsOneWidget);

        await gesture.up();
        await tester.pump();
      },
    );

    testWidgets(
      'Outline pressed: border=1px, faceOffset=3, faceSideInset=2',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestButton(type: ButtonType.outline));

        final gesture = await tester.press(find.byType(GestureDetector));
        await tester.pump();

        final painter = findPainter(tester);
        // Border is 1px all around
        expect((painter as dynamic).borderTop, 1.0);
        expect((painter as dynamic).borderBottom, 1.0);
        expect((painter as dynamic).borderSide, 1.0);
        // Face drops 3px extra beyond the 1px border
        expect((painter as dynamic).faceOffset, 3.0);
        // Face horizontal inset stays at default (2px) even though border is 1px
        expect((painter as dynamic).faceSideInset, 2.0);
        // Border is always visible for outline
        expect((painter as dynamic).showBorder, true);

        await gesture.up();
        await tester.pump();
      },
    );

    testWidgets(
      'Outline default: borderTop=1, borderBottom=4, borderSide=2, faceOffset=0',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestButton(type: ButtonType.outline));

        final painter = findPainter(tester);
        expect((painter as dynamic).borderTop, 1.0);
        expect((painter as dynamic).borderBottom, 4.0);
        expect((painter as dynamic).borderSide, 2.0);
        expect((painter as dynamic).faceOffset, 0.0);
        expect((painter as dynamic).faceSideInset, 2.0);
        expect((painter as dynamic).showBorder, true);
      },
    );

    testWidgets(
      'Outline button widget size unchanged on press',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestButton(type: ButtonType.outline));

        // Measure size before press
        final beforeBox = tester.renderObject<RenderBox>(
          find.byType(GestureDetector),
        );
        final beforeSize = beforeBox.size;

        // Press
        final gesture = await tester.press(find.byType(GestureDetector));
        await tester.pump();

        // Measure size after press
        final afterBox = tester.renderObject<RenderBox>(
          find.byType(GestureDetector),
        );
        final afterSize = afterBox.size;

        // Widget size must not change
        expect(afterSize.width, beforeSize.width);
        expect(afterSize.height, beforeSize.height);

        await gesture.up();
        await tester.pump();
      },
    );
  });
}
