import 'package:flutter/material.dart';
import 'colors.dart';
import 'typography.dart';
import 'padding.dart';
import 'radius.dart';

/// App theme built from foundation tokens.
class AppTheme {
  AppTheme._();

  static ThemeData get dark => ThemeData(
        brightness: Brightness.dark,
        scaffoldBackgroundColor: AppColors.background,
        colorScheme: const ColorScheme.dark(
          primary: AppColors.brand,
          secondary: AppColors.info,
          surface: AppColors.surface,
          error: AppColors.error,
          onPrimary: AppColors.textInverse,
          onSurface: AppColors.textPrimary,
        ),
        dividerColor: AppColors.surfaceBorder,
        textTheme: TextTheme(
          displayLarge: AppTypography.display1.bold,
          displayMedium: AppTypography.display2.bold,
          headlineLarge: AppTypography.heading1.bold,
          headlineMedium: AppTypography.heading3.bold,
          headlineSmall: AppTypography.heading5.bold,
          titleLarge: AppTypography.proHeading6.semiBold,
          titleMedium: AppTypography.body.semiBold,
          titleSmall: AppTypography.bodySmall.semiBold,
          bodyLarge: AppTypography.bodyLarge.regular,
          bodyMedium: AppTypography.body.regular,
          bodySmall: AppTypography.bodySmall.regular,
          labelLarge: AppTypography.bodySmall.bold,
          labelMedium: AppTypography.bodySmall.semiBold,
        ),
        inputDecorationTheme: InputDecorationTheme(
          filled: true,
          fillColor: AppColors.surface,
          border: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.surfaceBorder),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: BorderSide(color: AppColors.grey800),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.brand),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppPadding.inputPaddingH,
            vertical: AppPadding.inputPaddingV,
          ),
          hintStyle: const TextStyle(color: AppColors.grey600),
        ),
      );
}
