import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

Widget buildSimple({VoidCallback? onTap}) {
  return MaterialApp(
    home: Scaffold(
      body: ExerciseCardRead(
        variant: ExerciseCardReadVariant.simple,
        exerciseName: 'Shoulder Press',
        repLabel: 'Rep',
        repValue: '6',
        setLabel: 'Set',
        setValue: '4',
        equipmentLabel: 'Dumbell',
        equipmentValue: '15lb',
        onTap: onTap ?? () {},
      ),
    ),
  );
}

Widget buildFull() {
  return MaterialApp(
    home: Scaffold(
      body: ExerciseCardRead(
        score: 2.4,
        scoreColor: AppColors.brand,
        scoreVariant: ScoreBadgeVariant.trendUp,
        exerciseName: 'Shoulder Press',
        muscleGroup: 'Shoulder flexion',
        repLabel: 'Rep',
        repValue: '3',
        setLabel: 'Set',
        setValue: '4',
        onTap: () {},
      ),
    ),
  );
}

void main() {
  group('ExerciseCardRead — simple variant', () {
    testWidgets('renders exercise name', (tester) async {
      await tester.pumpWidget(buildSimple());
      expect(find.text('Shoulder Press'), findsOneWidget);
    });

    testWidgets('renders rep metric', (tester) async {
      await tester.pumpWidget(buildSimple());
      expect(find.text('Rep'), findsOneWidget);
      expect(find.text('6'), findsOneWidget);
    });

    testWidgets('renders set metric', (tester) async {
      await tester.pumpWidget(buildSimple());
      expect(find.text('Set'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('renders equipment when provided', (tester) async {
      await tester.pumpWidget(buildSimple());
      expect(find.text('Dumb...'), findsOneWidget);
    });

    testWidgets('does not render ScoreBadge', (tester) async {
      await tester.pumpWidget(buildSimple());
      expect(find.byType(ScoreBadge), findsNothing);
    });

    testWidgets('does not render muscle group text', (tester) async {
      await tester.pumpWidget(buildSimple());
      expect(find.text('Shoulder flexion'), findsNothing);
    });

    testWidgets('onTap fires when tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(buildSimple(onTap: () => tapped = true));
      await tester.tap(find.byType(ExerciseCardRead));
      await tester.pump();
      expect(tapped, isTrue);
    });
  });

  group('ExerciseCardRead — full variant regression', () {
    testWidgets('full variant still renders after surgery', (tester) async {
      await tester.pumpWidget(buildFull());
      expect(find.byType(ExerciseCardRead), findsOneWidget);
      expect(find.byType(ScoreBadge), findsOneWidget);
    });
  });
}
