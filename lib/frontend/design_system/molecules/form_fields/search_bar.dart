import 'package:flutter/material.dart';
import '../../atoms/primitives/icon.dart';
import '../../atoms/inputs/text_field.dart';
import '../../foundation/color/colors.dart';
import '../../foundation/space/padding.dart';
import '../../foundation/space/radius.dart';
import '../../icons/app_icons.dart';
import '../../icons/icon_sizes.dart';
import '../behaviors/controller_owner_mixin.dart';

/// Molecule: pill-shaped search bar. Shows a search icon by default, and
/// swaps to a clear (close) icon when text is present so the user can
/// clear the input.
class AppSearchBar extends StatefulWidget {
  final String? hintText;
  final TextEditingController? controller;
  final FocusNode? focusNode;
  final ValueChanged<String>? onChanged;
  final ValueChanged<String>? onSubmitted;

  const AppSearchBar({
    super.key,
    this.hintText,
    this.controller,
    this.focusNode,
    this.onChanged,
    this.onSubmitted,
  });

  @override
  State<AppSearchBar> createState() => _AppSearchBarState();
}

class _AppSearchBarState extends State<AppSearchBar>
    with ControllerOwnerMixin {
  @override
  TextEditingController? get externalController => widget.controller;

  @override
  void onTextChanged() {
    setState(() {});
  }

  @override
  void initState() {
    super.initState();
    initController();
  }

  @override
  void dispose() {
    disposeController();
    super.dispose();
  }

  void _clear() {
    controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    // When text is present, show clear icon; otherwise show search icon.
    final suffixIcon = hasText
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

    return AppTextField(
      controller: controller,
      focusNode: widget.focusNode,
      hintText: widget.hintText ?? 'Search...',
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      borderRadius: AppRadius.pill,
      suffixWidget: suffixIcon,
    );
  }
}
