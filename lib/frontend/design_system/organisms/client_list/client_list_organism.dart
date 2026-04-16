import 'package:flutter/material.dart';
import '../../design_system.dart';
import 'client_list_types.dart';

/// Organism: cross-molecule client list with two sections.
///
/// "Current clients" shows [CurrentClientCard] molecules with optional sorting
/// and search filtering. "All clients" shows [AllClientCard] molecules where
/// each card's state (add/remove/rosterFull) is derived from cross-list logic.
/// All clients are searchable by name **and** email.
///
/// Search UI and controllers are owned by the template layer — this organism
/// receives a pre-computed [searchText] string and is purely reactive.
///
/// This widget owns no controllers and triggers no side effects — it reports
/// all user actions upward through callbacks.
class ClientListOrganism extends StatelessWidget {
  final List<CurrentClientData> currentClients;
  final List<AllClientData> allClients;
  final int maxCurrentClients;
  final String searchText;
  final Map<SortCategory, SortOption?> activeSort;
  final ValueChanged<String> onCurrentClientTap;
  final ValueChanged<AllClientActionEvent> onAllClientAction;
  final VoidCallback onAddClientsTap;
  final ScrollController? scrollController;

  const ClientListOrganism({
    super.key,
    required this.currentClients,
    required this.allClients,
    required this.maxCurrentClients,
    required this.searchText,
    required this.activeSort,
    required this.onCurrentClientTap,
    required this.onAllClientAction,
    required this.onAddClientsTap,
    this.scrollController,
  });

  // ── Cross-list logic ──

  bool get _isRosterFull => currentClients.length >= maxCurrentClients;
  Set<String> get _currentClientIds =>
      currentClients.map((c) => c.clientId).toSet();

  AllClientCardState _cardStateFor(AllClientData c) {
    if (_isRosterFull) return AllClientCardState.rosterFull;
    return _currentClientIds.contains(c.clientId)
        ? AllClientCardState.remove
        : AllClientCardState.add;
  }

  // ── Filtering ──

  List<CurrentClientData> get _filteredCurrent {
    final base = searchText.isEmpty
        ? currentClients
        : currentClients
            .where((c) =>
                c.clientName.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
    return _sortedCurrent(base);
  }

  List<AllClientData> get _filteredAll {
    final base = searchText.isEmpty
        ? allClients
        : allClients
            .where((c) =>
                c.clientName
                    .toLowerCase()
                    .contains(searchText.toLowerCase()) ||
                c.email.toLowerCase().contains(searchText.toLowerCase()))
            .toList();
    return _sortedAll(base);
  }

  // ── Sorting ──

  List<CurrentClientData> _sortedCurrent(List<CurrentClientData> list) {
    final scoreOpt = activeSort[SortCategory.exerciseScore];
    if (scoreOpt != null) {
      return [...list]
        ..sort((a, b) => scoreOpt == SortOption.lowToHigh
            ? a.score.compareTo(b.score)
            : b.score.compareTo(a.score));
    }
    final alphaOpt = activeSort[SortCategory.alphabet];
    if (alphaOpt != null) {
      return [...list]
        ..sort((a, b) => alphaOpt == SortOption.aToZ
            ? a.clientName.compareTo(b.clientName)
            : b.clientName.compareTo(a.clientName));
    }
    return list;
  }

  List<AllClientData> _sortedAll(List<AllClientData> list) {
    // exerciseScore intentionally skipped — AllClientData has no score field
    final alphaOpt = activeSort[SortCategory.alphabet];
    if (alphaOpt != null) {
      return [...list]
        ..sort((a, b) => alphaOpt == SortOption.aToZ
            ? a.clientName.compareTo(b.clientName)
            : b.clientName.compareTo(a.clientName));
    }
    return list;
  }

  // ── Empty state getters ──

  bool get _isSearchActive => searchText.isNotEmpty;
  bool get _hasCurrentResults => _filteredCurrent.isNotEmpty;
  bool get _hasAllResults => _filteredAll.isNotEmpty;
  bool get _isNoSearchResults =>
      _isSearchActive && !_hasCurrentResults && !_hasAllResults;
  bool get _isNoClientsAtAll =>
      !_isSearchActive && currentClients.isEmpty && allClients.isEmpty;

  @override
  Widget build(BuildContext context) {
    final filtered = _filteredCurrent;
    final filteredAll = _filteredAll;

    return CustomScrollView(
      controller: scrollController,
      slivers: [
        // ── Current clients sticky header ──
        SliverPersistentHeader(
          pinned: true,
          delegate: _SectionHeaderDelegate(
            label: 'Current clients',
            count: '${currentClients.length}/$maxCurrentClients',
          ),
        ),

        // ── Current client cards ──
        if (filtered.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final client = filtered[i];
                final isLast = i == filtered.length - 1;
                return Padding(
                  padding: EdgeInsets.only(
                    bottom: isLast ? AppGrid.grid8 : AppGrid.grid16,
                  ),
                  child: Semantics(
                    label:
                        'Client: ${client.clientName}, score: ${client.score.toStringAsFixed(1)}',
                    child: CurrentClientCard(
                      clientName: client.clientName,
                      lastSessionText: client.lastSessionText,
                      score: client.score,
                      status: client.status,
                      onTap: () => onCurrentClientTap(client.clientId),
                    ),
                  ),
                );
              },
              childCount: filtered.length,
            ),
          ),

        // ── All clients sticky header ──
        SliverPersistentHeader(
          pinned: true,
          delegate: _SectionHeaderDelegate(
            label: 'All clients',
            count: '${allClients.length}',
          ),
        ),

        // ── All clients section content ──
        if (_isNoClientsAtAll)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: IconTextAction(
                iconPath: AppIcons.add,
                label: 'Add Clients',
                onTap: onAddClientsTap,
              ),
            ),
          )
        else if (_isNoSearchResults)
          SliverFillRemaining(
            hasScrollBody: false,
            child: Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  AppText(
                    'No search results',
                    style: AppTypography.bodyLarge.bold,
                    color: AppColors.brand,
                  ),
                  SizedBox(height: AppGrid.grid8),
                  IconTextAction(
                    iconPath: AppIcons.add,
                    label: 'Add Clients',
                    onTap: onAddClientsTap,
                  ),
                ],
              ),
            ),
          )
        else if (filteredAll.isNotEmpty)
          SliverList(
            delegate: SliverChildBuilderDelegate(
              (context, i) {
                final client = filteredAll[i];
                final state = _cardStateFor(client);
                final semanticLabel = state == AllClientCardState.add
                    ? 'Add ${client.clientName} to current clients'
                    : state == AllClientCardState.remove
                        ? 'Remove ${client.clientName} from current clients'
                        : client.clientName;
                return Padding(
                  padding: EdgeInsets.only(
                      bottom:
                          i < filteredAll.length - 1 ? AppGrid.grid16 : 0),
                  child: Semantics(
                    label: semanticLabel,
                    child: AllClientCard(
                      clientName: client.clientName,
                      email: client.email,
                      state: state,
                      onTap: () => onCurrentClientTap(client.clientId),
                      onAction: () => onAllClientAction(
                        AllClientActionEvent(
                          clientId: client.clientId,
                          action: state == AllClientCardState.remove
                              ? AllClientCardState.remove
                              : AllClientCardState.add,
                        ),
                      ),
                    ),
                  ),
                );
              },
              childCount: filteredAll.length,
            ),
          ),
      ],
    );
  }
}

// ── Private section header delegate ──

class _SectionHeaderDelegate extends SliverPersistentHeaderDelegate {
  final String label;
  final String count;

  const _SectionHeaderDelegate({required this.label, required this.count});

  // top padding: AppGrid.grid4 = 4.0
  // body (AppTypography.body.semiBold: 16px × 1.5 line-height = 24px)
  // bottom padding: AppGrid.grid8 = 8.0
  // total: 4 + 24 + 8 = 36 = AppGrid.grid36
  static const double _extent = AppGrid.grid36;

  @override
  double get minExtent => _extent;

  @override
  double get maxExtent => _extent;

  @override
  bool shouldRebuild(_SectionHeaderDelegate old) =>
      old.label != label || old.count != count;

  @override
  Widget build(
    BuildContext context,
    double shrinkOffset,
    bool overlapsContent,
  ) {
    return Container(
      color: AppColors.background,
      padding: const EdgeInsets.only(
        top: AppGrid.grid4,
        bottom: AppGrid.grid8,
      ),
      child: SectionHeader(label: label, count: count),
    );
  }
}
