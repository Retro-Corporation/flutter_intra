import 'package:flutter/material.dart';

/// Atom: renders text using a design-system [TextStyle] from [AppTypography].
///
/// Usage:
/// ```dart
/// AppText('Hello', style: AppTypography.body.regular)
/// AppText('LABEL', style: AppTypography.caption.bold)
/// AppText('Muted', style: AppTypography.body.regular, color: AppColors.textSecondary)
/// ```
class AppText extends StatelessWidget {
  final String data;
  final TextStyle style;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppText(
    this.data, {
    super.key,
    required this.style,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  @override
  Widget build(BuildContext context) {
    return Text(
      data,
      style: color != null ? style.copyWith(color: color) : style,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
