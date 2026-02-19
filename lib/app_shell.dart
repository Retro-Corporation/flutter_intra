/// app_shell.dart
///
/// Application runtime container (Streamlit-style root shell).
///
/// This is the persistent UI root of the application.
/// It manages which pages are visible and keeps long-running systems alive.
///
/// Responsibilities:
/// - Hosts primary app pages (Camera, Gallery, Results, Settings)
/// - Controls navigation state (bottom navigation, tab switching)
/// - Preserves page state using IndexedStack
/// - Keeps camera and ML pipelines mounted while switching pages
/// - Coordinates runtime UI layout
///
/// This file represents the "running application".
/// If app.dart defines what the app is,
/// app_shell.dart defines what the app is currently doing.
///
/// This layer is intentionally ABOVE services.
///
/// Dependency direction:
/// pages → services
/// app_shell → pages
///
/// Services MUST NOT import or depend on this file.
///
/// Why this separation exists:
/// - Prevents camera restarts when navigating
/// - Keeps ML pipelines persistent
/// - Avoids rebuilding heavy widgets
/// - Mirrors Streamlit-style page switching
///
/// This file may:
/// - Subscribe to service streams
/// - Pass service data to pages
/// - Coordinate runtime UI state
///
/// This file must NOT:
/// - Contain ML processing logic
/// - Control camera hardware directly
/// - Store business logic
///
/// Those belong in:
/// services/camera/
/// services/ml/
/// services/storage/
///
/// If this file grows too large, split navigation into:
/// - app_shell_navigation.dart
/// - app_shell_state.dart
///
/// But AppShell must remain the root runtime container.
import 'package:flutter/material.dart';
import 'pages/camera_page.dart';
import 'figma/test.dart';

/// AppShell - The root runtime container for the application.
///
/// This widget serves as the persistent container that hosts all pages
/// and manages navigation state using IndexedStack and bottom navigation.
///
/// Uses IndexedStack to preserve page state when switching between pages,
/// preventing camera restarts and maintaining scroll positions.
class AppShell extends StatefulWidget {
  const AppShell({super.key});

  @override
  State<AppShell> createState() => _AppShellState();
}

class _AppShellState extends State<AppShell> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: _currentIndex == 1
          ? AppBar(
              title: const Text('Figma Design'),
              backgroundColor: const Color(0xFF0E0E10),
              foregroundColor: Colors.white,
            )
          : null,
      body: IndexedStack(
        index: _currentIndex,
        children: [
          const CameraPage(),
          SingleChildScrollView(child: Joints4()),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        backgroundColor: const Color(0xFF0E0E10),
        selectedItemColor: Colors.white,
        unselectedItemColor: Colors.white54,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.camera_alt),
            label: 'Camera',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.design_services),
            label: 'Figma',
          ),
        ],
      ),
    );
  }
}
