import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  Widget buildTestDivider({String? label}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: AppDivider(label: label),
        ),
      ),
    );
  }

  group('AppDivider — no label', () {
    testWidgets(
      'Renders a single Container, no Row present',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestDivider());

        // The plain divider is a bare Container — no Row wrapper
        expect(find.byType(Row), findsNothing);
        expect(find.byType(Container), findsOneWidget);
      },
    );

    testWidgets(
      'Container color equals AppColors.surfaceBorder',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestDivider());

        final container = tester.widget<Container>(find.byType(Container));
        expect(container.color, AppColors.surfaceBorder);
      },
    );

    testWidgets(
      'Container height equals AppStroke.xs (1.0)',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestDivider());

        final container = tester.widget<Container>(find.byType(Container));
        expect(container.constraints?.maxHeight, AppStroke.xs);
      },
    );
  });

  group('AppDivider — with label', () {
    testWidgets(
      'Renders a Row',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestDivider(label: 'or'));

        expect(find.byType(Row), findsOneWidget);
      },
    );

    testWidgets(
      'Label string appears in an AppText widget',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestDivider(label: 'or'));

        expect(find.byType(AppText), findsOneWidget);
        expect(find.text('or'), findsOneWidget);
      },
    );

    testWidgets(
      'Two Expanded widgets are present for the rule lines',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestDivider(label: 'or'));

        expect(find.byType(Expanded), findsNWidgets(2));
      },
    );
  });
}
