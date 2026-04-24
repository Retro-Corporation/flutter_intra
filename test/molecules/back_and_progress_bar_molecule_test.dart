import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  Widget build({required double progress, VoidCallback? onBack}) {
    return MaterialApp(
      home: Scaffold(
        body: BackAndProgressBarMolecule(
          progress: progress,
          onBack: onBack ?? () {},
        ),
      ),
    );
  }

  group('BackAndProgressBarMolecule', () {
    testWidgets('renders AppButton', (tester) async {
      await tester.pumpWidget(build(progress: 0.5));
      expect(find.byType(AppButton), findsOneWidget);
    });

    testWidgets('renders AppProgressBar with correct value', (tester) async {
      await tester.pumpWidget(build(progress: 0.5));
      final bar = tester.widget<AppProgressBar>(find.byType(AppProgressBar));
      expect(bar.value, 0.5);
    });

    testWidgets('tapping back button fires onBack', (tester) async {
      var called = false;
      await tester.pumpWidget(build(progress: 0.5, onBack: () => called = true));
      await tester.tap(find.byType(AppButton));
      await tester.pump();
      expect(called, isTrue);
    });
  });
}
