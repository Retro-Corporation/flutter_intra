import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  Widget buildTemplate({
    String heading = 'Test heading',
    String primaryLabel = 'Primary',
    VoidCallback? onPrimary,
    String secondaryLabel = 'Secondary',
    ButtonType secondaryButtonType = ButtonType.ghost,
    VoidCallback? onSecondary,
  }) {
    return MaterialApp(
      home: AvatarMessageTemplate(
        heading: heading,
        primaryLabel: primaryLabel,
        onPrimary: onPrimary ?? () {},
        secondaryLabel: secondaryLabel,
        secondaryButtonType: secondaryButtonType,
        onSecondary: onSecondary ?? () {},
      ),
    );
  }

  group('AvatarMessageTemplate rendering', () {
    testWidgets('renders heading text', (tester) async {
      await tester.pumpWidget(
        buildTemplate(heading: 'Exercise saved great job!'),
      );
      expect(find.text('Exercise saved great job!'), findsOneWidget);
    });

    testWidgets('renders primary label', (tester) async {
      await tester.pumpWidget(buildTemplate(primaryLabel: 'Create Exercise'));
      expect(find.text('Create Exercise'), findsOneWidget);
    });

    testWidgets('renders secondary label', (tester) async {
      await tester.pumpWidget(buildTemplate(secondaryLabel: 'Not Now'));
      expect(find.text('Not Now'), findsOneWidget);
    });
  });

  group('AvatarMessageTemplate callbacks', () {
    testWidgets('tapping primary fires onPrimary', (tester) async {
      var called = false;
      await tester.pumpWidget(
        buildTemplate(
          primaryLabel: 'Create Exercise',
          onPrimary: () => called = true,
        ),
      );
      await tester.tap(find.text('Create Exercise'));
      await tester.pump();
      expect(called, isTrue);
    });

    testWidgets('tapping secondary fires onSecondary', (tester) async {
      var called = false;
      await tester.pumpWidget(
        buildTemplate(
          secondaryLabel: 'Not Now',
          onSecondary: () => called = true,
        ),
      );
      await tester.tap(find.text('Not Now'));
      await tester.pump();
      expect(called, isTrue);
    });
  });

  group('AvatarMessageTemplate secondary button type', () {
    testWidgets('ghost secondaryButtonType produces a ghost AppButton',
        (tester) async {
      await tester.pumpWidget(
        buildTemplate(secondaryButtonType: ButtonType.ghost),
      );
      final buttons = tester.widgetList<AppButton>(find.byType(AppButton)).toList();
      // buttons[0] = primary (filled), buttons[1] = secondary
      expect(buttons[1].type, ButtonType.ghost);
    });

    testWidgets('outline secondaryButtonType produces an outline AppButton',
        (tester) async {
      await tester.pumpWidget(
        buildTemplate(secondaryButtonType: ButtonType.outline),
      );
      final buttons = tester.widgetList<AppButton>(find.byType(AppButton)).toList();
      expect(buttons[1].type, ButtonType.outline);
    });
  });
}
