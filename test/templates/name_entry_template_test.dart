import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

// Helper: pump the template inside a full app shell.
Widget buildTemplate({
  VoidCallback? onBack,
  ValueChanged<({String first, String last})>? onSubmit,
  double progressBaseValue = 0.2,
  double fieldProgressDelta = 0.03,
}) {
  return MaterialApp(
    home: NameEntryTemplate(
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
Finder get _backArrow => find.byType(AppIcon);

void main() {
  group('NameEntryTemplate', () {
    // ── Button state ────────────────────────────────────────────────────────

    testWidgets('Continue is disabled when both fields empty', (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.pump();

      final button = tester.widget<AppButton>(_continueButton);
      expect(button.isDisabled, isTrue);
    });

    testWidgets('Continue is disabled when only first name filled',
        (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.enterText(_firstField, 'John');
      await tester.pump();

      final button = tester.widget<AppButton>(_continueButton);
      expect(button.isDisabled, isTrue);
    });

    testWidgets('Continue is disabled when only last name filled',
        (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.enterText(_lastField, 'Smith');
      await tester.pump();

      final button = tester.widget<AppButton>(_continueButton);
      expect(button.isDisabled, isTrue);
    });

    testWidgets('Continue is enabled when both fields non-empty', (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.enterText(_firstField, 'John');
      await tester.enterText(_lastField, 'Smith');
      await tester.pump();

      final button = tester.widget<AppButton>(_continueButton);
      expect(button.isDisabled, isFalse);
    });

    // ── Progress bar ─────────────────────────────────────────────────────────

    testWidgets('Progress bar shows base value when both fields empty',
        (tester) async {
      await tester.pumpWidget(buildTemplate(progressBaseValue: 0.2));
      await tester.pump();

      final bar = tester.widget<AppProgressBar>(find.byType(AppProgressBar));
      expect(bar.value, closeTo(0.2, 0.001));
    });

    testWidgets('Progress bar advances when first name filled', (tester) async {
      await tester.pumpWidget(
        buildTemplate(progressBaseValue: 0.2, fieldProgressDelta: 0.03),
      );
      await tester.enterText(_firstField, 'John');
      await tester.pump();

      final bar = tester.widget<AppProgressBar>(find.byType(AppProgressBar));
      expect(bar.value, closeTo(0.23, 0.001));
    });

    testWidgets('Progress bar advances when both fields filled', (tester) async {
      await tester.pumpWidget(
        buildTemplate(progressBaseValue: 0.2, fieldProgressDelta: 0.03),
      );
      await tester.enterText(_firstField, 'John');
      await tester.enterText(_lastField, 'Smith');
      await tester.pump();

      final bar = tester.widget<AppProgressBar>(find.byType(AppProgressBar));
      expect(bar.value, closeTo(0.26, 0.001));
    });

    // ── Callbacks ────────────────────────────────────────────────────────────

    testWidgets('onSubmit fires with correct first + last values',
        (tester) async {
      ({String first, String last})? captured;

      await tester.pumpWidget(buildTemplate(onSubmit: (v) => captured = v));
      await tester.enterText(_firstField, 'John');
      await tester.enterText(_lastField, 'Smith');
      await tester.pump();

      // Tap the enabled Continue button.
      await tester.tap(_continueButton);
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!.first, 'John');
      expect(captured!.last, 'Smith');
    });

    testWidgets('onBack fires when back arrow is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTemplate(onBack: () => tapped = true));
      await tester.pump();

      await tester.tap(_backArrow);
      await tester.pump();

      expect(tapped, isTrue);
    });

    // ── Focus chain ──────────────────────────────────────────────────────────

    testWidgets('Submitting first field moves focus to last field',
        (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.pump();

      await tester.tap(_firstField);
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      // Last field should now have focus.
      final lastMolecule = tester.widget<AppTextFieldMolecule>(_lastField);
      expect(lastMolecule.focusNode.hasFocus, isTrue);
    });

    // ── Lifecycle ────────────────────────────────────────────────────────────

    testWidgets('All controllers and focus nodes are disposed without error',
        (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.pump();

      // Replacing with an empty widget triggers dispose on the template.
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump();

      // No exceptions thrown = controllers and focus nodes disposed cleanly.
      expect(tester.takeException(), isNull);
    });
  });
}
