import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  Widget build(FilterButtonState state, {VoidCallback? onTap}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: FilterButton(
            state: state,
            onTap: onTap ?? () {},
            icon: AppIcons.filter,
          ),
        ),
      ),
    );
  }

  group('FilterButton states', () {
    testWidgets('idle state: icon color is textPrimary', (tester) async {
      await tester.pumpWidget(build(FilterButtonState.idle));
      final icon = tester.widget<AppIcon>(find.byType(AppIcon));
      expect(icon.color, AppColors.textPrimary);
    });

    testWidgets('open state: icon color is textPrimary', (tester) async {
      await tester.pumpWidget(build(FilterButtonState.open));
      final icon = tester.widget<AppIcon>(find.byType(AppIcon));
      expect(icon.color, AppColors.textPrimary);
    });

    testWidgets('sorted state: icon color is brand', (tester) async {
      await tester.pumpWidget(build(FilterButtonState.sorted));
      final icon = tester.widget<AppIcon>(find.byType(AppIcon));
      expect(icon.color, AppColors.brand);
    });

    testWidgets('renders the icon path passed in', (tester) async {
      await tester.pumpWidget(build(FilterButtonState.idle));
      final icon = tester.widget<AppIcon>(find.byType(AppIcon));
      expect(icon.icon, AppIcons.filter);
    });
  });

  group('FilterButton interaction', () {
    testWidgets('onTap fires on tap', (tester) async {
      bool fired = false;
      await tester.pumpWidget(build(FilterButtonState.idle, onTap: () => fired = true));
      await tester.tap(find.byType(PressableSurface));
      await tester.pump();
      expect(fired, true);
    });
  });
}
