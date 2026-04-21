import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/atoms/behaviors/pressable_surface.dart';
import 'package:flutter_intra/frontend/design_system/atoms/primitives/text.dart';
import 'package:flutter_intra/frontend/design_system/atoms/primitives/thumbnail.dart';
import 'package:flutter_intra/frontend/design_system/atoms/primitives/thumbnail_types.dart';
import 'package:flutter_intra/frontend/design_system/foundation/color/colors.dart';
import 'package:flutter_intra/frontend/design_system/molecules/cards/exercise_thumbnail_card.dart';
import 'package:flutter_intra/frontend/design_system/molecules/cards/exercise_thumbnail_card_types.dart';

Widget buildCard({
  ExerciseThumbnailCardSize size = ExerciseThumbnailCardSize.small,
  String? label,
  bool selected = false,
  VoidCallback? onTap,
}) {
  return MaterialApp(
    home: Scaffold(
      body: Center(
        child: ExerciseThumbnailCard(
          size: size,
          label: label,
          selected: selected,
          onTap: onTap,
        ),
      ),
    ),
  );
}

void main() {
  group('ExerciseThumbnailCard', () {
    testWidgets('small renders 100px Thumbnail and no label', (tester) async {
      await tester.pumpWidget(buildCard());

      final thumbnail = tester.widget<Thumbnail>(find.byType(Thumbnail));
      expect(thumbnail.size, ThumbnailSize.size100);
      expect(find.byType(AppText), findsNothing);
    });

    testWidgets('large renders 128px Thumbnail and label', (tester) async {
      await tester.pumpWidget(
        buildCard(size: ExerciseThumbnailCardSize.large, label: 'ACL Rehab'),
      );

      final thumbnail = tester.widget<Thumbnail>(find.byType(Thumbnail));
      expect(thumbnail.size, ThumbnailSize.size128);
      expect(find.text('ACL Rehab'), findsOneWidget);
    });

    testWidgets('selected: true sets border to textPrimary', (tester) async {
      await tester.pumpWidget(buildCard(selected: true));

      final surface = tester.widget<PressableSurface>(
        find.byType(PressableSurface),
      );
      expect(surface.borderColor, AppColors.textPrimary);
    });

    testWidgets('selected: false sets border to surfaceBorder', (tester) async {
      await tester.pumpWidget(buildCard());

      final surface = tester.widget<PressableSurface>(
        find.byType(PressableSurface),
      );
      expect(surface.borderColor, AppColors.surfaceBorder);
    });

    testWidgets('onTap fires when tapped', (tester) async {
      var tapCount = 0;
      await tester.pumpWidget(buildCard(onTap: () => tapCount++));

      await tester.tap(find.byType(PressableSurface));
      await tester.pumpAndSettle();
      expect(tapCount, 1);
    });

    test('asserts label is only used with large variant', () {
      expect(
        () => ExerciseThumbnailCard(
          size: ExerciseThumbnailCardSize.small,
          label: 'should throw',
        ),
        throwsAssertionError,
      );
    });

    testWidgets('large with null label renders no AppText', (tester) async {
      await tester.pumpWidget(buildCard(size: ExerciseThumbnailCardSize.large));

      expect(find.byType(AppText), findsNothing);
    });
  });
}
