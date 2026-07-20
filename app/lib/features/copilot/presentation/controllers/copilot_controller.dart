import 'dart:async';

import 'package:core_domain/core_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen_app/di/di.dart';

/// The conversation's messages and whether an answer is streaming in.
final class CopilotUiState {
  /// Creates a state snapshot.
  const CopilotUiState({this.messages = const [], this.isSending = false});

  /// Turns so far, oldest first.
  final List<Message> messages;

  /// Whether the most recent assistant message is still streaming.
  final bool isSending;

  /// Copies with overrides.
  CopilotUiState copyWith({List<Message>? messages, bool? isSending}) {
    return CopilotUiState(
      messages: messages ?? this.messages,
      isSending: isSending ?? this.isSending,
    );
  }
}

/// Drives one local conversation with the copilot.
///
/// Reduces the `CopilotEvent` stream into UI state: token deltas append
/// to the live assistant message, evidence attaches citation ids to it,
/// and the same reducer will work unchanged once the mock is replaced by
/// the real SSE proxy client (docs/05-backend-and-ai.md §3).
final class CopilotController extends Notifier<CopilotUiState> {
  static const _conversationId = ConversationId('local');

  StreamSubscription<CopilotEvent>? _subscription;
  int _messageCounter = 0;

  @override
  CopilotUiState build() {
    ref.onDispose(() => _subscription?.cancel());
    return const CopilotUiState();
  }

  /// Sends [text] as a new user turn and streams the assistant's reply.
  Future<void> send(String text) async {
    final trimmed = text.trim();
    if (trimmed.isEmpty || state.isSending) return;

    final userMessage = Message(
      id: MessageId('m-${_messageCounter++}'),
      role: MessageRole.user,
      content: trimmed,
      timestamp: DateTime.now(),
    );
    final assistantId = MessageId('m-${_messageCounter++}');
    final assistantPlaceholder = Message(
      id: assistantId,
      role: MessageRole.assistant,
      content: '',
      timestamp: DateTime.now(),
    );

    state = state.copyWith(
      messages: [...state.messages, userMessage, assistantPlaceholder],
      isSending: true,
    );

    final askCopilot = ref.read(askCopilotProvider);
    await _subscription?.cancel();
    _subscription = askCopilot(_conversationId, trimmed).listen(
      (event) => _reduce(assistantId, event),
      onDone: () => state = state.copyWith(isSending: false),
      onError: (Object _, StackTrace __) =>
          state = state.copyWith(isSending: false),
    );
  }

  void _reduce(MessageId assistantId, CopilotEvent event) {
    switch (event) {
      case CopilotTokenDelta(:final text):
        _updateAssistant(
          assistantId,
          (m) => Message(
            id: m.id,
            role: m.role,
            timestamp: m.timestamp,
            content: m.content + text,
            evidence: m.evidence,
          ),
        );
      case CopilotEvidence(:final transactionIds):
        _updateAssistant(
          assistantId,
          (m) => Message(
            id: m.id,
            role: m.role,
            timestamp: m.timestamp,
            content: m.content,
            evidence: transactionIds,
          ),
        );
      case CopilotInsightCard():
        // Hook point for structured cards once the mock (or the real
        // proxy) emits them; no-op for now.
        break;
      case CopilotDone():
        state = state.copyWith(isSending: false);
      case CopilotFailed():
        state = state.copyWith(isSending: false);
    }
  }

  void _updateAssistant(MessageId id, Message Function(Message) update) {
    state = state.copyWith(
      messages: [
        for (final message in state.messages)
          if (message.id == id) update(message) else message,
      ],
    );
  }
}

/// The active conversation state.
final copilotControllerProvider =
    NotifierProvider<CopilotController, CopilotUiState>(
  CopilotController.new,
);
