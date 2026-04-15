import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/atoms/behaviors/pressable_surface.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  group('PressableSurface', () {
    testWidgets('renders child content', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PressableSurface(
                backgroundColor: AppColors.surface,
                borderColor: AppColors.surfaceBorder,
                borderRadius: AppRadius.md,
                child: const Text('hello'),
              ),
            ),
          ),
        ),
      );

      expect(find.text('hello'), findsOneWidget);
    });

    testWidgets('onTap fires after tap up', (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PressableSurface(
                backgroundColor: AppColors.surface,
                borderColor: AppColors.surfaceBorder,
                borderRadius: AppRadius.md,
                onTap: () => tapped = true,
                child: const Text('tap me'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PressableSurface));
      await tester.pump();

      expect(tapped, isTrue);
    });

    testWidgets('onTap does not fire when isInteractive is false', (WidgetTester tester) async {
      var tapped = false;

      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PressableSurface(
                backgroundColor: AppColors.surface,
                borderColor: AppColors.surfaceBorder,
                borderRadius: AppRadius.md,
                onTap: () => tapped = true,
                isInteractive: false,
                child: const Text('not interactive'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PressableSurface));
      await tester.pump();

      expect(tapped, isFalse);
    });

    testWidgets('onTap does not fire when onTap is null', (WidgetTester tester) async {
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: PressableSurface(
                backgroundColor: AppColors.surface,
                borderColor: AppColors.surfaceBorder,
                borderRadius: AppRadius.md,
                child: const Text('no tap'),
              ),
            ),
          ),
        ),
      );

      await tester.tap(find.byType(PressableSurface));
      await tester.pump();

      // Should not throw — widget still renders
      expect(find.text('no tap'), findsOneWidget);
    });
  });
}
