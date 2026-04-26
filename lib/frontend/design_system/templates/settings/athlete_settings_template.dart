import 'package:flutter/material.dart';
import '../../design_system.dart';

/// Template: Athlete Settings page.
///
/// Owns all [TextEditingController]s and [FocusNode]s for every editable field.
/// Fires per-field callbacks on every change (auto-save pattern).
/// Never navigates or calls services — collects and hands off only.
class AthleteSettingsTemplate extends StatefulWidget {
  // Display data
  final String? avatarUrl;

  // Initial field values
  final String initialFirstName;
  final String initialLastName;
  final String initialEmail;
  final String initialPhone;

  // Initial notification states
  final bool initialSessionReminders;
  final bool initialPractitionersUpdates;
  final bool initialProductUpdates;

  // Nav — AppNavBar (index 0 = home, 1 = crown, 2 = profile)
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  // Per-field auto-save callbacks
  final ValueChanged<String> onFirstNameChanged;
  final ValueChanged<String> onLastNameChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPhoneChanged;

  // Notification callbacks
  final ValueChanged<bool> onSessionRemindersChanged;
  final ValueChanged<bool> onPractitionersUpdatesChanged;
  final ValueChanged<bool> onProductUpdatesChanged;

  // Action callbacks
  final VoidCallback onAvatarTap;
  final VoidCallback onAccountSwitchTap;
  final VoidCallback onChangePasswordTap;
  final VoidCallback onSignOut;       // fires after confirmation dialog
  final VoidCallback onDeleteAccount; // fires after confirmation dialog

  const AthleteSettingsTemplate({
    super.key,
    this.avatarUrl,
    required this.initialFirstName,
    required this.initialLastName,
    required this.initialEmail,
    required this.initialPhone,
    required this.initialSessionReminders,
    required this.initialPractitionersUpdates,
    required this.initialProductUpdates,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onFirstNameChanged,
    required this.onLastNameChanged,
    required this.onEmailChanged,
    required this.onPhoneChanged,
    required this.onSessionRemindersChanged,
    required this.onPractitionersUpdatesChanged,
    required this.onProductUpdatesChanged,
    required this.onAvatarTap,
    required this.onAccountSwitchTap,
    required this.onChangePasswordTap,
    required this.onSignOut,
    required this.onDeleteAccount,
  });

  @override
  State<AthleteSettingsTemplate> createState() =>
      _AthleteSettingsTemplateState();
}

class _AthleteSettingsTemplateState extends State<AthleteSettingsTemplate> {
  // Controllers — owned here, never by child molecules
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _phoneController;

  // Focus nodes — owned here
  late final FocusNode _firstNameFocus;
  late final FocusNode _lastNameFocus;
  late final FocusNode _emailFocus;
  late final FocusNode _phoneFocus;

  // Local toggle state
  late bool _sessionReminders;
  late bool _practitionersUpdates;
  late bool _productUpdates;

  @override
  void initState() {
    super.initState();

    _firstNameController =
        TextEditingController(text: widget.initialFirstName);
    _lastNameController =
        TextEditingController(text: widget.initialLastName);
    _emailController =
        TextEditingController(text: widget.initialEmail);
    _phoneController =
        TextEditingController(text: widget.initialPhone);

    _firstNameFocus = FocusNode();
    _lastNameFocus = FocusNode();
    _emailFocus = FocusNode();
    _phoneFocus = FocusNode();

    _firstNameController.addListener(
        () => widget.onFirstNameChanged(_firstNameController.text));
    _lastNameController.addListener(
        () => widget.onLastNameChanged(_lastNameController.text));
    _emailController.addListener(
        () => widget.onEmailChanged(_emailController.text));

    _sessionReminders = widget.initialSessionReminders;
    _practitionersUpdates = widget.initialPractitionersUpdates;
    _productUpdates = widget.initialProductUpdates;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _phoneFocus.dispose();
    super.dispose();
  }

  void _onSignOutTap() => showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: AppConfirmationDialog(
            subtitle: 'Do you want to',
            title: 'Sign Out?',
            confirmLabel: 'Yes - Sign me out',
            cancelLabel: 'Not now',
            onConfirm: widget.onSignOut,
            onCancel: () => Navigator.of(context).pop(),
          ),
        ),
      );

  void _onDeleteAccountTap() => showDialog<void>(
        context: context,
        barrierDismissible: true,
        builder: (_) => Dialog(
          backgroundColor: Colors.transparent,
          child: AppConfirmationDialog(
            subtitle: 'Do you want to',
            title: 'Delete Your Account?',
            confirmLabel: 'Yes - Delete account',
            cancelLabel: 'No please',
            onConfirm: widget.onDeleteAccount,
            onCancel: () => Navigator.of(context).pop(),
          ),
        ),
      );

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      bottomNavigationBar: AppNavBar(
        tabs: const [
          NavBarTab(
            activeIcon: AppIcons.homeFilled,
            inactiveIcon: AppIcons.home,
          ),
          NavBarTab(
            activeIcon: AppIcons.crownFilled,
            inactiveIcon: AppIcons.crown,
          ),
          NavBarTab(
            activeIcon: AppIcons.profileFilled,
            inactiveIcon: AppIcons.profile,
          ),
        ],
        selectedIndex: widget.selectedIndex,
        onTabSelected: widget.onTabSelected,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          keyboardDismissBehavior: ScrollViewKeyboardDismissBehavior.onDrag,
          child: Padding(
            padding: const EdgeInsets.symmetric(
              horizontal: AppGrid.grid16,
              vertical: AppPadding.pagePadding,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // ── Header ──
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    SizedBox(width: IconSizes.lg),
                    AppAvatar(
                      content: const AvatarUpload(),
                      size: AvatarSize.xl,
                      onTap: widget.onAvatarTap,
                    ),
                    AppButton(
                      type: ButtonType.outline,
                      size: ButtonSize.md,
                      color: AppColors.textPrimary,
                      leadingIcon: AppIcons.profileFilled,
                      onPressed: widget.onAccountSwitchTap,
                    ),
                  ],
                ),
                const SizedBox(height: AppGrid.grid24),

                // ── Details section ──
                Row(
                  children: [
                    AppText(
                      'Details',
                      style: AppTypography.body.bold,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppGrid.grid8),
                    const Expanded(
                      child: Divider(
                        color: AppColors.surfaceBorder,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppGrid.grid16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText('First name', style: AppTypography.body.bold),
                    AppTextFieldMolecule(
                      controller: _firstNameController,
                      focusNode: _firstNameFocus,
                      showClearButton: false,
                    ),
                  ],
                ),
                const SizedBox(height: AppGrid.grid16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText('Last name', style: AppTypography.body.bold),
                    AppTextFieldMolecule(
                      controller: _lastNameController,
                      focusNode: _lastNameFocus,
                      showClearButton: false,
                    ),
                  ],
                ),
                const SizedBox(height: AppGrid.grid16),
                // Password — read-only display row; tapping navigates to change-password
                GestureDetector(
                  onTap: widget.onChangePasswordTap,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText('Password', style: AppTypography.body.bold),
                      const AppStaticDisplayField(
                        value: '••••••••',
                        alignment: Alignment.centerLeft,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: AppGrid.grid16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText('Email', style: AppTypography.body.bold),
                    AppTextFieldMolecule(
                      controller: _emailController,
                      focusNode: _emailFocus,
                      showClearButton: false,
                    ),
                  ],
                ),
                const SizedBox(height: AppGrid.grid16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText('Phone number', style: AppTypography.body.bold),
                    AppPhoneField(
                      controller: _phoneController,
                      focusNode: _phoneFocus,
                      onChanged: widget.onPhoneChanged,
                    ),
                  ],
                ),
                const SizedBox(height: AppGrid.grid24),

                // ── Notifications section ──
                Row(
                  children: [
                    AppText(
                      'Notifications',
                      style: AppTypography.body.bold,
                      color: AppColors.textSecondary,
                    ),
                    const SizedBox(width: AppGrid.grid8),
                    const Expanded(
                      child: Divider(
                        color: AppColors.surfaceBorder,
                        thickness: 1,
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: AppGrid.grid16),
                LabeledToggle(
                  label: 'Session Reminders',
                  value: _sessionReminders,
                  onChanged: (v) {
                    setState(() => _sessionReminders = v);
                    widget.onSessionRemindersChanged(v);
                  },
                ),
                const SizedBox(height: AppGrid.grid16),
                LabeledToggle(
                  label: 'Practitioners Updates',
                  value: _practitionersUpdates,
                  onChanged: (v) {
                    setState(() => _practitionersUpdates = v);
                    widget.onPractitionersUpdatesChanged(v);
                  },
                ),
                const SizedBox(height: AppGrid.grid16),
                LabeledToggle(
                  label: 'Product updates + tips',
                  value: _productUpdates,
                  onChanged: (v) {
                    setState(() => _productUpdates = v);
                    widget.onProductUpdatesChanged(v);
                  },
                ),
                const SizedBox(height: AppGrid.grid24),

                // ── Actions section ──
                AppButton(
                  type: ButtonType.outline,
                  size: ButtonSize.md,
                  color: AppColors.brand,
                  label: 'Sign out',
                  onPressed: _onSignOutTap,
                ),
                const SizedBox(height: AppGrid.grid16),
                AppButton(
                  type: ButtonType.ghost,
                  size: ButtonSize.md,
                  color: AppColors.error,
                  label: 'Delete account',
                  onPressed: _onDeleteAccountTap,
                ),
                const SizedBox(height: AppGrid.grid24),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
