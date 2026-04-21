import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';
import 'package:flutter_intra/frontend/design_system/molecules/display/icon_section_header.dart';
import 'package:flutter_intra/frontend/design_system/atoms/primitives/icon.dart';

void main() {
  Widget buildTestWidget({
    required String label,
    String? iconPath,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: IconSectionHeader(label: label, iconPath: iconPath),
        ),
      ),
    );
  }

  bool _isOnePxDivider(Container c) {
    final constraints = c.constraints;
    if (constraints == null) return false;
    return constraints.hasTightHeight && constraints.maxHeight == 1;
  }

  group('IconSectionHeader', () {
    testWidgets('renders label text', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(label: 'Details'));

      expect(find.text('Details'), findsOneWidget);
    });

    testWidgets('renders icon when iconPath is provided',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        label: 'Details',
        iconPath: 'assets/icons/home.svg',
      ));

      expect(find.byType(AppIcon), findsOneWidget);
    });

    testWidgets('does not render AppIcon when iconPath is null',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(label: 'Details'));

      expect(find.byType(AppIcon), findsNothing);
    });

    testWidgets('trailing divider Container with height 1 is present without icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(label: 'Details'));

      final dividers =
          tester.widgetList<Container>(find.byType(Container)).where(_isOnePxDivider);
      expect(dividers.length, greaterThanOrEqualTo(1));
    });

    testWidgets('trailing divider Container with height 1 is present with icon',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        label: 'Details',
        iconPath: 'assets/icons/home.svg',
      ));

      final dividers =
          tester.widgetList<Container>(find.byType(Container)).where(_isOnePxDivider);
      expect(dividers.length, greaterThanOrEqualTo(1));
    });
  });
}
