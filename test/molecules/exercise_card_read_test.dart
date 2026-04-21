import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';
import 'package:flutter_intra/frontend/design_system/molecules/cards/exercise_card_read.dart';
import 'package:flutter_intra/frontend/design_system/atoms/primitives/score_badge_types.dart';

Widget build({
  double score = 82,
  Color? scoreColor,
  ScoreBadgeVariant scoreVariant = ScoreBadgeVariant.plain,
  String exerciseName = 'Shoulder Press',
  String muscleGroup = 'Shoulder flexion',
  String reps = 'Rep 3',
  String setCount = 'Sets 4',
  String equipment = 'Barbell',
  VoidCallback? onTap,
}) {
  return MaterialApp(
    home: Scaffold(
      body: ExerciseCardRead(
        score: score,
        scoreColor: scoreColor ?? Colors.orange,
        scoreVariant: scoreVariant,
        exerciseName: exerciseName,
        muscleGroup: muscleGroup,
        reps: reps,
        setCount: setCount,
        equipment: equipment,
        onTap: onTap ?? () {},
      ),
    ),
  );
}

void main() {
  group('ExerciseCardRead rendering', () {
    testWidgets('renders exercise name', (tester) async {
      await tester.pumpWidget(build(exerciseName: 'Shoulder Press'));

      expect(find.text('Shoulder Press'), findsOneWidget);
    });

    testWidgets('renders muscle group', (tester) async {
      await tester.pumpWidget(build(muscleGroup: 'Shoulder flexion'));

      expect(find.text('Shoulder flexion'), findsOneWidget);
    });

    testWidgets('renders reps metric', (tester) async {
      await tester.pumpWidget(build(reps: 'Rep 3'));

      expect(find.text('Rep 3'), findsOneWidget);
    });

    testWidgets('renders set count metric', (tester) async {
      await tester.pumpWidget(build(setCount: 'Sets 4'));

      expect(find.text('Sets 4'), findsOneWidget);
    });

    testWidgets('renders equipment metric', (tester) async {
      await tester.pumpWidget(build(equipment: 'Barbell'));

      expect(find.text('Barbell'), findsOneWidget);
    });

    testWidgets('renders ScoreBadge', (tester) async {
      await tester.pumpWidget(build(score: 75));

      expect(find.byType(ScoreBadge), findsOneWidget);
    });

    testWidgets('renders Thumbnail', (tester) async {
      await tester.pumpWidget(build());

      expect(find.byType(Thumbnail), findsOneWidget);
    });
  });

  group('ExerciseCardRead score variants', () {
    testWidgets('plain variant renders without error', (tester) async {
      await tester.pumpWidget(build(scoreVariant: ScoreBadgeVariant.plain));

      expect(find.byType(ExerciseCardRead), findsOneWidget);
    });

    testWidgets('trendUp variant renders without error', (tester) async {
      await tester.pumpWidget(build(scoreVariant: ScoreBadgeVariant.trendUp));

      expect(find.byType(ExerciseCardRead), findsOneWidget);
    });

    testWidgets('trendDown variant renders without error', (tester) async {
      await tester.pumpWidget(build(scoreVariant: ScoreBadgeVariant.trendDown));

      expect(find.byType(ExerciseCardRead), findsOneWidget);
    });
  });

  group('ExerciseCardRead interaction', () {
    testWidgets('onTap fires when card is tapped', (tester) async {
      bool tapped = false;
      await tester.pumpWidget(build(onTap: () => tapped = true));

      await tester.tap(find.byType(ExerciseCardRead));
      await tester.pump();

      expect(tapped, isTrue);
    });
  });
}
