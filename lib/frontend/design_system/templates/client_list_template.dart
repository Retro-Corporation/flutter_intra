import 'package:flutter/material.dart';
import '../design_system.dart';

/// Template: Client search page.
///
/// Owns all controllers and wires search, sort, and navigation state into
/// [ClientListOrganism]. Data and callbacks enter through the constructor —
/// this template generates nothing and decides nothing.
class ClientListTemplate extends StatefulWidget {
  final List<CurrentClientData> currentClients;
  final List<AllClientData> allClients;
  final int maxCurrentClients;
  final ValueChanged<String> onClientTap;
  final ValueChanged<AllClientActionEvent> onClientAction;
  final VoidCallback onAddClients;

  const ClientListTemplate({
    super.key,
    required this.currentClients,
    required this.allClients,
    required this.maxCurrentClients,
    required this.onClientTap,
    required this.onClientAction,
    required this.onAddClients,
  });

  @override
  State<ClientListTemplate> createState() => _ClientListTemplateState();
}

class _ClientListTemplateState extends State<ClientListTemplate> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  final _scrollController = ScrollController();
  Map<SortCategory, SortOption?> _activeSort = {};
  bool _sortOpen = false;
  PractitionerTab _selectedTab = PractitionerTab.clients;

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    _scrollController.dispose();
    super.dispose();
  }

  FilterButtonState get _filterButtonState {
    if (_sortOpen) return FilterButtonState.open;
    if (_activeSort.values.any((v) => v != null)) return FilterButtonState.sorted;
    return FilterButtonState.idle;
  }

  void _closeSortPanel() => setState(() => _sortOpen = false);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: PractitionerNavBar(
        selectedTab: _selectedTab,
        onTabSelected: (tab) => setState(() => _selectedTab = tab),
      ),
      body: GestureDetector(
        onTap: () => FocusScope.of(context).unfocus(),
        behavior: HitTestBehavior.translucent,
        child: SafeArea(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // ── Header row ──
              Padding(
                padding: const EdgeInsets.fromLTRB(
                  AppGrid.grid16,
                  AppGrid.grid16,
                  AppGrid.grid16,
                  0,
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: AppText(
                        'Client search',
                        style: AppTypography.proHeading6.bold,
                      ),
                    ),
                    AppButton(
                      label: 'Add client',
                      leadingIcon: AppIcons.userAddFilled,
                      type: ButtonType.filled,
                      color: AppColors.brand,
                      onPressed: widget.onAddClients,
                    ),
                  ],
                ),
              ),

              const SizedBox(height: AppGrid.grid32),

              // ── Search + filter row ──
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppGrid.grid16,
                ),
                child: IntrinsicHeight(
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      Expanded(
                        child: TapRegion(
                          onTapOutside: (_) => FocusScope.of(context).unfocus(),
                          child: AppSearchBar(
                            variant: SearchBarVariant.card,
                            controller: _searchController,
                            focusNode: _searchFocusNode,
                            hintText: 'Search clients...',
                            onChanged: (_) {},
                          ),
                        ),
                      ),
                      const SizedBox(width: AppGrid.grid32),
                      TapRegion(
                        groupId: 'sort-panel',
                        child: AspectRatio(
                          aspectRatio: 1,
                          child: FilterButton(
                            state: _filterButtonState,
                            icon: AppIcons.filter,
                            onTap: () => setState(() => _sortOpen = !_sortOpen),
                            backgroundColor: AppColors.background,
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: AppGrid.grid24),

              // ── Client list + sort panel overlay ──
              Expanded(
                child: Stack(
                  children: [
                    // Client list (base layer — never moves)
                    Positioned.fill(
                      child: Padding(
                        padding: const EdgeInsets.symmetric(
                          horizontal: AppGrid.grid16,
                        ),
                        child: ClientListOrganism(
                          currentClients: widget.currentClients,
                          allClients: widget.allClients,
                          maxCurrentClients: widget.maxCurrentClients,
                          searchText: _searchController.text,
                          activeSort: _activeSort,
                          scrollController: _scrollController,
                          onCurrentClientTap: widget.onClientTap,
                          onAllClientAction: widget.onClientAction,
                          onAddClientsTap: widget.onAddClients,
                        ),
                      ),
                    ),

                    // Sort panel overlay (floats above list, dismisses on outside tap)
                    if (_sortOpen)
                      Positioned(
                        top: 0,
                        left: AppGrid.grid16,
                        right: AppGrid.grid16,
                        child: TapRegion(
                          groupId: 'sort-panel',
                          onTapOutside: (_) => _closeSortPanel(),
                          child: SortPanel(
                            selectedSorts: _activeSort,
                            onSortChanged: (s) => setState(() => _activeSort = s),
                            onClearAll: () => setState(() => _activeSort = {}),
                          ),
                        ),
                      ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
