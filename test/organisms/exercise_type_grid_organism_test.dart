import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

Widget _wrap(Widget child) {
  return MaterialApp(home: Scaffold(body: child));
}

void main() {
  group('ExerciseTypeGridOrganism', () {
    testWidgets('renders 4 ExerciseThumbnailCard widgets', (tester) async {
      await tester.pumpWidget(
        _wrap(
          ExerciseTypeGridOrganism(onChanged: (_) {}),
        ),
      );

      expect(find.byType(ExerciseThumbnailCard), findsNWidgets(4));
    });

    testWidgets('each card has the correct label for its discipline',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          ExerciseTypeGridOrganism(onChanged: (_) {}),
        ),
      );

      final cards = tester
          .widgetList<ExerciseThumbnailCard>(find.byType(ExerciseThumbnailCard))
          .toList();

      for (var i = 0; i < ExerciseDiscipline.values.length; i++) {
        expect(cards[i].label, ExerciseDiscipline.values[i].label);
      }
    });

    testWidgets(
        'tapping an unselected card reports that discipline via onChanged '
        'and marks the card as selected', (tester) async {
      final reported = <ExerciseDiscipline?>[];

      await tester.pumpWidget(
        _wrap(
          ExerciseTypeGridOrganism(
            onChanged: reported.add,
          ),
        ),
      );

      // Tap the first card (Isometric) — starts unselected
      final cards = tester
          .widgetList<ExerciseThumbnailCard>(find.byType(ExerciseThumbnailCard))
          .toList();
      cards.first.onTap!();
      await tester.pump();

      expect(reported, [ExerciseDiscipline.isometric]);
      final updated = tester
          .widgetList<ExerciseThumbnailCard>(find.byType(ExerciseThumbnailCard))
          .toList();
      expect(updated.first.selected, isTrue);
    });

    testWidgets(
        'tapping the already-selected card deselects it and reports null',
        (tester) async {
      final reported = <ExerciseDiscipline?>[];

      await tester.pumpWidget(
        _wrap(
          ExerciseTypeGridOrganism(
            initialValue: ExerciseDiscipline.dynamic,
            onChanged: reported.add,
          ),
        ),
      );

      // The dynamic card is the second card (index 1)
      final cards = tester
          .widgetList<ExerciseThumbnailCard>(find.byType(ExerciseThumbnailCard))
          .toList();
      expect(cards[1].selected, isTrue);

      cards[1].onTap!();
      await tester.pump();

      expect(reported, [null]);
      final updated = tester
          .widgetList<ExerciseThumbnailCard>(find.byType(ExerciseThumbnailCard))
          .toList();
      expect(updated[1].selected, isFalse);
    });
  });
}
