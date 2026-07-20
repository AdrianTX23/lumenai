import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

Widget _host(Widget child) => MaterialApp(
      theme: buildLdsDarkTheme(),
      home: Scaffold(body: Center(child: child)),
    );

void main() {
  group('ChatBubble', () {
    testWidgets('renders content and aligns by role', (tester) async {
      await tester.pumpWidget(
        _host(
          const Column(
            children: [
              ChatBubble(role: ChatBubbleRole.user, content: 'Hi'),
              ChatBubble(role: ChatBubbleRole.assistant, content: 'Hello'),
            ],
          ),
        ),
      );

      expect(find.text('Hi'), findsOneWidget);
      expect(find.text('Hello'), findsOneWidget);

      final userAlign = tester.widget<Align>(
        find.ancestor(
          of: find.text('Hi'),
          matching: find.byType(Align),
        ),
      );
      expect(userAlign.alignment, Alignment.centerRight);

      final assistantAlign = tester.widget<Align>(
        find.ancestor(
          of: find.text('Hello'),
          matching: find.byType(Align),
        ),
      );
      expect(assistantAlign.alignment, Alignment.centerLeft);
    });

    testWidgets('shows the evidence chip and fires the tap callback',
        (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _host(
          ChatBubble(
            role: ChatBubbleRole.assistant,
            content: 'Answer',
            evidenceLabel: '3 sources',
            onEvidenceTap: () => tapped = true,
          ),
        ),
      );

      expect(find.text('3 sources'), findsOneWidget);
      await tester.tap(find.text('3 sources'));
      expect(tapped, isTrue);
    });

    testWidgets('omits the evidence chip when none is provided',
        (tester) async {
      await tester.pumpWidget(
        _host(
          const ChatBubble(role: ChatBubbleRole.assistant, content: 'Answer'),
        ),
      );

      expect(find.byIcon(Icons.receipt_long_rounded), findsNothing);
    });
  });

  group('PromptSuggestionChip', () {
    testWidgets('fires onTap when pressed', (tester) async {
      var tapped = false;
      await tester.pumpWidget(
        _host(
          PromptSuggestionChip(label: 'Ask me', onTap: () => tapped = true),
        ),
      );

      await tester.tap(find.text('Ask me'));
      expect(tapped, isTrue);
    });
  });

  group('InsightCard', () {
    testWidgets('renders title, body and confidence label', (tester) async {
      await tester.pumpWidget(
        _host(
          const InsightCard(
            title: 'Title',
            body: 'Body text',
            confidenceLabel: 'Based on 5 transactions',
          ),
        ),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(find.text('Body text'), findsOneWidget);
      expect(find.text('Based on 5 transactions'), findsOneWidget);
    });

    testWidgets('omits the confidence line when absent', (tester) async {
      await tester.pumpWidget(
        _host(const InsightCard(title: 'Title', body: 'Body text')),
      );

      expect(find.text('Title'), findsOneWidget);
      expect(find.byType(InsightCard), findsOneWidget);
    });
  });
}
