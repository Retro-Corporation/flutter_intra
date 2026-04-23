import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';

void main() {
  group('PractitionerHeader', () {
    Widget buildSubject() {
      return const MaterialApp(
        home: Scaffold(
          body: PractitionerHeader(
            avatarUrl: 'https://i.pravatar.cc/150?img=32',
            name: 'Shashi Panchal',
            clinic: 'Retro Clinic',
          ),
        ),
      );
    }

    testWidgets('renders name text', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Shashi Panchal'), findsOneWidget);
    });

    testWidgets('renders clinic text', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.text('Retro Clinic'), findsOneWidget);
    });

    testWidgets('renders one AppAvatar', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.byType(AppAvatar), findsOneWidget);
    });

    testWidgets('renders two AppIcon widgets', (tester) async {
      await tester.pumpWidget(buildSubject());
      expect(find.byType(AppIcon), findsNWidgets(2));
    });
  });
}
