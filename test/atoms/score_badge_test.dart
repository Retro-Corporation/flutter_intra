import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/atoms/primitives/score_badge.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  group('ScoreBadge', () {
    Widget buildSubject({
      required double score,
      required Color underlineColor,
    }) {
      return MaterialApp(
        home: Scaffold(
          body: Center(
            child: ScoreBadge(
              score: score,
              underlineColor: underlineColor,
            ),
          ),
        ),
      );
    }

    testWidgets('renders score text', (tester) async {
      await tester.pumpWidget(
        buildSubject(score: 3.5, underlineColor: AppColors.brand),
      );

      expect(find.text('3.5'), findsOneWidget);
    });

    testWidgets('urgent variant renders AppColors.brand underline', (tester) async {
      await tester.pumpWidget(
        buildSubject(score: 3.5, underlineColor: AppColors.brand),
      );

      final containers = tester.widgetList<Container>(find.byType(Container)).toList();
      // The underline Container is the last one (after the text)
      expect(containers.last.color, AppColors.brand);
    });

    testWidgets('pendingReview variant renders AppColors.textPrimary underline', (tester) async {
      await tester.pumpWidget(
        buildSubject(score: 3.5, underlineColor: AppColors.textPrimary),
      );

      final containers = tester.widgetList<Container>(find.byType(Container)).toList();
      expect(containers.last.color, AppColors.textPrimary);
    });

    testWidgets('reviewed variant renders AppColors.surfaceBorder underline', (tester) async {
      await tester.pumpWidget(
        buildSubject(score: 3.5, underlineColor: AppColors.surfaceBorder),
      );

      final containers = tester.widgetList<Container>(find.byType(Container)).toList();
      expect(containers.last.color, AppColors.surfaceBorder);
    });
  });
}
