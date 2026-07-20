import 'package:core_domain/src/entities/copilot_event.dart';
import 'package:core_domain/src/value_objects/identifiers.dart';

/// Port: the copilot pipeline. Two adapters share this contract — a mock
/// (dev/demo/tests, scripted streams over local data) and the real SSE
/// client to the AI proxy — so the entire copilot UX is built and
/// golden-tested before any network call exists
/// (docs/05-backend-and-ai.md §3).
// Ports legitimately start single-method; a function type would freeze the
// contract shape.
// ignore: one_member_abstracts
abstract interface class CopilotRepository {
  /// Asks [question] within [conversationId], streaming the answer as it
  /// is produced.
  Stream<CopilotEvent> ask(ConversationId conversationId, String question);
}
