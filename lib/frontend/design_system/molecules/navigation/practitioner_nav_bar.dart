import 'package:flutter/material.dart';

import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/stroke.dart';
import '../../icons/app_icons.dart';
import '../../atoms/controls/nav_bar_item.dart';
import '../../atoms/controls/nav_bar_item_types.dart';
import 'practitioner_nav_bar_types.dart';

class PractitionerNavBar extends StatelessWidget {
  final PractitionerTab selectedTab;
  final ValueChanged<PractitionerTab> onTabSelected;

  const PractitionerNavBar({
    required this.selectedTab,
    required this.onTabSelected,
    super.key,
  });

  String _iconPath(PractitionerTab tab) => switch (tab) {
    PractitionerTab.clients  => selectedTab == tab ? AppIcons.groupFilled   : AppIcons.group,
    PractitionerTab.workouts => selectedTab == tab ? AppIcons.bodyFilled    : AppIcons.body,
    PractitionerTab.profile  => selectedTab == tab ? AppIcons.profileFilled : AppIcons.profile,
  };

  NavBarItemState _stateFor(PractitionerTab tab) =>
      tab == selectedTab ? NavBarItemState.active : NavBarItemState.inactive;

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
        children: PractitionerTab.values.map((tab) => Expanded(
          child: NavBarItem(
            iconPath: _iconPath(tab),
            state: _stateFor(tab),
            onTap: () => onTabSelected(tab),
          ),
        )).toList(),
      ),
    );
  }
}
