import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  AppConfirmationDialog buildDialog({
    VoidCallback? onConfirm,
    VoidCallback? onCancel,
  }) {
    return AppConfirmationDialog(
      subtitle: 'Do you want to',
      title: 'Sign Out?',
      confirmLabel: 'Yes - Sign me out',
      cancelLabel: 'Not now',
      onConfirm: onConfirm ?? () {},
      onCancel: onCancel ?? () {},
    );
  }

  group('AppConfirmationDialog', () {
    testWidgets('renders subtitle text correctly', (tester) async {
      await tester.pumpWidget(wrap(buildDialog()));
      expect(find.text('Do you want to'), findsOneWidget);
    });

    testWidgets('renders title text correctly', (tester) async {
      await tester.pumpWidget(wrap(buildDialog()));
      expect(find.text('Sign Out?'), findsOneWidget);
    });

    testWidgets('onConfirm fires when confirm button tapped', (tester) async {
      bool confirmed = false;
      await tester.pumpWidget(wrap(buildDialog(onConfirm: () => confirmed = true)));
      await tester.tap(find.text('Yes - Sign me out'));
      expect(confirmed, isTrue);
    });

    testWidgets('onCancel fires when cancel button tapped', (tester) async {
      bool cancelled = false;
      await tester.pumpWidget(wrap(buildDialog(onCancel: () => cancelled = true)));
      await tester.tap(find.text('Not now'));
      expect(cancelled, isTrue);
    });

    testWidgets('confirm button uses AppColors.error', (tester) async {
      await tester.pumpWidget(wrap(buildDialog()));
      final confirmButton = tester.widget<AppButton>(find.byType(AppButton).first);
      expect(confirmButton.color, AppColors.error);
    });

    testWidgets('cancel button uses AppColors.textPrimary', (tester) async {
      await tester.pumpWidget(wrap(buildDialog()));
      final cancelButton = tester.widget<AppButton>(find.byType(AppButton).last);
      expect(cancelButton.color, AppColors.textPrimary);
    });
  });
}
