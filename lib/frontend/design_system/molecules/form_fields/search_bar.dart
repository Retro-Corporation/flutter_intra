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
import '../behaviors/controller_owner_mixin.dart';
import '../behaviors/focus_owner_mixin.dart';
import 'search_bar_types.dart';

/// Molecule: search bar. Shows a search icon by default, and swaps to a
/// clear (×) icon when text is present.
///
/// Two visual variants via [SearchBarVariant]:
/// - [SearchBarVariant.pill] — flat pill-shaped input (default).
/// - [SearchBarVariant.card] — 3D raised card input with 8px radius.
class AppSearchBar extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  /// Visual style. Defaults to [SearchBarVariant.pill] — no existing callers break.
  final SearchBarVariant variant;

  const AppSearchBar({
    super.key,
    this.hintText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
    this.variant = SearchBarVariant.pill,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar>
    with ControllerOwnerMixin, FocusOwnerMixin {
  @override
  TextEditingController? get externalController => widget.controller;

  @override
  FocusNode? get externalFocusNode => widget.focusNode;

  @override
  void onTextChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initController();
    if (widget.variant == SearchBarVariant.card) initFocusOwner();
  }

  @override
  void dispose() {
    if (widget.variant == SearchBarVariant.card) disposeFocusOwner();
    disposeController();
    super.dispose();
  }

  void _clear() {
    controller.clear();
    widget.onChanged?.call('');
  }

  /// Suffix icon shared between both variants.
  Widget _buildSuffixIcon() {
    return hasText
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
      controller: controller,
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
      controller: controller,
      focusNode: effectiveFocusNode,
      hintText: widget.hintText ?? 'Search...',
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      borderColor: isFocused ? AppColors.brand : AppColors.surfaceBorder,
      backgroundColor: AppColors.background,
      textStyle: AppTypography.body.bold,
      suffixWidget: _buildSuffixIcon(),
    );
  }
}
