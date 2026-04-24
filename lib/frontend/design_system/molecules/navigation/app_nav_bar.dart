import 'package:flutter/material.dart';

import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/stroke.dart';
import '../../atoms/controls/nav_bar_item.dart';
import '../../atoms/controls/nav_bar_item_types.dart';
import 'app_nav_bar_types.dart';

class AppNavBar extends StatelessWidget {
  final List<NavBarTab> tabs;
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  const AppNavBar({
    required this.tabs,
    required this.selectedIndex,
    required this.onTabSelected,
    super.key,
  })  : assert(tabs.length > 0, 'AppNavBar requires at least one tab'),
        assert(
          selectedIndex >= 0 && selectedIndex < tabs.length,
          'selectedIndex must be within 0..tabs.length-1',
        );

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.background,
        border: Border(
          top: BorderSide(color: AppColors.surfaceBorder, width: AppStroke.xs),
        ),
      ),
      padding: const EdgeInsets.symmetric(
        horizontal: AppGrid.grid24,
        vertical: AppGrid.grid16,
      ),
      child: Row(
        children: List.generate(tabs.length, (i) {
          final tab = tabs[i];
          final isSelected = i == selectedIndex;
          return Expanded(
            child: NavBarItem(
              iconPath: isSelected ? tab.activeIcon : tab.inactiveIcon,
              state: isSelected ? NavBarItemState.active : NavBarItemState.inactive,
              onTap: () => onTabSelected(i),
            ),
          );
        }),
      ),
    );
  }
}
