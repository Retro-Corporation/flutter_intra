import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';
import 'package:flutter_intra/frontend/design_system/templates/value_explanation_template.dart';

void main() {
  Widget buildWidget({
    String heading = 'Test Heading',
    String subheading = 'Test Subheading',
    double progressValue = 0.5,
    String primaryLabel = 'Continue',
    VoidCallback? onBack,
    VoidCallback? onPrimary,
    String? secondaryLabel,
    VoidCallback? onSecondary,
  }) {
    return MaterialApp(
      home: ValueExplanationTemplate(
        heading: heading,
        subheading: subheading,
        progressValue: progressValue,
        primaryLabel: primaryLabel,
        onBack: onBack ?? () {},
        onPrimary: onPrimary ?? () {},
        secondaryLabel: secondaryLabel,
        onSecondary: onSecondary,
      ),
    );
  }

  // Set phone-sized surface so the fixed-height MediaHolder (408px) fits.
  void setPhoneSize(WidgetTester tester) {
    tester.view.physicalSize = const Size(1170, 2532); // 390×844 @3x
    tester.view.devicePixelRatio = 3.0;
    addTearDown(tester.view.resetPhysicalSize);
    addTearDown(tester.view.resetDevicePixelRatio);
  }

  group('ValueExplanationTemplate — content rendering', () {
    testWidgets('Renders heading string in an AppText widget', (tester) async {
      setPhoneSize(tester);
      await tester.pumpWidget(buildWidget());

      expect(find.text('Test Heading'), findsOneWidget);
      expect(
        find.ancestor(of: find.text('Test Heading'), matching: find.byType(AppText)),
        findsOneWidget,
      );
    });

    testWidgets('Renders subheading string in an AppText widget', (tester) async {
      setPhoneSize(tester);
      await tester.pumpWidget(buildWidget());

      expect(find.text('Test Subheading'), findsOneWidget);
      expect(
        find.ancestor(of: find.text('Test Subheading'), matching: find.byType(AppText)),
        findsOneWidget,
      );
    });

    testWidgets('Renders a MediaHolder widget', (tester) async {
      setPhoneSize(tester);
      await tester.pumpWidget(buildWidget());

      expect(find.byType(MediaHolder), findsOneWidget);
    });

    testWidgets('Renders an AppButton with the primaryLabel text', (tester) async {
      setPhoneSize(tester);
      await tester.pumpWidget(buildWidget());

      expect(find.text('Continue'), findsOneWidget);
    });
  });

  group('ValueExplanationTemplate — secondary button absent', () {
    testWidgets(
      'When secondaryLabel is null, secondary text is not present',
      (tester) async {
        setPhoneSize(tester);
        await tester.pumpWidget(buildWidget(secondaryLabel: null));

        expect(find.text('Continue'), findsOneWidget);
        expect(find.text('Skip for now'), findsNothing);
      },
    );
  });

  group('ValueExplanationTemplate — secondary button present', () {
    testWidgets(
      'When secondaryLabel is provided, that text is present',
      (tester) async {
        setPhoneSize(tester);
        await tester.pumpWidget(buildWidget(
          secondaryLabel: 'Skip for now',
          onSecondary: () {},
        ));

        expect(find.text('Skip for now'), findsOneWidget);
      },
    );
  });

  group('ValueExplanationTemplate — callbacks', () {
    testWidgets('Tapping the primary button fires onPrimary', (tester) async {
      setPhoneSize(tester);
      var fired = false;
      await tester.pumpWidget(buildWidget(onPrimary: () => fired = true));

      await tester.tap(find.text('Continue'));
      await tester.pump();

      expect(fired, isTrue);
    });

    testWidgets('Tapping the secondary button fires onSecondary', (tester) async {
      setPhoneSize(tester);
      var fired = false;
      await tester.pumpWidget(buildWidget(
        secondaryLabel: 'Skip for now',
        onSecondary: () => fired = true,
      ));

      await tester.tap(find.text('Skip for now'));
      await tester.pump();

      expect(fired, isTrue);
    });
  });
}
