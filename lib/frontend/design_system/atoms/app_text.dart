import 'package:flutter/material.dart';
import '../foundation/typography.dart';

class AppText extends StatelessWidget {
  final String text;
  final TextStyle textStyle;
  final Color? color;
  final TextAlign? textAlign;
  final int? maxLines;
  final TextOverflow? overflow;

  const AppText(
    this.text, {
    super.key,
    required this.textStyle,
    this.color,
    this.textAlign,
    this.maxLines,
    this.overflow,
  });

  // ── Display ──

  AppText.display1(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow})
      : textStyle = AppTypography.display1.black;

  AppText.display2(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow})
      : textStyle = AppTypography.display2.black;

  // ── Headings ──

  AppText.heading1(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow})
      : textStyle = AppTypography.heading1.bold;

  AppText.heading2(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow})
      : textStyle = AppTypography.heading2.bold;

  AppText.heading3(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow})
      : textStyle = AppTypography.heading3.bold;

  AppText.heading4(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow})
      : textStyle = AppTypography.heading4.bold;

  AppText.heading5(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow})
      : textStyle = AppTypography.heading5.bold;

  AppText.proHeading6(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow})
      : textStyle = AppTypography.proHeading6.bold;

  // ── Body ──

  AppText.bodyLarge(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow})
      : textStyle = AppTypography.bodyLarge.regular;

  AppText.body(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow})
      : textStyle = AppTypography.body.regular;

  AppText.bodySmall(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow})
      : textStyle = AppTypography.bodySmall.regular;

  // ── Links ──

  AppText.link(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow})
      : textStyle = AppTypography.link.semiBold;

  AppText.linkSmall(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow})
      : textStyle = AppTypography.linkSmall.semiBold;

  // ── Utility ──

  AppText.caption(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow})
      : textStyle = AppTypography.caption;

  AppText.overline(this.text, {super.key, this.color, this.textAlign, this.maxLines, this.overflow})
      : textStyle = AppTypography.overline;

  @override
  Widget build(BuildContext context) {
    return Text(
      text,
      style: color != null ? textStyle.copyWith(color: color) : textStyle,
      textAlign: textAlign,
      maxLines: maxLines,
      overflow: overflow,
    );
  }
}
