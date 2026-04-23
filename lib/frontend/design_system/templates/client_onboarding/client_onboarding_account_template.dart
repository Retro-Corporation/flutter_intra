import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../../design_system.dart';
import 'client_onboarding_account_template_types.dart';

/// Template: Client Onboarding — Account Creation (Step 1 of 2).
///
/// Collects email, password, and phone number for a new client account.
/// Progress bar runs from [progressBaseValue] → 0.60 as each field becomes
/// valid. Create Account button is disabled until all three fields pass
/// validation. Hands collected values to [onSubmit]. Never navigates or
/// calls a service.
///
/// Enhancement: email validates on blur (error shown only after user leaves
/// the field). Haptic feedback fires on Create Account tap.
class ClientOnboardingAccountTemplate extends StatefulWidget {
  /// Called when the user taps the back arrow.
  final VoidCallback onBack;

  /// Called when the user taps Create Account with all fields valid.
  final ValueChanged<ClientOnboardingAccountResult> onSubmit;

  /// Where this screen starts in the overall flow progress.
  final double progressBaseValue;

  const ClientOnboardingAccountTemplate({
    super.key,
    required this.onBack,
    required this.onSubmit,
    this.progressBaseValue = 0.0,
  });

  @override
  State<ClientOnboardingAccountTemplate> createState() =>
      _ClientOnboardingAccountTemplateState();
}

class _ClientOnboardingAccountTemplateState
    extends State<ClientOnboardingAccountTemplate> {
  // ── Controller + focus ownership ─────────────────────────────────────────
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final TextEditingController _phoneController;
  late final FocusNode _emailFocus;
  late final FocusNode _passwordFocus;
  late final FocusNode _phoneFocus;

  // ── Email blur tracking ───────────────────────────────────────────────────
  // Error only shown after the user has left the email field at least once.
  bool _emailBlurred = false;

  // ── Progress constants ────────────────────────────────────────────────────
  static const double _progressMax = 0.60;

  // ── Validation helpers ────────────────────────────────────────────────────
  static bool _isValidEmail(String v) =>
      RegExp(r'^[\w.+\-]+@[\w\-]+\.[\w.]+$').hasMatch(v);

  static bool _isCompletePhone(String v) =>
      v.replaceAll(RegExp(r'\D'), '').length == 10;

  // ── Derived state ─────────────────────────────────────────────────────────
  bool get _emailValid => _isValidEmail(_emailController.text);
  bool get _passwordValid => _passwordController.text.isNotEmpty;
  bool get _phoneValid => _isCompletePhone(_phoneController.text);
  bool get _allValid => _emailValid && _passwordValid && _phoneValid;

  double get _progressValue {
    final validCount = (_emailValid ? 1 : 0) +
        (_passwordValid ? 1 : 0) +
        (_phoneValid ? 1 : 0);
    final step = (_progressMax - widget.progressBaseValue) / 3;
    return widget.progressBaseValue + validCount * step;
  }

  FieldState get _emailFieldState {
    if (!_emailBlurred) return FieldState.defaultState;
    if (_emailController.text.isEmpty) return FieldState.defaultState;
    return _emailValid ? FieldState.defaultState : FieldState.error;
  }

  String? get _emailHelperText {
    if (_emailFieldState == FieldState.error) {
      return 'Please enter a valid email address';
    }
    return null;
  }

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _phoneController = TextEditingController();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();
    _phoneFocus = FocusNode();

    _emailController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
    _phoneController.addListener(_onFieldChanged);
    _emailFocus.addListener(_onEmailFocusChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onFieldChanged);
    _passwordController.removeListener(_onFieldChanged);
    _phoneController.removeListener(_onFieldChanged);
    _emailFocus.removeListener(_onEmailFocusChanged);

    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _onFieldChanged() => setState(() {});

  void _onEmailFocusChanged() {
    if (!_emailFocus.hasFocus && !_emailBlurred) {
      setState(() => _emailBlurred = true);
    }
  }

  void _submit() {
    HapticFeedback.lightImpact();
    widget.onSubmit(ClientOnboardingAccountResult(
      email: _emailController.text,
      password: _passwordController.text,
      phone: _phoneController.text,
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

                    const SizedBox(height: AppGrid.grid44),

                    // Heading
                    AppText(
                      'Create a new client account',
                      style: AppTypography.bodyLarge.bold,
                      textAlign: TextAlign.center,
                    ),

                    const SizedBox(height: AppGrid.grid24),

                    // Email field — validates on blur
                    AppTextFieldMolecule(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      hintText: 'Email',
                      keyboardType: TextInputType.emailAddress,
                      state: _emailFieldState,
                      helperText: _emailHelperText,
                      onSubmitted: (_) =>
                          FocusScope.of(context).requestFocus(_passwordFocus),
                    ),

                    const SizedBox(height: AppGrid.grid24),

                    // Password field
                    AppPasswordField(
                      controller: _passwordController,
                      focusNode: _passwordFocus,
                      hintText: 'Password',
                    ),

                    const SizedBox(height: AppGrid.grid24),

                    // Phone field
                    AppPhoneField(
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      hintText: 'Phone number',
                    ),

                    const SizedBox(height: AppGrid.grid24),

                    const Expanded(child: SizedBox.shrink()),
                    const SizedBox(height: AppGrid.grid80),
                  ],
                ),
              ),

              // ── Create Account button — pinned to bottom ──────────────────
              Positioned(
                left: AppPadding.rem15,
                right: AppPadding.rem15,
                bottom: AppGrid.grid60,
                child: AppButton(
                  label: 'Create Account',
                  type: ButtonType.filled,
                  size: ButtonSize.md,
                  color: AppColors.brand,
                  isDisabled: !_allValid,
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
