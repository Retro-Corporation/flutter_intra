import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

// Helper: pump the template inside a full app shell with dark theme.
Widget buildTemplate({
  bool hasOrganization = false,
  String? organizationName,
  String? clinicBranchName,
  String initialFirstName = 'Tavon',
  String initialLastName = 'Powell',
  String initialEmail = 'tavoncpowell@gmail.com',
  String initialPersonalPhone = '(XXX) XXX-6936',
  String initialWorkEmail = 'tavoncpowell@gmail.com',
  String initialWorkPhone = '(XXX) XXX-6936',
  bool initialClientHelpAlerts = false,
  bool initialPractitionersUpdates = false,
  bool initialProductUpdates = false,
  ValueChanged<String>? onFirstNameChanged,
  ValueChanged<String>? onLastNameChanged,
  ValueChanged<String>? onEmailChanged,
  ValueChanged<String>? onPersonalPhoneChanged,
  ValueChanged<String>? onWorkEmailChanged,
  ValueChanged<String>? onWorkPhoneChanged,
  ValueChanged<bool>? onClientHelpAlertsChanged,
  ValueChanged<bool>? onPractitionersUpdatesChanged,
  ValueChanged<bool>? onProductUpdatesChanged,
  VoidCallback? onAvatarTap,
  VoidCallback? onAccountSwitchTap,
  VoidCallback? onJoinBranch,
  VoidCallback? onCreateOrganization,
  VoidCallback? onOrganizationTap,
  VoidCallback? onClinicBranchTap,
  VoidCallback? onChangePasswordTap,
  VoidCallback? onSignOut,
  VoidCallback? onDeleteAccount,
}) {
  return MaterialApp(
    theme: AppTheme.dark,
    home: PractitionerSettingsTemplate(
      hasOrganization: hasOrganization,
      organizationName: organizationName,
      clinicBranchName: clinicBranchName,
      initialFirstName: initialFirstName,
      initialLastName: initialLastName,
      initialEmail: initialEmail,
      initialPersonalPhone: initialPersonalPhone,
      initialWorkEmail: initialWorkEmail,
      initialWorkPhone: initialWorkPhone,
      initialClientHelpAlerts: initialClientHelpAlerts,
      initialPractitionersUpdates: initialPractitionersUpdates,
      initialProductUpdates: initialProductUpdates,
      selectedIndex: 2,
      onTabSelected: (_) {},
      onFirstNameChanged: onFirstNameChanged ?? (_) {},
      onLastNameChanged: onLastNameChanged ?? (_) {},
      onEmailChanged: onEmailChanged ?? (_) {},
      onPersonalPhoneChanged: onPersonalPhoneChanged ?? (_) {},
      onWorkEmailChanged: onWorkEmailChanged ?? (_) {},
      onWorkPhoneChanged: onWorkPhoneChanged ?? (_) {},
      onClientHelpAlertsChanged: onClientHelpAlertsChanged ?? (_) {},
      onPractitionersUpdatesChanged: onPractitionersUpdatesChanged ?? (_) {},
      onProductUpdatesChanged: onProductUpdatesChanged ?? (_) {},
      onAvatarTap: onAvatarTap ?? () {},
      onAccountSwitchTap: onAccountSwitchTap ?? () {},
      onJoinBranch: onJoinBranch ?? () {},
      onCreateOrganization: onCreateOrganization ?? () {},
      onOrganizationTap: onOrganizationTap ?? () {},
      onClinicBranchTap: onClinicBranchTap ?? () {},
      onChangePasswordTap: onChangePasswordTap ?? () {},
      onSignOut: onSignOut ?? () {},
      onDeleteAccount: onDeleteAccount ?? () {},
    ),
  );
}

// Finders
Finder get _firstNameField =>
    find.widgetWithText(AppTextFieldMolecule, 'First name');
Finder get _signOutButton => find.widgetWithText(AppButton, 'Sign out');
Finder get _passwordRow => find.text('••••••••');
Finder get _deleteAccountText => find.text('Delete account');

void main() {
  group('PractitionerSettingsTemplate', () {
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

    testWidgets('onJoinBranch fires when Join Branch tapped (no org)',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTemplate(
          hasOrganization: false,
          onJoinBranch: () => tapped = true,
        ),
      );
      await tester.pump();

      await tester.tap(find.widgetWithText(AppButton, '+ Join Branch'));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('onOrganizationTap fires when Organization field tapped (has org)',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        buildTemplate(
          hasOrganization: true,
          organizationName: 'BTL Industries',
          clinicBranchName: 'Healthcare professionals',
          onOrganizationTap: () => tapped = true,
        ),
      );
      await tester.pump();

      await tester.tap(find.text('BTL Industries'));
      await tester.pump();

      expect(tapped, isTrue);
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

    testWidgets('onDeleteAccount fires when Delete account confirmation is confirmed',
        (tester) async {
      var deleted = false;
      await tester.pumpWidget(
        buildTemplate(onDeleteAccount: () => deleted = true),
      );
      await tester.pump();

      // Drag the scroll view down to reveal the delete account text
      await tester.drag(find.byType(SingleChildScrollView), const Offset(0, -600));
      await tester.pumpAndSettle();

      // Tap Delete account text → dialog appears
      await tester.tap(_deleteAccountText);
      await tester.pumpAndSettle();

      // Tap confirm button in dialog
      await tester.tap(find.text('Yes - Delete account'));
      await tester.pump();

      expect(deleted, isTrue);
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
