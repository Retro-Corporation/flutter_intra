import 'package:flutter/material.dart';

import '../design_system.dart';

/// Template for Screen 06 — Code Entry.
///
/// The user enters the 6-digit code sent by their practitioner.
/// Owns all [TextEditingController]s and [FocusNode]s for the OTP row,
/// nudges the progress bar as cells fill, and calls [onCompleted] with the
/// code when all six digits are entered. Never navigates or validates.
class CodeEntryTemplate extends StatefulWidget {
  const CodeEntryTemplate({
    super.key,
    required this.onBack,
    required this.onCompleted,
    required this.onPractitionerSignIn,
    required this.onSkip,
    this.progressBaseValue = 0.0,
    this.cellProgressDelta = 0.02,
    this.errorMessage,
  });

  /// Called when the user taps the back arrow.
  final VoidCallback onBack;

  /// Called when all 6 digits are filled. Parent validates — never this template.
  final ValueChanged<String> onCompleted;

  /// Called when the user taps "Practitioner Sign In".
  final VoidCallback onPractitionerSignIn;

  /// Called when the user taps "Skip for Now".
  final VoidCallback onSkip;

  /// Where this screen starts in the overall flow progress (e.g. 0.5).
  final double progressBaseValue;

  /// How much each filled cell nudges the progress bar forward (e.g. 0.02).
  final double cellProgressDelta;

  /// When non-null, cells render in error state and this string replaces
  /// the default helper text below the OTP row.
  final String? errorMessage;

  @override
  State<CodeEntryTemplate> createState() => _CodeEntryTemplateState();
}

class _CodeEntryTemplateState extends State<CodeEntryTemplate> {
  // ── Controller + focus ownership ─────────────────────────────────────────
  late final List<TextEditingController> _controllers;
  late final List<FocusNode> _focusNodes;
  static const int _cellCount = 6;

  // ── Derived state ─────────────────────────────────────────────────────────
  int get _filledCount =>
      _controllers.where((c) => c.text.isNotEmpty).length;

  bool get _allFilled => _filledCount == _cellCount;

  double get _progressValue =>
      widget.progressBaseValue + _filledCount * widget.cellProgressDelta;

  @override
  void initState() {
    super.initState();
    _controllers = List.generate(_cellCount, (_) => TextEditingController());
    _focusNodes = List.generate(_cellCount, (_) => FocusNode());
    for (final c in _controllers) {
      c.addListener(_onOtpChanged);
    }
  }

  @override
  void dispose() {
    for (final c in _controllers) {
      c.removeListener(_onOtpChanged);
      c.dispose();
    }
    for (final fn in _focusNodes) {
      fn.dispose();
    }
    super.dispose();
  }

  void _onOtpChanged() => setState(() {});

  @override
  Widget build(BuildContext context) {
    final hasError = widget.errorMessage != null;

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: GestureDetector(
          behavior: HitTestBehavior.translucent,
          onTap: () => FocusScope.of(context).unfocus(),
          child: Stack(
            children: [
              // ── Content column ────────────────────────────────────────────
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

                    const SizedBox(height: AppGrid.grid32),

                    // Heading
                    AppText(
                      'Working with a practitioner?',
                      style: AppTypography.bodyLarge.bold,
                      textAlign: TextAlign.center,
                    ),

                    // Subheading
                    AppText(
                      'Enter the code to access your training plan',
                      style: AppTypography.body.regular,
                      color: AppColors.textPrimary,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppGrid.grid32),

                    // OTP row
                    AppOtpField(
                      controllers: _controllers,
                      focusNodes: _focusNodes,
                      hasError: hasError,
                      onChanged: (_) {},
                      onCompleted: widget.onCompleted,
                    ),

                    const SizedBox(height: AppGrid.grid12),

                    // Helper / error text
                    AppText(
                      widget.errorMessage ??
                          'Check your email or messages for the code your practitioner sent you.',
                      style: AppTypography.bodySmall.regular,
                      color: hasError
                          ? AppColors.error
                          : AppColors.textSecondary,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppGrid.grid60),

                    // Divider — 60px below helper text
                    const AppDivider(label: 'or'),

                    const Expanded(child: SizedBox.shrink()),

                    const SizedBox(height: AppGrid.grid80),
                  ],
                ),
              ),

              // ── Bottom buttons — pinned ────────────────────────────────────
              Positioned(
                left: AppPadding.rem15,
                right: AppPadding.rem15,
                bottom: AppGrid.grid16,
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    AppButton(
                      label: 'Practitioner Sign In',
                      type: ButtonType.filled,
                      size: ButtonSize.md,
                      color: AppColors.textPrimary,
                      onPressed: widget.onPractitionerSignIn,
                    ),
                    const SizedBox(height: AppGrid.grid12),
                    AppButton(
                      label: _allFilled ? 'Continue' : 'Skip for Now',
                      type: ButtonType.filled,
                      size: ButtonSize.md,
                      color: AppColors.brand,
                      onPressed: _allFilled
                          ? () => widget.onCompleted(
                              _controllers.map((c) => c.text).join())
                          : widget.onSkip,
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
