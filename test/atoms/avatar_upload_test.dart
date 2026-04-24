import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  Widget wrap(Widget child) => MaterialApp(home: Scaffold(body: child));

  group('AvatarUpload', () {
    testWidgets('AvatarUpload content renders add icon', (tester) async {
      await tester.pumpWidget(wrap(
        const AppAvatar(content: AvatarUpload(), size: AvatarSize.xl),
      ));
      await tester.pump();
      // AppIcon with AppIcons.add should be present
      expect(find.byType(AppIcon), findsOneWidget);
    });

    testWidgets('AppAvatar with onTap wraps in GestureDetector', (tester) async {
      await tester.pumpWidget(wrap(
        AppAvatar(content: AvatarUpload(), size: AvatarSize.xl, onTap: () {}),
      ));
      expect(find.byType(GestureDetector), findsWidgets);
    });

    testWidgets('tapping fires onTap callback', (tester) async {
      var tapped = false;
      await tester.pumpWidget(wrap(
        AppAvatar(
          content: AvatarUpload(),
          size: AvatarSize.xl,
          onTap: () => tapped = true,
        ),
      ));
      await tester.tap(find.byType(AppAvatar));
      expect(tapped, isTrue);
    });

    testWidgets('AppAvatar with onTap null has no extra GestureDetector', (tester) async {
      await tester.pumpWidget(wrap(
        const AppAvatar(content: AvatarUpload(), size: AvatarSize.xl),
      ));
      // Without onTap, the Semantics wraps directly — no GestureDetector added by AppAvatar
      final gestures = tester.widgetList<GestureDetector>(find.byType(GestureDetector));
      expect(gestures.length, 0);
    });

    testWidgets('semantic label is Upload profile photo', (tester) async {
      await tester.pumpWidget(wrap(
        const AppAvatar(content: AvatarUpload(), size: AvatarSize.xl),
      ));
      expect(find.bySemanticsLabel('Upload profile photo'), findsOneWidget);
    });
  });
}
