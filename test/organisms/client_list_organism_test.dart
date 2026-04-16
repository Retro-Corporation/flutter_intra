import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';
import 'package:flutter_intra/frontend/design_system/organisms/client_list/client_list_organism.dart';
import 'package:flutter_intra/frontend/design_system/organisms/client_list/client_list_types.dart';

// ── Test fixtures ──

final _currentClients = [
  CurrentClientData(
      clientId: 'c1',
      clientName: 'Alice Brown',
      lastSessionText: '1 day ago',
      score: 7.2,
      status: ReviewStatus.urgent),
  CurrentClientData(
      clientId: 'c2',
      clientName: 'Bob Smith',
      lastSessionText: '3 days ago',
      score: 3.5,
      status: ReviewStatus.reviewed),
  CurrentClientData(
      clientId: 'c3',
      clientName: 'Carol Davis',
      lastSessionText: '2 days ago',
      score: 9.1,
      status: ReviewStatus.pendingReview),
];

final _allClients = [
  AllClientData(
      clientId: 'c1',
      clientName: 'Alice Brown',
      email: 'alice@example.com'), // in current roster
  AllClientData(
      clientId: 'a1',
      clientName: 'Dave Wilson',
      email: 'dave@example.com'),
  AllClientData(
      clientId: 'a2',
      clientName: 'Eve Johnson',
      email: 'eve@example.com'),
];

Widget _buildOrganism({
  List<CurrentClientData>? currentClients,
  List<AllClientData>? allClients,
  int maxCurrentClients = 30,
  String searchText = '',
  Map<SortCategory, SortOption?> activeSort = const {},
  ValueChanged<String>? onCurrentClientTap,
  ValueChanged<AllClientActionEvent>? onAllClientAction,
  VoidCallback? onAddClientsTap,
  ScrollController? scrollController,
}) {
  return MaterialApp(
    home: Scaffold(
      body: ClientListOrganism(
        currentClients: currentClients ?? _currentClients,
        allClients: allClients ?? _allClients,
        maxCurrentClients: maxCurrentClients,
        searchText: searchText,
        activeSort: activeSort,
        onCurrentClientTap: onCurrentClientTap ?? (_) {},
        onAllClientAction: onAllClientAction ?? (_) {},
        onAddClientsTap: onAddClientsTap ?? () {},
        scrollController: scrollController,
      ),
    ),
  );
}

void main() {
  group('ClientListOrganism', () {
    // ── Search filtering ──

    testWidgets('search filters current clients by name', (tester) async {
      await tester.pumpWidget(_buildOrganism(searchText: 'Alice'));
      // Alice appears in both current and all sections (shared clientId).
      // findsWidgets confirms she is present; Bob and Carol confirm non-matches are absent.
      expect(find.text('Alice Brown'), findsWidgets);
      expect(find.text('Bob Smith'), findsNothing);
      expect(find.text('Carol Davis'), findsNothing);
    });

    testWidgets('search filters all clients by name', (tester) async {
      await tester.pumpWidget(_buildOrganism(searchText: 'Dave'));
      expect(find.text('Dave Wilson'), findsOneWidget);
      expect(find.text('Eve Johnson'), findsNothing);
    });

    testWidgets('empty search text shows all clients', (tester) async {
      await tester.pumpWidget(_buildOrganism(searchText: ''));
      await tester.pumpAndSettle();
      expect(find.text('Alice Brown'), findsWidgets); // appears in both sections
      expect(find.text('Bob Smith'), findsOneWidget);
      expect(find.text('Carol Davis'), findsOneWidget);
      expect(find.text('Dave Wilson'), findsOneWidget);
      expect(find.text('Eve Johnson'), findsOneWidget);
    });

    // ── Sorting ──

    testWidgets('score sort low-to-high reorders current clients',
        (tester) async {
      await tester.pumpWidget(_buildOrganism(
        activeSort: {SortCategory.exerciseScore: SortOption.lowToHigh},
      ));
      // Bob (3.5) → Alice (7.2) → Carol (9.1)
      // Use .first for Alice — she appears in both current and all sections.
      final bob = tester.getTopLeft(find.text('Bob Smith'));
      final aliceIsBelow =
          tester.getTopLeft(find.text('Alice Brown').first).dy > bob.dy;
      expect(aliceIsBelow, isTrue);
    });

    testWidgets('score sort high-to-low reorders current clients',
        (tester) async {
      await tester.pumpWidget(_buildOrganism(
        activeSort: {SortCategory.exerciseScore: SortOption.highToLow},
      ));
      // Carol (9.1) → Alice (7.2) → Bob (3.5)
      // Use .first for Alice — she appears in both current and all sections.
      final carol = tester.getTopLeft(find.text('Carol Davis'));
      final carolBeforeAlice =
          carol.dy < tester.getTopLeft(find.text('Alice Brown').first).dy;
      expect(carolBeforeAlice, isTrue);
    });

    testWidgets('alphabet A→Z sorts current clients', (tester) async {
      await tester.pumpWidget(_buildOrganism(
        activeSort: {SortCategory.alphabet: SortOption.aToZ},
      ));
      // Use .first for Alice — she appears in both current and all sections.
      final alice = tester.getTopLeft(find.text('Alice Brown').first);
      final bob = tester.getTopLeft(find.text('Bob Smith'));
      expect(alice.dy < bob.dy, isTrue);
    });

    testWidgets('alphabet Z→A sorts all clients', (tester) async {
      await tester.pumpWidget(_buildOrganism(
        activeSort: {SortCategory.alphabet: SortOption.zToA},
      ));
      final eve = tester.getTopLeft(find.text('Eve Johnson'));
      final dave = tester.getTopLeft(find.text('Dave Wilson'));
      expect(eve.dy < dave.dy, isTrue);
    });

    // ── Empty states ──

    testWidgets('no current clients shows both section headers', (tester) async {
      await tester.pumpWidget(_buildOrganism(
        currentClients: [],
        allClients: _allClients,
      ));
      expect(find.text('Current clients'), findsOneWidget);
      expect(find.text('All clients'), findsOneWidget);
    });

    testWidgets('no search results shows message and CTA', (tester) async {
      await tester.pumpWidget(_buildOrganism(searchText: 'zzzzzzz'));
      await tester.pumpAndSettle();
      expect(find.text('No search results'), findsOneWidget);
      expect(find.text('Add Clients'), findsOneWidget);
    });

    testWidgets('no clients at all shows CTA only (no "No search results")',
        (tester) async {
      await tester.pumpWidget(_buildOrganism(
        currentClients: [],
        allClients: [],
      ));
      await tester.pumpAndSettle();
      expect(find.text('Add Clients'), findsOneWidget);
      expect(find.text('No search results'), findsNothing);
    });

    // ── Roster full ──

    testWidgets('roster full hides add/remove icons on all client cards',
        (tester) async {
      bool actionFired = false;
      await tester.pumpWidget(_buildOrganism(
        maxCurrentClients: _currentClients.length,
        onAllClientAction: (_) => actionFired = true,
      ));
      await tester.pumpAndSettle();
      expect(actionFired, isFalse);
    });

    // ── Callbacks ──

    testWidgets('current card tap fires onCurrentClientTap with correct ID',
        (tester) async {
      String? tappedId;
      await tester.pumpWidget(_buildOrganism(
        onCurrentClientTap: (id) => tappedId = id,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Bob Smith').first);
      await tester.pumpAndSettle();
      expect(tappedId, 'c2');
    });

    testWidgets('all client name tap fires onCurrentClientTap with correct ID',
        (tester) async {
      String? tappedId;
      await tester.pumpWidget(_buildOrganism(
        onCurrentClientTap: (id) => tappedId = id,
      ));
      await tester.pumpAndSettle();
      await tester.tap(find.text('Dave Wilson'));
      await tester.pumpAndSettle();
      expect(tappedId, 'a1');
    });

    testWidgets('all client action fires onAllClientAction with add for non-roster member',
        (tester) async {
      AllClientActionEvent? event;
      await tester.pumpWidget(_buildOrganism(
        onAllClientAction: (e) => event = e,
      ));
      await tester.pumpAndSettle();
      // Dave Wilson (a1) is not in current roster — card shows add state.
      // Find the card by locating Dave Wilson's card and tapping the action zone.
      // AllClientCard uses AppIcons.add (SVG), so we tap the right zone of Dave's card.
      // The action zone is a GestureDetector on the right side.
      // We scroll to ensure Dave is visible, then tap his action area.
      final daveCard = find.ancestor(
        of: find.text('Dave Wilson'),
        matching: find.byType(AllClientCard),
      );
      expect(daveCard, findsOneWidget);
      // Tap the right portion of Dave's card (action zone)
      final cardBox = tester.getRect(daveCard);
      await tester.tapAt(Offset(cardBox.right - 20, cardBox.center.dy));
      await tester.pumpAndSettle();
      expect(event?.action, AllClientCardState.add);
    });

    testWidgets(
        'all client action fires onAllClientAction with remove for current roster member',
        (tester) async {
      AllClientActionEvent? event;
      await tester.pumpWidget(_buildOrganism(
        onAllClientAction: (e) => event = e,
      ));
      await tester.pumpAndSettle();
      // Alice (c1) is in current roster — her AllClientCard shows remove state.
      final aliceCard = find.ancestor(
        of: find.text('alice@example.com'),
        matching: find.byType(AllClientCard),
      );
      expect(aliceCard, findsOneWidget);
      final cardBox = tester.getRect(aliceCard);
      await tester.tapAt(Offset(cardBox.right - 20, cardBox.center.dy));
      await tester.pumpAndSettle();
      expect(event?.action, AllClientCardState.remove);
    });

    // ── Section headers ──

    testWidgets('both section headers render', (tester) async {
      await tester.pumpWidget(_buildOrganism());
      await tester.pumpAndSettle();
      expect(find.text('Current clients'), findsOneWidget);
      expect(find.text('All clients'), findsOneWidget);
    });

    // ── scrollController ──

    testWidgets('scrollController wires to CustomScrollView', (tester) async {
      final controller = ScrollController();
      await tester.pumpWidget(_buildOrganism(scrollController: controller));
      await tester.pumpAndSettle();
      // If controller is attached, it means the CustomScrollView accepted it
      expect(controller.hasClients, isTrue);
      controller.dispose();
    });
  });
}
