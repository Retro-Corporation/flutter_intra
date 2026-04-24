import 'package:flutter/material.dart';

import '../design_system.dart';

class ProgressStepTemplate extends StatelessWidget {
  const ProgressStepTemplate({
    super.key,
    required this.progress,
    required this.onBack,
    required this.heading,
    required this.subtitle,
    required this.body,
    required this.primaryLabel,
    this.onPrimary,
  });

  final double progress;
  final VoidCallback onBack;
  final String heading;
  final String subtitle;
  final Widget body;
  final String primaryLabel;
  final VoidCallback? onPrimary;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: AppGrid.grid16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const SizedBox(height: AppGrid.grid16),
              BackAndProgressBarMolecule(
                progress: progress,
                onBack: onBack,
              ),
              const SizedBox(height: AppGrid.grid24),
              HeadingWithSubtitleMolecule(
                heading: heading,
                subtitle: subtitle,
              ),
              const SizedBox(height: AppGrid.grid24),
              body,
              const Spacer(),
              const SizedBox(height: AppGrid.grid24),
              SizedBox(
                width: double.infinity,
                child: AppButton(
                  label: primaryLabel,
                  type: ButtonType.filled,
                  size: ButtonSize.md,
                  isDisabled: onPrimary == null,
                  onPressed: onPrimary,
                ),
              ),
              const SizedBox(height: AppGrid.grid16),
            ],
          ),
        ),
      ),
    );
  }
}
