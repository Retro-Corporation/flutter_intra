import 'package:flutter/material.dart';

import '../design_system.dart';

/// Template for Screen 03 — Name Entry.
///
/// Collects a user's first and last name. Owns all [TextEditingController]s
/// and [FocusNode]s, computes sub-progress as fields fill, and calls
/// [onSubmit] with the collected values. Never navigates or calls a service.
class NameEntryTemplate extends StatefulWidget {
  const NameEntryTemplate({
    super.key,
    required this.onBack,
    required this.onSubmit,
    this.progressBaseValue = 0.0,
    this.fieldProgressDelta = 0.03,
  });

  /// Called when the user taps the back arrow.
  final VoidCallback onBack;

  /// Called when the user taps Continue with both fields non-empty.
  final ValueChanged<({String first, String last})> onSubmit;

  /// Where this screen starts in the overall flow progress (e.g. 0.2).
  final double progressBaseValue;

  /// How much each filled field nudges the progress bar forward (2–5%).
  final double fieldProgressDelta;

  @override
  State<NameEntryTemplate> createState() => _NameEntryTemplateState();
}

class _NameEntryTemplateState extends State<NameEntryTemplate> {
  // ── Controller + focus ownership ─────────────────────────────────────────
  late final TextEditingController _firstController;
  late final TextEditingController _lastController;
  late final FocusNode _firstFocus;
  late final FocusNode _lastFocus;

  // ── Derived state ─────────────────────────────────────────────────────────
  bool get _firstNonEmpty => _firstController.text.isNotEmpty;
  bool get _lastNonEmpty => _lastController.text.isNotEmpty;
  bool get _bothNonEmpty => _firstNonEmpty && _lastNonEmpty;

  double get _progressValue =>
      widget.progressBaseValue +
      (_firstNonEmpty ? widget.fieldProgressDelta : 0) +
      (_lastNonEmpty ? widget.fieldProgressDelta : 0);

  @override
  void initState() {
    super.initState();
    _firstController = TextEditingController();
    _lastController = TextEditingController();
    _firstFocus = FocusNode();
    _lastFocus = FocusNode();

    _firstController.addListener(_onFieldChanged);
    _lastController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _firstController.removeListener(_onFieldChanged);
    _lastController.removeListener(_onFieldChanged);
    _firstController.dispose();
    _lastController.dispose();
    _firstFocus.dispose();
    _lastFocus.dispose();
    super.dispose();
  }

  void _onFieldChanged() => setState(() {});

  void _submit() {
    widget.onSubmit((
      first: _firstController.text,
      last: _lastController.text,
    ));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              // ── Content column ──────────────────────────────────────────
              Padding(
                padding: const EdgeInsets.symmetric(
                  horizontal: AppPadding.rem15,
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const SizedBox(height: AppGrid.grid16),

                    // Top bar: back arrow + progress bar
                    Row(
                      children: [
                        GestureDetector(
                          onTap: widget.onBack,
                          child: AppIcon(
                            AppIcons.arrowBack,
                            size: IconSizes.md,
                          ),
                        ),
                        const SizedBox(width: AppGrid.grid12),
                        Expanded(
                          child: AppProgressBar(value: _progressValue),
                        ),
                      ],
                    ),

                    const SizedBox(height: AppGrid.grid44),

                    // Heading
                    AppText(
                      'What is your full name?',
                      style: AppTypography.bodyLarge.bold,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppGrid.grid24),

                    // First name field
                    AppTextFieldMolecule(
                      controller: _firstController,
                      focusNode: _firstFocus,
                      hintText: 'First name',
                      onSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_lastFocus),
                    ),

                    const SizedBox(height: AppGrid.grid24),

                    // Last name field
                    AppTextFieldMolecule(
                      controller: _lastController,
                      focusNode: _lastFocus,
                      hintText: 'Last name',
                    ),

                    const SizedBox(height: AppGrid.grid24),

                    // Spacer pushes Continue button clearance to bottom
                    const Expanded(child: SizedBox.shrink()),
                    const SizedBox(height: AppGrid.grid80),
                  ],
                ),
              ),

              // ── Continue button — pinned to bottom ──────────────────────
              Positioned(
                left: AppPadding.rem15,
                right: AppPadding.rem15,
                bottom: AppGrid.grid60,
                child: AppButton(
                  label: 'Continue',
                  type: ButtonType.filled,
                  size: ButtonSize.md,
                  color: AppColors.brand,
                  isDisabled: !_bothNonEmpty,
                  onPressed: _submit,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
