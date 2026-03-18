import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/catalog.dart';

void main() {
  group('Design System Catalog', () {
    testWidgets(
      'Catalog app renders without errors and shows title',
      (WidgetTester tester) async {
        await tester.pumpWidget(const DesignCatalogApp());
        await tester.pumpAndSettle();

        // Verify the catalog title renders
        expect(find.text('Design System'), findsOneWidget);
        expect(find.text('CATALOG'), findsOneWidget);
      },
    );

    testWidgets(
      'Foundation section is expanded by default and shows content',
      (WidgetTester tester) async {
        await tester.pumpWidget(const DesignCatalogApp());
        await tester.pumpAndSettle();

        // Foundation section header should be visible
        expect(find.text('FOUNDATION'), findsOneWidget);

        // Foundation sub-sections should be visible since it starts expanded
        expect(find.text('SEMANTIC COLORS'), findsOneWidget);
      },
    );

    testWidgets(
      'Atoms section expands to show button types on tap',
      (WidgetTester tester) async {
        // Use a large enough surface to fit content
        tester.view.physicalSize = const Size(1200, 4000);
        tester.view.devicePixelRatio = 1.0;
        addTearDown(tester.view.resetPhysicalSize);
        addTearDown(tester.view.resetDevicePixelRatio);

        await tester.pumpWidget(const DesignCatalogApp());
        await tester.pump(const Duration(milliseconds: 500));

        // Scroll to the ATOMS header
        final listView = find.byType(Scrollable).last;
        await tester.scrollUntilVisible(find.text('ATOMS'), 300, scrollable: listView);
        await tester.pump(const Duration(milliseconds: 100));

        // Tap the Atoms header to expand it
        await tester.tap(find.text('ATOMS'));
        // Pump past the AnimatedSize duration (300ms)
        await tester.pump(const Duration(milliseconds: 500));

        // Scroll further to reveal button content
        await tester.scrollUntilVisible(find.text('TYPES'), 300, scrollable: listView);
        await tester.pump(const Duration(milliseconds: 100));

        // After expanding, button type labels should be visible
        expect(find.text('TYPES'), findsOneWidget);
        // The three button type variants should render
        expect(find.text('Filled'), findsWidgets);
        expect(find.text('Outline'), findsWidgets);
        expect(find.text('Ghost'), findsWidgets);
      },
    );
  });
}
