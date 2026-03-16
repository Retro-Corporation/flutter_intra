import 'package:flutter/material.dart';
import '../foundation/colors.dart';
import '../foundation/grid.dart';
import '../foundation/padding.dart';

class AppDivider extends StatelessWidget {
  final double? indent;

  const AppDivider({super.key, this.indent});

  @override
  Widget build(BuildContext context) {
    return Divider(
      color: AppColors.surfaceBorder,
      thickness: 1,
      height: AppPadding.sectionGap,
      indent: indent,
      endIndent: indent,
    );
  }
}

class AppSpacer extends StatelessWidget {
  final double size;

  AppSpacer({super.key, this.size = 16});
  AppSpacer.space4({super.key}) : size = AppGrid.grid4;
  AppSpacer.space8({super.key}) : size = AppGrid.grid8;
  AppSpacer.space12({super.key}) : size = AppGrid.grid12;
  AppSpacer.space16({super.key}) : size = AppGrid.grid16;
  AppSpacer.space20({super.key}) : size = AppGrid.grid20;
  AppSpacer.space24({super.key}) : size = AppGrid.grid24;
  AppSpacer.space32({super.key}) : size = AppGrid.grid32;
  AppSpacer.space40({super.key}) : size = AppGrid.grid40;
  AppSpacer.space60({super.key}) : size = AppGrid.grid60;

  @override
  Widget build(BuildContext context) {
    return SizedBox(height: size);
  }
}
