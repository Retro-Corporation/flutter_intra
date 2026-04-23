import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';
import 'package:flutter_intra/frontend/design_system/templates/given_exercise_template.dart';

void main() {
  const practitioner = PractitionerInfo(
    avatarUrl: 'https://i.pravatar.cc/150?img=32',
    name: 'Shashi Panchal',
    clinic: 'Retro Clinic',
  );

  const exercises = [
    ExerciseData(
      exerciseName: 'Shoulder Flexion',
      repLabel: 'Rep',
      repValue: '6',
      setLabel: 'Set',
      setValue: '4',
      equipmentLabel: 'Dumbell',
      equipmentValue: '15lb',
    ),
    ExerciseData(
      exerciseName: 'Hip Abduction',
      repLabel: 'Rep',
      repValue: '10',
      setLabel: 'Set',
      setValue: '3',
    ),
  ];

  void setPhoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532); // 390×844 @3x
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  Widget buildWidget({
    required GivenExerciseState state,
    List<ExerciseData> exercises = const [],
    VoidCallback? onBack,
    VoidCallback? onSkipToHome,
    VoidCallback? onStartExercise,
  }) {
    return MaterialApp(
      theme: AppTheme.dark,
      home: GivenExerciseTemplate(
        practitioner: practitioner,
        state: state,
        exercises: exercises,
        onBack: onBack ?? () {},
        onSkipToHome: onSkipToHome ?? () {},
        onStartExercise: onStartExercise ?? () {},
      ),
    );
  }

  // ── Shared ──

  group('GivenExerciseTemplate — shared', () {
    testWidgets('Practitioner name renders in all states', (tester) async {
      setPhoneSize(tester);
      for (final state in GivenExerciseState.values) {
        await tester.pumpWidget(
          buildWidget(state: state, exercises: exercises),
        );
        expect(find.text('Shashi Panchal'), findsOneWidget,
            reason: 'Missing name in $state');
      }
    });

    testWidgets('AppProgressBar is present in all states', (tester) async {
      setPhoneSize(tester);
      for (final state in GivenExerciseState.values) {
        await tester.pumpWidget(
          buildWidget(state: state, exercises: exercises),
        );
        expect(find.byType(AppProgressBar), findsOneWidget,
            reason: 'Missing progress bar in $state');
      }
    });

    testWidgets('Tapping back arrow fires onBack', (tester) async {
      setPhoneSize(tester);
      var fired = false;
      await tester.pumpWidget(buildWidget(
        state: GivenExerciseState.loaded,
        exercises: exercises,
        onBack: () => fired = true,
      ));

      await tester.tap(find.byType(GestureDetector).first);
      await tester.pump();

      expect(fired, isTrue);
    });
  });

  // ── Loaded state ──

  group('GivenExerciseTemplate — loaded', () {
    testWidgets('Renders an ExerciseCardRead for each exercise', (tester) async {
      setPhoneSize(tester);
      await tester.pumpWidget(
        buildWidget(state: GivenExerciseState.loaded, exercises: exercises),
      );

      expect(find.byType(ExerciseCardRead), findsNWidgets(exercises.length));
    });

    testWidgets('Exercise names appear in list', (tester) async {
      setPhoneSize(tester);
      await tester.pumpWidget(
        buildWidget(state: GivenExerciseState.loaded, exercises: exercises),
      );

      expect(find.text('Shoulder Flexion'), findsOneWidget);
      expect(find.text('Hip Abduction'), findsOneWidget);
    });

    testWidgets('"Skip to homepage" button is present', (tester) async {
      setPhoneSize(tester);
      await tester.pumpWidget(
        buildWidget(state: GivenExerciseState.loaded, exercises: exercises),
      );
      expect(find.text('Skip to homepage'), findsOneWidget);
    });

    testWidgets('"Start exercise" button is present', (tester) async {
      setPhoneSize(tester);
      await tester.pumpWidget(
        buildWidget(state: GivenExerciseState.loaded, exercises: exercises),
      );
      expect(find.text('Start exercise'), findsOneWidget);
    });

    testWidgets('Tapping "Skip to homepage" fires onSkipToHome', (tester) async {
      setPhoneSize(tester);
      var fired = false;
      await tester.pumpWidget(buildWidget(
        state: GivenExerciseState.loaded,
        exercises: exercises,
        onSkipToHome: () => fired = true,
      ));

      await tester.tap(find.text('Skip to homepage'));
      await tester.pump();

      expect(fired, isTrue);
    });

    testWidgets('Tapping "Start exercise" fires onStartExercise', (tester) async {
      setPhoneSize(tester);
      var fired = false;
      await tester.pumpWidget(buildWidget(
        state: GivenExerciseState.loaded,
        exercises: exercises,
        onStartExercise: () => fired = true,
      ));

      await tester.tap(find.text('Start exercise'));
      await tester.pump();

      expect(fired, isTrue);
    });
  });

  // ── Loading state ──

  group('GivenExerciseTemplate — loading', () {
    testWidgets('Renders 4 ExerciseCardSkeleton placeholders', (tester) async {
      setPhoneSize(tester);
      await tester.pumpWidget(buildWidget(state: GivenExerciseState.loading));

      expect(find.byType(ExerciseCardSkeleton), findsNWidgets(4));
    });

    testWidgets('No ExerciseCardRead cards appear', (tester) async {
      setPhoneSize(tester);
      await tester.pumpWidget(buildWidget(state: GivenExerciseState.loading));

      expect(find.byType(ExerciseCardRead), findsNothing);
    });

    testWidgets('Both footer buttons are present', (tester) async {
      setPhoneSize(tester);
      await tester.pumpWidget(buildWidget(state: GivenExerciseState.loading));

      expect(find.text('Skip to homepage'), findsOneWidget);
      expect(find.text('Start exercise'), findsOneWidget);
    });
  });

  // ── Error state ──

  group('GivenExerciseTemplate — error', () {
    testWidgets('"No exercise found" text is shown', (tester) async {
      setPhoneSize(tester);
      await tester.pumpWidget(buildWidget(state: GivenExerciseState.error));

      expect(find.text('No exercise found'), findsOneWidget);
    });

    testWidgets('No ExerciseCardRead or ExerciseCardSkeleton cards appear',
        (tester) async {
      setPhoneSize(tester);
      await tester.pumpWidget(buildWidget(state: GivenExerciseState.error));

      expect(find.byType(ExerciseCardRead), findsNothing);
      expect(find.byType(ExerciseCardSkeleton), findsNothing);
    });

    testWidgets('Only "Skip to homepage" button shown — no "Start exercise"',
        (tester) async {
      setPhoneSize(tester);
      await tester.pumpWidget(buildWidget(state: GivenExerciseState.error));

      expect(find.text('Skip to homepage'), findsOneWidget);
      expect(find.text('Start exercise'), findsNothing);
    });

    testWidgets('Tapping "Skip to homepage" fires onSkipToHome', (tester) async {
      setPhoneSize(tester);
      var fired = false;
      await tester.pumpWidget(buildWidget(
        state: GivenExerciseState.error,
        onSkipToHome: () => fired = true,
      ));

      await tester.tap(find.text('Skip to homepage'));
      await tester.pump();

      expect(fired, isTrue);
    });
  });
}
