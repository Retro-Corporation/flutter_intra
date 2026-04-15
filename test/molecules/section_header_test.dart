import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';
import 'package:flutter_intra/frontend/design_system/molecules/display/section_header.dart';

void main() {
  Widget buildTestWidget({
    required String label,
    required String count,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: SectionHeader(label: label, count: count),
        ),
      ),
    );
  }

  group('SectionHeader', () {
    testWidgets('renders label text', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        label: 'Current clients',
        count: '17/30',
      ));

      expect(find.text('Current clients'), findsOneWidget);
    });

    testWidgets('renders count text', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        label: 'Current clients',
        count: '17/30',
      ));

      expect(find.text('17/30'), findsOneWidget);
    });

    testWidgets('uses spaceBetween alignment', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        label: 'Current clients',
        count: '17/30',
      ));

      final row = tester.widget<Row>(find.byType(Row));
      expect(row.mainAxisAlignment, MainAxisAlignment.spaceBetween);
    });
  });
}
