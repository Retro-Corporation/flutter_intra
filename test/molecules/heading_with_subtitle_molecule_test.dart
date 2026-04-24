import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  Widget build({required String heading, required String subtitle}) {
    return MaterialApp(
      home: Scaffold(
        body: HeadingWithSubtitleMolecule(heading: heading, subtitle: subtitle),
      ),
    );
  }

  group('HeadingWithSubtitleMolecule', () {
    testWidgets('renders heading text', (tester) async {
      await tester.pumpWidget(build(
        heading: 'Exercise area setup',
        subtitle: 'Create space to workout in',
      ));
      expect(find.text('Exercise area setup'), findsOneWidget);
    });

    testWidgets('renders subtitle text', (tester) async {
      await tester.pumpWidget(build(
        heading: 'Exercise area setup',
        subtitle: 'Create space to workout in',
      ));
      expect(find.text('Create space to workout in'), findsOneWidget);
    });

    testWidgets('heading renders before subtitle in widget tree', (tester) async {
      await tester.pumpWidget(build(
        heading: 'Exercise area setup',
        subtitle: 'Create space to workout in',
      ));
      final texts = tester.widgetList<AppText>(find.byType(AppText)).toList();
      expect(texts[0].data, 'Exercise area setup');
      expect(texts[1].data, 'Create space to workout in');
    });
  });
}
