import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  Widget buildTestBadge({
    String? label,
    String? leadingIcon,
    String? trailingIcon,
    BadgeAvatar? avatar,
    BadgeType type = BadgeType.filled,
    BadgeSize size = BadgeSize.md,
    Color color = AppColors.brand,
    VoidCallback? onTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: AppBadge(
            label: label,
            leadingIcon: leadingIcon,
            trailingIcon: trailingIcon,
            avatar: avatar,
            type: type,
            size: size,
            color: color,
            onTap: onTap,
          ),
        ),
      ),
    );
  }

  // Helper to find the Container with BoxDecoration (the badge shell)
  Container findBadgeContainer(WidgetTester tester) {
    return tester.widgetList<Container>(find.byType(Container)).firstWhere(
      (c) => c.decoration is BoxDecoration,
    );
  }

  group('AppBadge rendering', () {
    testWidgets(
      'Text-only badge renders AppText with label',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestBadge(label: 'Test'));

        expect(find.text('Test'), findsOneWidget);
        expect(find.byType(AppText), findsOneWidget);
      },
    );

    testWidgets(
      'Icon-only badge renders AppIcon without AppText',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestBadge(leadingIcon: AppIcons.star));

        expect(find.byType(AppIcon), findsOneWidget);
        expect(find.byType(AppText), findsNothing);
      },
    );

    testWidgets(
      'Icon+text badge renders both AppIcon and AppText',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestBadge(
          leadingIcon: AppIcons.star,
          label: 'Featured',
        ));

        expect(find.byType(AppIcon), findsOneWidget);
        expect(find.byType(AppText), findsOneWidget);
      },
    );

    testWidgets(
      'Avatar+text badge renders ClipOval and AppText',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestBadge(
          avatar: const BadgeAvatarInitials('TP'),
          label: 'Tavon',
        ));

        expect(find.byType(ClipOval), findsOneWidget);
        expect(find.byType(AppText), findsOneWidget);
      },
    );
  });

  group('AppBadge sizing', () {
    testWidgets(
      'Size tiers render correct Container heights',
      (WidgetTester tester) async {
        final expected = <BadgeSize, double>{
          BadgeSize.xs: 1.25 * 16.0, // 20px
          BadgeSize.sm: 1.5 * 16.0,  // 24px
          BadgeSize.md: 2.0 * 16.0,  // 32px
          BadgeSize.lg: 2.5 * 16.0,  // 40px
        };

        for (final entry in expected.entries) {
          await tester.pumpWidget(buildTestBadge(
            label: 'Test',
            size: entry.key,
          ));
          await tester.pump();

          final container = findBadgeContainer(tester);
          expect(container.constraints?.maxHeight, entry.value);
        }
      },
    );

    testWidgets(
      'xs badge uses caption font size',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestBadge(label: 'XS', size: BadgeSize.xs));

        final text = tester.widget<Text>(find.byType(Text).first);
        expect(text.style?.fontSize, AppTypography.caption.fontSize);
      },
    );

    testWidgets(
      'lg badge uses bodyLarge font size',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestBadge(label: 'LG', size: BadgeSize.lg));

        final text = tester.widget<Text>(find.byType(Text).first);
        expect(text.style?.fontSize, AppTypography.bodyLarge.semiBold.fontSize);
      },
    );
  });

  group('AppBadge color resolution', () {
    testWidgets(
      'Filled badge background matches color prop',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestBadge(
          label: 'Test',
          color: AppColors.blue500,
        ));

        final container = findBadgeContainer(tester);
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, AppColors.blue500);
      },
    );

    testWidgets(
      'Filled badge border matches 700 shade',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestBadge(
          label: 'Test',
          color: AppColors.blue500,
        ));

        final container = findBadgeContainer(tester);
        final decoration = container.decoration as BoxDecoration;
        final border = decoration.border as Border;
        expect(border.top.color, AppColors.blue700);
      },
    );

    testWidgets(
      'Filled badge with light color uses dark foreground',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestBadge(
          label: 'Test',
          color: AppColors.yellow500,
        ));

        final appText = tester.widget<AppText>(find.byType(AppText));
        // AppText applies color via copyWith — check the rendered Text widget
        final text = tester.widget<Text>(find.byType(Text).first);
        expect(text.style?.color, AppColors.textInverse);
      },
    );

    testWidgets(
      'Filled badge with dark color uses light foreground',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestBadge(
          label: 'Test',
          color: AppColors.blue500,
        ));

        final text = tester.widget<Text>(find.byType(Text).first);
        expect(text.style?.color, AppColors.textPrimary);
      },
    );

    testWidgets(
      'Outline badge has transparent background and dark grey border',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestBadge(
          label: 'Test',
          type: BadgeType.outline,
          color: AppColors.red500,
        ));

        final container = findBadgeContainer(tester);
        final decoration = container.decoration as BoxDecoration;
        expect(decoration.color, Colors.transparent);

        final border = decoration.border as Border;
        expect(border.top.color, const Color(0xFF333333));
      },
    );
  });

  group('AppBadge interaction', () {
    testWidgets(
      'Badge without onTap has no GestureDetector',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestBadge(label: 'Static'));

        expect(find.byType(GestureDetector), findsNothing);
      },
    );

    testWidgets(
      'Badge with onTap wraps in GestureDetector',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestBadge(
          label: 'Tappable',
          onTap: () {},
        ));

        expect(find.byType(GestureDetector), findsOneWidget);
      },
    );

    testWidgets(
      'Tap fires onTap callback',
      (WidgetTester tester) async {
        int tapCount = 0;
        await tester.pumpWidget(buildTestBadge(
          label: 'Tap Me',
          onTap: () => tapCount++,
        ));

        await tester.tap(find.byType(GestureDetector));
        await tester.pump();

        expect(tapCount, 1);

        await tester.tap(find.byType(GestureDetector));
        await tester.pump();

        expect(tapCount, 2);
      },
    );
  });

  group('AppBadge avatar & composition', () {
    testWidgets(
      'BadgeAvatarInitials renders uppercase text in ClipOval',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestBadge(
          avatar: const BadgeAvatarInitials('ab'),
        ));

        expect(find.byType(ClipOval), findsOneWidget);
        expect(find.text('AB'), findsOneWidget);
      },
    );

    testWidgets(
      'BadgeAvatarIcon renders AppIcon inside ClipOval',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestBadge(
          avatar: const BadgeAvatarIcon(AppIcons.star),
        ));

        expect(find.byType(ClipOval), findsOneWidget);
        expect(find.byType(AppIcon), findsOneWidget);
      },
    );

    testWidgets(
      'Avatar + leadingIcon + label renders all three',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestBadge(
          avatar: const BadgeAvatarInitials('TP'),
          leadingIcon: AppIcons.star,
          label: 'Test',
        ));

        expect(find.byType(ClipOval), findsOneWidget);
        // AppIcon from leadingIcon + possibly one from avatar icon (but here avatar is initials)
        expect(find.byType(AppIcon), findsOneWidget);
        expect(find.byType(AppText), findsOneWidget);
      },
    );

    testWidgets(
      'Trailing icon x-position is greater than label x-position',
      (WidgetTester tester) async {
        await tester.pumpWidget(buildTestBadge(
          label: 'Test',
          trailingIcon: AppIcons.close,
        ));

        final textPos = tester.getTopLeft(find.byType(AppText));
        // There are potentially multiple AppIcon finders; get the trailing one
        final iconPos = tester.getTopLeft(find.byType(AppIcon));
        expect(iconPos.dx, greaterThan(textPos.dx));
      },
    );
  });
}
