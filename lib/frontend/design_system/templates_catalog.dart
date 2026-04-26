import 'package:flutter/material.dart';
import 'design_system.dart';
import 'templates/client_list_template.dart';
import 'templates/create_exercise/create_exercise_details_template.dart';
import 'templates/settings/athlete_settings_template.dart';
import 'templates/settings/practitioner_settings_template.dart';
import 'templates/value_explanation_template.dart';

/// Run with: flutter run -t lib/frontend/design_system/templates_catalog.dart
void main() => runApp(const TemplatesCatalogApp());

class TemplatesCatalogApp extends StatelessWidget {
  const TemplatesCatalogApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Templates',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.dark,
      home: const TemplatesCatalogHome(),
    );
  }
}

class TemplatesCatalogHome extends StatelessWidget {
  const TemplatesCatalogHome({super.key});

  // Add any template here — WIP or done. One line per template.
  // _HelloWorldTemplate is defined at the bottom of this file as a smoke test.
  static final Map<String, WidgetBuilder> _templates = {
    'Hello World': (_) => const _TemplateShell(child: _HelloWorldTemplate()),
    'Sign Up': (_) => _TemplateShell(
      child: SignUpTemplate(
        onCreateAccount: (_) {},
        onGoogle: () {},
        onLogIn: () {},
      ),
    ),
    'Log In': (_) => _TemplateShell(
      child: LogInTemplate(
        onLogIn: (_) {},
        onGoogle: () {},
        onCreateAccount: () {},
      ),
    ),
    'Name Entry': (_) => _TemplateShell(
      child: NameEntryTemplate(
        onBack: () {},
        onSubmit: (_) {},
        progressBaseValue: 0.2,
      ),
    ),
    'Client Onboarding — Account': (_) => _TemplateShell(
      child: ClientOnboardingAccountTemplate(
        onBack: () {},
        onSubmit: (_) {},
      ),
    ),
    'Client Onboarding — Name': (_) => _TemplateShell(
      child: ClientOnboardingNameTemplate(
        onBack: () {},
        onSubmit: (_) {},
      ),
    ),
    'Client Account — Exercise Plan': (_) => const _TemplateShell(child: ExercisePlanTemplate()),
    'Client List': (_) => _TemplateShell(
      child: ClientListTemplate(
        currentClients: _mockCurrentClients,
        allClients: _mockAllClients,
        maxCurrentClients: 30,
        onClientTap: (_) {},
        onClientAction: (_) {},
        onAddClients: () {},
      ),
    ),
    'Add Exercise': (_) => _TemplateShell(
      child: AddExerciseTemplate(
        sections: _mockAddExerciseSections,
        overallChips: _mockOverallChips,
        bodyPartChips: _mockBodyPartChips,
        outcomeChips: _mockOutcomeChips,
        isLoading: false,
        onBack: () {},
        onCreateNew: () {},
        onCardTap: (_) async => null,
        onAddPressed: (_) {},
        onSearchChanged: (_) {},
        onFilterChanged: (_, _, _) {},
      ),
    ),
    'Exercise Detail — Basic': (_) => _TemplateShell(
      child: ExerciseDetailTemplate(
        variant: ExerciseDetailVariant.basic,
        headerTitle: 'Exercise name',
        items: const [
          ExerciseDetailItem(
            id: 'e1',
            name: 'Shoulder Flexion',
            muscleGroup: 'Shoulder Mobility',
            equipment: 'Dumbells',
          ),
        ],
        onBack: () {},
        onAddExercise: (_) {},
      ),
    ),
    'Exercise Detail — Set': (_) => _TemplateShell(
      child: ExerciseDetailTemplate(
        variant: ExerciseDetailVariant.set,
        headerTitle: 'Exercise set name',
        items: const [
          ExerciseDetailItem(
            id: 'e1',
            name: 'Shoulder Flexion',
            muscleGroup: 'Shoulder Mobility',
            equipment: 'Dumbells',
          ),
          ExerciseDetailItem(
            id: 'e2',
            name: 'Hip Abduction',
            muscleGroup: 'Hip Mobility',
          ),
          ExerciseDetailItem(
            id: 'e3',
            name: 'Quad Extension',
            muscleGroup: 'Knee Stability',
            equipment: 'Band',
          ),
        ],
        onBack: () {},
        onAddExercise: (_) {},
        onAddSet: (_) {},
      ),
    ),
    'Exercise Detail — Template': (_) => _TemplateShell(
      child: ExerciseDetailTemplate(
        variant: ExerciseDetailVariant.template,
        headerTitle: 'Template name',
        items: const [
          ExerciseDetailItem(
            id: 'e1',
            name: 'Shoulder Flexion',
            muscleGroup: 'Shoulder Mobility',
            equipment: 'Dumbells',
          ),
          ExerciseDetailItem(
            id: 'e2',
            name: 'Hip Abduction',
            muscleGroup: 'Hip Mobility',
          ),
          ExerciseDetailItem(
            id: 'e3',
            name: 'Quad Extension',
            muscleGroup: 'Knee Stability',
            equipment: 'Band',
          ),
        ],
        onBack: () {},
        onAddExercise: (_) {},
        onAddTemplate: (_) {},
      ),
    ),
    'Value Exp 1 (Coach)': (_) => _TemplateShell(
      child: ValueExplanationTemplate(
        heading: 'Train With A Real Coach Experience',
        subheading: 'Your trainer watches your movement and helps you train safely and effectively.',
        progressValue: 0.4,
        primaryLabel: 'Continue',
        onBack: () {},
        onPrimary: () {},
      ),
    ),
    'Value Exp 2 (Feedback)': (_) => _TemplateShell(
      child: ValueExplanationTemplate(
        heading: 'Real Feedback. Every Rep.',
        subheading: 'Your coach tracks your movement in real time and corrects your technique as you train.',
        progressValue: 0.6,
        primaryLabel: 'Continue',
        onBack: () {},
        onPrimary: () {},
      ),
    ),
    'Code Entry': (_) => _TemplateShell(
      child: CodeEntryTemplate(
        onBack: () {},
        onCompleted: (_) {},
        onPractitionerSignIn: () {},
        onSkip: () {},
        progressBaseValue: 0.5,
      ),
    ),
    'Code Entry — Error': (_) => _TemplateShell(
      child: CodeEntryTemplate(
        onBack: () {},
        onCompleted: (_) {},
        onPractitionerSignIn: () {},
        onSkip: () {},
        progressBaseValue: 0.5,
        errorMessage: 'Incorrect code. Please try again.',
      ),
    ),
    'Branch Entry': (_) => _TemplateShell(
      child: BranchEntryTemplate(
        onBack: () {},
        onSubmit: (_) {},
        onSkip: () {},
        progressBaseValue: 0.7,
      ),
    ),
    'Branch Entry — Error': (_) => _TemplateShell(
      child: BranchEntryTemplate(
        onBack: () {},
        onSubmit: (_) {},
        onSkip: () {},
        progressBaseValue: 0.7,
        errorMessage: 'Invalid branch code. Please try again.',
      ),
    ),
    'Given Exercise — Loaded': (_) => _TemplateShell(
      child: GivenExerciseTemplate(
        practitioner: const PractitionerInfo(
          avatarUrl: 'https://i.pravatar.cc/150?img=32',
          name: 'Shashi Panchal',
          clinic: 'Retro Clinic',
        ),
        state: GivenExerciseState.loaded,
        exercises: const [
          ExerciseData(exerciseName: 'Shoulder Flexion', repLabel: 'Rep',  repValue: '6',  setLabel: 'Set', setValue: '4', equipmentLabel: 'Dumbell', equipmentValue: '15lb'),
          ExerciseData(exerciseName: 'Hip Abduction',    repLabel: 'Rep',  repValue: '10', setLabel: 'Set', setValue: '3', equipmentLabel: 'Band',    equipmentValue: 'Med'),
          ExerciseData(exerciseName: 'Quad Extension',   repLabel: 'Hold', repValue: '45', setLabel: 'Set', setValue: '3'),
          ExerciseData(exerciseName: 'Calf Raise',       repLabel: 'Rep',  repValue: '12', setLabel: 'Set', setValue: '4', equipmentLabel: 'Weight',  equipmentValue: '10lb'),
          ExerciseData(exerciseName: 'Hamstring Curl',   repLabel: 'Rep',  repValue: '8',  setLabel: 'Set', setValue: '3', equipmentLabel: 'Machine', equipmentValue: '40lb'),
          ExerciseData(exerciseName: 'Glute Bridge',     repLabel: 'Hold', repValue: '30', setLabel: 'Set', setValue: '4'),
          ExerciseData(exerciseName: 'Lateral Band Walk',repLabel: 'Rep',  repValue: '15', setLabel: 'Set', setValue: '3', equipmentLabel: 'Band',    equipmentValue: 'Light'),
        ],
        onBack: () {},
        onSkipToHome: () {},
        onStartExercise: () {},
      ),
    ),
    'Given Exercise — Loading': (_) => _TemplateShell(
      child: GivenExerciseTemplate(
        practitioner: const PractitionerInfo(
          avatarUrl: 'https://i.pravatar.cc/150?img=32',
          name: 'Shashi Panchal',
          clinic: 'Retro Clinic',
        ),
        state: GivenExerciseState.loading,
        onBack: () {},
        onSkipToHome: () {},
        onStartExercise: () {},
      ),
    ),
    'Given Exercise — Error': (_) => _TemplateShell(
      child: GivenExerciseTemplate(
        practitioner: const PractitionerInfo(
          avatarUrl: 'https://i.pravatar.cc/150?img=32',
          name: 'Shashi Panchal',
          clinic: 'Retro Clinic',
        ),
        state: GivenExerciseState.error,
        onBack: () {},
        onSkipToHome: () {},
        onStartExercise: () {},
      ),
    ),
    'Value Exp 3 (Adaptive + Skip)': (_) => _TemplateShell(
      child: ValueExplanationTemplate(
        heading: 'Training That Adapts To You',
        subheading: 'Your coach analyzes every session and adjusts exercises to match your progress.',
        progressValue: 0.8,
        primaryLabel: 'Continue',
        secondaryLabel: 'Skip for now',
        onBack: () {},
        onPrimary: () {},
        onSecondary: () {},
      ),
    ),
    'Create Exercise Details': (_) => _TemplateShell(
      child: CreateExerciseDetailsTemplate(
        bodySegments: const [
          LabelOption(id: 'core',        label: 'Core'),
          LabelOption(id: 'hips',        label: 'Hips'),
          LabelOption(id: 'full_body',   label: 'Full Body'),
          LabelOption(id: 'shoulders',   label: 'Shoulders'),
          LabelOption(id: 'back',        label: 'Back'),
          LabelOption(id: 'knees',       label: 'Knees'),
          LabelOption(id: 'lower_body',  label: 'Lower Body'),
          LabelOption(id: 'elbows',      label: 'Elbows'),
          LabelOption(id: 'upper_body',  label: 'Upper Body'),
          LabelOption(id: 'neck',        label: 'Neck'),
          LabelOption(id: 'wrist_hand',  label: 'Wrist + Hand'),
          LabelOption(id: 'ankle_foot',  label: 'Ankle + Foot'),
        ],
        outcomes: const [
          LabelOption(id: 'mobility',   label: 'Mobility'),
          LabelOption(id: 'strength',   label: 'Strength'),
          LabelOption(id: 'endurance',  label: 'Endurance'),
          LabelOption(id: 'stability',  label: 'Stability + Motor Control'),
          LabelOption(id: 'power',      label: 'Power'),
        ],
        equipment: const [
          EquipmentOption(id: 'eq1', label: 'Dumbbells',    categoryId: 'weights'),
          EquipmentOption(id: 'eq2', label: 'Barbell',      categoryId: 'weights'),
          EquipmentOption(id: 'eq3', label: 'BOSU Ball',    categoryId: 'balance'),
          EquipmentOption(id: 'eq4', label: 'Balance Disc', categoryId: 'balance'),
          EquipmentOption(id: 'eq5', label: 'Resistance Band', categoryId: 'bands'),
          EquipmentOption(id: 'eq6', label: 'Loop Band',    categoryId: 'bands'),
          EquipmentOption(id: 'eq7', label: 'Chair',        categoryId: 'furniture'),
          EquipmentOption(id: 'eq8', label: 'Table',        categoryId: 'furniture'),
        ],
        equipmentCategories: const [
          EquipmentFilterCategory(id: 'weights',   label: 'Weights'),
          EquipmentFilterCategory(id: 'balance',   label: 'Balance'),
          EquipmentFilterCategory(id: 'bands',     label: 'Bands'),
          EquipmentFilterCategory(id: 'furniture', label: 'Furniture'),
        ],
        equipmentThumbnails: null,
        tabHintMessages: const {
          0: ['Set the starting position.', 'Align the camera properly.', 'Keep the frame steady.'],
          1: ['Mark key movement frames.', 'Review each position.', 'Adjust as needed.'],
          2: ['Preview the full movement.', 'Check for smooth transitions.', 'Re-record if needed.'],
          3: [
            'Finalize the exercise details.',
            'Add a body segment to help with filtering.',
            'Outcome goals help clients understand intent.',
          ],
        },
        onAddNewEquipment: () {},
        onSubmit: (_) {},
      ),
    ),
    'Create Exercise Intro': (_) => _TemplateShell(
      child: AvatarMessageTemplate(
        heading: "Let's create a new exercise for your clients",
        primaryLabel: 'Create Exercise',
        onPrimary: () {},
        secondaryLabel: 'Not Now',
        secondaryButtonType: ButtonType.ghost,
        onSecondary: () {},
      ),
    ),
    'Completed Exercise': (_) => _TemplateShell(
      child: AvatarMessageTemplate(
        heading: 'Exercise saved great job!',
        primaryLabel: 'Client page',
        onPrimary: () {},
        primaryLeadingIcon: AppIcons.groupFilled,
        primaryLeadingIconSize: IconSizes.lg,
        secondaryLabel: 'View Exercise',
        secondaryButtonType: ButtonType.outline,
        secondaryLeadingIcon: AppIcons.crownFilled,
        onSecondary: () {},
      ),
    ),
    'How To': (_) => _TemplateShell(
      child: ProgressStepTemplate(
        progress: 0.25,
        onBack: () {},
        heading: 'How Exercise Creation Works',
        subtitle: 'Record the movement, correct key positions, then define the exercise.',
        body: const MediaHolder(size: MediaHolderSize.sm),
        primaryLabel: 'Continue',
        onPrimary: () {},
      ),
    ),
    'Basic Set Up (area)': (_) => _TemplateShell(
      child: ProgressStepTemplate(
        progress: 0.5,
        onBack: () {},
        heading: 'Exercise area setup',
        subtitle: 'Create space to workout in',
        body: const MediaHolder(size: MediaHolderSize.sm),
        primaryLabel: 'Continue',
        onPrimary: () {},
      ),
    ),
    'Basic Set Up (phone)': (_) => _TemplateShell(
      child: ProgressStepTemplate(
        progress: 0.75,
        onBack: () {},
        heading: 'Phone setup',
        subtitle: 'Place phone on the left/right of you at 45°',
        body: const MediaHolder(size: MediaHolderSize.sm),
        primaryLabel: "Let's start",
        onPrimary: () {},
      ),
    ),
    'Select Exercise Type': (_) => const _TemplateShell(
      child: _SelectExerciseTypePreview(),
    ),
    'Athlete Settings': (_) => _TemplateShell(
      child: AthleteSettingsTemplate(
        avatarUrl: null,
        initialFirstName: 'Tavon',
        initialLastName: 'Powell',
        initialEmail: 'tavoncpowell@gmail.com',
        initialPhone: '(XXX) XXX-6936',
        initialSessionReminders: true,
        initialPractitionersUpdates: true,
        initialProductUpdates: true,
        selectedIndex: 2,
        onTabSelected: (_) {},
        onFirstNameChanged: (_) {},
        onLastNameChanged: (_) {},
        onEmailChanged: (_) {},
        onPhoneChanged: (_) {},
        onSessionRemindersChanged: (_) {},
        onPractitionersUpdatesChanged: (_) {},
        onProductUpdatesChanged: (_) {},
        onAvatarTap: () {},
        onAccountSwitchTap: () {},
        onChangePasswordTap: () {},
        onSignOut: () {},
        onDeleteAccount: () {},
      ),
    ),
    'Practitioner Settings (No Org)': (_) => _TemplateShell(
      child: PractitionerSettingsTemplate(
        hasOrganization: false,
        avatarUrl: null,
        initialFirstName: 'Tavon',
        initialLastName: 'Powell',
        initialEmail: 'tavoncpowell@gmail.com',
        initialPersonalPhone: '(XXX) XXX-6936',
        initialWorkEmail: 'tavoncpowell@gmail.com',
        initialWorkPhone: '(XXX) XXX-6936',
        initialClientHelpAlerts: true,
        initialPractitionersUpdates: true,
        initialProductUpdates: true,
        selectedIndex: 2,
        onTabSelected: (_) {},
        onFirstNameChanged: (_) {},
        onLastNameChanged: (_) {},
        onEmailChanged: (_) {},
        onPersonalPhoneChanged: (_) {},
        onWorkEmailChanged: (_) {},
        onWorkPhoneChanged: (_) {},
        onClientHelpAlertsChanged: (_) {},
        onPractitionersUpdatesChanged: (_) {},
        onProductUpdatesChanged: (_) {},
        onAvatarTap: () {},
        onAccountSwitchTap: () {},
        onJoinBranch: () {},
        onCreateOrganization: () {},
        onOrganizationTap: () {},
        onClinicBranchTap: () {},
        onChangePasswordTap: () {},
        onSignOut: () {},
        onDeleteAccount: () {},
      ),
    ),
    'Practitioner Settings (Has Org)': (_) => _TemplateShell(
      child: PractitionerSettingsTemplate(
        hasOrganization: true,
        organizationName: 'BTL Industries',
        clinicBranchName: 'Healthcare professionals',
        avatarUrl: null,
        initialFirstName: 'Tavon',
        initialLastName: 'Powell',
        initialEmail: 'tavoncpowell@gmail.com',
        initialPersonalPhone: '(XXX) XXX-6936',
        initialWorkEmail: 'tavoncpowell@gmail.com',
        initialWorkPhone: '(XXX) XXX-6936',
        initialClientHelpAlerts: true,
        initialPractitionersUpdates: true,
        initialProductUpdates: true,
        selectedIndex: 2,
        onTabSelected: (_) {},
        onFirstNameChanged: (_) {},
        onLastNameChanged: (_) {},
        onEmailChanged: (_) {},
        onPersonalPhoneChanged: (_) {},
        onWorkEmailChanged: (_) {},
        onWorkPhoneChanged: (_) {},
        onClientHelpAlertsChanged: (_) {},
        onPractitionersUpdatesChanged: (_) {},
        onProductUpdatesChanged: (_) {},
        onAvatarTap: () {},
        onAccountSwitchTap: () {},
        onJoinBranch: () {},
        onCreateOrganization: () {},
        onOrganizationTap: () {},
        onClinicBranchTap: () {},
        onChangePasswordTap: () {},
        onSignOut: () {},
        onDeleteAccount: () {},
      ),
    ),
  };

  @override
  Widget build(BuildContext context) {
    final names = _templates.keys.toList();
    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(AppPadding.pagePadding),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              AppText('Templates', style: AppTypography.heading4.bold),
              const SizedBox(height: AppGrid.grid4),
              AppText(
                '${names.length} ${names.length == 1 ? 'screen' : 'screens'}',
                style: AppTypography.bodySmall.regular,
                color: AppColors.textSecondary,
              ),
              const SizedBox(height: AppGrid.grid24),
              Expanded(
                child: names.isEmpty
                    ? Center(
                        child: AppText(
                          'No templates yet',
                          style: AppTypography.body.regular,
                          color: AppColors.textSecondary,
                        ),
                      )
                    : ListView.separated(
                        itemCount: names.length,
                        separatorBuilder: (context, index) =>
                            const SizedBox(height: AppGrid.grid16),
                        itemBuilder: (context, i) => PressableSurface(
                          backgroundColor: AppColors.surface,
                          borderColor: AppColors.surfaceBorder,
                          borderRadius: AppRadius.sm,
                          onTap: () => Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: _templates[names[i]]!,
                            ),
                          ),
                          child: Padding(
                            padding: const EdgeInsets.fromLTRB(
                              AppPadding.cardPadding,
                              AppPadding.rem1,
                              AppPadding.cardPadding,
                              AppPadding.rem1,
                            ),
                            child: Row(
                              children: [
                                Expanded(
                                  child: AppText(
                                    names[i],
                                    style: AppTypography.body.bold,
                                  ),
                                ),
                                const Icon(
                                  Icons.arrow_forward_ios,
                                  size: 14,
                                  color: AppColors.textSecondary,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// ── Template shell ──
// Wraps any template with a floating back button. Use for every _templates entry.

class _TemplateShell extends StatelessWidget {
  final Widget child;
  const _TemplateShell({required this.child});

  @override
  Widget build(BuildContext context) {
    return Stack(
      children: [
        child,
        Positioned(
          top: MediaQuery.of(context).padding.top + AppGrid.grid8,
          left: AppGrid.grid8,
          child: GestureDetector(
            onTap: () => Navigator.of(context).pop(),
            child: Container(
              padding: const EdgeInsets.all(AppGrid.grid8),
              decoration: BoxDecoration(
                color: AppColors.surface.withValues(alpha: 0.85),
                borderRadius: BorderRadius.circular(AppRadius.sm),
              ),
              child: const Icon(
                Icons.arrow_back_ios_new,
                size: 16,
                color: AppColors.textPrimary,
              ),
            ),
          ),
        ),
      ],
    );
  }
}

// ── Mock data for template viewer ──
// Matches the Figma Screen01 reference. Lives here so templates stay data-agnostic.

const _mockCurrentClients = [
  CurrentClientData(clientId: '1', clientName: 'Ryan Levin',     lastSessionText: '1 day ago',    score: 3.9, status: ReviewStatus.reviewed),
  CurrentClientData(clientId: '2', clientName: 'Dulce Franci',   lastSessionText: '1 day ago',    score: 4.6, status: ReviewStatus.reviewed),
  CurrentClientData(clientId: '3', clientName: 'Jaylon Carder',  lastSessionText: '10 hours ago', score: 3.5, status: ReviewStatus.urgent),
  CurrentClientData(clientId: '4', clientName: 'Gretchen Mango', lastSessionText: '8 days ago',   score: 8.2, status: ReviewStatus.pendingReview),
  CurrentClientData(clientId: '5', clientName: 'Erin Press',     lastSessionText: '1 day ago',    score: 3.9, status: ReviewStatus.reviewed),
  CurrentClientData(clientId: '6', clientName: 'Dulce Vaccaro',  lastSessionText: '8 days ago',   score: 5.9, status: ReviewStatus.reviewed),
];

const _mockAllClients = [
  AllClientData(clientId: '1',  clientName: 'Ryan Levin',     email: 'ryan@email.com'),
  AllClientData(clientId: '2',  clientName: 'Dulce Franci',   email: 'dulce.f@email.com'),
  AllClientData(clientId: '3',  clientName: 'Jaylon Carder',  email: 'jaylon@email.com'),
  AllClientData(clientId: '4',  clientName: 'Gretchen Mango', email: 'gretchen@email.com'),
  AllClientData(clientId: '5',  clientName: 'Erin Press',     email: 'erin@email.com'),
  AllClientData(clientId: '6',  clientName: 'Dulce Vaccaro',  email: 'dulce.v@email.com'),
  AllClientData(clientId: '7',  clientName: 'Marcus Webb',    email: 'marcus@email.com'),
  AllClientData(clientId: '8',  clientName: 'Sofia Reyes',    email: 'sofia@email.com'),
  AllClientData(clientId: '9',  clientName: 'Noah Kim',       email: 'noah@email.com'),
  AllClientData(clientId: '10', clientName: 'Layla Hassan',   email: 'layla@email.com'),
];

// ── Add Exercise mock data ──

const _mockOverallChips = <CategoryChip>[
  CategoryChip(label: 'Templates', iconAsset: AppIcons.listView),
  CategoryChip(label: 'Bundles', iconAsset: AppIcons.bundles),
  CategoryChip(label: 'Community', iconAsset: AppIcons.group),
  CategoryChip(label: 'Core'),
  CategoryChip(label: 'Full body'),
  CategoryChip(label: 'Back'),
  CategoryChip(label: 'Lower body'),
  CategoryChip(label: 'Upper body'),
];

const _mockBodyPartChips = <String>[
  'Hips',
  'Shoulders',
  'Knees',
  'Elbows',
  'Spine',
  'Neck',
  'Wrist + Hand',
  'Ankle + Foot',
];

const _mockOutcomeChips = <String>[
  'Mobility',
  'Strength',
  'Endurance',
  'Stability + Motor Control',
  'Power',
];

const _mockAddExerciseSections = <ExerciseSectionData>[
  ExerciseSectionData(
    title: 'Saved Templates',
    layout: ExerciseSectionLayout.templateRow,
    iconPath: AppIcons.star,
    items: [
      ExerciseItem(id: 't1', label: 'ACL Rehab'),
      ExerciseItem(id: 't2', label: 'Hamstring Strain'),
      ExerciseItem(id: 't3', label: 'Rotator Cuff'),
    ],
  ),
  ExerciseSectionData(
    title: 'Saved',
    layout: ExerciseSectionLayout.exerciseGrid,
    iconPath: AppIcons.star,
    items: [
      ExerciseItem(id: 'e1'),
      ExerciseItem(id: 'e2'),
      ExerciseItem(id: 'e3'),
      ExerciseItem(id: 'e4'),
      ExerciseItem(id: 'e5'),
      ExerciseItem(id: 'e6'),
    ],
  ),
];

// ── Select Exercise Type preview ──
// Stateful wrapper so card selection is live in the template viewer.

class _SelectExerciseTypePreview extends StatefulWidget {
  const _SelectExerciseTypePreview();

  @override
  State<_SelectExerciseTypePreview> createState() =>
      _SelectExerciseTypePreviewState();
}

class _SelectExerciseTypePreviewState extends State<_SelectExerciseTypePreview> {
  ExerciseDiscipline? _selected;

  @override
  Widget build(BuildContext context) {
    return ProgressStepTemplate(
      progress: 1.0,
      onBack: () {},
      heading: 'Select Exercise Type',
      subtitle: "Choose the type of exercise you're creating.",
      body: ExerciseTypeGridOrganism(
        initialValue: _selected,
        onChanged: (value) => setState(() => _selected = value),
      ),
      primaryLabel: 'Continue',
      onPrimary: _selected == null ? null : () {},
    );
  }
}

// ── Smoke test template ──
// Verifies the viewer works end-to-end. Private to this file — not exported.

class _HelloWorldTemplate extends StatelessWidget {
  const _HelloWorldTemplate();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Center(
        child: AppText('Hello World', style: AppTypography.heading4.bold),
      ),
    );
  }
}
