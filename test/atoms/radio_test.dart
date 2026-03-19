import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  Widget buildTestRadio({
    bool? selected,
    bool selfToggle = false,
    ValueChanged<bool>? onChanged,
    RadioSize size = RadioSize.md,
    Color color = AppColors.brand,
    bool isDisabled = false,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: AppRadio(
            selected: selected,
            selfToggle: selfToggle,
            onChanged: onChanged,
            size: size,
            color: color,
            isDisabled: isDisabled,
          ),
        ),
      ),
    );
  }

  CustomPainter findPainter(WidgetTester tester) {
    final allCustomPaints =
        tester.widgetList<CustomPaint>(find.byType(CustomPaint));
    final radioPaint = allCustomPaints.firstWhere(
      (cp) =>
          cp.painter != null &&
          cp.painter.runtimeType.toString() == '_RadioPainter',
    );
    return radioPaint.painter!;
  }

  group('AppRadio', () {
    testWidgets('renders unselected by default', (WidgetTester tester) async {
      await tester.pumpWidget(buildTestRadio());

      final painter = findPainter(tester);
      // Unselected: transparent background, no dot
      expect(
        (painter as dynamic).backgroundColor,
        Colors.transparent,
      );
      expect((painter as dynamic).showDot, false);
    });

    testWidgets('renders selected state with accent color and dot',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestRadio(selected: true));

      final painter = findPainter(tester);
      expect((painter as dynamic).backgroundColor, AppColors.brand);
      expect((painter as dynamic).showDot, true);
      expect((painter as dynamic).dotColor, AppColors.textPrimary);
    });

    testWidgets('selfToggle toggles on tap', (WidgetTester tester) async {
      bool? changedValue;

      await tester.pumpWidget(buildTestRadio(
        selfToggle: true,
        onChanged: (v) => changedValue = v,
      ));

      // Initially unselected
      var painter = findPainter(tester);
      expect((painter as dynamic).showDot, false);

      // Tap to select
      await tester.tap(find.byType(AppRadio));
      await tester.pump();

      painter = findPainter(tester);
      expect((painter as dynamic).showDot, true);
      expect(changedValue, true);
    });

    testWidgets('disabled state blocks interaction',
        (WidgetTester tester) async {
      bool? changedValue;

      await tester.pumpWidget(buildTestRadio(
        selfToggle: true,
        isDisabled: true,
        onChanged: (v) => changedValue = v,
      ));

      await tester.tap(find.byType(AppRadio));
      await tester.pump();

      // Should remain unselected
      final painter = findPainter(tester);
      expect((painter as dynamic).showDot, false);
      expect(changedValue, null);
    });

    testWidgets('3D border geometry: rest has bottom=4, pressed has all=1',
        (WidgetTester tester) async {
      await tester.pumpWidget(buildTestRadio(selfToggle: true));

      // Rest state
      var painter = findPainter(tester);
      expect((painter as dynamic).borderTop, 1.0);
      expect((painter as dynamic).borderBottom, 4.0);
      expect((painter as dynamic).borderSide, 2.0);
      expect((painter as dynamic).faceOffset, 0.0);

      // Press down
      final gesture = await tester.startGesture(
        tester.getCenter(find.byType(AppRadio)),
      );
      await tester.pump();

      painter = findPainter(tester);
      expect((painter as dynamic).borderTop, 1.0);
      expect((painter as dynamic).borderBottom, 1.0);
      expect((painter as dynamic).borderSide, 1.0);
      expect((painter as dynamic).faceOffset, 3.0);

      await gesture.up();
      await tester.pump();
    });
  });
}
