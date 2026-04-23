import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

// Helper: pump the template inside a full app shell.
Widget buildTemplate({
  VoidCallback? onBack,
  ValueChanged<ClientOnboardingAccountResult>? onSubmit,
  double progressBaseValue = 0.0,
}) {
  return MaterialApp(
    home: ClientOnboardingAccountTemplate(
      onBack: onBack ?? () {},
      onSubmit: onSubmit ?? (_) {},
      progressBaseValue: progressBaseValue,
    ),
  );
}

// Finders
Finder get _emailField =>
    find.widgetWithText(AppTextFieldMolecule, 'Email');
Finder get _passwordField =>
    find.widgetWithText(AppPasswordField, 'Password');
Finder get _phoneField =>
    find.widgetWithText(AppPhoneField, 'Phone number');
Finder get _createButton =>
    find.widgetWithText(AppButton, 'Create Account');
Finder get _backArrow => find.byType(AppIcon).first;

void main() {
  group('ClientOnboardingAccountTemplate', () {
    // ── Rendering ──────────────────────────────────────────────────────────

    testWidgets('renders heading text', (tester) async {
      await tester.pumpWidget(buildTemplate());
      expect(find.text('Create a new client account'), findsOneWidget);
    });

    testWidgets('renders all 3 fields', (tester) async {
      await tester.pumpWidget(buildTemplate());
      expect(_emailField, findsOneWidget);
      expect(_passwordField, findsOneWidget);
      expect(_phoneField, findsOneWidget);
    });

    // ── Button state ───────────────────────────────────────────────────────

    testWidgets('Create Account is disabled when all fields empty',
        (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.pump();

      final button = tester.widget<AppButton>(_createButton);
      expect(button.isDisabled, isTrue);
    });

    testWidgets('Create Account is disabled with only email valid',
        (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.enterText(_emailField, 'user@example.com');
      await tester.pump();

      final button = tester.widget<AppButton>(_createButton);
      expect(button.isDisabled, isTrue);
    });

    testWidgets('Create Account is disabled with email + password but no phone',
        (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.enterText(_emailField, 'user@example.com');
      await tester.enterText(_passwordField, 'password123');
      await tester.pump();

      final button = tester.widget<AppButton>(_createButton);
      expect(button.isDisabled, isTrue);
    });

    testWidgets(
        'Create Account is disabled with valid email + phone but no password',
        (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.enterText(_emailField, 'user@example.com');
      await tester.enterText(_phoneField, '5551234567');
      await tester.pump();

      final button = tester.widget<AppButton>(_createButton);
      expect(button.isDisabled, isTrue);
    });

    testWidgets('Create Account is enabled when all 3 fields valid',
        (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.enterText(_emailField, 'user@example.com');
      await tester.enterText(_passwordField, 'password123');
      await tester.enterText(_phoneField, '5551234567');
      await tester.pump();

      final button = tester.widget<AppButton>(_createButton);
      expect(button.isDisabled, isFalse);
    });

    testWidgets('Create Account is disabled with invalid email format',
        (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.enterText(_emailField, 'notanemail');
      await tester.enterText(_passwordField, 'password123');
      await tester.enterText(_phoneField, '5551234567');
      await tester.pump();

      final button = tester.widget<AppButton>(_createButton);
      expect(button.isDisabled, isTrue);
    });

    testWidgets('Create Account is disabled with incomplete phone (7 digits)',
        (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.enterText(_emailField, 'user@example.com');
      await tester.enterText(_passwordField, 'password123');
      await tester.enterText(_phoneField, '5551234');
      await tester.pump();

      final button = tester.widget<AppButton>(_createButton);
      expect(button.isDisabled, isTrue);
    });

    // ── Email blur validation ──────────────────────────────────────────────

    testWidgets('invalid email shows no error before blur', (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.enterText(_emailField, 'notanemail');
      await tester.pump();

      expect(find.text('Please enter a valid email address'), findsNothing);
    });

    testWidgets('invalid email shows error after blur', (tester) async {
      await tester.pumpWidget(buildTemplate());

      // Focus email field, type invalid email, then move focus away
      await tester.tap(_emailField);
      await tester.pump();
      await tester.enterText(_emailField, 'notanemail');

      // Move focus to password field to trigger blur
      await tester.tap(_passwordField);
      await tester.pump();

      expect(find.text('Please enter a valid email address'), findsOneWidget);
    });

    testWidgets('valid email shows no error after blur', (tester) async {
      await tester.pumpWidget(buildTemplate());

      await tester.tap(_emailField);
      await tester.pump();
      await tester.enterText(_emailField, 'user@example.com');

      // Move focus to password field
      await tester.tap(_passwordField);
      await tester.pump();

      expect(find.text('Please enter a valid email address'), findsNothing);
    });

    // ── Progress bar ───────────────────────────────────────────────────────

    testWidgets('progress bar at progressBaseValue when all fields empty',
        (tester) async {
      await tester.pumpWidget(buildTemplate(progressBaseValue: 0.0));
      await tester.pump();

      final bar = tester.widget<AppProgressBar>(find.byType(AppProgressBar));
      expect(bar.value, closeTo(0.0, 0.001));
    });

    testWidgets('progress bar advances as each field becomes valid',
        (tester) async {
      await tester.pumpWidget(buildTemplate(progressBaseValue: 0.0));

      // 1 valid field → 0.20
      await tester.enterText(_emailField, 'user@example.com');
      await tester.pump();
      var bar = tester.widget<AppProgressBar>(find.byType(AppProgressBar));
      expect(bar.value, closeTo(0.20, 0.001));

      // 2 valid fields → 0.40
      await tester.enterText(_passwordField, 'password123');
      await tester.pump();
      bar = tester.widget<AppProgressBar>(find.byType(AppProgressBar));
      expect(bar.value, closeTo(0.40, 0.001));
    });

    testWidgets('progress bar reaches 0.60 when all 3 fields valid',
        (tester) async {
      await tester.pumpWidget(buildTemplate(progressBaseValue: 0.0));
      await tester.enterText(_emailField, 'user@example.com');
      await tester.enterText(_passwordField, 'password123');
      await tester.enterText(_phoneField, '5551234567');
      await tester.pump();

      final bar = tester.widget<AppProgressBar>(find.byType(AppProgressBar));
      expect(bar.value, closeTo(0.60, 0.001));
    });

    // ── Callbacks ──────────────────────────────────────────────────────────

    testWidgets('onSubmit fires with correct values', (tester) async {
      ClientOnboardingAccountResult? captured;

      await tester.pumpWidget(buildTemplate(
        onSubmit: (result) => captured = result,
      ));

      await tester.enterText(_emailField, 'user@example.com');
      await tester.enterText(_passwordField, 'password123');
      await tester.enterText(_phoneField, '5551234567');
      await tester.pump();

      await tester.tap(_createButton);
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!.email, 'user@example.com');
      expect(captured!.password, 'password123');
      expect(captured!.phone, '(555) 123-4567');
    });

    testWidgets('onBack fires when back arrow is tapped', (tester) async {
      var tapped = false;
      await tester.pumpWidget(buildTemplate(onBack: () => tapped = true));
      await tester.pump();

      await tester.tap(_backArrow);
      await tester.pump();

      expect(tapped, isTrue);
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
