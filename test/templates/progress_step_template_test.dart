import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';
import 'package:flutter/material.dart';

void main() {
  Widget build({
    double progress = 0.5,
    VoidCallback? onBack,
    String heading = 'Test Heading',
    String subtitle = 'Test subtitle',
    Widget? body,
    String primaryLabel = 'Continue',
    VoidCallback? onPrimary,
  }) {
    return MaterialApp(
      home: ProgressStepTemplate(
        progress: progress,
        onBack: onBack ?? () {},
        heading: heading,
        subtitle: subtitle,
        body: body ?? const SizedBox.shrink(),
        primaryLabel: primaryLabel,
        onPrimary: onPrimary,
      ),
    );
  }

  group('ProgressStepTemplate', () {
    testWidgets('renders BackAndProgressBarMolecule', (tester) async {
      await tester.pumpWidget(build());
      expect(find.byType(BackAndProgressBarMolecule), findsOneWidget);
    });

    testWidgets('renders HeadingWithSubtitleMolecule', (tester) async {
      await tester.pumpWidget(build());
      expect(find.byType(HeadingWithSubtitleMolecule), findsOneWidget);
    });

    testWidgets('renders body widget', (tester) async {
      const bodyKey = Key('test_body');
      await tester.pumpWidget(build(body: const SizedBox(key: bodyKey)));
      expect(find.byKey(bodyKey), findsOneWidget);
    });

    testWidgets('tapping back fires onBack', (tester) async {
      var called = false;
      await tester.pumpWidget(build(onBack: () => called = true));
      await tester.tap(
        find.descendant(
          of: find.byType(BackAndProgressBarMolecule),
          matching: find.byType(AppButton),
        ),
      );
      await tester.pump();
      expect(called, isTrue);
    });

    testWidgets('tapping primary fires onPrimary when non-null', (tester) async {
      var called = false;
      await tester.pumpWidget(build(onPrimary: () => called = true));
      // The last AppButton in the tree is the primary CTA
      await tester.tap(find.byType(AppButton).last);
      await tester.pump();
      expect(called, isTrue);
    });

    testWidgets('primary button is disabled when onPrimary is null', (tester) async {
      await tester.pumpWidget(build(onPrimary: null));
      final btn = tester.widget<AppButton>(find.byType(AppButton).last);
      expect(btn.isDisabled, isTrue);
    });
  });
}
