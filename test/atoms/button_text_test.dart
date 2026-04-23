import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  Widget buildTestButton({
    String? label,
    ButtonType type = ButtonType.filled,
    ButtonSize size = ButtonSize.md,
    Color color = AppColors.brand,
    String? leadingIcon,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: AppButton(
            label: label,
            leadingIcon: leadingIcon,
            type: type,
            size: size,
            color: color,
            onPressed: () {},
          ),
        ),
      ),
    );
  }

  group('Button text uses AppText atom', () {
    testWidgets(
      'Button renders label through AppText, not raw Text',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestButton(label: 'Save'));

        // AppText should be in the widget tree
        final appTextFinder = find.byType(AppText);
        expect(appTextFinder, findsOneWidget);

        // The AppText should contain the label
        final appText = tester.widget<AppText>(appTextFinder);
        expect(appText.data, 'Save');
      },
    );

    testWidgets(
      'Button text uses bold weight from size config typography',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestButton(label: 'Click', size: ButtonSize.md));

        final appText = tester.widget<AppText>(find.byType(AppText));
        // md size maps to AppTypography.body → bold = w700
        expect(appText.style.fontWeight, FontWeight.w700);
        // md body fontSize is 1rem = 16px
        expect(appText.style.fontSize, AppTypography.body.bold.fontSize);
      },
    );

    testWidgets(
      'Button text color matches resolved foreground for each button type',
      (WidgetTester tester) async {
        // Filled button with brand color → foreground based on brightness estimation
        await tester.pumpWidget(buildTestButton(label: 'Filled', type: ButtonType.filled));
        final filledText = tester.widget<AppText>(find.byType(AppText));
        expect(filledText.color, AppColors.textPrimary);

        // Outline button → foreground should be the button color itself
        await tester.pumpWidget(buildTestButton(label: 'Outline', type: ButtonType.outline));
        await tester.pump();
        final outlineText = tester.widget<AppText>(find.byType(AppText));
        expect(outlineText.color, AppColors.brand);

        // Ghost button → foreground should be the button color itself
        await tester.pumpWidget(buildTestButton(label: 'Ghost', type: ButtonType.ghost));
        await tester.pump();
        final ghostText = tester.widget<AppText>(find.byType(AppText));
        expect(ghostText.color, AppColors.brand);
      },
    );

    testWidgets(
      'Button text scales typography per size: sm, md, lg',
      (WidgetTester tester) async {
        // sm → bodySmall
        await tester.pumpWidget(buildTestButton(label: 'Sm', size: ButtonSize.sm));
        final smText = tester.widget<AppText>(find.byType(AppText));
        expect(smText.style.fontSize, AppTypography.bodySmall.semiBold.fontSize);

        // md → body
        await tester.pumpWidget(buildTestButton(label: 'Md', size: ButtonSize.md));
        await tester.pump();
        final mdText = tester.widget<AppText>(find.byType(AppText));
        expect(mdText.style.fontSize, AppTypography.body.semiBold.fontSize);

        // lg → bodyLarge
        await tester.pumpWidget(buildTestButton(label: 'Lg', size: ButtonSize.lg));
        await tester.pump();
        final lgText = tester.widget<AppText>(find.byType(AppText));
        expect(lgText.style.fontSize, AppTypography.bodyLarge.semiBold.fontSize);
      },
    );

    testWidgets(
      'Icon-only button has no AppText in the tree',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestButton(
          label: null,
          leadingIcon: AppIcons.add,
        ));

        // No label means no AppText widget should exist
        expect(find.byType(AppText), findsNothing);
      },
    );
  });
}
