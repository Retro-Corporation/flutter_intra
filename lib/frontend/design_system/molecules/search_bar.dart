import 'package:flutter/material.dart';
import '../design_system.dart';

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

class _AppSearchBarState extends State<AppSearchBar> {
  late TextEditingController _controller;
  bool _ownsController = false;
  bool _hasText = false;

  @override
  void initState() {
    super.initState();
    if (widget.controller != null) {
      _controller = widget.controller!;
    } else {
      _controller = TextEditingController();
      _ownsController = true;
    }
    _hasText = _controller.text.isNotEmpty;
    _controller.addListener(_onTextChanged);
  }

  @override
  void dispose() {
    _controller.removeListener(_onTextChanged);
    if (_ownsController) _controller.dispose();
    super.dispose();
  }

  void _onTextChanged() {
    final hasText = _controller.text.isNotEmpty;
    if (hasText != _hasText) {
      setState(() => _hasText = hasText);
    }
  }

  void _clear() {
    _controller.clear();
    widget.onChanged?.call('');
  }

  @override
  Widget build(BuildContext context) {
    // When text is present, show clear icon; otherwise show search icon.
    final suffixIcon = _hasText
        ? GestureDetector(
            onTap: _clear,
            child: Padding(
              padding: EdgeInsets.only(right: AppPadding.inputPaddingH),
              child: AppIcon(
                AppIcons.close,
                size: IconSizes.md,
                color: AppColors.textSecondary,
              ),
            ),
          )
        : Padding(
            padding: EdgeInsets.only(right: AppPadding.inputPaddingH),
            child: AppIcon(
              AppIcons.search,
              size: IconSizes.md,
              color: AppColors.textSecondary,
            ),
          );

    return AppTextField(
      controller: _controller,
      focusNode: widget.focusNode,
      hintText: widget.hintText ?? 'Search...',
      onChanged: widget.onChanged,
      onSubmitted: widget.onSubmitted,
      borderRadius: AppRadius.pill,
      suffixWidget: suffixIcon,
      showClearIcon: false,
    );
  }
}
