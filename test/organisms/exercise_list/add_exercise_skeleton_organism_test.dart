import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/foundation/color/colors.dart';
import 'package:flutter_intra/frontend/design_system/foundation/space/grid.dart';
import 'package:flutter_intra/frontend/design_system/organisms/exercise_list/add_exercise_skeleton_organism.dart';

Widget _wrap() {
  return const MaterialApp(
    home: Scaffold(
      body: AddExerciseSkeletonOrganism(),
    ),
  );
}

// ── Helpers ──

bool _isSurfaceContainer(Widget w) {
  if (w is! Container) return false;
  final deco = w.decoration;
  if (deco is! BoxDecoration) return false;
  return deco.color == AppColors.surface;
}

bool _hasTightSize(Container c, double width, double height) {
  final constraints = c.constraints;
  if (constraints == null) return false;
  return constraints.maxWidth == width &&
      constraints.minWidth == width &&
      constraints.maxHeight == height &&
      constraints.minHeight == height;
}

void main() {
  group('AddExerciseSkeletonOrganism', () {
    testWidgets('renders without throwing', (tester) async {
      await tester.pumpWidget(_wrap());
      expect(find.byType(AddExerciseSkeletonOrganism), findsOneWidget);
    });

    testWidgets('contains at least 3 header placeholders (grid24 x 160)',
        (tester) async {
      await tester.pumpWidget(_wrap());
      final headers = find.byWidgetPredicate((w) {
        if (!_isSurfaceContainer(w)) return false;
        return _hasTightSize(w as Container, 160, AppGrid.grid24);
      });
      expect(headers, findsAtLeastNWidgets(3));
    });

    testWidgets('contains at least 4 large (128x128) blocks', (tester) async {
      await tester.pumpWidget(_wrap());
      final largeBlocks = find.byWidgetPredicate((w) {
        if (!_isSurfaceContainer(w)) return false;
        return _hasTightSize(w as Container, 128, 128);
      });
      expect(largeBlocks, findsAtLeastNWidgets(4));
    });

    testWidgets('contains at least 16 small (100x100) blocks', (tester) async {
      await tester.pumpWidget(_wrap());
      final smallBlocks = find.byWidgetPredicate((w) {
        if (!_isSurfaceContainer(w)) return false;
        return _hasTightSize(w as Container, 100, 100);
      });
      expect(smallBlocks, findsAtLeastNWidgets(16));
    });
  });
}
