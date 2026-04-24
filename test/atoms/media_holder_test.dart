import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  Widget buildTestMediaHolder() {
    return const MaterialApp(
      home: Scaffold(
        body: Center(child: MediaHolder()),
      ),
    );
  }

  group('MediaHolder rendering', () {
    testWidgets(
      'Renders a SizedBox with fixed 332x408 dimensions',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestMediaHolder());

        final sizedBox = tester.widget<SizedBox>(
          find.descendant(
            of: find.byType(MediaHolder),
            matching: find.byType(SizedBox),
          ),
        );
        expect(sizedBox.width, 332.0);
        expect(sizedBox.height, 408.0);
      },
    );

    testWidgets(
      'Renders at 360×360 for hero size',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          const MaterialApp(
            home: Scaffold(
              body: Center(child: MediaHolder(size: MediaHolderSize.hero)),
            ),
          ),
        );

        final sizedBox = tester.widget<SizedBox>(
          find.descendant(
            of: find.byType(MediaHolder),
            matching: find.byType(SizedBox),
          ),
        );
        expect(sizedBox.width, 360.0);
        expect(sizedBox.height, 360.0);
      },
    );
  });

  group('MediaHolder decoration', () {
    testWidgets(
      'Decoration color equals AppColors.surface',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestMediaHolder());

        final decoratedBox = tester.widget<DecoratedBox>(
          find.byType(DecoratedBox),
        );
        final decoration = decoratedBox.decoration as BoxDecoration;
        expect(decoration.color, AppColors.surface);
      },
    );

    testWidgets(
      'Border radius equals BorderRadius.circular(AppRadius.md)',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestMediaHolder());

        final decoratedBox = tester.widget<DecoratedBox>(
          find.byType(DecoratedBox),
        );
        final decoration = decoratedBox.decoration as BoxDecoration;
        expect(decoration.borderRadius, BorderRadius.circular(AppRadius.md));
      },
    );
  });
}
