import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';
import 'package:flutter_intra/frontend/design_system/molecules/cards/current_client_card.dart';
import 'package:flutter_intra/frontend/design_system/molecules/cards/current_client_card_types.dart';
import 'package:flutter_intra/frontend/design_system/atoms/behaviors/pressable_surface.dart';
import 'package:flutter_intra/frontend/design_system/atoms/primitives/score_badge.dart';

Widget buildCard({
  ReviewStatus status = ReviewStatus.reviewed,
  VoidCallback? onTap,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: CurrentClientCard(
          clientName: 'Ryan Levin',
          lastSessionText: 'Last Session: 1 day ago',
          score: 3.9,
          status: status,
          onTap: onTap ?? () {},
        ),
      ),
    ),
  );
}

void main() {
  group('CurrentClientCard', () {
    testWidgets('renders clientName', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.text('Ryan Levin'), findsOneWidget);
    });

    testWidgets('renders lastSessionText', (tester) async {
      await tester.pumpWidget(buildCard());
      expect(find.text('Last Session: 1 day ago'), findsOneWidget);
    });

    testWidgets('urgent status passes AppColors.brand to PressableSurface', (tester) async {
      await tester.pumpWidget(buildCard(status: ReviewStatus.urgent));
      final surface = tester.widget<PressableSurface>(find.byType(PressableSurface));
      expect(surface.borderColor, AppColors.brand);
    });

    testWidgets('pendingReview status passes AppColors.textPrimary to PressableSurface', (tester) async {
      await tester.pumpWidget(buildCard(status: ReviewStatus.pendingReview));
      final surface = tester.widget<PressableSurface>(find.byType(PressableSurface));
      expect(surface.borderColor, AppColors.textPrimary);
    });

    testWidgets('reviewed status passes AppColors.surfaceBorder to PressableSurface', (tester) async {
      await tester.pumpWidget(buildCard(status: ReviewStatus.reviewed));
      final surface = tester.widget<PressableSurface>(find.byType(PressableSurface));
      expect(surface.borderColor, AppColors.surfaceBorder);
    });

    testWidgets('urgent status passes AppColors.brand to ScoreBadge underlineColor', (tester) async {
      await tester.pumpWidget(buildCard(status: ReviewStatus.urgent));
      final badge = tester.widget<ScoreBadge>(find.byType(ScoreBadge));
      expect(badge.underlineColor, AppColors.brand);
    });

    testWidgets('onTap fires on tap', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildCard(onTap: () => tapped = true));
      await tester.tap(find.byType(PressableSurface));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });
}
