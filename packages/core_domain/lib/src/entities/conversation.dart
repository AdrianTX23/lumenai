import 'package:core_domain/src/value_objects/identifiers.dart';

/// Who authored a [Message].
enum MessageRole {
  /// The person using the app.
  user,

  /// Lumen's copilot.
  assistant,
}

/// One turn in a copilot [Conversation].
final class Message {
  /// Creates a message.
  const Message({
    required this.id,
    required this.role,
    required this.content,
    required this.timestamp,
    this.evidence = const [],
  });

  /// Stable identifier.
  final MessageId id;

  /// Who sent it.
  final MessageRole role;

  /// Rendered text. Grows incrementally while streaming.
  final String content;

  /// When the message started.
  final DateTime timestamp;

  /// Transactions the answer is grounded in — tapping one highlights the
  /// real ledger entry it cites. Empty for user messages and for
  /// assistant answers that cite nothing.
  final List<TransactionId> evidence;
}

/// A thread of messages with the copilot.
final class Conversation {
  /// Creates a conversation.
  const Conversation({required this.id, required this.messages});

  /// Stable identifier.
  final ConversationId id;

  /// Turns, oldest first.
  final List<Message> messages;
}
