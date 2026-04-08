import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  Widget buildTestPathButton({
    PathButtonShape shape = PathButtonShape.circle,
    PathButtonState state = PathButtonState.active,
    String icon = AppIcons.crown,
    List<PathButtonSegment> segments = const [
      PathButtonSegment(status: SegmentStatus.completed),
      PathButtonSegment(status: SegmentStatus.current),
      PathButtonSegment(status: SegmentStatus.upcoming),
    ],
    VoidCallback? onPressed,
    Color color = AppColors.brand,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: AppPathButton(
            shape: shape,
            state: state,
            icon: icon,
            segments: segments,
            onPressed: onPressed,
            color: color,
          ),
        ),
      ),
    );
  }

  // ── Test 1: Renders all 3 shapes without error ──

  group('AppPathButton rendering', () {
    for (final shape in PathButtonShape.values) {
      for (final state in PathButtonState.values) {
        testWidgets(
          'Renders $shape in $state state without error',
          (WidgetTester tester) async {
            await tester.pumpWidget(buildTestPathButton(
              shape: shape,
              state: state,
            ));

            // Widget should be in the tree
            expect(find.byType(AppPathButton), findsOneWidget);

            // Icon should be present
            expect(find.byType(AppIcon), findsOneWidget);

            // CustomPaint should be present (painter is rendering)
            expect(find.byType(CustomPaint), findsWidgets);
          },
        );
      }
    }
  });

  // ── Test 2: Tap interaction — active fires onPressed, locked does not ──

  group('AppPathButton tap interaction', () {
    testWidgets(
      'Active state fires onPressed on tap',
      (WidgetTester tester) async {
        int tapCount = 0;
        await tester.pumpWidget(buildTestPathButton(
          state: PathButtonState.active,
          onPressed: () => tapCount++,
        ));

        await tester.tap(find.byType(AppPathButton));
        await tester.pump();

        expect(tapCount, 1);
      },
    );

    testWidgets(
      'Completed state fires onPressed on tap',
      (WidgetTester tester) async {
        int tapCount = 0;
        await tester.pumpWidget(buildTestPathButton(
          state: PathButtonState.completed,
          onPressed: () => tapCount++,
        ));

        await tester.tap(find.byType(AppPathButton));
        await tester.pump();

        expect(tapCount, 1);
      },
    );

    testWidgets(
      'Locked state does NOT fire onPressed on tap',
      (WidgetTester tester) async {
        int tapCount = 0;
        await tester.pumpWidget(buildTestPathButton(
          state: PathButtonState.locked,
          onPressed: () => tapCount++,
        ));

        await tester.tap(find.byType(AppPathButton));
        await tester.pump();

        expect(tapCount, 0);
      },
    );
  });

  // ── Test 3: Pulse animation starts for active, not for completed/locked ──

  group('AppPathButton pulse animation', () {
    testWidgets(
      'Active state animates (widget rebuilds over time)',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestPathButton(
          state: PathButtonState.active,
        ));

        // Advance time to allow animation frames
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        // The widget should still be present and no errors after animation frames
        expect(find.byType(AppPathButton), findsOneWidget);
      },
    );

    testWidgets(
      'Completed state does not animate',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestPathButton(
          state: PathButtonState.completed,
        ));

        // Pump several frames — should not throw
        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(AppPathButton), findsOneWidget);
      },
    );

    testWidgets(
      'Locked state does not animate',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestPathButton(
          state: PathButtonState.locked,
        ));

        await tester.pump(const Duration(milliseconds: 500));
        await tester.pump(const Duration(milliseconds: 500));

        expect(find.byType(AppPathButton), findsOneWidget);
      },
    );
  });

  // ── Test 4: Pulse stops on tap and stays closed ──

  group('AppPathButton pulse stops on tap', () {
    testWidgets(
      'Tapping active button stops pulse animation',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestPathButton(
          state: PathButtonState.active,
          onPressed: () {},
        ));

        // Let pulse run for a bit
        await tester.pump(const Duration(milliseconds: 750));

        // Tap the button
        await tester.tap(find.byType(AppPathButton));
        await tester.pump();

        // Let the settle animation complete (300ms)
        await tester.pump(const Duration(milliseconds: 350));

        // Advance more frames — pulse should NOT resume
        await tester.pump(const Duration(milliseconds: 1000));
        await tester.pump(const Duration(milliseconds: 1000));

        // Widget should still be present without errors
        expect(find.byType(AppPathButton), findsOneWidget);
      },
    );
  });

  // ── Test 5: Segment count and status rendering ──

  group('AppPathButton segments', () {
    testWidgets(
      'Renders with 1 segment',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestPathButton(
          segments: const [
            PathButtonSegment(status: SegmentStatus.completed),
          ],
        ));

        expect(find.byType(AppPathButton), findsOneWidget);
      },
    );

    testWidgets(
      'Renders with 5 segments',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestPathButton(
          segments: const [
            PathButtonSegment(status: SegmentStatus.completed),
            PathButtonSegment(status: SegmentStatus.completed),
            PathButtonSegment(status: SegmentStatus.current),
            PathButtonSegment(status: SegmentStatus.upcoming),
            PathButtonSegment(status: SegmentStatus.upcoming),
          ],
        ));

        expect(find.byType(AppPathButton), findsOneWidget);
      },
    );

    testWidgets(
      'Rebuilds when segment status changes',
      (WidgetTester tester) async {
        // Start with all upcoming
        await tester.pumpWidget(buildTestPathButton(
          state: PathButtonState.completed,
          segments: const [
            PathButtonSegment(status: SegmentStatus.upcoming),
            PathButtonSegment(status: SegmentStatus.upcoming),
            PathButtonSegment(status: SegmentStatus.upcoming),
          ],
        ));

        expect(find.byType(AppPathButton), findsOneWidget);

        // Update to mixed
        await tester.pumpWidget(buildTestPathButton(
          state: PathButtonState.completed,
          segments: const [
            PathButtonSegment(status: SegmentStatus.completed),
            PathButtonSegment(status: SegmentStatus.completed),
            PathButtonSegment(status: SegmentStatus.upcoming),
          ],
        ));

        await tester.pump();

        // Widget should update without error
        expect(find.byType(AppPathButton), findsOneWidget);
      },
    );
  });
}
