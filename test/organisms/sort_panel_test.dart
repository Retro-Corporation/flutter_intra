import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';
import 'package:flutter_intra/frontend/design_system/organisms/sort/sort_panel.dart';
import 'package:flutter_intra/frontend/design_system/organisms/sort/sort_panel_types.dart';
import 'package:flutter_intra/frontend/design_system/molecules/controls/labeled_checkbox.dart';

void main() {
  Widget build({
    Map<SortCategory, SortOption?>? selectedSorts,
    ValueChanged<Map<SortCategory, SortOption?>>? onSortChanged,
    VoidCallback? onClearAll,
  }) {
    return MaterialApp(
      home: Scaffold(
        body: SingleChildScrollView(
          child: SortPanel(
            selectedSorts: selectedSorts ?? {},
            onSortChanged: onSortChanged ?? (_) {},
            onClearAll: onClearAll ?? () {},
          ),
        ),
      ),
    );
  }

  group('SortPanel single-select per category', () {
    testWidgets('selecting a new option deselects previous in same category', (tester) async {
      Map<SortCategory, SortOption?> current = {
        SortCategory.exerciseScore: SortOption.lowToHigh,
      };

      await tester.pumpWidget(build(
        selectedSorts: current,
        onSortChanged: (updated) => current = updated,
      ));

      // Find and tap "High → low" checkbox (second option in exerciseScore category)
      // The LabeledCheckbox with label 'High → low' should be unchecked
      expect(find.text('High → low'), findsOneWidget);
      expect(find.text('Low → high'), findsOneWidget);

      // Tap the second LabeledCheckbox (highToLow)
      final checkboxes = find.byType(LabeledCheckbox);
      await tester.tap(checkboxes.at(1));
      await tester.pump();

      // After tap, highToLow should be selected, lowToHigh should be null
      expect(current[SortCategory.exerciseScore], SortOption.highToLow);
    });

    testWidgets('selecting option in one category does not affect other category', (tester) async {
      Map<SortCategory, SortOption?> current = {
        SortCategory.exerciseScore: SortOption.lowToHigh,
        SortCategory.alphabet: SortOption.aToZ,
      };

      await tester.pumpWidget(build(
        selectedSorts: current,
        onSortChanged: (updated) => current = updated,
      ));

      // Tap the highToLow checkbox
      final checkboxes = find.byType(LabeledCheckbox);
      await tester.tap(checkboxes.at(1));
      await tester.pump();

      // exerciseScore changed, alphabet unchanged
      expect(current[SortCategory.exerciseScore], SortOption.highToLow);
      expect(current[SortCategory.alphabet], SortOption.aToZ);
    });

    testWidgets('tapping already-checked option deselects it', (tester) async {
      Map<SortCategory, SortOption?> current = {
        SortCategory.exerciseScore: SortOption.lowToHigh,
      };

      await tester.pumpWidget(build(
        selectedSorts: current,
        onSortChanged: (updated) => current = updated,
      ));

      // Tap the first checkbox (lowToHigh — currently checked)
      await tester.tap(find.byType(LabeledCheckbox).first);
      await tester.pump();

      expect(current[SortCategory.exerciseScore], isNull);
    });
  });

  group('SortPanel clear all', () {
    testWidgets('onClearAll fires when Clear all tapped', (tester) async {
      bool cleared = false;
      await tester.pumpWidget(build(onClearAll: () => cleared = true));

      // Find the AppButton with "Clear all" label and tap it
      await tester.tap(find.text('Clear all'));
      await tester.pump();

      expect(cleared, true);
    });
  });

  group('SortPanel rendering', () {
    testWidgets('renders all 4 options as LabeledCheckboxes', (tester) async {
      await tester.pumpWidget(build());
      expect(find.byType(LabeledCheckbox), findsNWidgets(4));
    });

    testWidgets('renders category labels', (tester) async {
      await tester.pumpWidget(build());
      expect(find.text('Exercise score'), findsOneWidget);
      expect(find.text('Alphabet'), findsOneWidget);
    });

    testWidgets('renders option labels', (tester) async {
      await tester.pumpWidget(build());
      expect(find.text('Low → high'), findsOneWidget);
      expect(find.text('High → low'), findsOneWidget);
      expect(find.text('Abc → xyz'), findsOneWidget);
      expect(find.text('Zyx → abc'), findsOneWidget);
    });

    testWidgets('onSortChanged reports correct state map', (tester) async {
      Map<SortCategory, SortOption?>? reported;
      await tester.pumpWidget(build(
        selectedSorts: {},
        onSortChanged: (m) => reported = m,
      ));

      // Tap first checkbox (lowToHigh)
      await tester.tap(find.byType(LabeledCheckbox).first);
      await tester.pump();

      expect(reported, isNotNull);
      expect(reported![SortCategory.exerciseScore], SortOption.lowToHigh);
    });
  });
}
