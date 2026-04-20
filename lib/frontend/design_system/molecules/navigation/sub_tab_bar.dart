import 'package:flutter/material.dart';

import '../../foundation/color/colors.dart';
import '../../foundation/motion/curves.dart';
import '../../foundation/motion/durations.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/stroke.dart';
import '../../atoms/controls/sub_tab_item.dart';
import 'sub_tab_bar_types.dart';

class SubTabBar extends StatefulWidget {
  final List<SubTabBarTab> tabs;
  final int activeIndex;
  final ValueChanged<int> onChanged;

  const SubTabBar({
    super.key,
    required this.tabs,
    required this.activeIndex,
    required this.onChanged,
  });

  @override
  State<SubTabBar> createState() => _SubTabBarState();
}

class _SubTabBarState extends State<SubTabBar> {
  late List<GlobalKey> _tabKeys;
  late List<double> _tabLefts;
  late List<double> _tabWidths;

  @override
  void initState() {
    super.initState();
    _tabKeys = List.generate(widget.tabs.length, (_) => GlobalKey());
    _tabLefts = List.filled(widget.tabs.length, 0.0);
    _tabWidths = List.filled(widget.tabs.length, 0.0);
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureTabs());
  }

  @override
  void didUpdateWidget(SubTabBar oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.tabs.length != widget.tabs.length) {
      _tabKeys = List.generate(widget.tabs.length, (_) => GlobalKey());
      _tabLefts = List.filled(widget.tabs.length, 0.0);
      _tabWidths = List.filled(widget.tabs.length, 0.0);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) => _measureTabs());
  }

  void _measureTabs() {
    final stackBox = context.findRenderObject() as RenderBox?;
    if (stackBox == null) return;

    final lefts = List<double>.filled(widget.tabs.length, 0.0);
    final widths = List<double>.filled(widget.tabs.length, 0.0);

    for (var i = 0; i < _tabKeys.length; i++) {
      final tabContext = _tabKeys[i].currentContext;
      if (tabContext == null) continue;
      final tabBox = tabContext.findRenderObject() as RenderBox?;
      if (tabBox == null) continue;
      final localOffset = stackBox.globalToLocal(tabBox.localToGlobal(Offset.zero));
      lefts[i] = localOffset.dx;
      widths[i] = tabBox.size.width;
    }

    setState(() {
      _tabLefts = lefts;
      _tabWidths = widths;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        // Tab row
        Row(
          children: [
            for (var i = 0; i < widget.tabs.length; i++) ...[
              if (i > 0) const SizedBox(width: AppGrid.grid12),
              Expanded(
                child: KeyedSubtree(
                  key: _tabKeys[i],
                  child: SubTabItem(
                    label: widget.tabs[i].label,
                    isActive: i == widget.activeIndex,
                    isEnabled: widget.tabs[i].isEnabled,
                    onTap: () {
                      if (widget.tabs[i].isEnabled) widget.onChanged(i);
                    },
                  ),
                ),
              ),
            ],
          ],
        ),
        // Sliding indicator
        if (widget.activeIndex < _tabWidths.length &&
            _tabWidths[widget.activeIndex] > 0)
          AnimatedPositioned(
            duration: AppDurations.toggle,
            curve: AppCurves.toggle,
            bottom: 0,
            left: _tabLefts[widget.activeIndex],
            width: _tabWidths[widget.activeIndex],
            height: AppStroke.xl,
            child: const ColoredBox(color: AppColors.brand),
          ),
      ],
    );
  }
}
