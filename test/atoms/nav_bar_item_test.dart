import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  Widget buildNavBarItem({
    required NavBarItemState state,
    String? iconPath,
    VoidCallback? onTap,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: NavBarItem(
            iconPath: iconPath ?? AppIcons.group,
            state: state,
            onTap: onTap ?? () {},
          ),
        ),
      ),
    );
  }

  group('NavBarItem active state', () {
    testWidgets(
      'has surface background with brand border',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildNavBarItem(state: NavBarItemState.active, iconPath: AppIcons.group),
        );

        final containers = tester.widgetList<Container>(find.byType(Container));
        final hasSurfaceWithBrandBorder = containers.any((c) {
          final decoration = c.decoration;
          if (decoration is BoxDecoration) {
            return decoration.color == AppColors.surface &&
                decoration.border != null;
          }
          return false;
        });
        expect(hasSurfaceWithBrandBorder, isTrue);
      },
    );

    testWidgets(
      'renders icon in brand color',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildNavBarItem(state: NavBarItemState.active, iconPath: AppIcons.group),
        );

        final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
        expect(
          svgPicture.colorFilter,
          const ColorFilter.mode(AppColors.brand, BlendMode.srcIn),
        );
      },
    );

    testWidgets(
      'is 56px tall',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildNavBarItem(state: NavBarItemState.active, iconPath: AppIcons.group),
        );

        final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
        final has56Tall = sizedBoxes.any((s) => s.height == 56.0);
        expect(has56Tall, isTrue);
      },
    );

    testWidgets(
      'has brand indicator bar (Positioned inside Stack)',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildNavBarItem(state: NavBarItemState.active, iconPath: AppIcons.group),
        );

        expect(find.byType(Positioned), findsOneWidget);
      },
    );
  });

  group('NavBarItem inactive state', () {
    testWidgets(
      'has no background decoration',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildNavBarItem(state: NavBarItemState.inactive, iconPath: AppIcons.group),
        );

        final containers = tester.widgetList<Container>(find.byType(Container));
        final hasBrandBackground = containers.any((c) {
          final decoration = c.decoration;
          if (decoration is BoxDecoration) {
            return decoration.color == AppColors.brand;
          }
          return false;
        });
        expect(hasBrandBackground, isFalse);
      },
    );

    testWidgets(
      'renders icon in textSecondary color',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildNavBarItem(state: NavBarItemState.inactive, iconPath: AppIcons.group),
        );

        final svgPicture = tester.widget<SvgPicture>(find.byType(SvgPicture));
        expect(
          svgPicture.colorFilter,
          const ColorFilter.mode(AppColors.textSecondary, BlendMode.srcIn),
        );
      },
    );

    testWidgets(
      'is 56px tall for alignment with active item',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildNavBarItem(state: NavBarItemState.inactive, iconPath: AppIcons.group),
        );

        final sizedBoxes = tester.widgetList<SizedBox>(find.byType(SizedBox));
        final has56Tall = sizedBoxes.any((s) => s.height == 56.0);
        expect(has56Tall, isTrue);
      },
    );
  });

  group('NavBarItem tap', () {
    testWidgets(
      'onTap fires',
      (WidgetTester tester) async {
        var tapped = false;
        await tester.pumpWidget(
          buildNavBarItem(
            state: NavBarItemState.active,
            onTap: () => tapped = true,
          ),
        );

        await tester.tap(find.byType(GestureDetector));
        await tester.pump();
        expect(tapped, isTrue);
      },
    );
  });

  group('NavBarItem icon paths', () {
    testWidgets(
      'renders with group icon path',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildNavBarItem(state: NavBarItemState.active, iconPath: AppIcons.group),
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'renders with body icon path',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildNavBarItem(state: NavBarItemState.active, iconPath: AppIcons.body),
        );
        expect(tester.takeException(), isNull);
      },
    );

    testWidgets(
      'renders with profile icon path',
      (WidgetTester tester) async {
        await tester.pumpWidget(
          buildNavBarItem(state: NavBarItemState.active, iconPath: AppIcons.profile),
        );
        expect(tester.takeException(), isNull);
      },
    );
  });
}
