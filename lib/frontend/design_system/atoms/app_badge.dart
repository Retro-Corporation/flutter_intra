import 'package:flutter/material.dart';
import '../foundation/colors.dart';
import '../foundation/radius.dart';

enum AppBadgeVariant { live, info, success, warning }

class AppBadge extends StatelessWidget {
  final String label;
  final AppBadgeVariant variant;
  final bool showDot;

  const AppBadge({
    super.key,
    required this.label,
    this.variant = AppBadgeVariant.info,
    this.showDot = false,
  });

  Color get _color => switch (variant) {
        AppBadgeVariant.live => AppColors.error,
        AppBadgeVariant.info => AppColors.brand,
        AppBadgeVariant.success => AppColors.success,
        AppBadgeVariant.warning => AppColors.warning,
      };

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: _color.withValues(alpha: 0.85),
        borderRadius: BorderRadius.circular(AppRadius.pill),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (showDot) ...[
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                color: Colors.white,
                shape: BoxShape.circle,
              ),
            ),
            const SizedBox(width: 6),
          ],
          Text(
            label,
            style: const TextStyle(
              fontFamily: 'Inter',
              fontSize: 11,
              fontWeight: FontWeight.w700,
              color: Colors.white,
              letterSpacing: 1.2,
            ),
          ),
        ],
      ),
    );
  }
}
