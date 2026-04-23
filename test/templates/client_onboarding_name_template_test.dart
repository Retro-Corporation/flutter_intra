import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

Widget buildTemplate({
  VoidCallback? onBack,
  ValueChanged<({String first, String last})>? onSubmit,
  double progressBaseValue = 0.60,
  double fieldProgressDelta = 0.175,
}) {
  return MaterialApp(
    home: ClientOnboardingNameTemplate(
      onBack: onBack ?? () {},
      onSubmit: onSubmit ?? (_) {},
      progressBaseValue: progressBaseValue,
      fieldProgressDelta: fieldProgressDelta,
    ),
  );
}

// Finders
Finder get _firstField => find.widgetWithText(AppTextFieldMolecule, 'First name');
Finder get _lastField  => find.widgetWithText(AppTextFieldMolecule, 'Last name');
Finder get _continueButton => find.widgetWithText(AppButton, 'Continue');
Finder get _backArrow => find.byType(AppIcon).first;

void main() {
  group('ClientOnboardingNameTemplate', () {
    // ── Rendering ──────────────────────────────────────────────────────────

    testWidgets("renders heading with correct apostrophe", (tester) async {
      await tester.pumpWidget(buildTemplate());
      expect(find.text("What is the client's full name?"), findsOneWidget);
    });

    testWidgets('renders both name fields', (tester) async {
      await tester.pumpWidget(buildTemplate());
      expect(_firstField, findsOneWidget);
      expect(_lastField, findsOneWidget);
    });

    // ── Button state ───────────────────────────────────────────────────────

    testWidgets('Continue is disabled when both fields empty', (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.pump();

      final button = tester.widget<AppButton>(_continueButton);
      expect(button.isDisabled, isTrue);
    });

    testWidgets('Continue is disabled when only first name filled',
        (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.enterText(_firstField, 'Jane');
      await tester.pump();

      final button = tester.widget<AppButton>(_continueButton);
      expect(button.isDisabled, isTrue);
    });

    testWidgets('Continue is disabled when only last name filled',
        (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.enterText(_lastField, 'Doe');
      await tester.pump();

      final button = tester.widget<AppButton>(_continueButton);
      expect(button.isDisabled, isTrue);
    });

    testWidgets('Continue is enabled when both fields non-empty',
        (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.enterText(_firstField, 'Jane');
      await tester.enterText(_lastField, 'Doe');
      await tester.pump();

      final button = tester.widget<AppButton>(_continueButton);
      expect(button.isDisabled, isFalse);
    });

    // ── Progress bar ───────────────────────────────────────────────────────

    testWidgets('progress bar at 0.60 when both fields empty', (tester) async {
      await tester.pumpWidget(buildTemplate(progressBaseValue: 0.60));
      await tester.pump();

      final bar = tester.widget<AppProgressBar>(find.byType(AppProgressBar));
      expect(bar.value, closeTo(0.60, 0.001));
    });

    testWidgets('progress bar at 0.775 when first name filled', (tester) async {
      await tester.pumpWidget(
        buildTemplate(progressBaseValue: 0.60, fieldProgressDelta: 0.175),
      );
      await tester.enterText(_firstField, 'Jane');
      await tester.pump();

      final bar = tester.widget<AppProgressBar>(find.byType(AppProgressBar));
      expect(bar.value, closeTo(0.775, 0.001));
    });

    testWidgets('progress bar at 0.95 when both fields filled', (tester) async {
      await tester.pumpWidget(
        buildTemplate(progressBaseValue: 0.60, fieldProgressDelta: 0.175),
      );
      await tester.enterText(_firstField, 'Jane');
      await tester.enterText(_lastField, 'Doe');
      await tester.pump();

      final bar = tester.widget<AppProgressBar>(find.byType(AppProgressBar));
      expect(bar.value, closeTo(0.95, 0.001));
    });

    // ── Callbacks ──────────────────────────────────────────────────────────

    testWidgets('onSubmit fires with correct first + last values',
        (tester) async {
      ({String first, String last})? captured;

      await tester.pumpWidget(buildTemplate(onSubmit: (v) => captured = v));
      await tester.enterText(_firstField, 'Jane');
      await tester.enterText(_lastField, 'Doe');
      await tester.pump();

      await tester.tap(_continueButton);
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!.first, 'Jane');
      expect(captured!.last, 'Doe');
    });

    testWidgets('onBack fires when back arrow is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTemplate(onBack: () => tapped = true));
      await tester.pump();

      await tester.tap(_backArrow);
      await tester.pump();

      expect(tapped, isTrue);
    });

    // ── Focus chain ────────────────────────────────────────────────────────

    testWidgets('submitting first field moves focus to last field',
        (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.pump();

      await tester.tap(_firstField);
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      final lastMolecule = tester.widget<AppTextFieldMolecule>(_lastField);
      expect(lastMolecule.focusNode.hasFocus, isTrue);
    });

    // ── Lifecycle ──────────────────────────────────────────────────────────

    testWidgets('controllers and focus nodes disposed without error',
        (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.pump();

      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
