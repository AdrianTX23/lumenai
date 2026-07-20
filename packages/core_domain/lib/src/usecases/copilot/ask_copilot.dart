import 'package:core_domain/src/entities/copilot_event.dart';
import 'package:core_domain/src/repositories/copilot_repository.dart';
import 'package:core_domain/src/value_objects/identifiers.dart';

/// Streams the copilot's answer to a question.
final class AskCopilot {
  /// Creates the use case.
  const AskCopilot(this._copilot);

  final CopilotRepository _copilot;

  /// Asks [question] within [conversationId].
  Stream<CopilotEvent> call(ConversationId conversationId, String question) =>
      _copilot.ask(conversationId, question);
}
