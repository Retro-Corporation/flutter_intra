import 'package:flutter/material.dart';
import '../foundation/colors.dart';
import '../foundation/padding.dart';
import '../foundation/radius.dart';

class AppInput extends StatelessWidget {
  final TextEditingController? controller;
  final String? hintText;
  final String? labelText;
  final int maxLines;
  final bool obscureText;
  final IconData? prefixIcon;
  final Widget? suffix;
  final ValueChanged<String>? onChanged;
  final TextInputType? keyboardType;

  const AppInput({
    super.key,
    this.controller,
    this.hintText,
    this.labelText,
    this.maxLines = 1,
    this.obscureText = false,
    this.prefixIcon,
    this.suffix,
    this.onChanged,
    this.keyboardType,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.grey800),
      ),
      child: TextField(
        controller: controller,
        maxLines: maxLines,
        obscureText: obscureText,
        onChanged: onChanged,
        keyboardType: keyboardType,
        style: const TextStyle(
          fontFamily: 'Inter',
          fontSize: 13,
          color: AppColors.textPrimary,
        ),
        decoration: InputDecoration(
          hintText: hintText,
          labelText: labelText,
          prefixIcon: prefixIcon != null
              ? Icon(prefixIcon, size: 20, color: AppColors.textSecondary)
              : null,
          suffix: suffix,
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppPadding.inputPaddingH,
            vertical: AppPadding.inputPaddingV,
          ),
          hintStyle: const TextStyle(color: AppColors.grey600),
          labelStyle: const TextStyle(color: AppColors.textSecondary),
        ),
      ),
    );
  }
}
