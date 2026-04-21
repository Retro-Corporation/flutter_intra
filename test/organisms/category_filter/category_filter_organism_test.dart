import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

import 'package:flutter_intra/frontend/design_system/organisms/category_filter/category_filter_organism.dart';
import 'package:flutter_intra/frontend/design_system/organisms/category_filter/category_filter_types.dart';

void main() {
  Widget build({
    List<CategoryChip>? overall,
    List<String>? bodyParts,
    List<String>? outcomes,
    void Function(String?, String?, String?)? onFilterChanged,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: CategoryFilterOrganism(
          overallChips: overall ??
              const [
                CategoryChip(label: 'Templates'),
                CategoryChip(label: 'Core'),
              ],
          bodyPartChips: bodyParts ?? const ['Hips', 'Shoulders'],
          outcomeChips: outcomes ?? const ['Mobility', 'Strength'],
          onFilterChanged: onFilterChanged ?? (_, __, ___) {},
        ),
      ),
    );
  }

  group('CategoryFilterOrganism — default state', () {
    testWidgets(
      'renders overall chips and body part chips, but not outcome chips',
      (tester) async {
        await tester.pumpWidget(build());
        await tester.pumpAndSettle();

        expect(find.text('Templates'), findsOneWidget);
        expect(find.text('Core'), findsOneWidget);
        expect(find.text('Hips'), findsOneWidget);
        expect(find.text('Shoulders'), findsOneWidget);
        expect(find.text('Mobility'), findsNothing);
        expect(find.text('Strength'), findsNothing);
      },
    );
  });

  group('CategoryFilterOrganism — selection', () {
    testWidgets(
      'tapping an overall chip fires callback with overall set, bodyPart null, outcome null',
      (tester) async {
        String? overallCap;
        String? bodyPartCap;
        String? outcomeCap;
        bool fired = false;

        await tester.pumpWidget(build(
          onFilterChanged: (overall, bodyPart, outcome) {
            overallCap = overall;
            bodyPartCap = bodyPart;
            outcomeCap = outcome;
            fired = true;
          },
        ));

        await tester.tap(find.text('Templates'));
        await tester.pumpAndSettle();

        expect(fired, isTrue);
        expect(overallCap, 'Templates');
        expect(bodyPartCap, isNull);
        expect(outcomeCap, isNull);
      },
    );

    testWidgets(
      'tapping a body part chip fires callback with bodyPart set',
      (tester) async {
        String? overallCap;
        String? bodyPartCap;
        String? outcomeCap;

        await tester.pumpWidget(build(
          onFilterChanged: (overall, bodyPart, outcome) {
            overallCap = overall;
            bodyPartCap = bodyPart;
            outcomeCap = outcome;
          },
        ));

        await tester.tap(find.text('Hips'));
        await tester.pumpAndSettle();

        expect(overallCap, isNull);
        expect(bodyPartCap, 'Hips');
        expect(outcomeCap, isNull);
      },
    );

    // Note: "selecting a new overall clears previously-selected body part and
    // outcome" is a defensive behavior in the tap handler but is unreachable
    // via the UI — once any chip is selected, the overall chips are hidden
    // from row 1 (replaced by body parts), so the user cannot tap a
    // non-selected overall chip while dependents are set. Test #2 above
    // covers the reachable case (overall selection from default state).

    testWidgets(
      'tapping a selected chip deselects it and fires callback with that slot null',
      (tester) async {
        String? overallCap;
        String? bodyPartCap;
        String? outcomeCap;

        await tester.pumpWidget(build(
          onFilterChanged: (overall, bodyPart, outcome) {
            overallCap = overall;
            bodyPartCap = bodyPart;
            outcomeCap = outcome;
          },
        ));

        // Select Hips.
        await tester.tap(find.text('Hips'));
        await tester.pumpAndSettle();
        expect(bodyPartCap, 'Hips');

        // Tap Hips again — should deselect.
        await tester.tap(find.text('Hips'));
        await tester.pumpAndSettle();

        expect(overallCap, isNull);
        expect(bodyPartCap, isNull);
        expect(outcomeCap, isNull);
      },
    );

    testWidgets(
      'tapping an outcome chip post-expansion fires callback with outcome set',
      (tester) async {
        String? overallCap;
        String? bodyPartCap;
        String? outcomeCap;

        await tester.pumpWidget(build(
          onFilterChanged: (overall, bodyPart, outcome) {
            overallCap = overall;
            bodyPartCap = bodyPart;
            outcomeCap = outcome;
          },
        ));

        // Expand first by selecting a body part.
        await tester.tap(find.text('Hips'));
        await tester.pumpAndSettle();

        // Outcomes are now visible. Tap one.
        await tester.tap(find.text('Mobility'));
        await tester.pumpAndSettle();

        expect(overallCap, isNull);
        expect(bodyPartCap, 'Hips');
        expect(outcomeCap, 'Mobility');
      },
    );
  });

  group('CategoryFilterOrganism — single-select per row', () {
    testWidgets(
      'only one body part can be selected at a time',
      (tester) async {
        String? bodyPartCap;

        await tester.pumpWidget(build(
          onFilterChanged: (_, bodyPart, __) {
            bodyPartCap = bodyPart;
          },
        ));

        // Select Hips.
        await tester.tap(find.text('Hips'));
        await tester.pumpAndSettle();
        expect(bodyPartCap, 'Hips');

        // Select Shoulders. Hips should be deselected implicitly
        // because the state only holds a single _selectedBodyPart.
        await tester.tap(find.text('Shoulders'));
        await tester.pumpAndSettle();

        expect(bodyPartCap, 'Shoulders');
      },
    );

    testWidgets(
      'only one outcome can be selected at a time',
      (tester) async {
        String? outcomeCap;

        await tester.pumpWidget(build(
          onFilterChanged: (_, __, outcome) {
            outcomeCap = outcome;
          },
        ));

        // Expand by selecting a body part.
        await tester.tap(find.text('Hips'));
        await tester.pumpAndSettle();

        // Select first outcome.
        await tester.tap(find.text('Mobility'));
        await tester.pumpAndSettle();
        expect(outcomeCap, 'Mobility');

        // Select second outcome — first should be replaced.
        await tester.tap(find.text('Strength'));
        await tester.pumpAndSettle();

        expect(outcomeCap, 'Strength');
      },
    );
  });

  group('CategoryFilterOrganism — layout revert', () {
    testWidgets(
      'clearing the only selected chip reverts layout to default (outcomes hidden)',
      (tester) async {
        await tester.pumpWidget(build());

        // Select Hips — layout expands, outcomes appear in row 2.
        await tester.tap(find.text('Hips'));
        await tester.pumpAndSettle();
        expect(find.text('Mobility'), findsOneWidget);

        // Tap Hips again to deselect — layout should revert.
        await tester.tap(find.text('Hips'));
        await tester.pumpAndSettle();

        expect(find.text('Mobility'), findsNothing);
        expect(find.text('Strength'), findsNothing);
        // Default body-parts row should be back.
        expect(find.text('Hips'), findsOneWidget);
        expect(find.text('Shoulders'), findsOneWidget);
      },
    );

    testWidgets(
      'clearing overall when body part still selected keeps expanded layout',
      (tester) async {
        String? overallCap;
        String? bodyPartCap;

        await tester.pumpWidget(build(
          onFilterChanged: (overall, bodyPart, _) {
            overallCap = overall;
            bodyPartCap = bodyPart;
          },
        ));

        // Select Templates (clears any deps, which are already null here).
        await tester.tap(find.text('Templates'));
        await tester.pumpAndSettle();
        expect(overallCap, 'Templates');

        // Select Hips — body part now set alongside overall.
        await tester.tap(find.text('Hips'));
        await tester.pumpAndSettle();
        expect(bodyPartCap, 'Hips');

        // Deselect Templates (overall). Body part still selected, so
        // _isExpanded remains true and outcomes remain visible.
        await tester.tap(find.text('Templates'));
        await tester.pumpAndSettle();

        expect(overallCap, isNull);
        expect(bodyPartCap, 'Hips');
        expect(find.text('Mobility'), findsOneWidget);
        expect(find.text('Strength'), findsOneWidget);
      },
    );
  });
}
