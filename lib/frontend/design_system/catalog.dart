import 'package:flutter/material.dart';
import 'design_system.dart';

/// Run with: flutter run -t lib/frontend/design_system/catalog.dart
void main() {
  runApp(const DesignCatalogApp());
}

class DesignCatalogApp extends StatelessWidget {
  const DesignCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Design System Catalog',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const CatalogHome(),
    );
  }
}

// ── Catalog-only helpers ──

/// Catalog-only wrapper that creates and disposes a controller + focus node
/// for an input-molecule demo, then passes them to [builder].
///
/// Exists so catalog entries can render input molecules without violating the
/// rule that controller/focus ownership lives at the template layer in
/// production code.
class _CatalogInputDemo extends StatefulWidget {
  final String initialText;
  final Widget Function(TextEditingController controller, FocusNode focusNode) builder;

  const _CatalogInputDemo({
    required this.builder,
    this.initialText = '',
  });

  @override
  State<_CatalogInputDemo> createState() => _CatalogInputDemoState();
}

class _CatalogInputDemoState extends State<_CatalogInputDemo> {
  late final _controller = TextEditingController(text: widget.initialText);
  late final _focusNode = FocusNode();

  @override
  void dispose() {
    _controller.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) => widget.builder(_controller, _focusNode);
}

// ── Section / sub-section definition ──

class _SubSection {
  final String name;
  final GlobalKey key;
  _SubSection(this.name) : key = GlobalKey();
}

class _Section {
  final String name;
  final GlobalKey key;
  final List<_SubSection> subSections;
  bool isExpanded;

  _Section(this.name, List<String> subNames, {this.isExpanded = false})
      : key = GlobalKey(),
        subSections = subNames.map(_SubSection.new).toList();
}

// ── Main catalog ──

class CatalogHome extends StatefulWidget {
  const CatalogHome({super.key});

  @override
  State<CatalogHome> createState() => _CatalogHomeState();
}

class _CatalogHomeState extends State<CatalogHome> {
  final ScrollController _scrollController = ScrollController();
  bool _navExpanded = false;
  int _activeSection = 0;

  // Controllers for bare AppTextField showcases.
  final _textFieldDefault = TextEditingController();
  final _textFieldValue = TextEditingController(text: 'Hello world');
  final _textFieldPassword = TextEditingController();

  Map<SortCategory, SortOption?> _sortPanelSorts = {};

  late final List<_Section> _sections;
  // Track which nav sections have sub-items expanded
  late final Map<int, bool> _navSubExpanded;

  @override
  void initState() {
    super.initState();
    _sections = [
      _Section('Foundation', [
        'Semantic Colors',
        'Color Palettes',
        'Gradients',
        'Typography',
        '4-Point Grid',
        'Padding',
        'Corner Radius',
        'Stroke Widths',
      ], isExpanded: true),
      _Section('Atoms', [
        // primitives/
        'Text',
        'Icons',
        'Badges',
        'Score Badge',
        'Avatars',
        // controls/
        'Buttons',
        'Checkboxes',
        'Toggles',
        'Radios',
        'Nav Bar Item',
        // inputs/
        'Text Fields',
        // path/
        'Path Buttons',
        // behaviors/
        'Pressable Surface',
        // playground/
        'Button Playground',
      ]),
      _Section('Molecules', [
        'Text Fields',
        'Password Fields',
        'Text Areas',
        'Number Fields',
        'Search Bar',
        'Section Header',
        'Icon Text Action',
        'Current Client Card',
        'All Client Card',
        'Labeled Checkbox',
        'Filter Button',
        'Practitioner Nav Bar',
      ]),
      _Section('Organisms', [
        // client_list/
        'Client List',
        // sort/
        'Sort Panel',
      ]),
      _Section('Templates', []),
    ];
    _navSubExpanded = {for (var i = 0; i < _sections.length; i++) i: false};
    _scrollController.addListener(_onScroll);
  }

  @override
  void dispose() {
    _scrollController.removeListener(_onScroll);
    _scrollController.dispose();
    _textFieldDefault.dispose();
    _textFieldValue.dispose();
    _textFieldPassword.dispose();
    super.dispose();
  }

  void _onScroll() {
    // Determine which section is currently visible
    for (int i = _sections.length - 1; i >= 0; i--) {
      final key = _sections[i].key;
      if (key.currentContext != null) {
        final box = key.currentContext!.findRenderObject() as RenderBox?;
        if (box != null) {
          final pos = box.localToGlobal(Offset.zero);
          if (pos.dy <= 120) {
            if (_activeSection != i) {
              setState(() => _activeSection = i);
            }
            return;
          }
        }
      }
    }
  }

  void _scrollToSection(int index) {
    // Auto-expand the section if collapsed
    if (!_sections[index].isExpanded) {
      setState(() => _sections[index].isExpanded = true);
    }
    // Wait for build, then scroll
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _sections[index].key;
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _scrollToSubSection(int sectionIndex, int subIndex) {
    // Auto-expand parent
    if (!_sections[sectionIndex].isExpanded) {
      setState(() => _sections[sectionIndex].isExpanded = true);
    }
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final key = _sections[sectionIndex].subSections[subIndex].key;
      if (key.currentContext != null) {
        Scrollable.ensureVisible(
          key.currentContext!,
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
        );
      }
    });
  }

  void _expandAll() {
    setState(() {
      for (final s in _sections) {
        s.isExpanded = true;
      }
    });
  }

  void _collapseAll() {
    setState(() {
      for (final s in _sections) {
        s.isExpanded = false;
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Row(
          children: [
            // ── Left nav panel ──
            _buildNavPanel(),

            // ── Main content ──
            Expanded(
              child: ListView(
                controller: _scrollController,
                padding: const EdgeInsets.all(AppPadding.pagePadding),
                children: [
                  AppText('Design System', style: AppTypography.heading4.bold),
                  const SizedBox(height: 4),
                  AppText('CATALOG', style: AppTypography.overline.semiBold),
                  const SizedBox(height: AppGrid.grid24),

                  // Foundation
                  _buildCollapsibleSection(0, _buildFoundationContent()),

                  const SizedBox(height: AppGrid.grid16),

                  // Atoms
                  _buildCollapsibleSection(1, _buildAtomsContent()),

                  const SizedBox(height: AppGrid.grid16),

                  // Molecules
                  _buildCollapsibleSection(2, _buildMoleculesContent()),

                  const SizedBox(height: AppGrid.grid16),

                  // Organisms
                  _buildCollapsibleSection(3, _buildOrganismsContent()),

                  const SizedBox(height: AppGrid.grid16),

                  // Templates
                  _buildCollapsibleSection(4, [
                    const SizedBox(height: AppGrid.grid24),
                    Center(
                      child: AppText(
                        'Coming soon',
                        style: AppTypography.body.regular,
                        color: AppColors.textSecondary,
                      ),
                    ),
                    const SizedBox(height: AppGrid.grid24),
                  ]),

                  const SizedBox(height: AppGrid.grid60),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Nav panel ──

  Widget _buildNavPanel() {
    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeInOut,
      width: _navExpanded ? 220 : 48,
      decoration: const BoxDecoration(
        color: AppColors.surface,
        border: Border(
          right: BorderSide(color: AppColors.surfaceBorder, width: AppStroke.xs),
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Toggle button
          InkWell(
            onTap: () => setState(() => _navExpanded = !_navExpanded),
            child: Container(
              height: 48,
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 12),
              alignment: _navExpanded ? Alignment.centerLeft : Alignment.center,
              child: Row(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(
                    _navExpanded
                        ? Icons.view_sidebar
                        : Icons.view_sidebar_outlined,
                    color: AppColors.textPrimary,
                    size: 22,
                  ),
                  if (_navExpanded) ...[
                    const SizedBox(width: AppGrid.grid8),
                    AppText(
                      'Sections',
                      style: AppTypography.bodySmall.bold,
                    ),
                  ],
                ],
              ),
            ),
          ),

          if (_navExpanded) ...[
            const Divider(color: AppColors.surfaceBorder, height: 1),

            // Expand / Collapse all
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Row(
                children: [
                  _NavAction(
                    label: 'Expand All',
                    onTap: _expandAll,
                  ),
                  const SizedBox(width: AppGrid.grid8),
                  _NavAction(
                    label: 'Collapse All',
                    onTap: _collapseAll,
                  ),
                ],
              ),
            ),

            const Divider(color: AppColors.surfaceBorder, height: 1),

            // Section links
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: List.generate(_sections.length, (i) {
                    final section = _sections[i];
                    final isActive = _activeSection == i;
                    return Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Top-level section link
                        InkWell(
                          onTap: () => _scrollToSection(i),
                          child: Container(
                            width: double.infinity,
                            padding: const EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 8,
                            ),
                            decoration: BoxDecoration(
                              border: Border(
                                left: BorderSide(
                                  color: isActive
                                      ? AppColors.brand
                                      : Colors.transparent,
                                  width: AppStroke.lg,
                                ),
                              ),
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: AppText(
                                    section.name,
                                    style: AppTypography.bodySmall.bold,
                                    color: isActive
                                        ? AppColors.brand
                                        : AppColors.textPrimary,
                                  ),
                                ),
                                if (section.subSections.isNotEmpty)
                                  GestureDetector(
                                    onTap: () => setState(() {
                                      _navSubExpanded[i] =
                                          !(_navSubExpanded[i] ?? false);
                                    }),
                                    child: AnimatedRotation(
                                      turns:
                                          (_navSubExpanded[i] ?? false) ? 0.25 : 0,
                                      duration: const Duration(milliseconds: 200),
                                      child: const Icon(
                                        Icons.chevron_right,
                                        size: 16,
                                        color: AppColors.textSecondary,
                                      ),
                                    ),
                                  ),
                              ],
                            ),
                          ),
                        ),

                        // Sub-section links
                        if ((_navSubExpanded[i] ?? false) &&
                            section.subSections.isNotEmpty)
                          ...section.subSections.asMap().entries.map((entry) {
                            return InkWell(
                              onTap: () => _scrollToSubSection(i, entry.key),
                              child: Padding(
                                padding: const EdgeInsets.only(
                                  left: 24,
                                  right: 12,
                                  top: 4,
                                  bottom: 4,
                                ),
                                child: AppText(
                                  entry.value.name,
                                  style: AppTypography.caption.bold,
                                  color: AppColors.textSecondary,
                                ),
                              ),
                            );
                          }),
                      ],
                    );
                  }),
                ),
              ),
            ),
          ],
        ],
      ),
    );
  }

  // ── Collapsible section ──

  Widget _buildCollapsibleSection(int index, List<Widget> children) {
    final section = _sections[index];
    return Column(
      key: section.key,
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Header ribbon
        GestureDetector(
          onTap: () => setState(() => section.isExpanded = !section.isExpanded),
          child: Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.rem1,
              vertical: AppPadding.rem075,
            ),
            decoration: BoxDecoration(
              color: AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.surfaceBorder, width: AppStroke.xs),
            ),
            child: Row(
              children: [
                Expanded(
                  child: AppText(
                    section.name.toUpperCase(),
                    style: AppTypography.heading5.bold,
                  ),
                ),
                AnimatedRotation(
                  turns: section.isExpanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.chevron_right,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
        ),

        // Content
        AnimatedSize(
          duration: const Duration(milliseconds: 300),
          curve: Curves.easeInOut,
          alignment: Alignment.topCenter,
          child: section.isExpanded
              ? Padding(
                  padding: const EdgeInsets.only(top: AppGrid.grid16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: children,
                  ),
                )
              : const SizedBox.shrink(),
        ),
      ],
    );
  }

  // ── Foundation content ──

  List<Widget> _buildFoundationContent() {
    final subs = _sections[0].subSections;
    return [
      // ── COLOR ──
      _folderGroupHeader('COLOR'),

      // Semantic Colors
      _subSectionHeader(subs[0]),
      const SizedBox(height: AppGrid.grid12),
      const _ColorRow('Brand', AppColors.brand),
      const _ColorRow('Brand Light', AppColors.brandLight),
      const _ColorRow('Brand Subtle', AppColors.brandSubtle),
      const _ColorRow('Brand Dark', AppColors.brandDark),
      const _ColorRow('Background', AppColors.background),
      const _ColorRow('Surface', AppColors.surface),
      const _ColorRow('Surface Border', AppColors.surfaceBorder),
      const _ColorRow('Text Primary', AppColors.textPrimary),
      const _ColorRow('Text Secondary', AppColors.textSecondary),
      const _ColorRow('Error', AppColors.error),
      const _ColorRow('Info', AppColors.info),
      const _ColorRow('Success', AppColors.success),
      const _ColorRow('Warning', AppColors.warning),

      _sectionDivider(),

      // Color Palettes
      _subSectionHeader(subs[1]),
      const SizedBox(height: AppGrid.grid12),
      AppText('GREY', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const _PaletteStrip([
        _PaletteColor('50', AppColors.grey50),
        _PaletteColor('100', AppColors.grey100),
        _PaletteColor('200', AppColors.grey200),
        _PaletteColor('300', AppColors.grey300),
        _PaletteColor('500', AppColors.grey500),
        _PaletteColor('600', AppColors.grey600),
        _PaletteColor('700', AppColors.grey700),
        _PaletteColor('800', AppColors.grey800),
        _PaletteColor('850', AppColors.grey850),
        _PaletteColor('900', AppColors.grey900),
      ]),

      const SizedBox(height: AppGrid.grid24),
      AppText('ORANGE (PRIMARY)', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const _PaletteStrip([
        _PaletteColor('50', AppColors.orange50),
        _PaletteColor('100', AppColors.orange100),
        _PaletteColor('500', AppColors.orange500),
        _PaletteColor('700', AppColors.orange700),
        _PaletteColor('900', AppColors.orange900),
      ]),

      const SizedBox(height: AppGrid.grid24),
      AppText('BLUE', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const _PaletteStrip([
        _PaletteColor('500', AppColors.blue500),
        _PaletteColor('700', AppColors.blue700),
        _PaletteColor('900', AppColors.blue900),
      ]),

      const SizedBox(height: AppGrid.grid24),
      AppText('RED', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const _PaletteStrip([
        _PaletteColor('500', AppColors.red500),
        _PaletteColor('700', AppColors.red700),
        _PaletteColor('900', AppColors.red900),
      ]),

      const SizedBox(height: AppGrid.grid24),
      AppText('GREEN', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const _PaletteStrip([
        _PaletteColor('500', AppColors.green500),
        _PaletteColor('700', AppColors.green700),
        _PaletteColor('900', AppColors.green900),
      ]),

      const SizedBox(height: AppGrid.grid24),
      AppText('PURPLE', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const _PaletteStrip([
        _PaletteColor('500', AppColors.purple500),
        _PaletteColor('700', AppColors.purple700),
        _PaletteColor('900', AppColors.purple900),
      ]),

      const SizedBox(height: AppGrid.grid24),
      AppText('YELLOW', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const _PaletteStrip([
        _PaletteColor('500', AppColors.yellow500),
        _PaletteColor('700', AppColors.yellow700),
        _PaletteColor('900', AppColors.yellow900),
      ]),

      _sectionDivider(),

      // Gradients
      _subSectionHeader(subs[2]),
      const SizedBox(height: AppGrid.grid12),
      const _GradientSwatch('Brand', AppColors.brandGradient),
      const SizedBox(height: AppGrid.grid8),
      const _GradientSwatch('Error', AppColors.errorGradient),

      // ── TYPE ──
      _folderGroupHeader('TYPE'),

      // Typography
      _subSectionHeader(subs[3]),
      const SizedBox(height: AppGrid.grid8),
      Row(
        children: [
          Expanded(child: AppText('BLACK', style: AppTypography.overline.semiBold)),
          const SizedBox(width: AppGrid.grid8),
          Expanded(child: AppText('BOLD', style: AppTypography.overline.semiBold)),
          const SizedBox(width: AppGrid.grid8),
          Expanded(child: AppText('SEMI BOLD', style: AppTypography.overline.semiBold)),
          const SizedBox(width: AppGrid.grid8),
          Expanded(child: AppText('REGULAR', style: AppTypography.overline.semiBold)),
        ],
      ),
      const SizedBox(height: AppGrid.grid16),

      _TypeRow('Display 1', AppTypography.display1),
      _TypeRow('Display 2', AppTypography.display2),
      _TypeRow('Heading 1', AppTypography.heading1),
      _TypeRow('Heading 2', AppTypography.heading2),
      _TypeRow('Heading 3', AppTypography.heading3),
      _TypeRow('Heading 4', AppTypography.heading4),
      _TypeRow('Heading 5', AppTypography.heading5),
      _TypeRow('Pro Heading 6', AppTypography.proHeading6),
      _TypeRow('Body Large (19.2)', AppTypography.bodyLarge),
      _TypeRow('Body (16)', AppTypography.body),
      _TypeRow('Body Small (13.3)', AppTypography.bodySmall),

      const SizedBox(height: AppGrid.grid16),
      AppText('LINKS', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      Row(
        children: [
          Expanded(child: AppText('Link Large', style: AppTypography.linkLarge.semiBold)),
          Expanded(child: AppText('Link', style: AppTypography.link.semiBold)),
          Expanded(child: AppText('Link Small', style: AppTypography.linkSmall.semiBold)),
        ],
      ),

      // ── SPACE ──
      _folderGroupHeader('SPACE'),

      // 4-Point Grid
      _subSectionHeader(subs[4]),
      const SizedBox(height: AppGrid.grid12),
      const _SpacingRow('grid0', '0rem', AppGrid.grid0),
      const _SpacingRow('grid4', '0.25rem', AppGrid.grid4),
      const _SpacingRow('grid8', '0.5rem', AppGrid.grid8),
      const _SpacingRow('grid12', '0.75rem', AppGrid.grid12),
      const _SpacingRow('grid16', '1rem', AppGrid.grid16),
      const _SpacingRow('grid20', '1.25rem', AppGrid.grid20),
      const _SpacingRow('grid24', '1.5rem', AppGrid.grid24),
      const _SpacingRow('grid28', '1.75rem', AppGrid.grid28),
      const _SpacingRow('grid32', '2rem', AppGrid.grid32),
      const _SpacingRow('grid36', '2.25rem', AppGrid.grid36),
      const _SpacingRow('grid40', '2.5rem', AppGrid.grid40),
      const _SpacingRow('grid44', '2.75rem', AppGrid.grid44),
      const _SpacingRow('grid48', '3rem', AppGrid.grid48),
      const _SpacingRow('grid52', '3.25rem', AppGrid.grid52),
      const _SpacingRow('grid56', '3.5rem', AppGrid.grid56),
      const _SpacingRow('grid60', '3.75rem', AppGrid.grid60),
      const _SpacingRow('grid64', '4rem', AppGrid.grid64),
      const _SpacingRow('grid68', '4.25rem', AppGrid.grid68),
      const _SpacingRow('grid72', '4.5rem', AppGrid.grid72),
      const _SpacingRow('grid76', '4.75rem', AppGrid.grid76),
      const _SpacingRow('grid80', '5rem', AppGrid.grid80),
      const _SpacingRow('grid84', '5.25rem', AppGrid.grid84),
      const _SpacingRow('grid88', '5.5rem', AppGrid.grid88),
      const _SpacingRow('grid92', '5.75rem', AppGrid.grid92),
      const _SpacingRow('grid96', '6rem', AppGrid.grid96),
      const _SpacingRow('grid100', '6.25rem', AppGrid.grid100),
      const _SpacingRow('grid160', '10rem', AppGrid.grid160),
      const _SpacingRow('grid240', '15rem', AppGrid.grid240),

      _sectionDivider(),

      // Padding
      _subSectionHeader(subs[5]),
      const SizedBox(height: AppGrid.grid12),
      const _SpacingRow('rem0', '0rem', AppPadding.rem0),
      const _SpacingRow('rem025', '0.25rem', AppPadding.rem025),
      const _SpacingRow('rem05', '0.5rem', AppPadding.rem05),
      const _SpacingRow('rem075', '0.75rem', AppPadding.rem075),
      const _SpacingRow('rem1', '1rem', AppPadding.rem1),
      const _SpacingRow('rem15', '1.5rem', AppPadding.rem15),
      const _SpacingRow('rem2', '2rem', AppPadding.rem2),
      const _SpacingRow('rem3', '3rem', AppPadding.rem3),

      _sectionDivider(),

      // Corner Radius
      _subSectionHeader(subs[6]),
      const SizedBox(height: AppGrid.grid12),
      const _RadiusRow('none', AppRadius.none),
      _RadiusRow('sm (0.5rem)', AppRadius.sm),
      _RadiusRow('md (1rem)', AppRadius.md),
      _RadiusRow('lg (1.5rem)', AppRadius.lg),
      _RadiusRow('xl (2.5rem)', AppRadius.xl),
      const _RadiusRow('pill', AppRadius.pill),

      _sectionDivider(),

      // Stroke Widths
      _subSectionHeader(subs[7]),
      const SizedBox(height: AppGrid.grid12),
      const _StrokeRow('xs', AppStroke.xs),
      const _StrokeRow('sm', AppStroke.sm),
      const _StrokeRow('md', AppStroke.md),
      const _StrokeRow('lg', AppStroke.lg),
      const _StrokeRow('xl', AppStroke.xl),
      const _StrokeRow('xxl', AppStroke.xxl),
      const _StrokeRow('ring', AppStroke.ring),
    ];
  }

  // ── Atoms content ──

  List<Widget> _buildAtomsContent() {
    final subs = _sections[1].subSections;
    return [
      // ── PRIMITIVES ──
      _folderGroupHeader('PRIMITIVES'),

      // Text
      _subSectionHeader(subs[0]),
      const SizedBox(height: AppGrid.grid12),

      AppText('COLOR OVERRIDES', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      AppText('Primary (default)', style: AppTypography.body.regular),
      const SizedBox(height: AppGrid.grid4),
      AppText('Secondary', style: AppTypography.body.regular, color: AppColors.textSecondary),
      const SizedBox(height: AppGrid.grid4),
      Container(
        color: AppColors.textPrimary,
        padding: const EdgeInsets.symmetric(horizontal: AppPadding.rem05, vertical: AppPadding.rem025),
        child: AppText('Inverse', style: AppTypography.body.regular, color: AppColors.textInverse),
      ),
      const SizedBox(height: AppGrid.grid4),
      AppText('Brand', style: AppTypography.body.regular, color: AppColors.brand),

      const SizedBox(height: AppGrid.grid24),

      AppText('TRUNCATION', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      SizedBox(
        width: 200,
        child: AppText(
          'This is a long sentence that should be truncated after two lines of text to demonstrate overflow behavior.',
          style: AppTypography.bodySmall.regular,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
        ),
      ),

      const SizedBox(height: AppGrid.grid24),

      AppText('ALIGNMENT', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      SizedBox(
        width: double.infinity,
        child: AppText('Left aligned', style: AppTypography.body.regular, textAlign: TextAlign.left),
      ),
      const SizedBox(height: AppGrid.grid4),
      SizedBox(
        width: double.infinity,
        child: AppText('Center aligned', style: AppTypography.body.regular, textAlign: TextAlign.center),
      ),
      const SizedBox(height: AppGrid.grid4),
      SizedBox(
        width: double.infinity,
        child: AppText('Right aligned', style: AppTypography.body.regular, textAlign: TextAlign.right),
      ),

      const SizedBox(height: AppGrid.grid24),

      AppText('UTILITY STYLES', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      _TypeRow('Caption (11)', AppTypography.caption),
      _TypeRow('Overline (10)', AppTypography.overline),

      _sectionDivider(),

      // Icons
      _subSectionHeader(subs[1]),
      const SizedBox(height: AppGrid.grid12),
      AppText('OUTLINED (${AppIcons.all.length})', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid16,
        children: AppIcons.all.entries.map((e) => SizedBox(
          width: 72,
          child: Column(
            children: [
              AppIcon(e.value, size: IconSizes.lg),
              const SizedBox(height: AppGrid.grid4),
              AppText(
                e.key,
                style: AppTypography.overline.semiBold,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        )).toList(),
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('FILLED (${AppIcons.allFilled.length})', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid16,
        children: AppIcons.allFilled.entries.map((e) => SizedBox(
          width: 72,
          child: Column(
            children: [
              AppIcon(e.value, size: IconSizes.lg),
              const SizedBox(height: AppGrid.grid4),
              AppText(
                e.key,
                style: AppTypography.overline.semiBold,
                textAlign: TextAlign.center,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
              ),
            ],
          ),
        )).toList(),
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('COLOR VARIANTS', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Row(
        children: [
          _IconVariant('White', AppIcons.home, AppColors.textPrimary),
          _IconVariant('Black', AppIcons.home, AppColors.textInverse),
          _IconVariant('Disabled', AppIcons.home, AppColors.grey600),
          _IconVariant('Primary', AppIcons.home, AppColors.brand),
        ],
      ),

      const SizedBox(height: AppGrid.grid16),
      AppText('SIZE VARIANTS', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      Row(
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          _IconSize('sm', AppIcons.home, IconSizes.sm),
          const SizedBox(width: AppGrid.grid24),
          _IconSize('md', AppIcons.home, IconSizes.md),
          const SizedBox(width: AppGrid.grid24),
          _IconSize('lg', AppIcons.home, IconSizes.lg),
          const SizedBox(width: AppGrid.grid24),
          _IconSize('xl', AppIcons.home, IconSizes.xl),
        ],
      ),

      _sectionDivider(),

      // Badges
      _subSectionHeader(subs[2]),
      const SizedBox(height: AppGrid.grid12),

      AppText('VARIANTS', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid8,
        runSpacing: AppGrid.grid8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppBadge(label: 'Text Only'),
          AppBadge(leadingIcon: AppIcons.star, label: 'Icon + Text'),
          AppBadge(leadingIcon: AppIcons.crown),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('FILL STYLES', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid8,
        runSpacing: AppGrid.grid8,
        children: [
          AppBadge(label: 'Filled'),
          AppBadge(label: 'Outline', type: BadgeType.outline),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('COLORS (FILLED)', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid8,
        runSpacing: AppGrid.grid8,
        children: [
          AppBadge(label: 'Orange', color: AppColors.orange500),
          AppBadge(label: 'Blue', color: AppColors.blue500),
          AppBadge(label: 'Red', color: AppColors.red500),
          AppBadge(label: 'Green', color: AppColors.green500),
          AppBadge(label: 'Purple', color: AppColors.purple500),
          AppBadge(label: 'Yellow', color: AppColors.yellow500),
          AppBadge(label: 'Grey', color: AppColors.grey500),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('COLORS (OUTLINE)', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid8,
        runSpacing: AppGrid.grid8,
        children: [
          AppBadge(label: 'Orange', type: BadgeType.outline, color: AppColors.orange500),
          AppBadge(label: 'Blue', type: BadgeType.outline, color: AppColors.blue500),
          AppBadge(label: 'Red', type: BadgeType.outline, color: AppColors.red500),
          AppBadge(label: 'Green', type: BadgeType.outline, color: AppColors.green500),
          AppBadge(label: 'Purple', type: BadgeType.outline, color: AppColors.purple500),
          AppBadge(label: 'Yellow', type: BadgeType.outline, color: AppColors.yellow500),
          AppBadge(label: 'Grey', type: BadgeType.outline, color: AppColors.grey500),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('SIZES', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid8,
        runSpacing: AppGrid.grid8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppBadge(label: 'XS', size: BadgeSize.xs),
          AppBadge(label: 'Small', size: BadgeSize.sm),
          AppBadge(label: 'Medium', size: BadgeSize.md),
          AppBadge(label: 'Large', size: BadgeSize.lg),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('ICON SLOTS', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid8,
        runSpacing: AppGrid.grid8,
        children: [
          AppBadge(leadingIcon: AppIcons.star, label: 'Leading'),
          AppBadge(label: 'Trailing', trailingIcon: AppIcons.close),
          AppBadge(leadingIcon: AppIcons.star, label: 'Both', trailingIcon: AppIcons.close),
        ],
      ),

      _sectionDivider(),

      // Score Badge
      _subSectionHeader(subs[3]),
      const SizedBox(height: AppGrid.grid12),

      AppText('VARIANTS', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      Row(
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScoreBadge(score: 3.5, underlineColor: AppColors.brand),
              const SizedBox(height: AppGrid.grid4),
              AppText('urgent', style: AppTypography.caption.bold, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(width: AppGrid.grid24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScoreBadge(score: 8.2, underlineColor: AppColors.textPrimary),
              const SizedBox(height: AppGrid.grid4),
              AppText('pending review', style: AppTypography.caption.bold, color: AppColors.textSecondary),
            ],
          ),
          const SizedBox(width: AppGrid.grid24),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              const ScoreBadge(score: 4.6, underlineColor: AppColors.surfaceBorder),
              const SizedBox(height: AppGrid.grid4),
              AppText('reviewed', style: AppTypography.caption.bold, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),

      _sectionDivider(),

      // Avatars
      _subSectionHeader(subs[4]),
      const SizedBox(height: AppGrid.grid12),

      AppText('SIZES', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppAvatar(content: AvatarInitials('XS'), size: AvatarSize.xs),
          AppAvatar(content: AvatarInitials('SM'), size: AvatarSize.sm),
          AppAvatar(content: AvatarInitials('MD'), size: AvatarSize.md),
          AppAvatar(content: AvatarInitials('LG'), size: AvatarSize.lg),
          AppAvatar(content: AvatarInitials('XL'), size: AvatarSize.xl),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('CONTENT TYPES', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppAvatar(content: AvatarImage(AssetImage('assets/images/avatar_placeholder.png'))),
          AppAvatar(content: AvatarInitials('TP')),
          AppAvatar(),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('STATES', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppAvatar(content: AvatarInitials('LD'), isLoading: true),
          AppAvatar(content: AvatarInitials('DI'), isDisabled: true),
          AppAvatar(
            content: AvatarInitials('LD'),
            size: AvatarSize.lg,
            isLoading: true,
          ),
        ],
      ),


      // ── CONTROLS ──
      _folderGroupHeader('CONTROLS'),

      // Buttons
      _subSectionHeader(subs[5]),
      const SizedBox(height: AppGrid.grid12),

      AppText('TYPES', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid8,
        runSpacing: AppGrid.grid8,
        children: [
          AppButton(label: 'Filled', type: ButtonType.filled),
          AppButton(label: 'Outline', type: ButtonType.outline),
          AppButton(label: 'Ghost', type: ButtonType.ghost),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('COLORS (FILLED)', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid8,
        runSpacing: AppGrid.grid8,
        children: [
          AppButton(label: 'Brand', color: AppColors.brand),
          AppButton(label: 'White', color: AppColors.textPrimary),
          AppButton(label: 'Error', color: AppColors.error),
          AppButton(label: 'Info', color: AppColors.info),
          AppButton(label: 'Success', color: AppColors.success),
        ],
      ),

      const SizedBox(height: AppGrid.grid16),
      AppText('COLORS (OUTLINE)', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid8,
        runSpacing: AppGrid.grid8,
        children: [
          AppButton(label: 'Brand', type: ButtonType.outline, color: AppColors.brand),
          AppButton(label: 'White', type: ButtonType.outline, color: AppColors.textPrimary),
          AppButton(label: 'Error', type: ButtonType.outline, color: AppColors.error),
          AppButton(label: 'Info', type: ButtonType.outline, color: AppColors.info),
          AppButton(label: 'Success', type: ButtonType.outline, color: AppColors.success),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('SIZES', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid8,
        runSpacing: AppGrid.grid8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppButton(label: 'Small', size: ButtonSize.sm),
          AppButton(label: 'Medium', size: ButtonSize.md),
          AppButton(label: 'Large', size: ButtonSize.lg),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('CONTENT PATTERNS', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid8,
        runSpacing: AppGrid.grid8,
        children: [
          AppButton(label: 'Text only'),
          AppButton(leadingIcon: AppIcons.add),
          AppButton(leadingIcon: AppIcons.add, label: 'Leading'),
          AppButton(label: 'Trailing', trailingIcon: AppIcons.arrowRight),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('STATES', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid8,
        runSpacing: AppGrid.grid8,
        children: [
          AppButton(label: 'Default'),
          AppButton(label: 'Active', isActive: true),
          AppButton(label: 'Disabled', isDisabled: true),
          AppButton(label: 'Loading', isLoading: true),
          AppButton(label: 'Outline', type: ButtonType.outline),
          AppButton(label: 'Outline Active', type: ButtonType.outline, isActive: true),
        ],
      ),
      const SizedBox(height: AppGrid.grid24),
      AppText('TOGGLE DEMO', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const AppButton(label: 'Toggle Me', selfToggle: true),

      _sectionDivider(),

      // Checkboxes
      _subSectionHeader(subs[6]),
      const SizedBox(height: AppGrid.grid12),

      AppText('STATES', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid8,
        children: [
          AppCheckbox(selfToggle: true),
          AppCheckbox(selected: true),
          AppCheckbox(isIndeterminate: true),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('SIZES', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppCheckbox(selected: true, size: CheckboxSize.sm),
          AppCheckbox(selected: true, size: CheckboxSize.md),
          AppCheckbox(selected: true, size: CheckboxSize.lg),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('COLORS', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid8,
        children: [
          AppCheckbox(selected: true, color: AppColors.brand),
          AppCheckbox(selected: true, color: AppColors.error),
          AppCheckbox(selected: true, color: AppColors.success),
          AppCheckbox(selected: true, color: AppColors.info),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('DISABLED', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid8,
        children: [
          AppCheckbox(selected: false, isDisabled: true),
          AppCheckbox(selected: true, isDisabled: true),
          AppCheckbox(isIndeterminate: true, isDisabled: true),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('WITH LABEL (EXTERNAL COMPOSITION)', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      Row(
        children: [
          const AppCheckbox(selfToggle: true),
          const SizedBox(width: AppGrid.grid8),
          AppText('Checkbox text', style: AppTypography.body.regular),
        ],
      ),

      _sectionDivider(),

      // Toggles
      _subSectionHeader(subs[7]),
      const SizedBox(height: AppGrid.grid12),

      AppText('STATES', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppToggle(selfToggle: true),
          AppToggle(value: true),
          AppToggle(value: false),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('SIZES', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppToggle(value: true, size: ToggleSize.sm),
          AppToggle(value: true, size: ToggleSize.md),
          AppToggle(value: true, size: ToggleSize.lg),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('COLORS', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid8,
        children: [
          AppToggle(value: true, color: AppColors.brand),
          AppToggle(value: true, color: AppColors.error),
          AppToggle(value: true, color: AppColors.success),
          AppToggle(value: true, color: AppColors.info),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('DISABLED', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid8,
        children: [
          AppToggle(value: false, isDisabled: true),
          AppToggle(value: true, isDisabled: true),
        ],
      ),

      _sectionDivider(),

      // Radios
      _subSectionHeader(subs[8]),
      const SizedBox(height: AppGrid.grid12),

      AppText('STATES', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppRadio(selfToggle: true),
          AppRadio(selected: true),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('SIZES', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppRadio(selected: true, size: RadioSize.sm),
          AppRadio(selected: true, size: RadioSize.md),
          AppRadio(selected: true, size: RadioSize.lg),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('COLORS', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid8,
        children: [
          AppRadio(selected: true, color: AppColors.brand),
          AppRadio(selected: true, color: AppColors.error),
          AppRadio(selected: true, color: AppColors.success),
          AppRadio(selected: true, color: AppColors.info),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('DISABLED', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid8,
        children: [
          AppRadio(selected: false, isDisabled: true),
          AppRadio(selected: true, isDisabled: true),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('WITH LABEL (EXTERNAL COMPOSITION)', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      Row(
        children: [
          const AppRadio(selfToggle: true),
          const SizedBox(width: AppGrid.grid8),
          AppText('Radio text', style: AppTypography.body.regular),
        ],
      ),

      _sectionDivider(),

      // Nav Bar Item
      _subSectionHeader(subs[9]),
      const SizedBox(height: AppGrid.grid12),

      AppText('STATES', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      Wrap(
        spacing: AppGrid.grid24,
        runSpacing: AppGrid.grid16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Column(children: [
            NavBarItem(iconPath: AppIcons.group, state: NavBarItemState.active, onTap: () {}),
            const SizedBox(height: AppGrid.grid8),
            AppText('clients — active', style: AppTypography.caption.bold, color: AppColors.textSecondary),
          ]),
          Column(children: [
            NavBarItem(iconPath: AppIcons.group, state: NavBarItemState.inactive, onTap: () {}),
            const SizedBox(height: AppGrid.grid8),
            AppText('clients — inactive', style: AppTypography.caption.bold, color: AppColors.textSecondary),
          ]),
          Column(children: [
            NavBarItem(iconPath: AppIcons.body, state: NavBarItemState.active, onTap: () {}),
            const SizedBox(height: AppGrid.grid8),
            AppText('workouts — active', style: AppTypography.caption.bold, color: AppColors.textSecondary),
          ]),
          Column(children: [
            NavBarItem(iconPath: AppIcons.body, state: NavBarItemState.inactive, onTap: () {}),
            const SizedBox(height: AppGrid.grid8),
            AppText('workouts — inactive', style: AppTypography.caption.bold, color: AppColors.textSecondary),
          ]),
          Column(children: [
            NavBarItem(iconPath: AppIcons.profile, state: NavBarItemState.active, onTap: () {}),
            const SizedBox(height: AppGrid.grid8),
            AppText('profile — active', style: AppTypography.caption.bold, color: AppColors.textSecondary),
          ]),
          Column(children: [
            NavBarItem(iconPath: AppIcons.profile, state: NavBarItemState.inactive, onTap: () {}),
            const SizedBox(height: AppGrid.grid8),
            AppText('profile — inactive', style: AppTypography.caption.bold, color: AppColors.textSecondary),
          ]),
        ],
      ),

      // ── INPUTS ──
      _folderGroupHeader('INPUTS'),

      // Text Fields
      _subSectionHeader(subs[10]),
      const SizedBox(height: AppGrid.grid12),

      AppText('DEFAULT', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      AppTextField(controller: _textFieldDefault, hintText: 'Text box...'),

      const SizedBox(height: AppGrid.grid24),
      AppText('WITH VALUE', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      AppTextField(controller: _textFieldValue),

      const SizedBox(height: AppGrid.grid24),
      AppText('PASSWORD', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      AppTextField(controller: _textFieldPassword, hintText: 'Enter password...', obscureText: true),


      // ── PATH ──
      _folderGroupHeader('PATH'),

      // Path Buttons
      _subSectionHeader(subs[11]),
      const SizedBox(height: AppGrid.grid12),

      AppText('ACTIVE (TAP TO STOP PULSE)', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppPathButton(
            shape: PathButtonShape.circle,
            state: PathButtonState.active,
            icon: AppIcons.crownFilled,
            segments: [
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.current),
              PathButtonSegment(status: SegmentStatus.upcoming),
            ],
          ),
          AppPathButton(
            shape: PathButtonShape.triangle,
            state: PathButtonState.active,
            icon: AppIcons.starFilled,
            segments: [
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.current),
              PathButtonSegment(status: SegmentStatus.upcoming),
            ],
          ),
          AppPathButton(
            shape: PathButtonShape.roundedSquare,
            state: PathButtonState.active,
            icon: AppIcons.trophyFilled,
            segments: [
              PathButtonSegment(status: SegmentStatus.current),
              PathButtonSegment(status: SegmentStatus.upcoming),
              PathButtonSegment(status: SegmentStatus.upcoming),
              PathButtonSegment(status: SegmentStatus.upcoming),
              PathButtonSegment(status: SegmentStatus.upcoming),
            ],
          ),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('COMPLETED (MIXED SEGMENTS)', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppPathButton(
            shape: PathButtonShape.circle,
            state: PathButtonState.completed,
            icon: AppIcons.crownFilled,
            segments: [
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.completed),
            ],
          ),
          AppPathButton(
            shape: PathButtonShape.triangle,
            state: PathButtonState.completed,
            icon: AppIcons.starFilled,
            segments: [
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.upcoming),
              PathButtonSegment(status: SegmentStatus.upcoming),
            ],
          ),
          AppPathButton(
            shape: PathButtonShape.roundedSquare,
            state: PathButtonState.completed,
            icon: AppIcons.trophyFilled,
            segments: [
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.upcoming),
            ],
          ),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('LOCKED', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppPathButton(
            shape: PathButtonShape.circle,
            state: PathButtonState.locked,
            icon: AppIcons.crownFilled,
            segments: [
              PathButtonSegment(status: SegmentStatus.upcoming),
              PathButtonSegment(status: SegmentStatus.upcoming),
              PathButtonSegment(status: SegmentStatus.upcoming),
            ],
          ),
          AppPathButton(
            shape: PathButtonShape.triangle,
            state: PathButtonState.locked,
            icon: AppIcons.starFilled,
            segments: [
              PathButtonSegment(status: SegmentStatus.upcoming),
              PathButtonSegment(status: SegmentStatus.upcoming),
            ],
          ),
          AppPathButton(
            shape: PathButtonShape.roundedSquare,
            state: PathButtonState.locked,
            icon: AppIcons.trophyFilled,
            segments: [
              PathButtonSegment(status: SegmentStatus.upcoming),
              PathButtonSegment(status: SegmentStatus.upcoming),
              PathButtonSegment(status: SegmentStatus.upcoming),
              PathButtonSegment(status: SegmentStatus.upcoming),
            ],
          ),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('SEGMENT COUNTS (1–5)', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          AppPathButton(
            shape: PathButtonShape.circle,
            state: PathButtonState.completed,
            icon: AppIcons.medal,
            segments: [
              PathButtonSegment(status: SegmentStatus.completed),
            ],
          ),
          AppPathButton(
            shape: PathButtonShape.circle,
            state: PathButtonState.completed,
            icon: AppIcons.medal,
            segments: [
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.upcoming),
            ],
          ),
          AppPathButton(
            shape: PathButtonShape.circle,
            state: PathButtonState.completed,
            icon: AppIcons.medal,
            segments: [
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.upcoming),
            ],
          ),
          AppPathButton(
            shape: PathButtonShape.circle,
            state: PathButtonState.completed,
            icon: AppIcons.medal,
            segments: [
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.upcoming),
            ],
          ),
          AppPathButton(
            shape: PathButtonShape.circle,
            state: PathButtonState.completed,
            icon: AppIcons.medal,
            segments: [
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.upcoming),
            ],
          ),
        ],
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('COLORS (CYCLING SHAPES)', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid8,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          // Orange — circle, active
          AppPathButton(
            shape: PathButtonShape.circle,
            state: PathButtonState.active,
            icon: AppIcons.crownFilled,
            color: AppColors.orange500,
            segments: [
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.current),
              PathButtonSegment(status: SegmentStatus.upcoming),
            ],
          ),
          // Red — triangle, active
          AppPathButton(
            shape: PathButtonShape.triangle,
            state: PathButtonState.active,
            icon: AppIcons.starFilled,
            color: AppColors.red500,
            segments: [
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.current),
              PathButtonSegment(status: SegmentStatus.upcoming),
            ],
          ),
          // Blue — square, active
          AppPathButton(
            shape: PathButtonShape.roundedSquare,
            state: PathButtonState.active,
            icon: AppIcons.trophyFilled,
            color: AppColors.blue500,
            segments: [
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.current),
              PathButtonSegment(status: SegmentStatus.upcoming),
            ],
          ),
          // Green — circle, completed
          AppPathButton(
            shape: PathButtonShape.circle,
            state: PathButtonState.completed,
            icon: AppIcons.crownFilled,
            color: AppColors.green500,
            segments: [
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.completed),
            ],
          ),
          // Yellow — triangle, completed
          AppPathButton(
            shape: PathButtonShape.triangle,
            state: PathButtonState.completed,
            icon: AppIcons.starFilled,
            color: AppColors.yellow500,
            segments: [
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.upcoming),
            ],
          ),
          // Purple — square, completed
          AppPathButton(
            shape: PathButtonShape.roundedSquare,
            state: PathButtonState.completed,
            icon: AppIcons.trophyFilled,
            color: AppColors.purple500,
            segments: [
              PathButtonSegment(status: SegmentStatus.completed),
              PathButtonSegment(status: SegmentStatus.upcoming),
            ],
          ),
          // Orange — triangle, locked
          AppPathButton(
            shape: PathButtonShape.triangle,
            state: PathButtonState.locked,
            icon: AppIcons.starFilled,
            color: AppColors.orange500,
            segments: [
              PathButtonSegment(status: SegmentStatus.upcoming),
              PathButtonSegment(status: SegmentStatus.upcoming),
              PathButtonSegment(status: SegmentStatus.upcoming),
            ],
          ),
          // Red — square, locked
          AppPathButton(
            shape: PathButtonShape.roundedSquare,
            state: PathButtonState.locked,
            icon: AppIcons.trophyFilled,
            color: AppColors.red500,
            segments: [
              PathButtonSegment(status: SegmentStatus.upcoming),
              PathButtonSegment(status: SegmentStatus.upcoming),
            ],
          ),
          // Blue — circle, locked
          AppPathButton(
            shape: PathButtonShape.circle,
            state: PathButtonState.locked,
            icon: AppIcons.crownFilled,
            color: AppColors.blue500,
            segments: [
              PathButtonSegment(status: SegmentStatus.upcoming),
              PathButtonSegment(status: SegmentStatus.upcoming),
              PathButtonSegment(status: SegmentStatus.upcoming),
              PathButtonSegment(status: SegmentStatus.upcoming),
            ],
          ),
        ],
      ),


      // ── BEHAVIORS ──
      _folderGroupHeader('BEHAVIORS'),

      // Pressable Surface
      _subSectionHeader(subs[12]),
      const SizedBox(height: AppGrid.grid12),

      AppText('VARIANTS', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid16,
        children: [
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PressableSurface(
                backgroundColor: AppColors.surface,
                borderColor: AppColors.brand,
                borderRadius: AppRadius.md,
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(AppGrid.grid16),
                  child: AppText('Press me', style: AppTypography.body.bold),
                ),
              ),
              const SizedBox(height: AppGrid.grid4),
              AppText('brand border', style: AppTypography.caption.bold, color: AppColors.textSecondary),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PressableSurface(
                backgroundColor: AppColors.surface,
                borderColor: AppColors.textPrimary,
                borderRadius: AppRadius.md,
                onTap: () {},
                child: Padding(
                  padding: const EdgeInsets.all(AppGrid.grid16),
                  child: AppText('Press me', style: AppTypography.body.bold),
                ),
              ),
              const SizedBox(height: AppGrid.grid4),
              AppText('white border', style: AppTypography.caption.bold, color: AppColors.textSecondary),
            ],
          ),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              PressableSurface(
                backgroundColor: AppColors.surface,
                borderColor: AppColors.surfaceBorder,
                borderRadius: AppRadius.md,
                isInteractive: false,
                child: Padding(
                  padding: const EdgeInsets.all(AppGrid.grid16),
                  child: AppText('Not interactive', style: AppTypography.body.bold),
                ),
              ),
              const SizedBox(height: AppGrid.grid4),
              AppText('isInteractive: false', style: AppTypography.caption.bold, color: AppColors.textSecondary),
            ],
          ),
        ],
      ),


      // ── PLAYGROUND ──
      _folderGroupHeader('PLAYGROUND'),

      // Button Playground (collapsed by default)
      _CollapsibleSubsection(
        sub: subs[13],
        child: const _ButtonPlayground(),
      ),
    ];
  }

  // ── Molecules content ──

  List<Widget> _buildMoleculesContent() {
    final subs = _sections[2].subSections;
    return [
      // ── FORM FIELDS ──
      _folderGroupHeader('FORM FIELDS'),

      // ── Text Fields ──
      _subSectionHeader(subs[0]),
      const SizedBox(height: AppGrid.grid12),

      AppText('STATES', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      SizedBox(
        width: 300,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppTextFieldMolecule(
            controller: controller,
            focusNode: focusNode,
            label: 'Default',
            hintText: 'Text box...',
          ),
        ),
      ),
      const SizedBox(height: AppGrid.grid16),
      SizedBox(
        width: 300,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppTextFieldMolecule(
            controller: controller,
            focusNode: focusNode,
            label: 'Focused',
            hintText: 'Text box...',
            state: FieldState.focused,
          ),
        ),
      ),
      const SizedBox(height: AppGrid.grid16),
      SizedBox(
        width: 300,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppTextFieldMolecule(
            controller: controller,
            focusNode: focusNode,
            label: 'Error',
            hintText: 'Text box...',
            helperText: 'Something went wrong',
            state: FieldState.error,
          ),
        ),
      ),
      const SizedBox(height: AppGrid.grid16),
      SizedBox(
        width: 300,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppTextFieldMolecule(
            controller: controller,
            focusNode: focusNode,
            label: 'Success',
            hintText: 'Text box...',
            helperText: 'Looks good!',
            state: FieldState.success,
          ),
        ),
      ),
      const SizedBox(height: AppGrid.grid16),
      SizedBox(
        width: 300,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppTextFieldMolecule(
            controller: controller,
            focusNode: focusNode,
            label: 'Disabled',
            hintText: 'Text box...',
            state: FieldState.disabled,
          ),
        ),
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('WITH HELPER TEXT', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      SizedBox(
        width: 300,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppTextFieldMolecule(
            controller: controller,
            focusNode: focusNode,
            label: 'Title for text box',
            hintText: 'Text box...',
            helperText: 'Helper Text',
          ),
        ),
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('WITH LEADING ICON', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      SizedBox(
        width: 300,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppTextFieldMolecule(
            controller: controller,
            focusNode: focusNode,
            label: 'With icon',
            hintText: 'Search items...',
            leadingIcon: AppIcons.search,
          ),
        ),
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('WITH CHARACTER COUNT', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      SizedBox(
        width: 300,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppTextFieldMolecule(
            controller: controller,
            focusNode: focusNode,
            label: 'Username',
            hintText: 'Enter username...',
            helperText: 'Helper Text',
            maxLength: 20,
          ),
        ),
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('CARD / 3D', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      SizedBox(
        width: 300,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppTextFieldMolecule(
            controller: controller,
            focusNode: focusNode,
            label: 'Default',
            hintText: 'Text box...',
            variant: InputVariant.card,
          ),
        ),
      ),
      const SizedBox(height: AppGrid.grid16),
      SizedBox(
        width: 300,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppTextFieldMolecule(
            controller: controller,
            focusNode: focusNode,
            label: 'Error',
            hintText: 'Text box...',
            helperText: 'Something went wrong',
            state: FieldState.error,
            variant: InputVariant.card,
          ),
        ),
      ),
      const SizedBox(height: AppGrid.grid16),
      SizedBox(
        width: 300,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppTextFieldMolecule(
            controller: controller,
            focusNode: focusNode,
            label: 'Disabled',
            hintText: 'Text box...',
            state: FieldState.disabled,
            variant: InputVariant.card,
          ),
        ),
      ),

      _sectionDivider(),

      // ── Password Fields ──
      _subSectionHeader(subs[1]),
      const SizedBox(height: AppGrid.grid12),

      AppText('STATES', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      SizedBox(
        width: 300,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppPasswordField(
            controller: controller,
            focusNode: focusNode,
            label: 'Password',
            hintText: 'Password text',
            helperText: 'Helper Text',
            minLength: 7,
          ),
        ),
      ),
      const SizedBox(height: AppGrid.grid16),
      SizedBox(
        width: 300,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppPasswordField(
            controller: controller,
            focusNode: focusNode,
            label: 'Password',
            hintText: 'Password text',
            helperText: 'Helper Text',
            minLength: 7,
            state: FieldState.focused,
          ),
        ),
      ),
      const SizedBox(height: AppGrid.grid16),
      SizedBox(
        width: 300,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppPasswordField(
            controller: controller,
            focusNode: focusNode,
            label: 'Password',
            hintText: 'Password text',
            helperText: 'Helper Text',
            minLength: 7,
            state: FieldState.error,
          ),
        ),
      ),
      const SizedBox(height: AppGrid.grid16),
      SizedBox(
        width: 300,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppPasswordField(
            controller: controller,
            focusNode: focusNode,
            label: 'Password',
            hintText: 'Password text',
            helperText: 'Helper Text',
            minLength: 7,
            state: FieldState.success,
          ),
        ),
      ),
      const SizedBox(height: AppGrid.grid16),
      SizedBox(
        width: 300,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppPasswordField(
            controller: controller,
            focusNode: focusNode,
            label: 'Password',
            hintText: 'Password text',
            helperText: 'Helper Text',
            minLength: 7,
            state: FieldState.disabled,
          ),
        ),
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('CARD / 3D', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      SizedBox(
        width: 300,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppPasswordField(
            controller: controller,
            focusNode: focusNode,
            label: 'Password',
            hintText: 'Password text',
            helperText: 'Helper Text',
            minLength: 7,
            variant: InputVariant.card,
          ),
        ),
      ),
      const SizedBox(height: AppGrid.grid16),
      SizedBox(
        width: 300,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppPasswordField(
            controller: controller,
            focusNode: focusNode,
            label: 'Password',
            hintText: 'Password text',
            helperText: 'Something went wrong',
            minLength: 7,
            state: FieldState.error,
            variant: InputVariant.card,
          ),
        ),
      ),

      _sectionDivider(),

      // ── Text Areas ──
      _subSectionHeader(subs[2]),
      const SizedBox(height: AppGrid.grid12),

      AppText('FIXED HEIGHT', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      SizedBox(
        width: 400,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppTextArea(
            controller: controller,
            focusNode: focusNode,
            label: 'Description',
            hintText: 'Enter a description...',
            helperText: 'Max 200 characters',
            maxLength: 200,
            maxLines: 4,
          ),
        ),
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('AUTO-GROW', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      SizedBox(
        width: 400,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppTextArea(
            controller: controller,
            focusNode: focusNode,
            label: 'Notes',
            hintText: 'Start typing...',
            helperText: 'Grows as you type',
            autoGrow: true,
            minLines: 2,
            maxLines: 8,
          ),
        ),
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('ERROR STATE', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      SizedBox(
        width: 400,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppTextArea(
            controller: controller,
            focusNode: focusNode,
            label: 'Description',
            hintText: 'Enter a description...',
            helperText: 'This field is required',
            state: FieldState.error,
          ),
        ),
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('CARD / 3D', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      SizedBox(
        width: 400,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppTextArea(
            controller: controller,
            focusNode: focusNode,
            label: 'Description',
            hintText: 'Enter a description...',
            helperText: 'Max 200 characters',
            maxLength: 200,
            maxLines: 4,
            variant: InputVariant.card,
          ),
        ),
      ),
      const SizedBox(height: AppGrid.grid16),
      SizedBox(
        width: 400,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppTextArea(
            controller: controller,
            focusNode: focusNode,
            label: 'Notes',
            hintText: 'Start typing...',
            helperText: 'Grows as you type',
            autoGrow: true,
            minLines: 2,
            maxLines: 8,
            variant: InputVariant.card,
          ),
        ),
      ),

      _sectionDivider(),

      // ── Number Fields ──
      _subSectionHeader(subs[3]),
      const SizedBox(height: AppGrid.grid12),

      AppText('INSIDE (DEFAULT)', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      SizedBox(
        width: 200,
        child: _CatalogInputDemo(
          initialText: '1',
          builder: (controller, focusNode) => AppNumberField(
            controller: controller,
            focusNode: focusNode,
            label: 'Quantity',
            hintText: '0',
            min: 0,
            max: 99,
          ),
        ),
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('OUTSIDE', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      SizedBox(
        width: 280,
        child: _CatalogInputDemo(
          initialText: '1',
          builder: (controller, focusNode) => AppNumberField(
            controller: controller,
            focusNode: focusNode,
            label: 'Quantity',
            hintText: '0',
            min: 0,
            max: 99,
            stepperLayout: StepperLayout.outside,
          ),
        ),
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('WITH HELPER TEXT', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      SizedBox(
        width: 200,
        child: _CatalogInputDemo(
          initialText: '2',
          builder: (controller, focusNode) => AppNumberField(
            controller: controller,
            focusNode: focusNode,
            label: 'Players',
            hintText: '0',
            helperText: 'Min 2, Max 8',
            min: 2,
            max: 8,
          ),
        ),
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('DISABLED', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      SizedBox(
        width: 200,
        child: _CatalogInputDemo(
          initialText: '5',
          builder: (controller, focusNode) => AppNumberField(
            controller: controller,
            focusNode: focusNode,
            label: 'Quantity',
            hintText: '0',
            state: FieldState.disabled,
          ),
        ),
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('CARD / 3D — INSIDE', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      SizedBox(
        width: 200,
        child: _CatalogInputDemo(
          initialText: '1',
          builder: (controller, focusNode) => AppNumberField(
            controller: controller,
            focusNode: focusNode,
            label: 'Quantity',
            hintText: '0',
            min: 0,
            max: 99,
            variant: InputVariant.card,
          ),
        ),
      ),
      const SizedBox(height: AppGrid.grid24),
      AppText('CARD / 3D — OUTSIDE', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      SizedBox(
        width: 280,
        child: _CatalogInputDemo(
          initialText: '1',
          builder: (controller, focusNode) => AppNumberField(
            controller: controller,
            focusNode: focusNode,
            label: 'Quantity',
            hintText: '0',
            min: 0,
            max: 99,
            stepperLayout: StepperLayout.outside,
            variant: InputVariant.card,
          ),
        ),
      ),

      _sectionDivider(),

      // ── Search Bar ──
      _subSectionHeader(subs[4]),
      const SizedBox(height: AppGrid.grid12),

      AppText('PILL / DEFAULT', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      SizedBox(
        width: 300,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppSearchBar(
            controller: controller,
            focusNode: focusNode,
            hintText: 'Search Bar...',
          ),
        ),
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('PILL / WITH VALUE', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      SizedBox(
        width: 300,
        child: _CatalogInputDemo(
          initialText: 'Flutter',
          builder: (controller, focusNode) => AppSearchBar(
            controller: controller,
            focusNode: focusNode,
            hintText: 'Search bar',
          ),
        ),
      ),

      const SizedBox(height: AppGrid.grid24),
      AppText('CARD / 3D', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      SizedBox(
        width: 300,
        child: _CatalogInputDemo(
          builder: (controller, focusNode) => AppSearchBar(
            controller: controller,
            focusNode: focusNode,
            hintText: 'Search...',
            variant: SearchBarVariant.card,
          ),
        ),
      ),

      // ── DISPLAY ──
      _folderGroupHeader('DISPLAY'),

      // ── Section Header ──
      _subSectionHeader(subs[5]),
      const SizedBox(height: AppGrid.grid12),

      AppText('VARIANTS', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const SectionHeader(label: 'Current clients', count: '17/30'),
      const SizedBox(height: AppGrid.grid16),
      const SectionHeader(label: 'All clients', count: '130'),
      const SizedBox(height: AppGrid.grid16),
      const SectionHeader(label: 'Current clients', count: '0/30'),

      _sectionDivider(),

      // ── Icon Text Action ──
      _subSectionHeader(subs[6]),
      const SizedBox(height: AppGrid.grid12),

      AppText('DEFAULT', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      IconTextAction(
        iconPath: AppIcons.add,
        label: 'Add Clients',
        onTap: () {},
      ),

      // ── CARDS ──
      _folderGroupHeader('CARDS'),

      // ── Current Client Card ──
      _subSectionHeader(subs[7]),
      const SizedBox(height: AppGrid.grid12),

      AppText('VARIANTS', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          children: [
            CurrentClientCard(
              clientName: 'Ryan Levin',
              lastSessionText: 'Last Session: 1 day ago',
              score: 3.9,
              status: ReviewStatus.urgent,
              onTap: () {},
            ),
            const SizedBox(height: AppGrid.grid12),
            CurrentClientCard(
              clientName: 'Gretchen Mango',
              lastSessionText: 'Last Session: 8 days ago',
              score: 8.2,
              status: ReviewStatus.pendingReview,
              onTap: () {},
            ),
            const SizedBox(height: AppGrid.grid12),
            CurrentClientCard(
              clientName: 'Dulce Franci',
              lastSessionText: 'Last Session: 1 day ago',
              score: 4.6,
              status: ReviewStatus.reviewed,
              onTap: () {},
            ),
          ],
        ),
      ),

      _sectionDivider(),

      // ── All Client Card ──
      _subSectionHeader(subs[8]),
      const SizedBox(height: AppGrid.grid12),

      AppText('VARIANTS', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 360),
        child: Column(
          children: [
            AllClientCard(
              clientName: 'Charlie Vetrovs',
              email: 'charlie@example.com',
              state: AllClientCardState.add,
              onTap: () {},
              onAction: () {},
            ),
            const SizedBox(height: AppGrid.grid12),
            AllClientCard(
              clientName: 'Charlie Vetrovs',
              email: 'charlie@example.com',
              state: AllClientCardState.remove,
              onTap: () {},
              onAction: () {},
            ),
            const SizedBox(height: AppGrid.grid12),
            AllClientCard(
              clientName: 'Charlie Vetrovs',
              email: 'charlie@example.com',
              state: AllClientCardState.rosterFull,
              onTap: () {},
              onAction: () {},
            ),
          ],
        ),
      ),

      // ── CONTROLS ──
      _folderGroupHeader('CONTROLS'),

      // ── Labeled Checkbox ──
      _subSectionHeader(subs[9]),
      const SizedBox(height: AppGrid.grid12),

      AppText('STATES', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      StatefulBuilder(
        builder: (context, setState) {
          bool checked1 = true;
          bool checked2 = false;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              LabeledCheckbox(
                label: 'Checked',
                isChecked: checked1,
                onChanged: (v) => setState(() => checked1 = v),
              ),
              const SizedBox(height: AppGrid.grid12),
              LabeledCheckbox(
                label: 'Unchecked',
                isChecked: checked2,
                onChanged: (v) => setState(() => checked2 = v),
              ),
              const SizedBox(height: AppGrid.grid12),
              LabeledCheckbox(
                label: 'Long label — this text wraps within the available width to show Expanded behavior',
                isChecked: false,
                onChanged: (_) {},
              ),
            ],
          );
        },
      ),

      _sectionDivider(),

      // ── Filter Button ──
      _subSectionHeader(subs[10]),
      const SizedBox(height: AppGrid.grid12),

      AppText('STATES', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      Wrap(
        spacing: AppGrid.grid16,
        runSpacing: AppGrid.grid16,
        crossAxisAlignment: WrapCrossAlignment.center,
        children: [
          Column(children: [
            FilterButton(state: FilterButtonState.idle, onTap: () {}),
            const SizedBox(height: AppGrid.grid8),
            AppText('idle', style: AppTypography.caption.bold, color: AppColors.textSecondary),
          ]),
          Column(children: [
            FilterButton(state: FilterButtonState.open, onTap: () {}),
            const SizedBox(height: AppGrid.grid8),
            AppText('open', style: AppTypography.caption.bold, color: AppColors.textSecondary),
          ]),
          Column(children: [
            FilterButton(state: FilterButtonState.sorted, onTap: () {}),
            const SizedBox(height: AppGrid.grid8),
            AppText('sorted', style: AppTypography.caption.bold, color: AppColors.textSecondary),
          ]),
        ],
      ),

      // ── NAVIGATION ──
      _folderGroupHeader('NAVIGATION'),

      // ── Practitioner Nav Bar ──
      _subSectionHeader(subs[11]),
      const SizedBox(height: AppGrid.grid12),

      AppText('TABS', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      StatefulBuilder(
        builder: (context, setState) {
          PractitionerTab selected = PractitionerTab.clients;
          return Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              PractitionerNavBar(
                selectedTab: selected,
                onTabSelected: (tab) => setState(() => selected = tab),
              ),
              const SizedBox(height: AppGrid.grid8),
              AppText(
                'Selected: ${selected.name}',
                style: AppTypography.caption.bold,
                color: AppColors.textSecondary,
              ),
            ],
          );
        },
      ),
    ];
  }

  // ── Organisms content ──

  List<Widget> _buildOrganismsContent() {
    final subs = _sections[3].subSections;
    return [
      // ── CLIENT LIST ──
      _folderGroupHeader('CLIENT LIST'),

      // ── Client List ──
      _subSectionHeader(subs[0]),
      const SizedBox(height: AppGrid.grid12),
      AppText('INTERACTIVE', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      const _ClientListCatalog(),

      // ── SORT ──
      _folderGroupHeader('SORT'),

      // ── Sort Panel ──
      _subSectionHeader(subs[1]),
      const SizedBox(height: AppGrid.grid12),

      AppText('STATES', style: AppTypography.overline.semiBold),
      const SizedBox(height: AppGrid.grid8),
      ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 320),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SortPanel(
              selectedSorts: _sortPanelSorts,
              onSortChanged: (updated) => setState(() => _sortPanelSorts = updated),
              onClearAll: () => setState(() => _sortPanelSorts = {}),
            ),
            const SizedBox(height: AppGrid.grid8),
            AppText(
              'Active: ${_sortPanelSorts.entries.where((e) => e.value != null).map((e) => e.value!.label).join(', ').isEmpty ? 'none' : _sortPanelSorts.entries.where((e) => e.value != null).map((e) => e.value!.label).join(', ')}',
              style: AppTypography.caption.bold,
              color: AppColors.textSecondary,
            ),
          ],
        ),
      ),
    ];
  }

  // ── Helpers ──

  Widget _subSectionHeader(_SubSection sub) {
    return Container(
      key: sub.key,
      child: AppText(sub.name.toUpperCase(), style: AppTypography.caption.bold),
    );
  }

  /// Renders a small folder-name label above a group of subsections so the
  /// catalog visibly mirrors the file tree (e.g. `PRIMITIVES/`, `CONTROLS/`).
  Widget _folderGroupHeader(String label) {
    return Padding(
      padding: const EdgeInsets.only(
        top: AppGrid.grid8,
        bottom: AppGrid.grid12,
      ),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          AppText(
            '$label/',
            style: AppTypography.overline.semiBold,
            color: AppColors.textSecondary,
          ),
          const SizedBox(width: AppGrid.grid8),
          Expanded(
            child: Container(
              height: AppStroke.xs,
              color: AppColors.surfaceBorder,
            ),
          ),
        ],
      ),
    );
  }

  static Widget _sectionDivider() => const Divider(
        color: AppColors.surfaceBorder,
        thickness: 1,
        height: AppPadding.sectionGap * 2,
      );
}

/// A subsection with its content hidden by default. Tap the header to expand.
/// Used for the Button Playground so the dev tool doesn't take up real estate
/// in the Atoms section.
class _CollapsibleSubsection extends StatefulWidget {
  final _SubSection sub;
  final Widget child;
  const _CollapsibleSubsection({required this.sub, required this.child});

  @override
  State<_CollapsibleSubsection> createState() => _CollapsibleSubsectionState();
}

class _CollapsibleSubsectionState extends State<_CollapsibleSubsection> {
  bool _expanded = false;

  @override
  Widget build(BuildContext context) {
    return Container(
      key: widget.sub.key,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          GestureDetector(
            behavior: HitTestBehavior.opaque,
            onTap: () => setState(() => _expanded = !_expanded),
            child: Row(
              children: [
                AppText(
                  widget.sub.name.toUpperCase(),
                  style: AppTypography.caption.bold,
                ),
                const SizedBox(width: AppGrid.grid8),
                AnimatedRotation(
                  turns: _expanded ? 0.25 : 0,
                  duration: const Duration(milliseconds: 200),
                  child: const Icon(
                    Icons.chevron_right,
                    size: 16,
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          AnimatedSize(
            duration: const Duration(milliseconds: 300),
            curve: Curves.easeInOut,
            alignment: Alignment.topCenter,
            child: _expanded
                ? Padding(
                    padding: const EdgeInsets.only(top: AppGrid.grid12),
                    child: widget.child,
                  )
                : const SizedBox.shrink(),
          ),
        ],
      ),
    );
  }
}

// ── Nav action button ──

class _NavAction extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _NavAction({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: AppText(
        label,
        style: AppTypography.caption.bold,
        color: AppColors.brand,
      ),
    );
  }
}

// ── Catalog helper widgets ──

class _ColorRow extends StatelessWidget {
  final String name;
  final Color color;
  const _ColorRow(this.name, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppGrid.grid8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.surfaceBorder, width: AppStroke.xs),
            ),
          ),
          const SizedBox(width: AppGrid.grid12),
          Expanded(child: AppText(name, style: AppTypography.body.regular)),
          AppText(
            '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
            style: AppTypography.caption.bold,
          ),
        ],
      ),
    );
  }
}

class _PaletteColor {
  final String label;
  final Color color;
  const _PaletteColor(this.label, this.color);
}

class _PaletteStrip extends StatelessWidget {
  final List<_PaletteColor> colors;
  const _PaletteStrip(this.colors);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(AppRadius.md),
          child: Row(
            children: colors
                .map((c) => Expanded(
                      child: Container(height: 48, color: c.color),
                    ))
                .toList(),
          ),
        ),
        const SizedBox(height: AppGrid.grid4),
        Row(
          children: colors
              .map((c) => Expanded(
                    child: AppText(
                      c.label,
                      textAlign: TextAlign.center,
                      style: AppTypography.overline.semiBold,
                    ),
                  ))
              .toList(),
        ),
      ],
    );
  }
}

class _TypeRow extends StatelessWidget {
  final String label;
  final TypeStyle typeStyle;
  const _TypeRow(this.label, this.typeStyle);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppGrid.grid16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          AppText(
            '${typeStyle.fontSize.toStringAsFixed(1)}px  •  ${(typeStyle.fontSize / AppScale.root).toStringAsFixed(2)}rem',
            style: AppTypography.overline.semiBold,
          ),
          const SizedBox(height: AppGrid.grid4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: AppText(
                  label,
                  style: typeStyle.black,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppGrid.grid8),
              Expanded(
                child: AppText(
                  label,
                  style: typeStyle.bold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppGrid.grid8),
              Expanded(
                child: AppText(
                  label,
                  style: typeStyle.semiBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              const SizedBox(width: AppGrid.grid8),
              Expanded(
                child: AppText(
                  label,
                  style: typeStyle.regular,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class _GradientSwatch extends StatelessWidget {
  final String name;
  final LinearGradient gradient;
  const _GradientSwatch(this.name, this.gradient);

  @override
  Widget build(BuildContext context) {
    return Container(
      height: 48,
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(AppRadius.md),
      ),
      alignment: Alignment.center,
      child: AppText(name, style: AppTypography.bodySmall.bold, color: AppColors.textPrimary),
    );
  }
}

class _SpacingRow extends StatelessWidget {
  final String name;
  final String remValue;
  final double value;
  const _SpacingRow(this.name, this.remValue, this.value);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppGrid.grid8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: AppText(name, style: AppTypography.caption.bold),
          ),
          Flexible(
            flex: 3,
            child: ConstrainedBox(
              constraints: BoxConstraints(maxWidth: value.clamp(0, 200)),
              child: Container(height: 24,
            decoration: BoxDecoration(
              color: AppColors.brand,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
            ),
          ),
          const SizedBox(width: AppGrid.grid8),
          Flexible(flex: 2, child: AppText('${value.toInt()}px  ($remValue)', style: AppTypography.bodySmall.regular, maxLines: 1, overflow: TextOverflow.ellipsis)),
        ],
      ),
    );
  }
}

class _RadiusRow extends StatelessWidget {
  final String name;
  final double radius;
  const _RadiusRow(this.name, this.radius);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppGrid.grid12),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.brand, width: AppStroke.md),
              borderRadius: BorderRadius.circular(radius.clamp(0, 32)),
            ),
          ),
          const SizedBox(width: AppGrid.grid16),
          Expanded(child: AppText(name, style: AppTypography.body.regular)),
          AppText('${radius.toInt()}px', style: AppTypography.caption.bold),
        ],
      ),
    );
  }
}

class _StrokeRow extends StatelessWidget {
  final String name;
  final double width;
  const _StrokeRow(this.name, this.width);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppGrid.grid12),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.brand, width: width),
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
          ),
          const SizedBox(width: AppGrid.grid16),
          Expanded(child: AppText(name, style: AppTypography.body.regular)),
          AppText('${width % 1 == 0 ? width.toInt() : width}px', style: AppTypography.caption.bold),
        ],
      ),
    );
  }
}

class _IconVariant extends StatelessWidget {
  final String label;
  final String iconPath;
  final Color color;
  const _IconVariant(this.label, this.iconPath, this.color);

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: label == 'Black' ? AppColors.grey50 : AppColors.surface,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(
              child: AppIcon(iconPath, size: IconSizes.lg, color: color),
            ),
          ),
          const SizedBox(height: AppGrid.grid4),
          AppText(label, style: AppTypography.overline.semiBold),
        ],
      ),
    );
  }
}

class _IconSize extends StatelessWidget {
  final String label;
  final String iconPath;
  final double size;
  const _IconSize(this.label, this.iconPath, this.size);

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        AppIcon(iconPath, size: size),
        const SizedBox(height: AppGrid.grid4),
        AppText('$label\n${size.toInt()}px', style: AppTypography.overline.semiBold, textAlign: TextAlign.center),
      ],
    );
  }
}

// ── Button Playground ──

class _ButtonPlayground extends StatefulWidget {
  const _ButtonPlayground();

  @override
  State<_ButtonPlayground> createState() => _ButtonPlaygroundState();
}

class _ButtonPlaygroundState extends State<_ButtonPlayground> {
  ButtonType _type = ButtonType.filled;
  ButtonSize _size = ButtonSize.md;
  int _colorIndex = 0;
  bool _hasLabel = true;
  bool _hasLeadingIcon = false;
  bool _hasTrailingIcon = false;
  bool _isActive = false;
  bool _selfToggle = false;
  bool _isDisabled = false;
  bool _isLoading = false;

  static const _colorOptions = <(String, Color)>[
    ('Brand', AppColors.brand),
    ('White', AppColors.textPrimary),
    ('Error', AppColors.error),
    ('Info', AppColors.info),
    ('Success', AppColors.success),
    ('Purple', AppColors.purple500),
    ('Yellow', AppColors.yellow500),
  ];

  @override
  Widget build(BuildContext context) {
    final chipStyle = AppTypography.bodySmall.semiBold;

    return Container(
      padding: const EdgeInsets.all(AppPadding.rem1),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.surfaceBorder, width: AppStroke.xs),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview
          Container(
            width: double.infinity,
            padding: const EdgeInsets.symmetric(vertical: AppGrid.grid40),
            decoration: BoxDecoration(
              color: AppColors.background,
              borderRadius: BorderRadius.circular(AppRadius.sm),
            ),
            child: Center(
              child: AppButton(
                label: _hasLabel ? 'Button' : null,
                leadingIcon: _hasLeadingIcon ? AppIcons.add : null,
                trailingIcon: _hasTrailingIcon ? AppIcons.arrowRight : null,
                type: _type,
                size: _size,
                color: _colorOptions[_colorIndex].$2,
                isActive: _selfToggle ? null : (_isActive ? true : null),
                selfToggle: _selfToggle,
                isDisabled: _isDisabled,
                isLoading: _isLoading,
                onPressed: () {},
              ),
            ),
          ),
          const SizedBox(height: AppGrid.grid16),

          // Type
          AppText('TYPE', style: AppTypography.overline.semiBold),
          const SizedBox(height: AppGrid.grid8),
          _buildChipRow(
            labels: ButtonType.values.map((t) => t.name).toList(),
            selectedIndex: _type.index,
            onSelected: (i) => setState(() => _type = ButtonType.values[i]),
            style: chipStyle,
          ),
          const SizedBox(height: AppGrid.grid16),

          // Size
          AppText('SIZE', style: AppTypography.overline.semiBold),
          const SizedBox(height: AppGrid.grid8),
          _buildChipRow(
            labels: ButtonSize.values.map((s) => s.name).toList(),
            selectedIndex: _size.index,
            onSelected: (i) => setState(() => _size = ButtonSize.values[i]),
            style: chipStyle,
          ),
          const SizedBox(height: AppGrid.grid16),

          // Color
          AppText('COLOR', style: AppTypography.overline.semiBold),
          const SizedBox(height: AppGrid.grid8),
          Wrap(
            spacing: AppGrid.grid8,
            runSpacing: AppGrid.grid8,
            children: List.generate(_colorOptions.length, (i) {
              final selected = i == _colorIndex;
              final option = _colorOptions[i];
              return GestureDetector(
                onTap: () => setState(() => _colorIndex = i),
                child: Container(
                  width: 32,
                  height: 32,
                  decoration: BoxDecoration(
                    color: option.$2,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: selected
                        ? Border.all(color: AppColors.textPrimary, width: AppStroke.md)
                        : Border.all(color: AppColors.surfaceBorder, width: AppStroke.xs),
                  ),
                ),
              );
            }),
          ),
          const SizedBox(height: AppGrid.grid4),
          AppText(_colorOptions[_colorIndex].$1, style: AppTypography.caption.bold),
          const SizedBox(height: AppGrid.grid16),

          // Content
          AppText('CONTENT', style: AppTypography.overline.semiBold),
          const SizedBox(height: AppGrid.grid8),
          _buildToggle('Label', _hasLabel, (v) => setState(() {
            _hasLabel = v;
            if (!_hasLabel && !_hasLeadingIcon && !_hasTrailingIcon) {
              _hasLabel = true;
            }
          })),
          _buildToggle('Leading Icon', _hasLeadingIcon, (v) => setState(() {
            _hasLeadingIcon = v;
            if (!_hasLabel && !_hasLeadingIcon && !_hasTrailingIcon) {
              _hasLabel = true;
            }
          })),
          _buildToggle('Trailing Icon', _hasTrailingIcon, (v) => setState(() {
            _hasTrailingIcon = v;
            if (!_hasLabel && !_hasLeadingIcon && !_hasTrailingIcon) {
              _hasLabel = true;
            }
          })),
          const SizedBox(height: AppGrid.grid16),

          // States
          AppText('STATE', style: AppTypography.overline.semiBold),
          const SizedBox(height: AppGrid.grid8),
          _buildToggle('Active', _isActive, (v) => setState(() {
            _isActive = v;
            if (v) _selfToggle = false;
          })),
          _buildToggle('Self Toggle', _selfToggle, (v) => setState(() {
            _selfToggle = v;
            if (v) _isActive = false;
          })),
          _buildToggle('Disabled', _isDisabled, (v) => setState(() => _isDisabled = v)),
          _buildToggle('Loading', _isLoading, (v) => setState(() => _isLoading = v)),
        ],
      ),
    );
  }

  Widget _buildChipRow({
    required List<String> labels,
    required int selectedIndex,
    required ValueChanged<int> onSelected,
    required TextStyle style,
  }) {
    return Wrap(
      spacing: AppGrid.grid8,
      children: List.generate(labels.length, (i) {
        final selected = i == selectedIndex;
        return GestureDetector(
          onTap: () => onSelected(i),
          child: Container(
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.rem075,
              vertical: AppGrid.grid4,
            ),
            decoration: BoxDecoration(
              color: selected ? AppColors.brand : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: selected ? AppColors.brand : AppColors.surfaceBorder,
                width: AppStroke.xs,
              ),
            ),
            child: AppText(
              labels[i].toUpperCase(),
              style: style,
              color: selected ? AppColors.textInverse : AppColors.textSecondary,
            ),
          ),
        );
      }),
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppGrid.grid4),
      child: Row(
        children: [
          SizedBox(
            width: 36,
            height: 24,
            child: Switch.adaptive(
              value: value,
              onChanged: onChanged,
              activeTrackColor: AppColors.brand,
            ),
          ),
          const SizedBox(width: AppGrid.grid8),
          AppText(label, style: AppTypography.bodySmall.regular),
        ],
      ),
    );
  }
}

// ── Client List Catalog ──

class _ClientListCatalog extends StatefulWidget {
  const _ClientListCatalog();

  @override
  State<_ClientListCatalog> createState() => _ClientListCatalogState();
}

class _ClientListCatalogState extends State<_ClientListCatalog> {
  final _searchController = TextEditingController();
  final _searchFocusNode = FocusNode();
  Map<SortCategory, SortOption?> _activeSort = {};
  String _scenario = 'populated'; // populated | noCurrentClients | noSearchResults | noClientsAtAll | rosterFull

  // --- Mock data ---

  static final _allClients = List.generate(
    10,
    (i) => AllClientData(
      clientId: 'all_$i',
      clientName: [
        'Charlie Vetrovs',
        'Alex Morgan',
        'Jordan Lee',
        'Sam Kim',
        'Taylor Swift',
        'Blake Chen',
        'Riley Park',
        'Casey Wu',
        'Drew Hall',
        'Quinn Adams'
      ][i],
      email:
          '${['charlie', 'alex', 'jordan', 'sam', 'taylor', 'blake', 'riley', 'casey', 'drew', 'quinn'][i]}@gmail.com',
    ),
  );

  static final _currentClients = [
    CurrentClientData(
        clientId: 'all_0',
        clientName: 'Charlie Vetrovs',
        lastSessionText: 'Last Session: 1 day ago',
        score: 3.9,
        status: ReviewStatus.urgent),
    CurrentClientData(
        clientId: 'all_1',
        clientName: 'Alex Morgan',
        lastSessionText: 'Last Session: 1 day ago',
        score: 4.6,
        status: ReviewStatus.reviewed),
    CurrentClientData(
        clientId: 'all_2',
        clientName: 'Jordan Lee',
        lastSessionText: 'Last Session: 10 hours ago',
        score: 3.5,
        status: ReviewStatus.urgent),
    CurrentClientData(
        clientId: 'all_3',
        clientName: 'Sam Kim',
        lastSessionText: 'Last Session: 6 days ago',
        score: 8.2,
        status: ReviewStatus.pendingReview),
    CurrentClientData(
        clientId: 'all_4',
        clientName: 'Taylor Swift',
        lastSessionText: 'Last Session: 1 day ago',
        score: 3.9,
        status: ReviewStatus.reviewed),
    CurrentClientData(
        clientId: 'all_5',
        clientName: 'Blake Chen',
        lastSessionText: 'Last Session: 8 days ago',
        score: 5.9,
        status: ReviewStatus.pendingReview),
  ];

  List<CurrentClientData> get _scenarioCurrent => switch (_scenario) {
        'noClientsAtAll' || 'noCurrentClients' => [],
        _ => _currentClients, // populated, noSearchResults, rosterFull
      };

  List<AllClientData> get _scenarioAll => switch (_scenario) {
        'noClientsAtAll' => [],
        _ => _allClients,
      };

  int get _scenarioMax =>
      _scenario == 'rosterFull' ? _currentClients.length : 30;

  String get _scenarioSearchText => switch (_scenario) {
        'noSearchResults' => 'zzzzz',
        _ => _searchController.text,
      };

  @override
  void initState() {
    super.initState();
    _searchController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _searchController.dispose();
    _searchFocusNode.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final chipStyle = AppTypography.bodySmall.semiBold;
    final scenarios = [
      'populated',
      'noCurrentClients',
      'noSearchResults',
      'noClientsAtAll',
      'rosterFull'
    ];
    final scenarioLabels = [
      'Populated',
      'No Current',
      'No Results',
      'No Clients',
      'Roster Full'
    ];

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // Scenario picker
        AppText('SCENARIO', style: AppTypography.overline.semiBold),
        const SizedBox(height: AppGrid.grid8),
        Wrap(
          spacing: AppGrid.grid8,
          runSpacing: AppGrid.grid8,
          children: List.generate(scenarios.length, (i) {
            final selected = _scenario == scenarios[i];
            return GestureDetector(
              onTap: () => setState(() => _scenario = scenarios[i]),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.rem075,
                  vertical: AppGrid.grid4,
                ),
                decoration: BoxDecoration(
                  color: selected ? AppColors.brand : Colors.transparent,
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color:
                        selected ? AppColors.brand : AppColors.surfaceBorder,
                    width: AppStroke.xs,
                  ),
                ),
                child: AppText(
                  scenarioLabels[i],
                  style: chipStyle,
                  color: selected
                      ? AppColors.textInverse
                      : AppColors.textSecondary,
                ),
              ),
            );
          }),
        ),

        const SizedBox(height: AppGrid.grid16),

        // Sort controls — chip pickers, not the SortPanel organism
        AppText('SORT', style: AppTypography.overline.semiBold),
        const SizedBox(height: AppGrid.grid8),
        Wrap(
          spacing: AppGrid.grid8,
          runSpacing: AppGrid.grid8,
          children: [
            for (final opt in SortOption.values)
              GestureDetector(
                onTap: () => setState(() {
                  final current = _activeSort[opt.category];
                  _activeSort = {
                    ..._activeSort,
                    opt.category: current == opt ? null : opt,
                  };
                }),
                child: Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: AppPadding.rem075,
                    vertical: AppGrid.grid4,
                  ),
                  decoration: BoxDecoration(
                    color: _activeSort[opt.category] == opt
                        ? AppColors.brand
                        : Colors.transparent,
                    borderRadius: BorderRadius.circular(AppRadius.sm),
                    border: Border.all(
                      color: _activeSort[opt.category] == opt
                          ? AppColors.brand
                          : AppColors.surfaceBorder,
                      width: AppStroke.xs,
                    ),
                  ),
                  child: AppText(
                    opt.label,
                    style: chipStyle,
                    color: _activeSort[opt.category] == opt
                        ? AppColors.textInverse
                        : AppColors.textSecondary,
                  ),
                ),
              ),
            GestureDetector(
              onTap: () => setState(() => _activeSort = {}),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.rem075,
                  vertical: AppGrid.grid4,
                ),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(AppRadius.sm),
                  border: Border.all(
                    color: AppColors.surfaceBorder,
                    width: AppStroke.xs,
                  ),
                ),
                child: AppText(
                  'Clear',
                  style: chipStyle,
                  color: AppColors.textSecondary,
                ),
              ),
            ),
          ],
        ),

        const SizedBox(height: AppGrid.grid16),

        // Search field (only active for non-preset-search scenarios)
        if (_scenario != 'noSearchResults') ...[
          AppText('SEARCH', style: AppTypography.overline.semiBold),
          const SizedBox(height: AppGrid.grid8),
          ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 320),
            child: AppSearchBar(
              controller: _searchController,
              focusNode: _searchFocusNode,
              hintText: 'Search clients...',
              onChanged: (_) => setState(() {}),
              variant: SearchBarVariant.card,
            ),
          ),
          const SizedBox(height: AppGrid.grid16),
        ],

        // Live preview
        AppText('PREVIEW', style: AppTypography.overline.semiBold),
        const SizedBox(height: AppGrid.grid8),
        Container(
          height: 640,
          decoration: BoxDecoration(
            color: AppColors.background,
            borderRadius: BorderRadius.circular(AppRadius.md),
            border: Border.all(
                color: AppColors.surfaceBorder, width: AppStroke.xs),
          ),
          clipBehavior: Clip.hardEdge,
          child: ClientListOrganism(
            currentClients: _scenarioCurrent,
            allClients: _scenarioAll,
            maxCurrentClients: _scenarioMax,
            searchText: _scenarioSearchText,
            activeSort: _activeSort,
            onCurrentClientTap: (id) {},
            onAllClientAction: (event) {},
            onAddClientsTap: () {},
          ),
        ),
      ],
    );
  }
}
