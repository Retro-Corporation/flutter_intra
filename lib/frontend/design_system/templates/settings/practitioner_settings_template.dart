import 'package:flutter/material.dart';
import '../../design_system.dart';

/// Template: Practitioner Settings page.
///
/// Owns all [TextEditingController]s and [FocusNode]s for every editable field.
/// Fires per-field callbacks on every change (auto-save pattern).
/// Never navigates or calls services — collects and hands off only.
class PractitionerSettingsTemplate extends StatefulWidget {
  // Display data
  final bool hasOrganization;
  final String? organizationName;
  final String? clinicBranchName;
  final String? avatarUrl;

  // Initial field values
  final String initialFirstName;
  final String initialLastName;
  final String initialEmail;
  final String initialPersonalPhone;
  final String initialWorkEmail;
  final String initialWorkPhone;

  // Initial notification states
  final bool initialClientHelpAlerts;
  final bool initialPractitionersUpdates;
  final bool initialProductUpdates;

  // Nav — AppNavBar (index 0 = group, 1 = body, 2 = profile)
  final int selectedIndex;
  final ValueChanged<int> onTabSelected;

  // Per-field auto-save callbacks
  final ValueChanged<String> onFirstNameChanged;
  final ValueChanged<String> onLastNameChanged;
  final ValueChanged<String> onEmailChanged;
  final ValueChanged<String> onPersonalPhoneChanged;
  final ValueChanged<String> onWorkEmailChanged;
  final ValueChanged<String> onWorkPhoneChanged;

  // Notification callbacks
  final ValueChanged<bool> onClientHelpAlertsChanged;
  final ValueChanged<bool> onPractitionersUpdatesChanged;
  final ValueChanged<bool> onProductUpdatesChanged;

  // Action callbacks
  final VoidCallback onAvatarTap;
  final VoidCallback onAccountSwitchTap;
  final VoidCallback onJoinBranch;
  final VoidCallback onCreateOrganization;
  final VoidCallback onOrganizationTap;
  final VoidCallback onClinicBranchTap;
  final VoidCallback onChangePasswordTap;
  final VoidCallback onSignOut;
  final VoidCallback onDeleteAccount;

  const PractitionerSettingsTemplate({
    super.key,
    required this.hasOrganization,
    this.organizationName,
    this.clinicBranchName,
    this.avatarUrl,
    required this.initialFirstName,
    required this.initialLastName,
    required this.initialEmail,
    required this.initialPersonalPhone,
    required this.initialWorkEmail,
    required this.initialWorkPhone,
    required this.initialClientHelpAlerts,
    required this.initialPractitionersUpdates,
    required this.initialProductUpdates,
    required this.selectedIndex,
    required this.onTabSelected,
    required this.onFirstNameChanged,
    required this.onLastNameChanged,
    required this.onEmailChanged,
    required this.onPersonalPhoneChanged,
    required this.onWorkEmailChanged,
    required this.onWorkPhoneChanged,
    required this.onClientHelpAlertsChanged,
    required this.onPractitionersUpdatesChanged,
    required this.onProductUpdatesChanged,
    required this.onAvatarTap,
    required this.onAccountSwitchTap,
    required this.onJoinBranch,
    required this.onCreateOrganization,
    required this.onOrganizationTap,
    required this.onClinicBranchTap,
    required this.onChangePasswordTap,
    required this.onSignOut,
    required this.onDeleteAccount,
  });

  @override
  State<PractitionerSettingsTemplate> createState() =>
      _PractitionerSettingsTemplateState();
}

class _PractitionerSettingsTemplateState
    extends State<PractitionerSettingsTemplate> {
  // Controllers — owned here, never by child molecules
  late final TextEditingController _firstNameController;
  late final TextEditingController _lastNameController;
  late final TextEditingController _emailController;
  late final TextEditingController _personalPhoneController;
  late final TextEditingController _workEmailController;
  late final TextEditingController _workPhoneController;

  // Focus nodes
  late final FocusNode _firstNameFocus;
  late final FocusNode _lastNameFocus;
  late final FocusNode _emailFocus;
  late final FocusNode _personalPhoneFocus;
  late final FocusNode _workEmailFocus;
  late final FocusNode _workPhoneFocus;

  // Toggle state
  late bool _clientHelpAlerts;
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
    _personalPhoneController =
        TextEditingController(text: widget.initialPersonalPhone);
    _workEmailController =
        TextEditingController(text: widget.initialWorkEmail);
    _workPhoneController =
        TextEditingController(text: widget.initialWorkPhone);

    _firstNameFocus = FocusNode();
    _lastNameFocus = FocusNode();
    _emailFocus = FocusNode();
    _personalPhoneFocus = FocusNode();
    _workEmailFocus = FocusNode();
    _workPhoneFocus = FocusNode();

    // Listeners fire auto-save callbacks on every keystroke
    _firstNameController.addListener(
        () => widget.onFirstNameChanged(_firstNameController.text));
    _lastNameController.addListener(
        () => widget.onLastNameChanged(_lastNameController.text));
    _emailController.addListener(
        () => widget.onEmailChanged(_emailController.text));
    _workEmailController.addListener(
        () => widget.onWorkEmailChanged(_workEmailController.text));
    // Phone fields use onChanged callback directly — no listener needed

    _clientHelpAlerts = widget.initialClientHelpAlerts;
    _practitionersUpdates = widget.initialPractitionersUpdates;
    _productUpdates = widget.initialProductUpdates;
  }

  @override
  void dispose() {
    _firstNameController.dispose();
    _lastNameController.dispose();
    _emailController.dispose();
    _personalPhoneController.dispose();
    _workEmailController.dispose();
    _workPhoneController.dispose();
    _firstNameFocus.dispose();
    _lastNameFocus.dispose();
    _emailFocus.dispose();
    _personalPhoneFocus.dispose();
    _workEmailFocus.dispose();
    _workPhoneFocus.dispose();
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
            activeIcon: AppIcons.groupFilled,
            inactiveIcon: AppIcons.group,
          ),
          NavBarTab(
            activeIcon: AppIcons.crownFilled,
            inactiveIcon: AppIcons.crown,
          ),
          NavBarTab(
            activeIcon: AppIcons.doctorFilled,
            inactiveIcon: AppIcons.doctor,
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

                // ── Join/Create (no org) ──
                if (!widget.hasOrganization) ...[
                  AppButton(
                    type: ButtonType.filled,
                    leadingIcon: AppIcons.group,
                    label: 'Join Branch',
                    onPressed: widget.onJoinBranch,
                  ),
                  const SizedBox(height: AppGrid.grid12),
                  AppButton(
                    type: ButtonType.outline,
                    color: AppColors.textPrimary,
                    label: 'Create Organization',
                    onPressed: widget.onCreateOrganization,
                  ),
                  const SizedBox(height: AppGrid.grid24),
                ],

                // ── Org/Branch display (has org) ──
                if (widget.hasOrganization) ...[
                  GestureDetector(
                    onTap: widget.onOrganizationTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Organization',
                          style: AppTypography.body.bold,
                        ),
                        AppStaticDisplayField(
                          value: widget.organizationName ?? '',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppGrid.grid16),
                  GestureDetector(
                    onTap: widget.onClinicBranchTap,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        AppText(
                          'Clinic Branch',
                          style: AppTypography.body.bold,
                        ),
                        AppStaticDisplayField(
                          value: widget.clinicBranchName ?? '',
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: AppGrid.grid24),
                ],

                // ── Details ──
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
                GestureDetector(
                  onTap: widget.onChangePasswordTap,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      AppText(
                        'Password',
                        style: AppTypography.body.bold,
                      ),
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
                    AppText('Personal email', style: AppTypography.body.bold),
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
                    AppText('Personal phone number', style: AppTypography.body.bold),
                    AppPhoneField(
                      controller: _personalPhoneController,
                      focusNode: _personalPhoneFocus,
                      onChanged: widget.onPersonalPhoneChanged,
                    ),
                  ],
                ),
                const SizedBox(height: AppGrid.grid24),

                // ── Work Details ──
                Row(
                  children: [
                    AppText(
                      'Work Details',
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
                    AppText('Work email', style: AppTypography.body.bold),
                    AppTextFieldMolecule(
                      controller: _workEmailController,
                      focusNode: _workEmailFocus,
                      showClearButton: false,
                    ),
                  ],
                ),
                const SizedBox(height: AppGrid.grid16),
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    AppText('Work phone number', style: AppTypography.body.bold),
                    AppPhoneField(
                      controller: _workPhoneController,
                      focusNode: _workPhoneFocus,
                      onChanged: widget.onWorkPhoneChanged,
                    ),
                  ],
                ),
                const SizedBox(height: AppGrid.grid24),

                // ── Practitioner Notifications ──
                Row(
                  children: [
                    AppText(
                      'Practitioner Notifications',
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
                  label: 'Client help alerts',
                  value: _clientHelpAlerts,
                  onChanged: (v) {
                    setState(() => _clientHelpAlerts = v);
                    widget.onClientHelpAlertsChanged(v);
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

                // ── Actions ──
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
