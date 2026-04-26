import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

// Helper: pump the template inside a full app shell with dark theme.
Widget buildTemplate({
  String initialFirstName = 'Tavon',
  String initialLastName = 'Powell',
  String initialEmail = 'tavoncpowell@gmail.com',
  String initialPhone = '(XXX) XXX-6936',
  bool initialSessionReminders = false,
  bool initialPractitionersUpdates = false,
  bool initialProductUpdates = false,
  ValueChanged<String>? onFirstNameChanged,
  ValueChanged<String>? onLastNameChanged,
  ValueChanged<String>? onEmailChanged,
  ValueChanged<String>? onPhoneChanged,
  ValueChanged<bool>? onSessionRemindersChanged,
  ValueChanged<bool>? onPractitionersUpdatesChanged,
  ValueChanged<bool>? onProductUpdatesChanged,
  VoidCallback? onAvatarTap,
  VoidCallback? onAccountSwitchTap,
  VoidCallback? onChangePasswordTap,
  VoidCallback? onSignOut,
  VoidCallback? onDeleteAccount,
}) {
  return MaterialApp(
    theme: AppTheme.dark,
    home: AthleteSettingsTemplate(
      initialFirstName: initialFirstName,
      initialLastName: initialLastName,
      initialEmail: initialEmail,
      initialPhone: initialPhone,
      initialSessionReminders: initialSessionReminders,
      initialPractitionersUpdates: initialPractitionersUpdates,
      initialProductUpdates: initialProductUpdates,
      selectedIndex: 2,
      onTabSelected: (_) {},
      onFirstNameChanged: onFirstNameChanged ?? (_) {},
      onLastNameChanged: onLastNameChanged ?? (_) {},
      onEmailChanged: onEmailChanged ?? (_) {},
      onPhoneChanged: onPhoneChanged ?? (_) {},
      onSessionRemindersChanged: onSessionRemindersChanged ?? (_) {},
      onPractitionersUpdatesChanged: onPractitionersUpdatesChanged ?? (_) {},
      onProductUpdatesChanged: onProductUpdatesChanged ?? (_) {},
      onAvatarTap: onAvatarTap ?? () {},
      onAccountSwitchTap: onAccountSwitchTap ?? () {},
      onChangePasswordTap: onChangePasswordTap ?? () {},
      onSignOut: onSignOut ?? () {},
      onDeleteAccount: onDeleteAccount ?? () {},
    ),
  );
}

// Finders — label is now an explicit AppText above the molecule, not inside it
Finder get _firstNameField => find.byType(AppTextFieldMolecule).first;
Finder get _signOutButton => find.widgetWithText(AppButton, 'Sign out');
Finder get _passwordRow => find.text('••••••••');
Finder get _deleteAccountText => find.text('Delete account');

void main() {
  group('AthleteSettingsTemplate', () {
    // ── Pre-population ───────────────────────────────────────────────────────

    testWidgets('controllers pre-populate from initial* props', (tester) async {
      await tester.pumpWidget(buildTemplate(
        initialFirstName: 'Jordan',
        initialLastName: 'Smith',
        initialEmail: 'jordan@test.com',
      ));
      await tester.pump();

      expect(find.text('Jordan'), findsOneWidget);
      expect(find.text('Smith'), findsOneWidget);
      expect(find.text('jordan@test.com'), findsOneWidget);
    });

    // ── Callbacks ───────────────────────────────────────────────────────────

    testWidgets('onFirstNameChanged fires when first name controller changes',
        (tester) async {
      String? captured;
      await tester.pumpWidget(
        buildTemplate(onFirstNameChanged: (v) => captured = v),
      );
      await tester.pump();

      await tester.enterText(_firstNameField, 'Alex');
      await tester.pump();

      expect(captured, 'Alex');
    });

    testWidgets('onChangePasswordTap fires when password row is tapped',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTemplate(onChangePasswordTap: () => tapped = true),
      );
      await tester.pump();

      await tester.tap(_passwordRow);
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('onSignOut fires when Sign out confirmation is confirmed',
        (tester) async {
      var signedOut = false;
      await tester.pumpWidget(
        buildTemplate(onSignOut: () => signedOut = true),
      );
      await tester.pump();

      // Drag the scroll view down to reveal the Sign out button
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // Tap Sign out button → dialog appears
      await tester.tap(_signOutButton);
      await tester.pumpAndSettle();

      // Tap confirm button in dialog
      await tester.tap(find.text('Yes - Sign me out'));
      await tester.pump();

      expect(signedOut, isTrue);
    });

    // ── Lifecycle ───────────────────────────────────────────────────────────

    testWidgets('all controllers and focus nodes dispose without error',
        (tester) async {
      await tester.pumpWidget(buildTemplate());
      await tester.pump();

      // Replace with an empty widget to trigger dispose
      await tester.pumpWidget(const MaterialApp(home: SizedBox.shrink()));
      await tester.pump();

      expect(tester.takeException(), isNull);
    });
  });
}
