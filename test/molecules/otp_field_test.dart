import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

Widget _wrap(Widget child) => MaterialApp(
      home: Scaffold(body: Center(child: child)),
    );

/// Creates matched lists of controllers and focus nodes for the given length.
/// Caller is responsible for disposing.
({List<TextEditingController> controllers, List<FocusNode> focusNodes}) _makeInputs(
  int length,
) {
  return (
    controllers: List.generate(length, (_) => TextEditingController()),
    focusNodes: List.generate(length, (_) => FocusNode()),
  );
}

void _disposeInputs(
  List<TextEditingController> controllers,
  List<FocusNode> focusNodes,
) {
  for (final c in controllers) c.dispose();
  for (final f in focusNodes) f.dispose();
}

void main() {
  group('AppOtpField', () {
    test('assert fires when controllers and focusNodes lengths differ', () {
      expect(
        () => AppOtpField(
          controllers: [TextEditingController()],
          focusNodes: [FocusNode(), FocusNode()],
        ),
        throwsAssertionError,
      );
    });

    testWidgets('renders controllers.length OtpCell widgets', (tester) async {
      final inputs = _makeInputs(6);
      addTearDown(() => _disposeInputs(inputs.controllers, inputs.focusNodes));

      await tester.pumpWidget(
        _wrap(AppOtpField(
          controllers: inputs.controllers,
          focusNodes: inputs.focusNodes,
        )),
      );

      expect(find.byType(OtpCell), findsNWidgets(6));
    });

    testWidgets('hasError: false — all cells receive OtpCellState.empty',
        (tester) async {
      final inputs = _makeInputs(6);
      addTearDown(() => _disposeInputs(inputs.controllers, inputs.focusNodes));

      await tester.pumpWidget(
        _wrap(AppOtpField(
          controllers: inputs.controllers,
          focusNodes: inputs.focusNodes,
        )),
      );

      final cells = tester.widgetList<OtpCell>(find.byType(OtpCell));
      for (final cell in cells) {
        expect(cell.state, OtpCellState.empty);
      }
    });

    testWidgets('hasError: true — all cells receive OtpCellState.error',
        (tester) async {
      final inputs = _makeInputs(6);
      addTearDown(() => _disposeInputs(inputs.controllers, inputs.focusNodes));

      await tester.pumpWidget(
        _wrap(AppOtpField(
          controllers: inputs.controllers,
          focusNodes: inputs.focusNodes,
          hasError: true,
        )),
      );

      final cells = tester.widgetList<OtpCell>(find.byType(OtpCell));
      for (final cell in cells) {
        expect(cell.state, OtpCellState.error);
      }
    });

    testWidgets('onChanged fires with partial code on each keystroke',
        (tester) async {
      final inputs = _makeInputs(6);
      addTearDown(() => _disposeInputs(inputs.controllers, inputs.focusNodes));

      final received = <String>[];
      await tester.pumpWidget(
        _wrap(AppOtpField(
          controllers: inputs.controllers,
          focusNodes: inputs.focusNodes,
          onChanged: received.add,
        )),
      );

      await tester.enterText(find.byType(TextField).first, '3');
      expect(received.last, '3');
    });

    testWidgets('onCompleted fires only when all cells are filled',
        (tester) async {
      final inputs = _makeInputs(3);
      addTearDown(() => _disposeInputs(inputs.controllers, inputs.focusNodes));

      String? completed;
      await tester.pumpWidget(
        _wrap(AppOtpField(
          controllers: inputs.controllers,
          focusNodes: inputs.focusNodes,
          onCompleted: (v) => completed = v,
        )),
      );

      // Fill first two cells — onCompleted must not fire yet
      inputs.controllers[0].text = '1';
      inputs.controllers[1].text = '2';
      await tester.pump();
      expect(completed, isNull);

      // Fill last cell via enterText to trigger onChanged
      await tester.enterText(find.byType(TextField).at(2), '3');
      expect(completed, '123');
    });

    testWidgets('auto-advances focus to next cell after digit entered',
        (tester) async {
      final inputs = _makeInputs(3);
      addTearDown(() => _disposeInputs(inputs.controllers, inputs.focusNodes));

      await tester.pumpWidget(
        _wrap(AppOtpField(
          controllers: inputs.controllers,
          focusNodes: inputs.focusNodes,
        )),
      );

      inputs.focusNodes[0].requestFocus();
      await tester.pump();
      await tester.enterText(find.byType(TextField).first, '5');
      await tester.pump();

      expect(inputs.focusNodes[1].hasFocus, isTrue);
    });

    testWidgets('dispose clears onKeyEvent on received focusNodes',
        (tester) async {
      final inputs = _makeInputs(3);
      addTearDown(() => _disposeInputs(inputs.controllers, inputs.focusNodes));

      await tester.pumpWidget(
        _wrap(AppOtpField(
          controllers: inputs.controllers,
          focusNodes: inputs.focusNodes,
        )),
      );

      // Confirm handlers were wired
      expect(inputs.focusNodes[0].onKeyEvent, isNotNull);

      // Unmount
      await tester.pumpWidget(const SizedBox.shrink());

      // Handlers must be cleared — template still owns the nodes
      expect(inputs.focusNodes[0].onKeyEvent, isNull);
    });
  });
}
