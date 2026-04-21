import 'package:flutter/material.dart';
import '../../atoms/primitives/icon.dart';
import '../../atoms/primitives/score_badge.dart';
import '../../atoms/primitives/score_badge_types.dart';
import '../../atoms/primitives/text.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/grid.dart';
import '../../foundation/space/padding.dart';
import '../../foundation/type/typography.dart';
import '../../icons/app_icons.dart';
import '../../molecules/navigation/sub_tab_bar.dart';
import '../../molecules/navigation/sub_tab_bar_types.dart';

/// Organism: page header for the Exercise Plan screen.
///
/// Composes a client info row (back button, name/email, score badge) and a
/// [SubTabBar]. Reports navigation and tab-change events upward via callbacks.
/// Never triggers navigation or calls services directly.
///
/// **Template owns:** all business state. This organism is stateless and
/// renders what it receives.
class ExercisePlanPageHeader extends StatelessWidget {
  final String clientName;
  final String clientEmail;
  final double score;
  final Color scoreColor;
  final ScoreBadgeVariant scoreVariant;
  final List<SubTabBarTab> tabs;
  final int activeTabIndex;
  final VoidCallback onBack;
  final ValueChanged<int> onTabChanged;

  const ExercisePlanPageHeader({
    super.key,
    required this.clientName,
    required this.clientEmail,
    required this.score,
    required this.scoreColor,
    required this.scoreVariant,
    required this.tabs,
    required this.activeTabIndex,
    required this.onBack,
    required this.onTabChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        // ── Row 1: client info ──
        Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: AppPadding.rem1,
            vertical: AppPadding.rem075,
          ),
          child: Row(
            children: [
              GestureDetector(
                onTap: onBack,
                child: const AppIcon(AppIcons.arrowBack),
              ),
              const SizedBox(width: AppGrid.grid16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    AppText(
                      clientName,
                      style: AppTypography.bodyLarge.bold,
                      color: AppColors.textPrimary,
                    ),
                    AppText(
                      clientEmail,
                      style: AppTypography.body.regular,
                      color: AppColors.textSecondary,
                    ),
                  ],
                ),
              ),
              const SizedBox(width: AppGrid.grid16),
              ScoreBadge(
                score: score,
                underlineColor: scoreColor,
                size: ScoreBadgeSize.md,
                variant: scoreVariant,
              ),
            ],
          ),
        ),

        // ── Row 2: tab bar ──
        SubTabBar(
          tabs: tabs,
          activeIndex: activeTabIndex,
          onChanged: onTabChanged,
        ),
      ],
    );
  }
}
