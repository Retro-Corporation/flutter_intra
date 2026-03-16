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

class CatalogHome extends StatelessWidget {
  const CatalogHome({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: ListView(
          padding: EdgeInsets.all(AppPadding.pagePadding),
          children: [
            Text('Design System', style: AppTypography.heading4.bold),
            const SizedBox(height: 4),
            Text('CATALOG', style: AppTypography.overline),
            _divider(),

            // ── SEMANTIC COLORS ──
            Text('SEMANTIC COLORS', style: AppTypography.caption),
            SizedBox(height: AppGrid.grid12),
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

            _divider(),

            // ── COLOR PALETTES ──
            Text('GREY', style: AppTypography.caption),
            SizedBox(height: AppGrid.grid12),
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

            SizedBox(height: AppGrid.grid24),
            Text('ORANGE (PRIMARY)', style: AppTypography.caption),
            SizedBox(height: AppGrid.grid12),
            const _PaletteStrip([
              _PaletteColor('50', AppColors.orange50),
              _PaletteColor('100', AppColors.orange100),
              _PaletteColor('500', AppColors.orange500),
              _PaletteColor('700', AppColors.orange700),
              _PaletteColor('900', AppColors.orange900),
            ]),

            SizedBox(height: AppGrid.grid24),
            Text('BLUE', style: AppTypography.caption),
            SizedBox(height: AppGrid.grid12),
            const _PaletteStrip([
              _PaletteColor('500', AppColors.blue500),
              _PaletteColor('700', AppColors.blue700),
              _PaletteColor('900', AppColors.blue900),
            ]),

            SizedBox(height: AppGrid.grid24),
            Text('RED', style: AppTypography.caption),
            SizedBox(height: AppGrid.grid12),
            const _PaletteStrip([
              _PaletteColor('500', AppColors.red500),
              _PaletteColor('700', AppColors.red700),
              _PaletteColor('900', AppColors.red900),
            ]),

            SizedBox(height: AppGrid.grid24),
            Text('GREEN', style: AppTypography.caption),
            SizedBox(height: AppGrid.grid12),
            const _PaletteStrip([
              _PaletteColor('500', AppColors.green500),
              _PaletteColor('700', AppColors.green700),
              _PaletteColor('900', AppColors.green900),
            ]),

            SizedBox(height: AppGrid.grid24),
            Text('PURPLE', style: AppTypography.caption),
            SizedBox(height: AppGrid.grid12),
            const _PaletteStrip([
              _PaletteColor('500', AppColors.purple500),
              _PaletteColor('700', AppColors.purple700),
              _PaletteColor('900', AppColors.purple900),
            ]),

            SizedBox(height: AppGrid.grid24),
            Text('YELLOW', style: AppTypography.caption),
            SizedBox(height: AppGrid.grid12),
            const _PaletteStrip([
              _PaletteColor('500', AppColors.yellow500),
              _PaletteColor('700', AppColors.yellow700),
              _PaletteColor('900', AppColors.yellow900),
            ]),

            _divider(),

            // ── GRADIENTS ──
            Text('GRADIENTS', style: AppTypography.caption),
            SizedBox(height: AppGrid.grid12),
            _GradientSwatch('Brand', AppColors.brandGradient),
            SizedBox(height: AppGrid.grid8),
            _GradientSwatch('Error', AppColors.errorGradient),

            _divider(),

            // ── TYPOGRAPHY (4-column: Black | Bold | Semi Bold | Regular) ──
            Text('TYPOGRAPHY', style: AppTypography.caption),
            SizedBox(height: AppGrid.grid8),
            // Column headers
            Row(
              children: [
                Expanded(child: Text('BLACK', style: AppTypography.overline)),
                SizedBox(width: AppGrid.grid8),
                Expanded(child: Text('BOLD', style: AppTypography.overline)),
                SizedBox(width: AppGrid.grid8),
                Expanded(child: Text('SEMI BOLD', style: AppTypography.overline)),
                SizedBox(width: AppGrid.grid8),
                Expanded(child: Text('REGULAR', style: AppTypography.overline)),
              ],
            ),
            SizedBox(height: AppGrid.grid16),

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

            SizedBox(height: AppGrid.grid16),
            Text('LINKS', style: AppTypography.caption),
            SizedBox(height: AppGrid.grid8),
            Row(
              children: [
                Expanded(child: Text('Link Large', style: AppTypography.linkLarge.semiBold)),
                Expanded(child: Text('Link', style: AppTypography.link.semiBold)),
                Expanded(child: Text('Link Small', style: AppTypography.linkSmall.semiBold)),
              ],
            ),

            _divider(),

            // ── SPACING GRID ──
            Text('4-POINT GRID (REM-SCALED)', style: AppTypography.caption),
            SizedBox(height: AppGrid.grid12),
            _SpacingRow('grid0', '0rem', AppGrid.grid0),
            _SpacingRow('grid4', '0.25rem', AppGrid.grid4),
            _SpacingRow('grid8', '0.5rem', AppGrid.grid8),
            _SpacingRow('grid12', '0.75rem', AppGrid.grid12),
            _SpacingRow('grid16', '1rem', AppGrid.grid16),
            _SpacingRow('grid20', '1.25rem', AppGrid.grid20),
            _SpacingRow('grid24', '1.5rem', AppGrid.grid24),
            _SpacingRow('grid28', '1.75rem', AppGrid.grid28),
            _SpacingRow('grid32', '2rem', AppGrid.grid32),
            _SpacingRow('grid36', '2.25rem', AppGrid.grid36),
            _SpacingRow('grid40', '2.5rem', AppGrid.grid40),
            _SpacingRow('grid60', '3.75rem', AppGrid.grid60),
            _SpacingRow('grid100', '6.25rem', AppGrid.grid100),
            _SpacingRow('grid160', '10rem', AppGrid.grid160),
            _SpacingRow('grid240', '15rem', AppGrid.grid240),

            _divider(),

            // ── PADDING ──
            Text('PADDING (SEMANTIC SPACING)', style: AppTypography.caption),
            SizedBox(height: AppGrid.grid12),
            _SpacingRow('none', '0rem', AppPadding.none),
            _SpacingRow('quarter', '0.25rem', AppPadding.quarter),
            _SpacingRow('half', '0.5rem', AppPadding.half),
            _SpacingRow('3/4', '0.75rem', AppPadding.threeQuarter),
            _SpacingRow('one', '1rem', AppPadding.one),
            _SpacingRow('oneAndHalf', '1.5rem', AppPadding.oneAndHalf),
            _SpacingRow('two', '2rem', AppPadding.two),
            _SpacingRow('three', '3rem', AppPadding.three),

            _divider(),

            // ── CORNER RADIUS ──
            Text('CORNER RADIUS', style: AppTypography.caption),
            SizedBox(height: AppGrid.grid12),
            _RadiusRow('none', AppRadius.none),
            _RadiusRow('sm (0.5rem)', AppRadius.sm),
            _RadiusRow('md (1rem)', AppRadius.md),
            _RadiusRow('lg (1.5rem)', AppRadius.lg),
            _RadiusRow('xl (2.5rem)', AppRadius.xl),
            _RadiusRow('pill', AppRadius.pill),

            _divider(),

            // ── ICONS ──
            Text('ICONS (${AppIcons.all.length})', style: AppTypography.caption),
            SizedBox(height: AppGrid.grid12),

            // Icon grid
            Wrap(
              spacing: AppGrid.grid16,
              runSpacing: AppGrid.grid16,
              children: AppIcons.all.entries.map((e) => SizedBox(
                width: 72,
                child: Column(
                  children: [
                    AppIcon(e.value, size: IconSizes.lg),
                    SizedBox(height: AppGrid.grid4),
                    Text(
                      e.key,
                      style: AppTypography.overline,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )).toList(),
            ),

            SizedBox(height: AppGrid.grid24),

            // Filled icon grid
            Text('FILLED ICONS (${AppIcons.allFilled.length})', style: AppTypography.caption),
            SizedBox(height: AppGrid.grid12),
            Wrap(
              spacing: AppGrid.grid16,
              runSpacing: AppGrid.grid16,
              children: AppIcons.allFilled.entries.map((e) => SizedBox(
                width: 72,
                child: Column(
                  children: [
                    AppIcon(e.value, size: IconSizes.lg),
                    SizedBox(height: AppGrid.grid4),
                    Text(
                      e.key,
                      style: AppTypography.overline,
                      textAlign: TextAlign.center,
                      maxLines: 2,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ],
                ),
              )).toList(),
            ),

            SizedBox(height: AppGrid.grid24),

            // Color variants
            Text('COLOR VARIANTS', style: AppTypography.overline),
            SizedBox(height: AppGrid.grid8),
            Row(
              children: [
                _IconVariant('White', AppIcons.home, AppColors.textPrimary),
                _IconVariant('Black', AppIcons.home, AppColors.textInverse),
                _IconVariant('Disabled', AppIcons.home, AppColors.grey600),
                _IconVariant('Primary', AppIcons.home, AppColors.brand),
              ],
            ),

            SizedBox(height: AppGrid.grid16),

            // Size variants
            Text('SIZE VARIANTS', style: AppTypography.overline),
            SizedBox(height: AppGrid.grid8),
            Row(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                _IconSize('sm', AppIcons.home, IconSizes.sm),
                SizedBox(width: AppGrid.grid24),
                _IconSize('md', AppIcons.home, IconSizes.md),
                SizedBox(width: AppGrid.grid24),
                _IconSize('lg', AppIcons.home, IconSizes.lg),
                SizedBox(width: AppGrid.grid24),
                _IconSize('xl', AppIcons.home, IconSizes.xl),
              ],
            ),

            _divider(),

            // ── BUTTONS ──
            Text('BUTTONS', style: AppTypography.caption),
            SizedBox(height: AppGrid.grid12),

            // By type
            Text('TYPES', style: AppTypography.overline),
            SizedBox(height: AppGrid.grid8),
            Wrap(
              spacing: AppGrid.grid8,
              runSpacing: AppGrid.grid8,
              children: const [
                AppButton(label: 'Filled', type: ButtonType.filled),
                AppButton(label: 'Outline', type: ButtonType.outline),
                AppButton(label: 'Ghost', type: ButtonType.ghost),
              ],
            ),

            SizedBox(height: AppGrid.grid24),

            // By color
            Text('COLORS (FILLED)', style: AppTypography.overline),
            SizedBox(height: AppGrid.grid8),
            Wrap(
              spacing: AppGrid.grid8,
              runSpacing: AppGrid.grid8,
              children: const [
                AppButton(label: 'Brand', color: AppColors.brand),
                AppButton(label: 'White', color: AppColors.textPrimary),
                AppButton(label: 'Error', color: AppColors.error),
                AppButton(label: 'Info', color: AppColors.info),
                AppButton(label: 'Success', color: AppColors.success),
              ],
            ),

            SizedBox(height: AppGrid.grid16),
            Text('COLORS (OUTLINE)', style: AppTypography.overline),
            SizedBox(height: AppGrid.grid8),
            Wrap(
              spacing: AppGrid.grid8,
              runSpacing: AppGrid.grid8,
              children: const [
                AppButton(label: 'Brand', type: ButtonType.outline, color: AppColors.brand),
                AppButton(label: 'White', type: ButtonType.outline, color: AppColors.textPrimary),
                AppButton(label: 'Error', type: ButtonType.outline, color: AppColors.error),
                AppButton(label: 'Info', type: ButtonType.outline, color: AppColors.info),
                AppButton(label: 'Success', type: ButtonType.outline, color: AppColors.success),
              ],
            ),

            SizedBox(height: AppGrid.grid24),

            // By size
            Text('SIZES', style: AppTypography.overline),
            SizedBox(height: AppGrid.grid8),
            Wrap(
              spacing: AppGrid.grid8,
              runSpacing: AppGrid.grid8,
              crossAxisAlignment: WrapCrossAlignment.center,
              children: const [
                AppButton(label: 'Small', size: ButtonSize.sm),
                AppButton(label: 'Medium', size: ButtonSize.md),
                AppButton(label: 'Large', size: ButtonSize.lg),
              ],
            ),

            SizedBox(height: AppGrid.grid24),

            // Content patterns
            Text('CONTENT PATTERNS', style: AppTypography.overline),
            SizedBox(height: AppGrid.grid8),
            Wrap(
              spacing: AppGrid.grid8,
              runSpacing: AppGrid.grid8,
              children: [
                const AppButton(label: 'Text only'),
                AppButton(leadingIcon: AppIcons.add),
                AppButton(leadingIcon: AppIcons.add, label: 'Leading'),
                AppButton(label: 'Trailing', trailingIcon: AppIcons.arrowRight),
              ],
            ),

            SizedBox(height: AppGrid.grid24),

            // States
            Text('STATES', style: AppTypography.overline),
            SizedBox(height: AppGrid.grid8),
            Wrap(
              spacing: AppGrid.grid8,
              runSpacing: AppGrid.grid8,
              children: const [
                AppButton(label: 'Default'),
                AppButton(label: 'Disabled', isDisabled: true),
                AppButton(label: 'Loading', isLoading: true),
              ],
            ),

            _divider(),

            // ── BUTTON PLAYGROUND ──
            Text('BUTTON PLAYGROUND', style: AppTypography.caption),
            SizedBox(height: AppGrid.grid12),
            const _ButtonPlayground(),

            SizedBox(height: AppGrid.grid60),
          ],
        ),
      ),
    );
  }

  static Widget _divider() => Divider(
        color: AppColors.surfaceBorder,
        thickness: 1,
        height: AppPadding.sectionGap * 2,
      );
}

// ── Catalog helper widgets ──

class _ColorRow extends StatelessWidget {
  final String name;
  final Color color;
  const _ColorRow(this.name, this.color);

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppGrid.grid8),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: color,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(color: AppColors.surfaceBorder),
            ),
          ),
          SizedBox(width: AppGrid.grid12),
          Expanded(child: Text(name, style: AppTypography.body.regular)),
          Text(
            '#${color.toARGB32().toRadixString(16).substring(2).toUpperCase()}',
            style: AppTypography.caption,
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
        SizedBox(height: AppGrid.grid4),
        Row(
          children: colors
              .map((c) => Expanded(
                    child: Text(
                      c.label,
                      textAlign: TextAlign.center,
                      style: AppTypography.overline,
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
      padding: EdgeInsets.only(bottom: AppGrid.grid16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            '${typeStyle.fontSize.toStringAsFixed(1)}px  •  ${(typeStyle.fontSize / AppScale.root).toStringAsFixed(2)}rem',
            style: AppTypography.overline,
          ),
          SizedBox(height: AppGrid.grid4),
          Row(
            crossAxisAlignment: CrossAxisAlignment.baseline,
            textBaseline: TextBaseline.alphabetic,
            children: [
              Expanded(
                child: Text(
                  label,
                  style: typeStyle.black,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppGrid.grid8),
              Expanded(
                child: Text(
                  label,
                  style: typeStyle.bold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppGrid.grid8),
              Expanded(
                child: Text(
                  label,
                  style: typeStyle.semiBold,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
              SizedBox(width: AppGrid.grid8),
              Expanded(
                child: Text(
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
      child: Text(name, style: AppTypography.bodySmall.bold.copyWith(color: AppColors.textPrimary)),
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
      padding: EdgeInsets.only(bottom: AppGrid.grid8),
      child: Row(
        children: [
          SizedBox(
            width: 80,
            child: Text(name, style: AppTypography.caption),
          ),
          Container(
            width: value.clamp(0, 200),
            height: 24,
            decoration: BoxDecoration(
              color: AppColors.brand,
              borderRadius: BorderRadius.circular(4),
            ),
          ),
          SizedBox(width: AppGrid.grid8),
          Text('${value.toInt()}px  ($remValue)', style: AppTypography.bodySmall.regular),
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
      padding: EdgeInsets.only(bottom: AppGrid.grid12),
      child: Row(
        children: [
          Container(
            width: 64,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.surface,
              border: Border.all(color: AppColors.brand, width: 2),
              borderRadius: BorderRadius.circular(radius.clamp(0, 32)),
            ),
          ),
          SizedBox(width: AppGrid.grid16),
          Expanded(child: Text(name, style: AppTypography.body.regular)),
          Text('${radius.toInt()}px', style: AppTypography.caption),
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
          SizedBox(height: AppGrid.grid4),
          Text(label, style: AppTypography.overline),
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
        SizedBox(height: AppGrid.grid4),
        Text('$label\n${size.toInt()}px', style: AppTypography.overline, textAlign: TextAlign.center),
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
  bool _isDisabled = false;
  bool _isLoading = false;

  // Override controls
  bool _useRadiusOverride = false;
  int _radiusIndex = 1; // default sm
  bool _usePaddingOverride = false;
  double _paddingValue = 16;
  bool _useHeightOverride = false;
  double _heightValue = 44;
  bool _useWidthOverride = false;
  double _widthValue = 120;

  static const _radiusOptions = <(String, double)>[
    ('none (0)', 0),
    ('sm (8)', 8),
    ('md (16)', 16),
    ('lg (24)', 24),
    ('xl (40)', 40),
    ('pill', 999),
  ];

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
      padding: EdgeInsets.all(AppPadding.one),
      decoration: BoxDecoration(
        color: AppColors.surface,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.surfaceBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Preview
          Container(
            width: double.infinity,
            padding: EdgeInsets.symmetric(vertical: AppGrid.grid40),
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
                isDisabled: _isDisabled,
                isLoading: _isLoading,
                onPressed: () {},
                radiusOverride: _useRadiusOverride ? _radiusOptions[_radiusIndex].$2 : null,
                paddingOverride: _usePaddingOverride ? _paddingValue : null,
                heightOverride: _useHeightOverride ? _heightValue : null,
                widthOverride: _useWidthOverride ? _widthValue : null,
              ),
            ),
          ),
          SizedBox(height: AppGrid.grid16),

          // Type
          Text('TYPE', style: AppTypography.overline),
          SizedBox(height: AppGrid.grid8),
          _buildChipRow(
            labels: ButtonType.values.map((t) => t.name).toList(),
            selectedIndex: _type.index,
            onSelected: (i) => setState(() => _type = ButtonType.values[i]),
            style: chipStyle,
          ),
          SizedBox(height: AppGrid.grid16),

          // Size
          Text('SIZE', style: AppTypography.overline),
          SizedBox(height: AppGrid.grid8),
          _buildChipRow(
            labels: ButtonSize.values.map((s) => s.name).toList(),
            selectedIndex: _size.index,
            onSelected: (i) => setState(() => _size = ButtonSize.values[i]),
            style: chipStyle,
          ),
          SizedBox(height: AppGrid.grid16),

          // Color
          Text('COLOR', style: AppTypography.overline),
          SizedBox(height: AppGrid.grid8),
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
                        ? Border.all(color: AppColors.textPrimary, width: 2)
                        : Border.all(color: AppColors.surfaceBorder),
                  ),
                ),
              );
            }),
          ),
          SizedBox(height: AppGrid.grid4),
          Text(_colorOptions[_colorIndex].$1, style: AppTypography.caption),
          SizedBox(height: AppGrid.grid16),

          // Content
          Text('CONTENT', style: AppTypography.overline),
          SizedBox(height: AppGrid.grid8),
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
          SizedBox(height: AppGrid.grid16),

          // States
          Text('STATE', style: AppTypography.overline),
          SizedBox(height: AppGrid.grid8),
          _buildToggle('Disabled', _isDisabled, (v) => setState(() => _isDisabled = v)),
          _buildToggle('Loading', _isLoading, (v) => setState(() => _isLoading = v)),
          SizedBox(height: AppGrid.grid16),

          // Corner Radius
          _buildToggle('Override Corner Radius', _useRadiusOverride, (v) => setState(() => _useRadiusOverride = v)),
          if (_useRadiusOverride) ...[
            SizedBox(height: AppGrid.grid4),
            _buildChipRow(
              labels: _radiusOptions.map((r) => r.$1).toList(),
              selectedIndex: _radiusIndex,
              onSelected: (i) => setState(() => _radiusIndex = i),
              style: chipStyle,
            ),
            SizedBox(height: AppGrid.grid8),
          ],

          // Padding
          _buildToggle('Override Padding', _usePaddingOverride, (v) => setState(() => _usePaddingOverride = v)),
          if (_usePaddingOverride) ...[
            _buildSlider(
              label: 'Horizontal Padding',
              value: _paddingValue,
              min: 0,
              max: 48,
              onChanged: (v) => setState(() => _paddingValue = v),
            ),
          ],

          // Height
          _buildToggle('Override Height', _useHeightOverride, (v) => setState(() => _useHeightOverride = v)),
          if (_useHeightOverride) ...[
            _buildSlider(
              label: 'Height',
              value: _heightValue,
              min: 24,
              max: 80,
              onChanged: (v) => setState(() => _heightValue = v),
            ),
          ],

          // Width
          _buildToggle('Override Width', _useWidthOverride, (v) => setState(() => _useWidthOverride = v)),
          if (_useWidthOverride) ...[
            _buildSlider(
              label: 'Width',
              value: _widthValue,
              min: 40,
              max: 300,
              onChanged: (v) => setState(() => _widthValue = v),
            ),
          ],
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
            padding: EdgeInsets.symmetric(
              horizontal: AppPadding.threeQuarter,
              vertical: AppGrid.grid4,
            ),
            decoration: BoxDecoration(
              color: selected ? AppColors.brand : Colors.transparent,
              borderRadius: BorderRadius.circular(AppRadius.sm),
              border: Border.all(
                color: selected ? AppColors.brand : AppColors.surfaceBorder,
              ),
            ),
            child: Text(
              labels[i].toUpperCase(),
              style: style.copyWith(
                color: selected ? AppColors.textInverse : AppColors.textSecondary,
              ),
            ),
          ),
        );
      }),
    );
  }

  Widget _buildSlider({
    required String label,
    required double value,
    required double min,
    required double max,
    required ValueChanged<double> onChanged,
  }) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppGrid.grid8),
      child: Row(
        children: [
          SizedBox(
            width: 100,
            child: Text('$label: ${value.round()}px', style: AppTypography.caption),
          ),
          Expanded(
            child: SliderTheme(
              data: SliderThemeData(
                activeTrackColor: AppColors.brand,
                inactiveTrackColor: AppColors.surfaceBorder,
                thumbColor: AppColors.brand,
                overlayColor: AppColors.brand.withValues(alpha: 0.2),
                trackHeight: 2,
                thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
              ),
              child: Slider(
                value: value,
                min: min,
                max: max,
                onChanged: onChanged,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggle(String label, bool value, ValueChanged<bool> onChanged) {
    return Padding(
      padding: EdgeInsets.only(bottom: AppGrid.grid4),
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
          SizedBox(width: AppGrid.grid8),
          Text(label, style: AppTypography.bodySmall.regular),
        ],
      ),
    );
  }
}
