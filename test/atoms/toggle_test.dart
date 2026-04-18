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

  // Thumb painter = the ThreeDPressPainter inside the toggle's ThreeDSurface.
  ThreeDPressPainter findThumbPainter(WidgetTester tester) {
    final surface = tester.widget<ThreeDSurface>(find.byType(ThreeDSurface));
    return surface.painter;
  }

  // Track color — pulled from the DecoratedBox that renders the pill track.
  Color findTrackColor(WidgetTester tester) {
    final dec = tester.widget<DecoratedBox>(
      find.descendant(
        of: find.byType(AppToggle),
        matching: find.byType(DecoratedBox),
      ),
    );
    return (dec.decoration as BoxDecoration).color!;
  }

  // Thumb position as [0.0 … 1.0] — derived from the thumb Positioned's `left`
  // divided by the total thumb travel distance.
  double findThumbPosition(WidgetTester tester, ToggleSize size) {
    // The thumb's Positioned has top: 0; the track's has top: trackTop > 0.
    final thumb = tester
        .widgetList<Positioned>(find.descendant(
          of: find.byType(AppToggle),
          matching: find.byType(Positioned),
        ))
        .firstWhere((p) => p.top == 0);

    // trackWidth and thumbSize per ToggleSize — see _ToggleSizeConfig.
    final (trackWidth, thumbSize) = switch (size) {
      ToggleSize.sm => (52.0, 24.0),
      ToggleSize.md => (68.0, 32.0),
      ToggleSize.lg => (84.0, 40.0),
    };
    const thumbBorderSide = 2.0; // AppStroke.md
    final thumbOuterWidth = thumbSize + (thumbBorderSide * 2);
    final thumbTravel = trackWidth - thumbOuterWidth;
    return thumbTravel == 0 ? 0.0 : (thumb.left ?? 0) / thumbTravel;
  }

  group('AppToggle rendering', () {
    testWidgets(
      'Off state renders with thumb at position 0.0',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestToggle());
        expect(findThumbPosition(tester, ToggleSize.md), 0.0);
      },
    );

    testWidgets(
      'On state renders with thumb at position 1.0',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestToggle(value: true));
        expect(findThumbPosition(tester, ToggleSize.md), 1.0);
      },
    );

    testWidgets(
      'Disabled state reduces opacity to 0.4',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestToggle(value: false, isDisabled: true));
        final opacity = tester.widget<Opacity>(
          find.descendant(
            of: find.byType(AppToggle),
            matching: find.byType(Opacity),
          ),
        );
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
        await tester.tap(find.byType(AppToggle));
        await tester.pumpAndSettle();
        expect(values, [true]);

        // Second tap → off
        await tester.tap(find.byType(AppToggle));
        await tester.pumpAndSettle();
        expect(values, [true, false]);
      },
    );

    testWidgets(
      'Parent-controlled mode respects value prop',
      (WidgetTester tester) async {
        // Start off
        await tester.pumpWidget(buildTestToggle(value: false));
        expect(findThumbPosition(tester, ToggleSize.md), 0.0);

        // Tap — state should NOT change visually (parent-controlled)
        await tester.tap(find.byType(AppToggle));
        await tester.pumpAndSettle();
        expect(findThumbPosition(tester, ToggleSize.md), 0.0);

        // Rebuild with true → animates to 1.0
        await tester.pumpWidget(buildTestToggle(value: true));
        await tester.pumpAndSettle();
        expect(findThumbPosition(tester, ToggleSize.md), 1.0);
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

        await tester.tap(find.byType(AppToggle));
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
        var sizedBox = tester.widget<SizedBox>(
          find.descendant(
            of: find.byType(AppToggle),
            matching: find.byType(SizedBox),
          ).first,
        );
        expect(sizedBox.width, 52.0);
        expect(sizedBox.height, 24 + 1.0 + 4.0);

        // md: trackWidth=68, thumbSize=32 + 1 top + 4 bottom = 37
        await tester.pumpWidget(buildTestToggle(size: ToggleSize.md));
        await tester.pump();
        sizedBox = tester.widget<SizedBox>(
          find.descendant(
            of: find.byType(AppToggle),
            matching: find.byType(SizedBox),
          ).first,
        );
        expect(sizedBox.width, 68.0);
        expect(sizedBox.height, 32 + 1.0 + 4.0);

        // lg: trackWidth=84, thumbSize=40 + 1 top + 4 bottom = 45
        await tester.pumpWidget(buildTestToggle(size: ToggleSize.lg));
        await tester.pump();
        sizedBox = tester.widget<SizedBox>(
          find.descendant(
            of: find.byType(AppToggle),
            matching: find.byType(SizedBox),
          ).first,
        );
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
        expect(findTrackColor(tester), AppColors.brand);
      },
    );

    testWidgets(
      'Custom color prop changes on-state track color',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestToggle(value: true, color: AppColors.error));
        expect(findTrackColor(tester), AppColors.error);
      },
    );

    testWidgets(
      'Off state uses surfaceBorder for track regardless of color',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestToggle(value: false, color: AppColors.error));
        expect(findTrackColor(tester), AppColors.surfaceBorder);
      },
    );

    testWidgets(
      'Thumb face is always surface color in both states',
      (WidgetTester tester) async {
        // Off
        await tester.pumpWidget(buildTestToggle(value: false));
        expect(findThumbPainter(tester).backgroundColor, AppColors.surface);

        // On
        await tester.pumpWidget(buildTestToggle(value: true));
        await tester.pumpAndSettle();
        expect(findThumbPainter(tester).backgroundColor, AppColors.surface);
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
        expect(findThumbPosition(tester, ToggleSize.md), lessThan(0.5));

        // At 125ms — should be mid-animation
        await tester.pump(const Duration(milliseconds: 125));
        final midPosition = findThumbPosition(tester, ToggleSize.md);
        expect(midPosition, greaterThan(0.0));
        expect(midPosition, lessThan(1.0));

        // At 250ms — should be complete
        await tester.pump(const Duration(milliseconds: 125));
        expect(findThumbPosition(tester, ToggleSize.md), 1.0);
      },
    );

    testWidgets(
      '3D border is static — same values in on and off states',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestToggle(value: false));
        final offPainter = findThumbPainter(tester);
        final offBorderBottom = offPainter.borderBottom;
        final offBorderSide = offPainter.borderSide;
        final offBorderTop = offPainter.borderTop;

        await tester.pumpWidget(buildTestToggle(value: true));
        await tester.pumpAndSettle();
        final onPainter = findThumbPainter(tester);
        expect(onPainter.borderBottom, offBorderBottom);
        expect(onPainter.borderSide, offBorderSide);
        expect(onPainter.borderTop, offBorderTop);

        // Verify exact values
        expect(onPainter.borderBottom, 4.0);
        expect(onPainter.borderSide, 2.0);
        expect(onPainter.borderTop, 1.0);
      },
    );
  });
}
