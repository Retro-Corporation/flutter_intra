/// Immutable icon config for one tab in [AppNavBar].
///
/// Pass [AppIcons] string paths — [activeIcon] is shown when this tab is
/// selected, [inactiveIcon] otherwise.
class NavBarTab {
  final String activeIcon;
  final String inactiveIcon;

  const NavBarTab({
    required this.activeIcon,
    required this.inactiveIcon,
  });
}
