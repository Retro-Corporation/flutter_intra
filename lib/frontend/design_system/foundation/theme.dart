import 'package:flutter/material.dart';
import 'color/colors.dart';
import 'type/typography.dart';
import 'space/padding.dart';
import 'space/radius.dart';
import 'space/stroke.dart';

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
            borderSide: const BorderSide(color: AppColors.surfaceBorder, width: AppStroke.xs),
          ),
          enabledBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.grey800, width: AppStroke.xs),
          ),
          focusedBorder: OutlineInputBorder(
            borderRadius: BorderRadius.circular(AppRadius.md),
            borderSide: const BorderSide(color: AppColors.brand, width: AppStroke.xs),
          ),
          contentPadding: EdgeInsets.symmetric(
            horizontal: AppPadding.inputPaddingH,
            vertical: AppPadding.inputPaddingV,
          ),
          hintStyle: AppTypography.body.regular.copyWith(color: AppColors.grey600),
        ),
      );
}
