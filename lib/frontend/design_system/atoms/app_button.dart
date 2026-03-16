import 'package:flutter/material.dart';
import '../foundation/colors.dart';
import '../foundation/typography.dart';
import '../foundation/radius.dart';

enum AppButtonVariant { primary, secondary, outline, danger }

class AppButton extends StatelessWidget {
  final String label;
  final VoidCallback? onPressed;
  final IconData? icon;
  final AppButtonVariant variant;
  final bool expanded;

  const AppButton({
    super.key,
    required this.label,
    this.onPressed,
    this.icon,
    this.variant = AppButtonVariant.primary,
    this.expanded = false,
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      height: 50,
      width: expanded ? double.infinity : null,
      child: switch (variant) {
        AppButtonVariant.primary => _buildPrimary(),
        AppButtonVariant.danger => _buildDanger(),
        AppButtonVariant.secondary => _buildSecondary(),
        AppButtonVariant.outline => _buildOutline(),
      },
    );
  }

  Widget _buildPrimary() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.brandGradient,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: AppColors.brand.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: _textButton(AppColors.textPrimary),
    );
  }

  Widget _buildDanger() {
    return DecoratedBox(
      decoration: BoxDecoration(
        gradient: AppColors.errorGradient,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: AppColors.error.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: _textButton(AppColors.textPrimary),
    );
  }

  Widget _buildSecondary() {
    return DecoratedBox(
      decoration: BoxDecoration(
        color: AppColors.blue500,
        borderRadius: BorderRadius.circular(AppRadius.md),
        boxShadow: [
          BoxShadow(
            color: AppColors.blue500.withValues(alpha: 0.35),
            blurRadius: 24,
            offset: const Offset(0, 6),
          ),
        ],
      ),
      child: _textButton(AppColors.textPrimary),
    );
  }

  Widget _buildOutline() {
    return OutlinedButton.icon(
      onPressed: onPressed,
      style: OutlinedButton.styleFrom(
        side: const BorderSide(color: AppColors.surfaceBorder),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      icon: icon != null
          ? Icon(icon, size: 18, color: AppColors.textPrimary)
          : const SizedBox.shrink(),
      label: Text(label, style: AppTypography.bodySmall.bold),
    );
  }

  Widget _textButton(Color color) {
    return TextButton.icon(
      onPressed: onPressed,
      style: TextButton.styleFrom(
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppRadius.md),
        ),
      ),
      icon: icon != null
          ? Icon(icon, size: 18, color: color)
          : const SizedBox.shrink(),
      label: Text(
        label,
        style: AppTypography.bodySmall.bold.copyWith(
          color: color,
          letterSpacing: 0.6,
        ),
      ),
    );
  }
}
