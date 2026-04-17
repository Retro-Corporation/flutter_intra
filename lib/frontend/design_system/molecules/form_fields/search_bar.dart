import 'package:flutter/material.dart';
import '../../atoms/primitives/icon.dart';
import '../../atoms/inputs/text_field.dart';
import '../../atoms/inputs/text_field_3d.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/padding.dart';
import '../../foundation/type/typography.dart';
import '../../foundation/space/radius.dart';
import '../../icons/app_icons.dart';
import '../../icons/icon_sizes.dart';
import 'search_bar_types.dart';

/// Molecule: search bar. Shows a search icon by default, and swaps to a
/// clear (×) icon when text is present.
///
/// Two visual variants via [SearchBarVariant]:
/// - [SearchBarVariant.pill] — flat pill-shaped input (default).
/// - [SearchBarVariant.card] — 3D raised card input with 8px radius.
class AppSearchBar extends StatefulWidget {
  final String? hintText;
  final TextEditingController controller;
  final FocusNode focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Visual style. Defaults to [SearchBarVariant.pill] — no existing callers break.
  final SearchBarVariant variant;

  const AppSearchBar({
    super.key,
    required this.controller,
    required this.focusNode,
    this.hintText,
    this.onChanged,
    this.onSubmitted,
    this.variant = SearchBarVariant.pill,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar> {
  bool _isFocused = false;

  @override
  void initState() {
    super.initState();
    widget.controller.addListener(_onTextChanged);
    if (widget.variant == SearchBarVariant.card) {
      widget.focusNode.addListener(_onFocusChanged);
    }
  }

  @override
  void dispose() {
    widget.controller.removeListener(_onTextChanged);
    if (widget.variant == SearchBarVariant.card) {
      widget.focusNode.removeListener(_onFocusChanged);
    }
    super.dispose();
  }

  void _onTextChanged() => setState(() {});

  void _onFocusChanged() =>
      setState(() => _isFocused = widget.focusNode.hasFocus);

  void _clear() {
    widget.controller.clear();
    widget.onChanged?.call('');
  }

  /// Suffix icon shared between both variants.
  Widget _buildSuffixIcon() {
    return widget.controller.text.isNotEmpty
        ? GestureDetector(
            onTap: _clear,
            child: Padding(
              padding: const EdgeInsets.only(right: AppPadding.inputPaddingH),
              child: AppIcon(
                AppIcons.close,
                size: IconSizes.md,
                color: AppColors.textSecondary,
              ),
            ),
          )
        : Padding(
            padding: const EdgeInsets.only(right: AppPadding.inputPaddingH),
            child: AppIcon(
              AppIcons.search,
              size: IconSizes.md,
              color: AppColors.textSecondary,
            ),
          );
  }

  @override
  Widget build(BuildContext context) {
    return switch (widget.variant) {
      SearchBarVariant.pill => _buildPill(),
      SearchBarVariant.card => _buildCard(),
    };
  }

  Widget _buildPill() {
    return AppTextField(
      controller: widget.controller,
      focusNode: widget.focusNode,
      hintText: widget.hintText ?? 'Search...',
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      borderRadius: AppRadius.pill,
      suffixWidget: _buildSuffixIcon(),
    );
  }

  Widget _buildCard() {
    return AppTextField3D(
      controller: widget.controller,
      focusNode: widget.focusNode,
      hintText: widget.hintText ?? 'Search...',
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      borderColor: _isFocused ? AppColors.brand : AppColors.surfaceBorder,
      backgroundColor: AppColors.background,
      textStyle: AppTypography.body.bold,
      suffixWidget: _buildSuffixIcon(),
    );
  }
}
