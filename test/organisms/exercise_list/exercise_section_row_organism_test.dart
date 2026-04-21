import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/molecules/cards/exercise_thumbnail_card.dart';
import 'package:flutter_intra/frontend/design_system/molecules/cards/exercise_thumbnail_card_types.dart';
import 'package:flutter_intra/frontend/design_system/molecules/display/icon_section_header.dart';
import 'package:flutter_intra/frontend/design_system/organisms/exercise_list/exercise_section_row_organism.dart';
import 'package:flutter_intra/frontend/design_system/organisms/exercise_list/exercise_section_row_types.dart';

Widget _wrap(Widget child) {
  return MaterialApp(
    home: Scaffold(body: child),
  );
}

void main() {
  group('ExerciseSectionRowOrganism', () {
    testWidgets(
      'templateRow renders IconSectionHeader and large ExerciseThumbnailCards',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            ExerciseSectionRowOrganism(
              title: 'Templates',
              layout: ExerciseSectionLayout.templateRow,
              items: const [
                ExerciseItem(id: 'a', label: 'Alpha'),
                ExerciseItem(id: 'b', label: 'Beta'),
              ],
              onCardTap: (_) {},
            ),
          ),
        );

        expect(find.byType(IconSectionHeader), findsOneWidget);
        final cards = tester
            .widgetList<ExerciseThumbnailCard>(find.byType(ExerciseThumbnailCard))
            .toList();
        expect(cards, hasLength(2));
        for (final card in cards) {
          expect(card.size, ExerciseThumbnailCardSize.large);
        }
      },
    );

    testWidgets(
      'exerciseGrid renders IconSectionHeader and small ExerciseThumbnailCards',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            ExerciseSectionRowOrganism(
              title: 'Exercises',
              layout: ExerciseSectionLayout.exerciseGrid,
              items: const [
                ExerciseItem(id: 'a'),
                ExerciseItem(id: 'b'),
                ExerciseItem(id: 'c'),
                ExerciseItem(id: 'd'),
              ],
              onCardTap: (_) {},
            ),
          ),
        );

        expect(find.byType(IconSectionHeader), findsOneWidget);
        final cards = tester
            .widgetList<ExerciseThumbnailCard>(find.byType(ExerciseThumbnailCard))
            .toList();
        expect(cards, hasLength(4));
        for (final card in cards) {
          expect(card.size, ExerciseThumbnailCardSize.small);
        }
      },
    );

    testWidgets('templateRow renders the correct label on each card',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          ExerciseSectionRowOrganism(
            title: 'Templates',
            layout: ExerciseSectionLayout.templateRow,
            items: const [
              ExerciseItem(id: 'x', label: 'Foo'),
            ],
            onCardTap: (_) {},
          ),
        ),
      );

      expect(find.text('Foo'), findsOneWidget);
    });

    testWidgets('empty items returns SizedBox.shrink with no IconSectionHeader',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          ExerciseSectionRowOrganism(
            title: 'Empty',
            layout: ExerciseSectionLayout.templateRow,
            items: const [],
            onCardTap: (_) {},
          ),
        ),
      );

      expect(find.byType(IconSectionHeader), findsNothing);
      expect(find.byType(ExerciseThumbnailCard), findsNothing);
    });

    testWidgets('onCardTap fires with the correct id when card onTap is invoked',
        (tester) async {
      String? tappedId;
      await tester.pumpWidget(
        _wrap(
          ExerciseSectionRowOrganism(
            title: 'Templates',
            layout: ExerciseSectionLayout.templateRow,
            items: const [
              ExerciseItem(id: 'first', label: 'First'),
              ExerciseItem(id: 'second', label: 'Second'),
            ],
            onCardTap: (id) => tappedId = id,
          ),
        ),
      );

      final firstCard = tester
          .widgetList<ExerciseThumbnailCard>(find.byType(ExerciseThumbnailCard))
          .first;
      firstCard.onTap!();

      expect(tappedId, 'first');
    });

    testWidgets('a card whose id is in selectedIds has selected: true',
        (tester) async {
      await tester.pumpWidget(
        _wrap(
          ExerciseSectionRowOrganism(
            title: 'Templates',
            layout: ExerciseSectionLayout.templateRow,
            items: const [
              ExerciseItem(id: 'a', label: 'A'),
              ExerciseItem(id: 'b', label: 'B'),
            ],
            selectedIds: const ['b'],
            onCardTap: (_) {},
          ),
        ),
      );

      final cards = tester
          .widgetList<ExerciseThumbnailCard>(find.byType(ExerciseThumbnailCard))
          .toList();
      expect(cards[0].selected, isFalse);
      expect(cards[1].selected, isTrue);
    });

    testWidgets('iconPath is passed through to IconSectionHeader',
        (tester) async {
      const path = 'assets/icons/foo.svg';
      await tester.pumpWidget(
        _wrap(
          ExerciseSectionRowOrganism(
            title: 'Templates',
            layout: ExerciseSectionLayout.templateRow,
            items: const [ExerciseItem(id: 'a', label: 'A')],
            iconPath: path,
            onCardTap: (_) {},
          ),
        ),
      );

      final header = tester.widget<IconSectionHeader>(
        find.byType(IconSectionHeader),
      );
      expect(header.iconPath, path);
    });

    testWidgets(
      'exerciseGrid places even indices in the top row and odd indices in the bottom row',
      (tester) async {
        await tester.pumpWidget(
          _wrap(
            ExerciseSectionRowOrganism(
              title: 'Exercises',
              layout: ExerciseSectionLayout.exerciseGrid,
              items: const [
                ExerciseItem(id: 'e0'),
                ExerciseItem(id: 'e1'),
                ExerciseItem(id: 'e2'),
                ExerciseItem(id: 'e3'),
                ExerciseItem(id: 'e4'),
              ],
              selectedIds: const ['e0', 'e2', 'e4'],
              onCardTap: (_) {},
            ),
          ),
        );

        // The grid's inner Column contains [topRow, SizedBox, bottomRow].
        final innerColumn = tester.widget<Column>(
          find.descendant(
            of: find.byType(SingleChildScrollView),
            matching: find.byType(Column),
          ),
        );
        expect(innerColumn.children, hasLength(3));

        final topRow = innerColumn.children[0] as Row;
        final bottomRow = innerColumn.children[2] as Row;

        final topCards = topRow.children
            .whereType<ExerciseThumbnailCard>()
            .toList();
        final bottomCards = bottomRow.children
            .whereType<ExerciseThumbnailCard>()
            .toList();

        // Even indices (0, 2, 4) go to top; odd indices (1, 3) go to bottom.
        expect(topCards, hasLength(3));
        expect(bottomCards, hasLength(2));

        // selectedIds were assigned to the even-indexed items, so every top-row
        // card should be selected and no bottom-row card should be.
        for (final card in topCards) {
          expect(card.selected, isTrue);
        }
        for (final card in bottomCards) {
          expect(card.selected, isFalse);
        }
      },
    );
  });
}
