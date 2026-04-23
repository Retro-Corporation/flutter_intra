import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('OtpCell', () {
    late TextEditingController controller;
    late FocusNode focusNode;

    setUp(() {
      controller = TextEditingController();
      focusNode = FocusNode();
    });

    tearDown(() {
      controller.dispose();
      focusNode.dispose();
    });

    testWidgets('renders a TextField', (tester) async {
      await tester.pumpWidget(
        _wrap(OtpCell(controller: controller, focusNode: focusNode)),
      );
      expect(find.byType(TextField), findsOneWidget);
    });

    testWidgets('maxLength is 1', (tester) async {
      await tester.pumpWidget(
        _wrap(OtpCell(controller: controller, focusNode: focusNode)),
      );
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.maxLength, 1);
    });

    testWidgets('keyboardType is number', (tester) async {
      await tester.pumpWidget(
        _wrap(OtpCell(controller: controller, focusNode: focusNode)),
      );
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.keyboardType, TextInputType.number);
    });

    testWidgets('uses the provided controller', (tester) async {
      await tester.pumpWidget(
        _wrap(OtpCell(controller: controller, focusNode: focusNode)),
      );
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.controller, same(controller));
    });

    testWidgets('uses the provided focusNode', (tester) async {
      await tester.pumpWidget(
        _wrap(OtpCell(controller: controller, focusNode: focusNode)),
      );
      final tf = tester.widget<TextField>(find.byType(TextField));
      expect(tf.focusNode, same(focusNode));
    });

    testWidgets('empty state — enabledBorder uses surfaceBorder', (tester) async {
      await tester.pumpWidget(
        _wrap(OtpCell(
          controller: controller,
          focusNode: focusNode,
          state: OtpCellState.empty,
        )),
      );
      final tf = tester.widget<TextField>(find.byType(TextField));
      final border = tf.decoration!.enabledBorder! as OutlineInputBorder;
      expect(border.borderSide.color, AppColors.surfaceBorder);
    });

    testWidgets('filled state — enabledBorder uses surfaceBorder', (tester) async {
      await tester.pumpWidget(
        _wrap(OtpCell(
          controller: controller,
          focusNode: focusNode,
          state: OtpCellState.filled,
        )),
      );
      final tf = tester.widget<TextField>(find.byType(TextField));
      final border = tf.decoration!.enabledBorder! as OutlineInputBorder;
      expect(border.borderSide.color, AppColors.surfaceBorder);
    });

    testWidgets('error state — enabledBorder uses error color', (tester) async {
      await tester.pumpWidget(
        _wrap(OtpCell(
          controller: controller,
          focusNode: focusNode,
          state: OtpCellState.error,
        )),
      );
      final tf = tester.widget<TextField>(find.byType(TextField));
      final border = tf.decoration!.enabledBorder! as OutlineInputBorder;
      expect(border.borderSide.color, AppColors.error);
    });

    testWidgets('non-error state — focusedBorder uses brand color', (tester) async {
      await tester.pumpWidget(
        _wrap(OtpCell(
          controller: controller,
          focusNode: focusNode,
          state: OtpCellState.empty,
        )),
      );
      final tf = tester.widget<TextField>(find.byType(TextField));
      final border = tf.decoration!.focusedBorder! as OutlineInputBorder;
      expect(border.borderSide.color, AppColors.brand);
    });

    testWidgets('error state — focusedBorder also uses error color', (tester) async {
      await tester.pumpWidget(
        _wrap(OtpCell(
          controller: controller,
          focusNode: focusNode,
          state: OtpCellState.error,
        )),
      );
      final tf = tester.widget<TextField>(find.byType(TextField));
      final border = tf.decoration!.focusedBorder! as OutlineInputBorder;
      expect(border.borderSide.color, AppColors.error);
    });

    testWidgets('onChanged fires when text changes', (tester) async {
      String? received;
      await tester.pumpWidget(
        _wrap(OtpCell(
          controller: controller,
          focusNode: focusNode,
          onChanged: (v) => received = v,
        )),
      );
      await tester.enterText(find.byType(TextField), '7');
      expect(received, '7');
    });

    testWidgets('sized to grid48 × grid52', (tester) async {
      await tester.pumpWidget(
        _wrap(OtpCell(controller: controller, focusNode: focusNode)),
      );
      final box = tester.renderObject<RenderBox>(find.byType(OtpCell));
      expect(box.size.width, AppGrid.grid48);
      expect(box.size.height, AppGrid.grid52);
    });
  });
}
