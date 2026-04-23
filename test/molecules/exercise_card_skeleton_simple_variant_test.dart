import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  group('ExerciseCardSkeleton — simple variant', () {
    testWidgets('simple variant renders without crash', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseCardSkeleton(
              variant: ExerciseCardSkeletonVariant.simple,
            ),
          ),
        ),
      );
      expect(find.byType(ExerciseCardSkeleton), findsOneWidget);
    });

    testWidgets('full variant (default) still renders — regression', (tester) async {
      await tester.pumpWidget(
        const MaterialApp(
          home: Scaffold(
            body: ExerciseCardSkeleton(),
          ),
        ),
      );
      expect(find.byType(ExerciseCardSkeleton), findsOneWidget);
    });
  });
}
