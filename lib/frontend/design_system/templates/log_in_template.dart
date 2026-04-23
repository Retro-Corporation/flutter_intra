import 'package:flutter/material.dart';

import '../design_system.dart';

/// Template for Screen 02 (variant) — Log In.
///
/// Sibling of [SignUpTemplate] — same visual skeleton, different copy and
/// callback intent. No top chrome — no back arrow, no progress bar. Owns
/// every [TextEditingController] and [FocusNode] on the page, disables the
/// Log in button until both fields are non-empty, and hands collected values
/// off to [onLogIn] on submit. Never navigates and never calls a service.
class LogInTemplate extends StatefulWidget {
  /// Called when the user taps Log in with both fields non-empty.
  final ValueChanged<({String email, String password})> onLogIn;

  /// Called when the user taps Continue with Google.
  final VoidCallback onGoogle;

  /// Called when the user taps Create Account.
  final VoidCallback onCreateAccount;

  const LogInTemplate({
    super.key,
    required this.onLogIn,
    required this.onGoogle,
    required this.onCreateAccount,
  });

  @override
  State<LogInTemplate> createState() => _LogInTemplateState();
}

class _LogInTemplateState extends State<LogInTemplate> {
  // ── Controller + focus ownership ─────────────────────────────────────────
  late final TextEditingController _emailController;
  late final TextEditingController _passwordController;
  late final FocusNode _emailFocus;
  late final FocusNode _passwordFocus;

  // ── Derived state ─────────────────────────────────────────────────────────
  bool get _bothNonEmpty =>
      _emailController.text.isNotEmpty && _passwordController.text.isNotEmpty;

  @override
  void initState() {
    super.initState();
    _emailController = TextEditingController();
    _passwordController = TextEditingController();
    _emailFocus = FocusNode();
    _passwordFocus = FocusNode();

    _emailController.addListener(_onFieldChanged);
    _passwordController.addListener(_onFieldChanged);
  }

  @override
  void dispose() {
    _emailController.removeListener(_onFieldChanged);
    _passwordController.removeListener(_onFieldChanged);
    _emailController.dispose();
    _passwordController.dispose();
    _emailFocus.dispose();
    _passwordFocus.dispose();
    super.dispose();
  }

  void _onFieldChanged() => setState(() {});

  void _submit() {
    widget.onLogIn((
      email: _emailController.text,
      password: _passwordController.text,
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
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppPadding.rem15,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                const SizedBox(height: AppGrid.grid80),

                // Heading
                AppText(
                  'Build Your Kingdom',
                  style: AppTypography.heading5.bold,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppGrid.grid24),

                // Subheading
                AppText(
                  'Log in to your profile and start training.',
                  style: AppTypography.body.bold,
                  textAlign: TextAlign.center,
                ),

                const SizedBox(height: AppGrid.grid24),

                // Email field
                AppTextFieldMolecule(
                  controller: _emailController,
                  focusNode: _emailFocus,
                  hintText: 'Email',
                  keyboardType: TextInputType.emailAddress,
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

                // Log in — primary CTA, disabled until both fields filled
                AppButton(
                  label: 'Log in',
                  type: ButtonType.filled,
                  size: ButtonSize.md,
                  color: AppColors.brand,
                  isDisabled: !_bothNonEmpty,
                  onPressed: _submit,
                ),

                const SizedBox(height: AppGrid.grid24),

                // Continue with Google — dedicated atom (multi-color SVG)
                AppGoogleSignInButton(onPressed: widget.onGoogle),

                const SizedBox(height: AppGrid.grid24),

                // "or" divider
                const AppDivider(label: 'or'),

                const SizedBox(height: AppGrid.grid24),

                // Create Account — outline button
                AppButton(
                  label: 'Create Account',
                  type: ButtonType.outline,
                  size: ButtonSize.md,
                  color: AppColors.textPrimary,
                  onPressed: widget.onCreateAccount,
                ),

                const Expanded(child: SizedBox.shrink()),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
