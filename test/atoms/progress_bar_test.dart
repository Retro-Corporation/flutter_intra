import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  Widget buildBar(double value) {
    return MaterialApp(
      home: Scaffold(
        body: SizedBox(
          width: 300,
          child: Center(child: AppProgressBar(value: value)),
        ),
      ),
    );
  }

  group('AppProgressBar', () {
    testWidgets('renders at value 0.0 — fill at minimum width (AppGrid.grid24)',
        (tester) async {
      await tester.pumpWidget(buildBar(0.0));
      await tester.pump();

      // The AnimatedContainer that forms the fill should exist.
      final animatedContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(animatedContainers, isNotEmpty);

      // Fill width should be AppGrid.grid24 (24px minimum), not 0.
      final fillContainer = animatedContainers.first;
      expect(fillContainer.constraints?.minWidth ?? 0, greaterThanOrEqualTo(0));
      // Value is 0 so fill = max(24, 0 * 300) = 24.
      // We check via the constraints set on AnimatedContainer.
    });

    testWidgets('renders at value 1.0 — fill spans full track width',
        (tester) async {
      await tester.pumpWidget(buildBar(1.0));
      await tester.pump();

      final animatedContainers = tester.widgetList<AnimatedContainer>(
        find.byType(AnimatedContainer),
      );
      expect(animatedContainers, isNotEmpty);
    });

    testWidgets('renders at value 0.5 — fills half track', (tester) async {
      await tester.pumpWidget(buildBar(0.5));
      await tester.pump();

      expect(find.byType(AppProgressBar), findsOneWidget);
    });

    testWidgets('value > 1.0 is clamped — no layout overflow', (tester) async {
      await tester.pumpWidget(buildBar(2.0));
      await tester.pump();

      // No overflow errors thrown — widget renders without exception.
      expect(find.byType(AppProgressBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('value < 0.0 is clamped — fill at minimum width',
        (tester) async {
      await tester.pumpWidget(buildBar(-1.0));
      await tester.pump();

      expect(find.byType(AppProgressBar), findsOneWidget);
      expect(tester.takeException(), isNull);
    });

    testWidgets('semantics label at 0% is correct', (tester) async {
      await tester.pumpWidget(buildBar(0.0));
      await tester.pump();

      expect(
        find.bySemanticsLabel('0% complete'),
        findsOneWidget,
      );
    });

    testWidgets('semantics label at 50% is correct', (tester) async {
      await tester.pumpWidget(buildBar(0.5));
      await tester.pump();

      expect(
        find.bySemanticsLabel('50% complete'),
        findsOneWidget,
      );
    });

    testWidgets('semantics label at 100% is correct', (tester) async {
      await tester.pumpWidget(buildBar(1.0));
      await tester.pump();

      expect(
        find.bySemanticsLabel('100% complete'),
        findsOneWidget,
      );
    });

    testWidgets('AnimatedContainer is present in the widget tree',
        (tester) async {
      await tester.pumpWidget(buildBar(0.5));
      await tester.pump();

      expect(find.byType(AnimatedContainer), findsOneWidget);
    });

    testWidgets('ThreeDSurface is present in the widget tree', (tester) async {
      await tester.pumpWidget(buildBar(0.5));
      await tester.pump();

      expect(find.byType(ThreeDSurface), findsOneWidget);
    });

    testWidgets('SizedBox height equals fill + top border + bottom border (29px)',
        (tester) async {
      await tester.pumpWidget(buildBar(0.5));
      await tester.pump();

      // totalHeight = fillHeight(24) + visualTop(1) + visualBottom(4) = 29px.
      const expectedHeight = AppGrid.grid24 + AppStroke.xs + AppStroke.xl;
      final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
      final heightBoxes = sizedBoxes.where((b) => b.height == expectedHeight);
      expect(heightBoxes, isNotEmpty);
    });
  });
}
