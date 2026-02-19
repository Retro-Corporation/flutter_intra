/// app.dart
///
/// Application configuration layer.
///
/// This file defines global app-level configuration and bootstraps the UI runtime.
/// It is responsible for constructing the MaterialApp and providing:
///
/// - Theme configuration
/// - Global app title
/// - Localization setup (future)
/// - Debug / build flags
/// - Root entry widget (AppShell)
///
/// This file DOES NOT:
/// - Contain business logic
/// - Access camera or ML services
/// - Perform navigation logic
/// - Hold runtime state
///
/// Think of this file as the "application descriptor".
/// It describes how the app should look and behave globally,
/// but does not run the app itself.
///
/// Dependency direction:
/// main.dart → app.dart → app_shell.dart
///
/// app.dart must remain UI-configuration only.
/// Services must never be referenced here.
///
/// If logic starts appearing here, it belongs in:
/// - app_shell.dart (runtime UI orchestration)
/// - services/ (business logic)
///
/// This separation prevents configuration from becoming coupled
/// with runtime state and keeps hot reload stable.
import 'package:flutter/material.dart';
import 'app_shell.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Intra',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
        useMaterial3: true,
      ),
      home: const AppShell(),
    );
  }
}
