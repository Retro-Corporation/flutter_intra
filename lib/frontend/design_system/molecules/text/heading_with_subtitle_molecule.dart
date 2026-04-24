import 'package:flutter/material.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

/// A page-level heading block: a bold heading followed by a regular
/// secondary-color subtitle.
///
/// Broadly reusable — not locked to stepped flows. Left-aligned,
/// stateless, no owned state.
class HeadingWithSubtitleMolecule extends StatelessWidget {
  final String heading;
  final String subtitle;

  const HeadingWithSubtitleMolecule({
    super.key,
    required this.heading,
    required this.subtitle,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        AppText(
          heading,
          style: AppTypography.bodyLarge.bold,
          color: AppColors.textPrimary,
        ),
        AppText(
          subtitle,
          style: AppTypography.body.bold,
          color: AppColors.textPrimary,
        ),
      ],
    );
  }
}
