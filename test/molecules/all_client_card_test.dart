import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';
import 'package:flutter_intra/frontend/design_system/molecules/cards/all_client_card.dart';
import 'package:flutter_intra/frontend/design_system/molecules/cards/all_client_card_types.dart';

Widget buildCard({
  AllClientCardState state = AllClientCardState.add,
  VoidCallback? onTap,
  VoidCallback? onAction,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: AllClientCard(
          clientName: 'Charlie Vetrovs',
          email: 'charlie@example.com',
          state: state,
          onTap: onTap ?? () {},
          onAction: onAction ?? () {},
        ),
      ),
    ),
  );
}

void main() {
  group('AllClientCard', () {
    testWidgets('add state renders AppIcons.add icon', (tester) async {
      await tester.pumpWidget(buildCard(state: AllClientCardState.add));

      final icons = tester.widgetList<AppIcon>(find.byType(AppIcon));
      expect(find.byType(AppIcon), findsWidgets);
      expect(icons.any((i) => i.icon == AppIcons.add), isTrue);
    });

    testWidgets('remove state renders AppIcons.close icon', (tester) async {
      await tester.pumpWidget(buildCard(state: AllClientCardState.remove));

      final icons = tester.widgetList<AppIcon>(find.byType(AppIcon));
      expect(find.byType(AppIcon), findsWidgets);
      expect(icons.any((i) => i.icon == AppIcons.close), isTrue);
    });

    testWidgets('rosterFull state shows only one GestureDetector zone',
        (tester) async {
      await tester.pumpWidget(buildCard(state: AllClientCardState.rosterFull));

      // rosterFull hides the right zone — only one GestureDetector inside the card
      final detectors = find.descendant(
        of: find.byType(AllClientCard),
        matching: find.byType(GestureDetector),
      );
      expect(detectors, findsOneWidget);
    });

    testWidgets('onTap fires when left zone tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildCard(
        state: AllClientCardState.add,
        onTap: () => tapped = true,
      ));

      final detectors = find.descendant(
        of: find.byType(AllClientCard),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(detectors.first);
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('onAction fires when right zone tapped', (tester) async {
      bool acted = false;
      await tester.pumpWidget(buildCard(
        state: AllClientCardState.add,
        onAction: () => acted = true,
      ));

      final detectors = find.descendant(
        of: find.byType(AllClientCard),
        matching: find.byType(GestureDetector),
      );
      await tester.tap(detectors.last);
      await tester.pump();

      expect(acted, isTrue);
    });

    testWidgets('clientName and email render', (tester) async {
      await tester.pumpWidget(buildCard());

      expect(find.text('Charlie Vetrovs'), findsOneWidget);
      expect(find.text('charlie@example.com'), findsOneWidget);
    });
  });
}
