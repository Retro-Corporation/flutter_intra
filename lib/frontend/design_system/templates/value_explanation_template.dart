import 'package:flutter/material.dart';

import '../design_system.dart';

class ValueExplanationTemplate extends StatelessWidget {
  final String heading;
  final String subheading;
  final double progressValue;
  final VoidCallback onBack;
  final String primaryLabel;
  final VoidCallback onPrimary;
  final String? secondaryLabel;
  final VoidCallback? onSecondary;

  const ValueExplanationTemplate({
    super.key,
    required this.heading,
    required this.subheading,
    required this.progressValue,
    required this.onBack,
    required this.primaryLabel,
    required this.onPrimary,
    this.secondaryLabel,
    this.onSecondary,
  });

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppGrid.grid16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const SizedBox(height: AppGrid.grid16),
              Row(
                children: [
                  AppButton(
                    leadingIcon: AppIcons.arrowBack,
                    type: ButtonType.ghost,
                    size: ButtonSize.md,
                    color: AppColors.textPrimary,
                    onPressed: onBack,
                  ),
                  const SizedBox(width: AppGrid.grid8),
                  Expanded(child: AppProgressBar(value: progressValue)),
                ],
              ),
              const SizedBox(height: AppGrid.grid24),
              AppText(heading, style: AppTypography.bodyLarge.bold, color: AppColors.textPrimary),
              AppText(subheading, style: AppTypography.body.bold, color: AppColors.textPrimary),
              const SizedBox(height: AppGrid.grid16),
              const Center(child: MediaHolder()),
              const Spacer(),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: primaryLabel,
                  type: ButtonType.filled,
                  size: ButtonSize.md,
                  onPressed: onPrimary,
                ),
              ),
              if (secondaryLabel != null) ...[
                const SizedBox(height: AppGrid.grid20),
                SizedBox(
                  width: double.infinity,
                  child: AppButton(
                    label: secondaryLabel!,
                    type: ButtonType.ghost,
                    size: ButtonSize.md,
                    color: AppColors.textPrimary,
                    onPressed: onSecondary,
                  ),
                ),
              ],
              const SizedBox(height: AppGrid.grid24),
            ],
          ),
        ),
      ),
    );
  }
}
