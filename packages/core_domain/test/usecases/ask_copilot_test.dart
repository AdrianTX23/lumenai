import 'package:core_domain/core_domain.dart';
import 'package:test/test.dart';

final class _ScriptedCopilotRepository implements CopilotRepository {
  ConversationId? lastConversationId;
  String? lastQuestion;

  @override
  Stream<CopilotEvent> ask(ConversationId conversationId, String question) {
    lastConversationId = conversationId;
    lastQuestion = question;
    return Stream.fromIterable(const [
      CopilotTokenDelta('You spent '),
      CopilotTokenDelta(r'$ 328.494 on dining this month.'),
      CopilotEvidence([TransactionId('tx-1'), TransactionId('tx-2')]),
      CopilotDone(),
    ]);
  }
}

void main() {
  group('AskCopilot', () {
    test('forwards conversation id and question to the repository', () async {
      final repo = _ScriptedCopilotRepository();
      final useCase = AskCopilot(repo);

      await useCase(const ConversationId('c1'), 'How much on dining?').toList();

      expect(repo.lastConversationId, const ConversationId('c1'));
      expect(repo.lastQuestion, 'How much on dining?');
    });

    test('streams events through unchanged, in order', () async {
      final useCase = AskCopilot(_ScriptedCopilotRepository());

      final events = await useCase(const ConversationId('c1'), 'q').toList();

      expect(events, hasLength(4));
      expect(events[0], isA<CopilotTokenDelta>());
      expect(events[1], isA<CopilotTokenDelta>());
      expect(
        (events[2] as CopilotEvidence).transactionIds,
        [const TransactionId('tx-1'), const TransactionId('tx-2')],
      );
      expect(events[3], isA<CopilotDone>());
    });

    test('exhaustive switch compiles over every CopilotEvent variant', () {
      const events = <CopilotEvent>[
        CopilotTokenDelta('hi'),
        CopilotEvidence([]),
        CopilotInsightCard(title: 't', body: 'b', supportingCount: 3),
        CopilotDone(),
        CopilotFailed(AiFailure('boom')),
      ];

      final kinds = events
          .map(
            (e) => switch (e) {
              CopilotTokenDelta() => 'delta',
              CopilotEvidence() => 'evidence',
              CopilotInsightCard() => 'card',
              CopilotDone() => 'done',
              CopilotFailed() => 'failed',
            },
          )
          .toList();

      expect(kinds, ['delta', 'evidence', 'card', 'done', 'failed']);
    });
  });
}
