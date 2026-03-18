import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/atoms/button.dart';
import 'package:flutter_intra/frontend/design_system/foundation/colors.dart';

void main() {
  // Helper to wrap widget in MaterialApp for testing
  Widget buildTestButton({
    ButtonType type = ButtonType.filled,
    ButtonSize size = ButtonSize.md,
    bool? isActive,
    bool selfToggle = false,
    ValueChanged<bool>? onActiveChanged,
    VoidCallback? onPressed,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: AppButton(
            label: 'Test',
            type: type,
            size: size,
            isActive: isActive,
            selfToggle: selfToggle,
            onActiveChanged: onActiveChanged,
            onPressed: onPressed ?? () {},
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

  group('Active state (filled)', () {
    testWidgets(
      'Active default has same geometry as default filled',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestButton(isActive: true));

        final painter = findPainter(tester);
        expect((painter as dynamic).borderBottom, 4.0);
        expect((painter as dynamic).borderSide, 2.0);
        expect((painter as dynamic).borderTop, 0.0);
        expect((painter as dynamic).showBorder, true);
      },
    );

    testWidgets(
      'Active colors: surface background, brand border color',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestButton(isActive: true));

        final painter = findPainter(tester);
        final bg = (painter as dynamic).backgroundColor as Color;
        final borderColor = (painter as dynamic).borderColor as Color;

        expect(bg, AppColors.surface);
        expect(borderColor, AppColors.brandDark); // orange700 via _resolve700
      },
    );

    testWidgets(
      'Active pressed has same geometry as default pressed',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestButton(isActive: true));

        final gesture = await tester.press(find.byType(GestureDetector));
        await tester.pump();

        final painter = findPainter(tester);
        expect((painter as dynamic).borderTop, 4.0);
        expect((painter as dynamic).borderBottom, 0.0);
        expect((painter as dynamic).borderSide, 2.0);
        expect((painter as dynamic).showBorder, false);

        await gesture.up();
        await tester.pump();
      },
    );

    testWidgets(
      'Active background unchanged on press',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestButton(isActive: true));

        final defaultPainter = findPainter(tester);
        final defaultBg = (defaultPainter as dynamic).backgroundColor as Color;

        final gesture = await tester.press(find.byType(GestureDetector));
        await tester.pump();

        final pressedPainter = findPainter(tester);
        final pressedBg = (pressedPainter as dynamic).backgroundColor as Color;

        expect(pressedBg, defaultBg);
        expect(pressedBg, AppColors.surface);

        await gesture.up();
        await tester.pump();
      },
    );

    testWidgets(
      'Active no layout shift on press',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestButton(isActive: true));

        final beforeBox = tester.renderObject<RenderBox>(
          find.byType(GestureDetector),
        );
        final beforeSize = beforeBox.size;

        final gesture = await tester.press(find.byType(GestureDetector));
        await tester.pump();

        final afterBox = tester.renderObject<RenderBox>(
          find.byType(GestureDetector),
        );
        final afterSize = afterBox.size;

        expect(afterSize.width, beforeSize.width);
        expect(afterSize.height, beforeSize.height);

        await gesture.up();
        await tester.pump();
      },
    );

    testWidgets(
      'Self-toggle flips between default and active colors',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestButton(selfToggle: true));

        // Before tap: default colors (brand background)
        final beforePainter = findPainter(tester);
        final beforeBg = (beforePainter as dynamic).backgroundColor as Color;
        expect(beforeBg, AppColors.brand);

        // Tap to toggle active
        await tester.tap(find.byType(GestureDetector));
        await tester.pump();

        // After tap: active colors (surface background)
        final afterPainter = findPainter(tester);
        final afterBg = (afterPainter as dynamic).backgroundColor as Color;
        expect(afterBg, AppColors.surface);

        // Tap again to toggle back
        await tester.tap(find.byType(GestureDetector));
        await tester.pump();

        final resetPainter = findPainter(tester);
        final resetBg = (resetPainter as dynamic).backgroundColor as Color;
        expect(resetBg, AppColors.brand);
      },
    );

    testWidgets(
      'Self-toggle fires onActiveChanged callback',
      (WidgetTester tester) async {
        final values = <bool>[];
        await tester.pumpWidget(buildTestButton(
          selfToggle: true,
          onActiveChanged: (v) => values.add(v),
        ));

        // First tap → active
        await tester.tap(find.byType(GestureDetector));
        await tester.pump();
        expect(values, [true]);

        // Second tap → inactive
        await tester.tap(find.byType(GestureDetector));
        await tester.pump();
        expect(values, [true, false]);
      },
    );

    testWidgets(
      'Parent-controlled does not self-toggle',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestButton(isActive: false));

        // Tap — parent-controlled, so button state doesn't change internally
        await tester.tap(find.byType(GestureDetector));
        await tester.pump();

        final painter = findPainter(tester);
        final bg = (painter as dynamic).backgroundColor as Color;
        // Still brand (not surface), because isActive is still false
        expect(bg, AppColors.brand);
      },
    );

    testWidgets(
      'Parent-controlled fires onActiveChanged with toggled value',
      (WidgetTester tester) async {
        final values = <bool>[];
        await tester.pumpWidget(buildTestButton(
          isActive: false,
          onActiveChanged: (v) => values.add(v),
        ));

        await tester.tap(find.byType(GestureDetector));
        await tester.pump();

        // Should fire with !isActive = true
        expect(values, [true]);
      },
    );

    testWidgets(
      'Null isActive means no active behavior — default colors',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestButton());

        final painter = findPainter(tester);
        final bg = (painter as dynamic).backgroundColor as Color;
        // Default filled: brand color background
        expect(bg, AppColors.brand);
      },
    );
  });
}
