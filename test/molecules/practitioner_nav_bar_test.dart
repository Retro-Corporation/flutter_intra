import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';
import 'package:flutter_intra/frontend/design_system/molecules/navigation/practitioner_nav_bar.dart';
import 'package:flutter_intra/frontend/design_system/molecules/navigation/practitioner_nav_bar_types.dart';

void main() {
  Widget build(PractitionerTab selected, {ValueChanged<PractitionerTab>? onTabSelected}) {
    return MaterialApp(
      home: Scaffold(
        body: PractitionerNavBar(
          selectedTab: selected,
          onTabSelected: onTabSelected ?? (_) {},
        ),
      ),
    );
  }

  group('PractitionerNavBar rendering', () {
    testWidgets('renders 3 NavBarItems', (tester) async {
      await tester.pumpWidget(build(PractitionerTab.clients));
      expect(find.byType(NavBarItem), findsNWidgets(3));
    });

    testWidgets('clients tab active: clients NavBarItem is active', (tester) async {
      await tester.pumpWidget(build(PractitionerTab.clients));
      final navItems = tester.widgetList<NavBarItem>(find.byType(NavBarItem)).toList();
      expect(navItems[0].state, NavBarItemState.active);
      expect(navItems[1].state, NavBarItemState.inactive);
      expect(navItems[2].state, NavBarItemState.inactive);
    });

    testWidgets('workouts tab active: workouts NavBarItem is active', (tester) async {
      await tester.pumpWidget(build(PractitionerTab.workouts));
      final navItems = tester.widgetList<NavBarItem>(find.byType(NavBarItem)).toList();
      expect(navItems[0].state, NavBarItemState.inactive);
      expect(navItems[1].state, NavBarItemState.active);
      expect(navItems[2].state, NavBarItemState.inactive);
    });

    testWidgets('profile tab active: profile NavBarItem is active', (tester) async {
      await tester.pumpWidget(build(PractitionerTab.profile));
      final navItems = tester.widgetList<NavBarItem>(find.byType(NavBarItem)).toList();
      expect(navItems[0].state, NavBarItemState.inactive);
      expect(navItems[1].state, NavBarItemState.inactive);
      expect(navItems[2].state, NavBarItemState.active);
    });

    testWidgets('active clients tab uses groupFilled icon', (tester) async {
      await tester.pumpWidget(build(PractitionerTab.clients));
      final navItems = tester.widgetList<NavBarItem>(find.byType(NavBarItem)).toList();
      expect(navItems[0].iconPath, AppIcons.groupFilled);
      expect(navItems[1].iconPath, AppIcons.body);
      expect(navItems[2].iconPath, AppIcons.profile);
    });
  });

  group('PractitionerNavBar interaction', () {
    testWidgets('tapping clients tab fires onTabSelected with clients', (tester) async {
      PractitionerTab? tapped;
      await tester.pumpWidget(build(PractitionerTab.workouts, onTabSelected: (t) => tapped = t));
      // Tap the first NavBarItem (clients)
      await tester.tap(find.byType(NavBarItem).first);
      await tester.pump();
      expect(tapped, PractitionerTab.clients);
    });

    testWidgets('tapping workouts tab fires onTabSelected with workouts', (tester) async {
      PractitionerTab? tapped;
      await tester.pumpWidget(build(PractitionerTab.clients, onTabSelected: (t) => tapped = t));
      await tester.tap(find.byType(NavBarItem).at(1));
      await tester.pump();
      expect(tapped, PractitionerTab.workouts);
    });

    testWidgets('tapping profile tab fires onTabSelected with profile', (tester) async {
      PractitionerTab? tapped;
      await tester.pumpWidget(build(PractitionerTab.clients, onTabSelected: (t) => tapped = t));
      await tester.tap(find.byType(NavBarItem).last);
      await tester.pump();
      expect(tapped, PractitionerTab.profile);
    });
  });
}
