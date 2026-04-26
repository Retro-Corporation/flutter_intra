import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';
import 'package:flutter_intra/frontend/design_system/organisms/client_account/equipment_picker_panel.dart';
import 'package:flutter_intra/frontend/design_system/organisms/client_account/equipment_picker_types.dart';

// ── shared fixtures ──────────────────────────────────────────────────────────

const _options = [
  EquipmentOption(id: 'barbell', label: 'Barbell'),
  EquipmentOption(id: 'dumbbell', label: 'Dumbbell'),
  EquipmentOption(id: 'cable', label: 'Cable'),
];

const _categories = [
  EquipmentFilterCategory(id: 'weights', label: 'Weights'),
  EquipmentFilterCategory(id: 'balance', label: 'Balance'),
  EquipmentFilterCategory(id: 'bands', label: 'Bands'),
];

// ── build helpers ────────────────────────────────────────────────────────────

Widget buildSimple({
  String title = 'Related equipment',
  List<EquipmentOption> options = _options,
  String? selectedId,
  ValueChanged<EquipmentOption>? onSelected,
}) {
  return MaterialApp(
    home: Scaffold(
      body: EquipmentPickerPanel(
        title: title,
        options: options,
        selectedId: selectedId,
        onSelected: onSelected ?? (_) {},
      ),
    ),
  );
}

Widget buildWithFilters({
  String title = 'Equipment category',
  String subtitle = 'Sub title',
  List<EquipmentOption> options = _options,
  List<EquipmentFilterCategory> categories = _categories,
  String? selectedId,
  String? selectedCategoryId,
  ValueChanged<EquipmentOption>? onSelected,
  ValueChanged<EquipmentFilterCategory?>? onCategoryChanged,
  VoidCallback? onAddNew,
}) {
  return MaterialApp(
    home: Scaffold(
      body: EquipmentPickerPanel(
        variant: EquipmentPickerVariant.withFilters,
        title: title,
        subtitle: subtitle,
        categories: categories,
        selectedCategoryId: selectedCategoryId,
        options: options,
        selectedId: selectedId,
        onSelected: onSelected ?? (_) {},
        onCategoryChanged: onCategoryChanged ?? (_) {},
        onAddNew: onAddNew ?? () {},
      ),
    ),
  );
}

// ── tests ────────────────────────────────────────────────────────────────────

void main() {
  // ── simple variant (existing — must remain unchanged) ────────────────────

  group('EquipmentPickerPanel rendering', () {
    testWidgets('renders the title', (tester) async {
      await tester.pumpWidget(buildSimple(title: 'Related equipment'));
      await tester.pumpAndSettle();

      expect(find.text('Related equipment'), findsOneWidget);
    });

    testWidgets('renders a row for every option', (tester) async {
      await tester.pumpWidget(buildSimple());
      await tester.pumpAndSettle();

      expect(find.byType(SchemeOptionRow), findsNWidgets(_options.length));
    });

    testWidgets('renders each option label', (tester) async {
      await tester.pumpWidget(buildSimple());
      await tester.pumpAndSettle();

      expect(find.text('Barbell'), findsOneWidget);
      expect(find.text('Dumbbell'), findsOneWidget);
      expect(find.text('Cable'), findsOneWidget);
    });
  });

  group('EquipmentPickerPanel selection', () {
    testWidgets('onSelected fires with the tapped option', (tester) async {
      EquipmentOption? selected;
      await tester.pumpWidget(buildSimple(onSelected: (o) => selected = o));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Dumbbell'));
      await tester.pump();

      expect(selected, isNotNull);
      expect(selected!.id, 'dumbbell');
      expect(selected!.label, 'Dumbbell');
    });

    testWidgets('tapping first option fires onSelected with correct option', (tester) async {
      EquipmentOption? selected;
      await tester.pumpWidget(buildSimple(onSelected: (o) => selected = o));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Barbell'));
      await tester.pump();

      expect(selected!.id, 'barbell');
    });
  });

  group('EquipmentPickerPanel entry animation', () {
    testWidgets('animates to fully visible without errors', (tester) async {
      await tester.pumpWidget(buildSimple());
      // Pump through full animation duration
      await tester.pumpAndSettle();

      // Panel is rendered and visible after animation completes
      expect(find.byType(EquipmentPickerPanel), findsOneWidget);
      expect(find.text('Related equipment'), findsOneWidget);
    });
  });

  // ── withFilters variant ──────────────────────────────────────────────────

  group('EquipmentPickerPanel withFilters — assertion', () {
    test('assert fires when variant is withFilters and categories is null', () {
      expect(
        () => EquipmentPickerPanel(
          variant: EquipmentPickerVariant.withFilters,
          title: 'Equipment category',
          options: const [],
          selectedId: null,
          onSelected: (_) {},
          // categories omitted — should assert
          subtitle: 'Sub title',
          onCategoryChanged: (_) {},
          onAddNew: () {},
        ),
        throwsAssertionError,
      );
    });

    test('assert fires when variant is withFilters and subtitle is null', () {
      expect(
        () => EquipmentPickerPanel(
          variant: EquipmentPickerVariant.withFilters,
          title: 'Equipment category',
          options: const [],
          selectedId: null,
          onSelected: (_) {},
          categories: _categories,
          // subtitle omitted — should assert
          onCategoryChanged: (_) {},
          onAddNew: () {},
        ),
        throwsAssertionError,
      );
    });

    test('assert fires when variant is withFilters and onCategoryChanged is null', () {
      expect(
        () => EquipmentPickerPanel(
          variant: EquipmentPickerVariant.withFilters,
          title: 'Equipment category',
          options: const [],
          selectedId: null,
          onSelected: (_) {},
          categories: _categories,
          subtitle: 'Sub title',
          // onCategoryChanged omitted — should assert
          onAddNew: () {},
        ),
        throwsAssertionError,
      );
    });

    test('assert fires when variant is withFilters and onAddNew is null', () {
      expect(
        () => EquipmentPickerPanel(
          variant: EquipmentPickerVariant.withFilters,
          title: 'Equipment category',
          options: const [],
          selectedId: null,
          onSelected: (_) {},
          categories: _categories,
          subtitle: 'Sub title',
          onCategoryChanged: (_) {},
          // onAddNew omitted — should assert
        ),
        throwsAssertionError,
      );
    });
  });

  group('EquipmentPickerPanel withFilters — rendering', () {
    testWidgets('renders title, chip row, subtitle, option rows, and footer', (tester) async {
      await tester.pumpWidget(buildWithFilters());
      await tester.pumpAndSettle();

      expect(find.text('Equipment category'), findsOneWidget);
      expect(find.text('Sub title'), findsOneWidget);
      // Chips
      expect(find.text('Weights'), findsOneWidget);
      expect(find.text('Balance'), findsOneWidget);
      expect(find.text('Bands'), findsOneWidget);
      // Option rows
      expect(find.byType(SchemeOptionRow), findsNWidgets(_options.length));
      // Footer
      expect(find.text('Add New Equipment'), findsOneWidget);
    });

    testWidgets('renders empty state text when options list is empty', (tester) async {
      await tester.pumpWidget(buildWithFilters(options: const []));
      await tester.pumpAndSettle();

      expect(find.text('No equipment in this category yet'), findsOneWidget);
      expect(find.byType(SchemeOptionRow), findsNothing);
    });

    testWidgets('selectedCategoryId drives which chip renders as filled/selected', (tester) async {
      await tester.pumpWidget(buildWithFilters(selectedCategoryId: 'weights'));
      await tester.pumpAndSettle();

      // There is exactly one AppBadge with BadgeType.filled — the selected chip.
      final badges = tester.widgetList<AppBadge>(find.byType(AppBadge));
      final filledBadges = badges.where((b) => b.type == BadgeType.filled).toList();
      expect(filledBadges.length, 1);
      expect(filledBadges.first.label, 'Weights');
    });

    testWidgets('selectedId drives which SchemeOptionRow is highlighted', (tester) async {
      await tester.pumpWidget(buildWithFilters(selectedId: 'dumbbell'));
      await tester.pumpAndSettle();

      final rows = tester.widgetList<SchemeOptionRow>(find.byType(SchemeOptionRow)).toList();
      final selected = rows.where((r) => r.isSelected).toList();
      expect(selected.length, 1);
      expect(selected.first.label, 'Dumbbell');
    });
  });

  group('EquipmentPickerPanel withFilters — chip interaction', () {
    testWidgets('tapping unselected chip fires onCategoryChanged with that category', (tester) async {
      EquipmentFilterCategory? changed;
      await tester.pumpWidget(buildWithFilters(
        onCategoryChanged: (cat) => changed = cat,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Balance'));
      await tester.pump();

      expect(changed, isNotNull);
      expect(changed!.id, 'balance');
    });

    testWidgets('tapping selected chip fires onCategoryChanged with null', (tester) async {
      EquipmentFilterCategory? changed = _categories.first; // non-null sentinel
      await tester.pumpWidget(buildWithFilters(
        selectedCategoryId: 'weights',
        onCategoryChanged: (cat) => changed = cat,
      ));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Weights'));
      await tester.pump();

      expect(changed, isNull);
    });
  });

  group('EquipmentPickerPanel withFilters — option and footer callbacks', () {
    testWidgets('tapping an option row fires onSelected with that option', (tester) async {
      EquipmentOption? selected;
      await tester.pumpWidget(buildWithFilters(onSelected: (o) => selected = o));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Cable'));
      await tester.pump();

      expect(selected, isNotNull);
      expect(selected!.id, 'cable');
    });

    testWidgets('tapping footer row fires onAddNew', (tester) async {
      var called = false;
      await tester.pumpWidget(buildWithFilters(onAddNew: () => called = true));
      await tester.pumpAndSettle();

      await tester.tap(find.text('Add New Equipment'));
      await tester.pump();

      expect(called, isTrue);
    });
  });
}
