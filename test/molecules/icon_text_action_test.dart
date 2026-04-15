import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';
import 'package:flutter_intra/frontend/design_system/molecules/display/icon_text_action.dart';

void main() {
  Widget buildTestWidget({
    required String iconPath,
    required String label,
    required VoidCallback onTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: IconTextAction(
            iconPath: iconPath,
            label: label,
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  group('IconTextAction', () {
    testWidgets('renders label text', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        iconPath: AppIcons.add,
        label: 'Add Clients',
        onTap: () {},
      ));

      expect(find.text('Add Clients'), findsOneWidget);
    });

    testWidgets('renders AppIcon', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestWidget(
        iconPath: AppIcons.add,
        label: 'Add Clients',
        onTap: () {},
      ));

      expect(find.byType(AppIcon), findsOneWidget);
    });

    testWidgets('onTap fires on tap', (WidgetTester tester) async {
      bool fired = false;

      await tester.pumpWidget(buildTestWidget(
        iconPath: AppIcons.add,
        label: 'Add Clients',
        onTap: () => fired = true,
      ));

      await tester.tap(find.byType(GestureDetector));
      await tester.pump();

      expect(fired, true);
    });
  });
}
