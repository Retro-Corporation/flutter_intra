import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';
import 'package:flutter_intra/frontend/design_system/molecules/controls/filter_button.dart';
import 'package:flutter_intra/frontend/design_system/molecules/controls/filter_button_types.dart';

void main() {
  Widget build(FilterButtonState state, {VoidCallback? onTap}) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: FilterButton(state: state, onTap: onTap ?? () {}),
        ),
      ),
    );
  }

  group('FilterButton states', () {
    testWidgets('idle state: renders AppIcon with filter path', (tester) async {
      await tester.pumpWidget(build(FilterButtonState.idle));
      final icon = tester.widget<AppIcon>(find.byType(AppIcon));
      expect(icon.icon, AppIcons.filter);
      expect(icon.color, AppColors.textSecondary);
    });

    testWidgets('open state: renders AppIcon with filterFilled path', (tester) async {
      await tester.pumpWidget(build(FilterButtonState.open));
      final icon = tester.widget<AppIcon>(find.byType(AppIcon));
      expect(icon.icon, AppIcons.filterFilled);
      expect(icon.color, AppColors.textPrimary);
    });

    testWidgets('sorted state: renders AppIcon with filterFilled path', (tester) async {
      await tester.pumpWidget(build(FilterButtonState.sorted));
      final icon = tester.widget<AppIcon>(find.byType(AppIcon));
      expect(icon.icon, AppIcons.filterFilled);
      expect(icon.color, AppColors.brand);
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
