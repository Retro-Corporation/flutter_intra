import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  Widget buildTestToggle({
    bool? value,
    bool selfToggle = false,
    ValueChanged<bool>? onChanged,
    ToggleSize size = ToggleSize.md,
    Color color = AppColors.brand,
    bool isDisabled = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: AppToggle(
            value: value,
            selfToggle: selfToggle,
            onChanged: onChanged,
            size: size,
            color: color,
            isDisabled: isDisabled,
          ),
        ),
      ),
    );
  }

  // Helper to extract the _TogglePainter from the widget tree
  CustomPainter findPainter(WidgetTester tester) {
    final allCustomPaints = tester.widgetList<CustomPaint>(find.byType(CustomPaint));
    final togglePaint = allCustomPaints.firstWhere(
      (cp) => cp.painter != null && cp.painter.runtimeType.toString() == '_TogglePainter',
    );
    return togglePaint.painter!;
  }

  group('AppToggle rendering', () {
    testWidgets(
      'Off state renders with painter position 0.0',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestToggle());
        final painter = findPainter(tester);
        expect((painter as dynamic).position, 0.0);
      },
    );

    testWidgets(
      'On state renders with painter position 1.0',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestToggle(value: true));
        final painter = findPainter(tester);
        expect((painter as dynamic).position, 1.0);
      },
    );

    testWidgets(
      'Disabled state reduces opacity to 0.4',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestToggle(value: false, isDisabled: true));
        final opacity = tester.widget<Opacity>(find.byType(Opacity));
        expect(opacity.opacity, 0.4);
      },
    );
  });

  group('AppToggle interaction', () {
    testWidgets(
      'Tap toggles state in selfToggle mode',
      (WidgetTester tester) async {
        final values = <bool>[];
        await tester.pumpWidget(buildTestToggle(
          selfToggle: true,
          onChanged: values.add,
        ));

        // First tap → on
        await tester.tap(find.byType(GestureDetector));
        await tester.pumpAndSettle();
        expect(values, [true]);

        // Second tap → off
        await tester.tap(find.byType(GestureDetector));
        await tester.pumpAndSettle();
        expect(values, [true, false]);
      },
    );

    testWidgets(
      'Parent-controlled mode respects value prop',
      (WidgetTester tester) async {
        // Start off
        await tester.pumpWidget(buildTestToggle(value: false));
        var painter = findPainter(tester);
        expect((painter as dynamic).position, 0.0);

        // Tap — state should NOT change visually (parent-controlled)
        await tester.tap(find.byType(GestureDetector));
        await tester.pumpAndSettle();
        painter = findPainter(tester);
        expect((painter as dynamic).position, 0.0);

        // Rebuild with true → animates to 1.0
        await tester.pumpWidget(buildTestToggle(value: true));
        await tester.pumpAndSettle();
        painter = findPainter(tester);
        expect((painter as dynamic).position, 1.0);
      },
    );

    testWidgets(
      'Disabled toggle does not respond to taps',
      (WidgetTester tester) async {
        final values = <bool>[];
        await tester.pumpWidget(buildTestToggle(
          selfToggle: true,
          isDisabled: true,
          onChanged: values.add,
        ));

        await tester.tap(find.byType(GestureDetector));
        await tester.pump();
        expect(values, isEmpty);
      },
    );
  });

  group('AppToggle sizing', () {
    testWidgets(
      'Size variants render correct SizedBox dimensions',
      (WidgetTester tester) async {
        // sm: trackWidth=52, thumbSize=24 + 1 top + 4 bottom = 29
        await tester.pumpWidget(buildTestToggle(size: ToggleSize.sm));
        var sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
        expect(sizedBox.width, 52.0);
        expect(sizedBox.height, 24 + 1.0 + 4.0);

        // md: trackWidth=68, thumbSize=32 + 1 top + 4 bottom = 37
        await tester.pumpWidget(buildTestToggle(size: ToggleSize.md));
        await tester.pump();
        sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
        expect(sizedBox.width, 68.0);
        expect(sizedBox.height, 32 + 1.0 + 4.0);

        // lg: trackWidth=84, thumbSize=40 + 1 top + 4 bottom = 45
        await tester.pumpWidget(buildTestToggle(size: ToggleSize.lg));
        await tester.pump();
        sizedBox = tester.widget<SizedBox>(find.byType(SizedBox).first);
        expect(sizedBox.width, 84.0);
        expect(sizedBox.height, 40 + 1.0 + 4.0);
      },
    );
  });

  group('AppToggle color', () {
    testWidgets(
      'On state uses brand color for track',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestToggle(value: true, color: AppColors.brand));
        final painter = findPainter(tester);
        expect((painter as dynamic).trackColor, AppColors.brand);
      },
    );

    testWidgets(
      'Custom color prop changes on-state track color',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestToggle(value: true, color: AppColors.error));
        final painter = findPainter(tester);
        expect((painter as dynamic).trackColor, AppColors.error);
      },
    );

    testWidgets(
      'Off state uses surfaceBorder for track regardless of color',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestToggle(value: false, color: AppColors.error));
        final painter = findPainter(tester);
        expect((painter as dynamic).trackColor, AppColors.surfaceBorder);
      },
    );

    testWidgets(
      'Thumb face is always surface color in both states',
      (WidgetTester tester) async {
        // Off
        await tester.pumpWidget(buildTestToggle(value: false));
        var painter = findPainter(tester);
        expect((painter as dynamic).thumbColor, AppColors.surface);

        // On
        await tester.pumpWidget(buildTestToggle(value: true));
        await tester.pumpAndSettle();
        painter = findPainter(tester);
        expect((painter as dynamic).thumbColor, AppColors.surface);
      },
    );
  });

  group('AppToggle animation & 3D border', () {
    testWidgets(
      'Thumb animates between positions over 250ms',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestToggle(value: false));
        await tester.pumpAndSettle();

        // Switch to on
        await tester.pumpWidget(buildTestToggle(value: true));

        // At 0ms — should still be near 0
        await tester.pump(const Duration(milliseconds: 0));
        var painter = findPainter(tester);
        expect((painter as dynamic).position, lessThan(0.5));

        // At 125ms — should be mid-animation
        await tester.pump(const Duration(milliseconds: 125));
        painter = findPainter(tester);
        final midPosition = (painter as dynamic).position as double;
        expect(midPosition, greaterThan(0.0));
        expect(midPosition, lessThan(1.0));

        // At 250ms — should be complete
        await tester.pump(const Duration(milliseconds: 125));
        painter = findPainter(tester);
        expect((painter as dynamic).position, 1.0);
      },
    );

    testWidgets(
      '3D border is static — same values in on and off states',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestToggle(value: false));
        var painter = findPainter(tester);
        final offBorderBottom = (painter as dynamic).thumbBorderBottom;
        final offBorderSide = (painter as dynamic).thumbBorderSide;
        final offBorderTop = (painter as dynamic).thumbBorderTop;

        await tester.pumpWidget(buildTestToggle(value: true));
        await tester.pumpAndSettle();
        painter = findPainter(tester);
        expect((painter as dynamic).thumbBorderBottom, offBorderBottom);
        expect((painter as dynamic).thumbBorderSide, offBorderSide);
        expect((painter as dynamic).thumbBorderTop, offBorderTop);

        // Verify exact values
        expect((painter as dynamic).thumbBorderBottom, 4.0);
        expect((painter as dynamic).thumbBorderSide, 2.0);
        expect((painter as dynamic).thumbBorderTop, 1.0);
      },
    );
  });
}
