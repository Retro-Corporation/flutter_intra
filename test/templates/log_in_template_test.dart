import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

// Helper: pump the template inside a full app shell.
Widget buildTemplate({
  ValueChanged<({String email, String password})>? onLogIn,
  VoidCallback? onGoogle,
  VoidCallback? onCreateAccount,
}) {
  return MaterialApp(
    home: LogInTemplate(
      onLogIn: onLogIn ?? (_) {},
      onGoogle: onGoogle ?? () {},
      onCreateAccount: onCreateAccount ?? () {},
    ),
  );
}

// Finders
Finder get _emailField =>
    find.widgetWithText(AppTextFieldMolecule, 'Email');
Finder get _passwordField =>
    find.widgetWithText(AppPasswordField, 'Password');
Finder get _logInButton => find.widgetWithText(AppButton, 'Log in');
Finder get _googleButton => find.byType(AppGoogleSignInButton);
Finder get _createAccountButton =>
    find.widgetWithText(AppButton, 'Create Account');

void main() {
  group('LogInTemplate', () {
    // ── Render ──────────────────────────────────────────────────────────────

    testWidgets('renders heading, subheading, fields, buttons, and divider',
        (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.pump();

      expect(find.text('Build Your Kingdom'), findsOneWidget);
      expect(find.text('Log in to your profile and start training.'),
          findsOneWidget);
      expect(_emailField, findsOneWidget);
      expect(_passwordField, findsOneWidget);
      expect(_logInButton, findsOneWidget);
      expect(_googleButton, findsOneWidget);
      expect(_createAccountButton, findsOneWidget);
      expect(find.byType(AppDivider), findsOneWidget);
      expect(find.text('or'), findsOneWidget);
    });

    // ── Button enablement ───────────────────────────────────────────────────

    testWidgets('Log in is disabled when both fields empty', (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.pump();

      final button = tester.widget<AppButton>(_logInButton);
      expect(button.isDisabled, isTrue);
    });

    testWidgets('Log in is disabled when only email is filled',
        (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.enterText(_emailField, 'user@example.com');
      await tester.pump();

      final button = tester.widget<AppButton>(_logInButton);
      expect(button.isDisabled, isTrue);
    });

    testWidgets('Log in is disabled when only password is filled',
        (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.enterText(_passwordField, 'secret123');
      await tester.pump();

      final button = tester.widget<AppButton>(_logInButton);
      expect(button.isDisabled, isTrue);
    });

    testWidgets('Log in is enabled when both fields are non-empty',
        (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.enterText(_emailField, 'user@example.com');
      await tester.enterText(_passwordField, 'secret123');
      await tester.pump();

      final button = tester.widget<AppButton>(_logInButton);
      expect(button.isDisabled, isFalse);
    });

    // ── Callbacks ───────────────────────────────────────────────────────────

    testWidgets('onLogIn fires with the entered email and password',
        (tester) async {
      ({String email, String password})? captured;

      await tester.pumpWidget(
        buildTemplate(onLogIn: (v) => captured = v),
      );
      await tester.enterText(_emailField, 'user@example.com');
      await tester.enterText(_passwordField, 'secret123');
      await tester.pump();

      await tester.tap(_logInButton);
      await tester.pump();

      expect(captured, isNotNull);
      expect(captured!.email, 'user@example.com');
      expect(captured!.password, 'secret123');
    });

    testWidgets('onGoogle fires when Continue with Google is tapped',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTemplate(onGoogle: () => tapped = true),
      );
      await tester.pump();

      await tester.tap(_googleButton);
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('onCreateAccount fires when Create Account is tapped',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTemplate(onCreateAccount: () => tapped = true),
      );
      await tester.pump();

      await tester.tap(_createAccountButton);
      await tester.pump();

      expect(tapped, isTrue);
    });

    // ── Focus chain ─────────────────────────────────────────────────────────

    testWidgets('submitting email moves focus to password', (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.pump();

      await tester.tap(_emailField);
      await tester.pump();

      await tester.testTextInput.receiveAction(TextInputAction.done);
      await tester.pump();

      final passwordMolecule =
          tester.widget<AppPasswordField>(_passwordField);
      expect(passwordMolecule.focusNode.hasFocus, isTrue);
    });

    // ── Lifecycle ───────────────────────────────────────────────────────────

    testWidgets('all controllers and focus nodes dispose without error',
        (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.pump();

      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
