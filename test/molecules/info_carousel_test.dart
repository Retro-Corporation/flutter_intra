import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:flutter_intra/frontend/design_system/design_system.dart';
import 'package:flutter_intra/frontend/design_system/molecules/display/info_carousel.dart';

void main() {
  const List<String> messages = [
    'First hint message',
    'Second hint message',
    'Third hint message',
  ];

  Widget build({
    List<String> msgs = messages,
    Duration interval = const Duration(seconds: 4),
  }) {
    return MaterialApp(
      home: Scaffold(
        body: Center(
          child: InfoCarousel(
            messages: msgs,
            interval: interval,
          ),
        ),
      ),
    );
  }

  group('InfoCarousel — rendering', () {
    testWidgets('renders first message initially', (WidgetTester tester) async {
      await tester.pumpWidget(build());
      await tester.pump();

      expect(find.text(messages[0]), findsOneWidget);
    });

    testWidgets('renders AppIcon widget', (WidgetTester tester) async {
      await tester.pumpWidget(build());
      await tester.pump();

      expect(find.byType(AppIcon), findsOneWidget);
    });
  });

  group('InfoCarousel — timer', () {
    testWidgets('shows message at index 1 after one interval',
        (WidgetTester tester) async {
      await tester.pumpWidget(build());
      await tester.pump();

      expect(find.text(messages[0]), findsOneWidget);

      await tester.pump(const Duration(seconds: 4));
      await tester.pump();

      expect(find.text(messages[1]), findsOneWidget);
    });

    testWidgets('shows message at index 2 after two intervals',
        (WidgetTester tester) async {
      await tester.pumpWidget(build());
      await tester.pump();

      await tester.pump(const Duration(seconds: 4));
      await tester.pump();

      await tester.pump(const Duration(seconds: 4));
      await tester.pump();

      expect(find.text(messages[2]), findsOneWidget);
    });

    testWidgets('wraps back to index 0 after three intervals',
        (WidgetTester tester) async {
      await tester.pumpWidget(build());
      await tester.pump();

      await tester.pump(const Duration(seconds: 4));
      await tester.pump();

      await tester.pump(const Duration(seconds: 4));
      await tester.pump();

      await tester.pump(const Duration(seconds: 4));
      await tester.pump();

      expect(find.text(messages[0]), findsOneWidget);
    });
  });

  group('InfoCarousel — didUpdateWidget', () {
    testWidgets('resets to index 0 when messages list changes',
        (WidgetTester tester) async {
      const List<String> altMessages = [
        'Alt first',
        'Alt second',
        'Alt third',
      ];

      // Use a StatefulWrapper to rebuild with new props
      final key = GlobalKey<_StatefulWrapperState>();
      await tester.pumpWidget(
        MaterialApp(
          home: Scaffold(
            body: Center(
              child: _StatefulWrapper(
                key: key,
                initialMessages: messages,
              ),
            ),
          ),
        ),
      );
      await tester.pump();

      // Advance to index 1
      await tester.pump(const Duration(seconds: 4));
      await tester.pump();
      expect(find.text(messages[1]), findsOneWidget);

      // Swap to a new messages list — should reset to index 0 of altMessages
      key.currentState!.updateMessages(altMessages);
      await tester.pump();

      expect(find.text(altMessages[0]), findsOneWidget);
    });
  });

  group('InfoCarousel — assert', () {
    testWidgets('fires assert when messages.length != 3',
        (WidgetTester tester) async {
      expect(
        () => InfoCarousel(messages: const ['only one']),
        throwsA(isA<AssertionError>()),
      );
    });
  });
}

// ---------------------------------------------------------------------------
// StatefulWrapper — drives didUpdateWidget tests
// ---------------------------------------------------------------------------

class _StatefulWrapper extends StatefulWidget {
  const _StatefulWrapper({super.key, required this.initialMessages});

  final List<String> initialMessages;

  @override
  State<_StatefulWrapper> createState() => _StatefulWrapperState();
}

class _StatefulWrapperState extends State<_StatefulWrapper> {
  late List<String> _messages;

  @override
  void initState() {
    super.initState();
    _messages = widget.initialMessages;
  }

  void updateMessages(List<String> next) {
    setState(() => _messages = next);
  }

  @override
  Widget build(BuildContext context) {
    return InfoCarousel(
      messages: _messages,
      interval: const Duration(seconds: 4),
    );
  }
}
