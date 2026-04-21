import 'package:flutter/material.dart';
import 'design_system.dart';
import 'templates/client_list_template.dart';
import 'templates/exercise_plan_template.dart';

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
