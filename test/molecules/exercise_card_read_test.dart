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
  String repLabel = 'Rep',
  String repValue = '3',
  String setLabel = 'Set',
  String setValue = '4',
  String? equipmentLabel = 'Barbell',
  String? equipmentValue,
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
        repLabel: repLabel,
        repValue: repValue,
        setLabel: setLabel,
        setValue: setValue,
        equipmentLabel: equipmentLabel,
        equipmentValue: equipmentValue,
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

    testWidgets('renders rep label and value', (tester) async {
      await tester.pumpWidget(build(repLabel: 'Rep', repValue: '3'));

      expect(find.text('Rep'), findsOneWidget);
      expect(find.text('3'), findsOneWidget);
    });

    testWidgets('renders set label and value', (tester) async {
      await tester.pumpWidget(build(setLabel: 'Set', setValue: '4'));

      expect(find.text('Set'), findsOneWidget);
      expect(find.text('4'), findsOneWidget);
    });

    testWidgets('renders equipment label (truncated to 4 chars when long)',
        (tester) async {
      // "Barbell" (7 chars) is truncated to "Barb..." internally.
      await tester.pumpWidget(build(equipmentLabel: 'Barbell'));

      expect(find.text('Barb...'), findsOneWidget);
    });

    testWidgets('renders short equipment label in full', (tester) async {
      await tester.pumpWidget(build(equipmentLabel: 'Bar'));

      expect(find.text('Bar'), findsOneWidget);
    });

    testWidgets('omits equipment slot when both label and value are null',
        (tester) async {
      await tester.pumpWidget(build(equipmentLabel: null, equipmentValue: null));

      // Only rep and set groups render — no equipment text
      expect(find.text('Rep'), findsOneWidget);
      expect(find.text('Set'), findsOneWidget);
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
