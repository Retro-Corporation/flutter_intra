import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  const practitionerTabs = [
    NavBarTab(activeIcon: AppIcons.groupFilled,   inactiveIcon: AppIcons.group),
    NavBarTab(activeIcon: AppIcons.bodyFilled,    inactiveIcon: AppIcons.body),
    NavBarTab(activeIcon: AppIcons.profileFilled, inactiveIcon: AppIcons.profile),
  ];

  Widget build({
    required List<NavBarTab> tabs,
    required int selectedIndex,
    ValueChanged<int>? onTabSelected,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: AppNavBar(
          tabs: tabs,
          selectedIndex: selectedIndex,
          onTabSelected: onTabSelected ?? (_) {},
        ),
      ),
    );
  }

  group('AppNavBar rendering', () {
    testWidgets('renders correct number of NavBarItems', (tester) async {
      await tester.pumpWidget(build(tabs: practitionerTabs, selectedIndex: 0));
      expect(find.byType(NavBarItem), findsNWidgets(3));
    });

    testWidgets('selectedIndex 0 — first active, others inactive', (tester) async {
      await tester.pumpWidget(build(tabs: practitionerTabs, selectedIndex: 0));
      final items = tester.widgetList<NavBarItem>(find.byType(NavBarItem)).toList();
      expect(items[0].state, NavBarItemState.active);
      expect(items[1].state, NavBarItemState.inactive);
      expect(items[2].state, NavBarItemState.inactive);
    });

    testWidgets('selectedIndex 1 — second active', (tester) async {
      await tester.pumpWidget(build(tabs: practitionerTabs, selectedIndex: 1));
      final items = tester.widgetList<NavBarItem>(find.byType(NavBarItem)).toList();
      expect(items[1].state, NavBarItemState.active);
    });

    testWidgets('selectedIndex 2 — third active', (tester) async {
      await tester.pumpWidget(build(tabs: practitionerTabs, selectedIndex: 2));
      final items = tester.widgetList<NavBarItem>(find.byType(NavBarItem)).toList();
      expect(items[2].state, NavBarItemState.active);
    });

    testWidgets('active tab uses activeIcon path', (tester) async {
      await tester.pumpWidget(build(tabs: practitionerTabs, selectedIndex: 0));
      final items = tester.widgetList<NavBarItem>(find.byType(NavBarItem)).toList();
      expect(items[0].iconPath, AppIcons.groupFilled);
      expect(items[1].iconPath, AppIcons.body);
      expect(items[2].iconPath, AppIcons.profile);
    });

    testWidgets('athlete config renders home/crown/profile', (tester) async {
      const athleteTabs = [
        NavBarTab(activeIcon: AppIcons.homeFilled,    inactiveIcon: AppIcons.home),
        NavBarTab(activeIcon: AppIcons.crownFilled,   inactiveIcon: AppIcons.crown),
        NavBarTab(activeIcon: AppIcons.profileFilled, inactiveIcon: AppIcons.profile),
      ];
      await tester.pumpWidget(build(tabs: athleteTabs, selectedIndex: 0));
      final items = tester.widgetList<NavBarItem>(find.byType(NavBarItem)).toList();
      expect(items[0].iconPath, AppIcons.homeFilled);
      expect(items[1].iconPath, AppIcons.crown);
      expect(items[2].iconPath, AppIcons.profile);
    });
  });

  group('AppNavBar interaction', () {
    testWidgets('tapping first tab fires onTabSelected(0)', (tester) async {
      int? received;
      await tester.pumpWidget(build(
        tabs: practitionerTabs, selectedIndex: 1,
        onTabSelected: (i) => received = i,
      ));
      await tester.tap(find.byType(NavBarItem).first);
      await tester.pump();
      expect(received, 0);
    });

    testWidgets('tapping second tab fires onTabSelected(1)', (tester) async {
      int? received;
      await tester.pumpWidget(build(
        tabs: practitionerTabs, selectedIndex: 0,
        onTabSelected: (i) => received = i,
      ));
      await tester.tap(find.byType(NavBarItem).at(1));
      await tester.pump();
      expect(received, 1);
    });

    testWidgets('tapping last tab fires onTabSelected(2)', (tester) async {
      int? received;
      await tester.pumpWidget(build(
        tabs: practitionerTabs, selectedIndex: 0,
        onTabSelected: (i) => received = i,
      ));
      await tester.tap(find.byType(NavBarItem).last);
      await tester.pump();
      expect(received, 2);
    });
  });
}
