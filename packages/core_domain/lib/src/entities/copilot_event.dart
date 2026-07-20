import 'package:core_domain/src/failures/failure.dart';
import 'package:core_domain/src/value_objects/identifiers.dart';

/// One increment of a streamed copilot answer.
///
/// Client code reduces a stream of these into UI state; the same union
/// works whether the events came from the mock repository (dev/demo/
/// tests) or the real SSE proxy — the two adapters share this contract
/// (docs/04-domain-model.md §5).
sealed class CopilotEvent {
  const CopilotEvent();
}

/// A chunk of prose to append to the streaming answer.
final class CopilotTokenDelta extends CopilotEvent {
  /// Creates a token delta carrying [text].
  const CopilotTokenDelta(this.text);

  /// Text to append.
  final String text;
}

/// Transactions the answer is grounded in. May arrive mid-stream or at
/// the end; the client highlights exactly these ledger entries.
final class CopilotEvidence extends CopilotEvent {
  /// Creates an evidence event citing [transactionIds].
  const CopilotEvidence(this.transactionIds);

  /// Cited transactions.
  final List<TransactionId> transactionIds;
}

/// A structured callout the client renders as a card rather than prose.
final class CopilotInsightCard extends CopilotEvent {
  /// Creates an insight card.
  const CopilotInsightCard({
    required this.title,
    required this.body,
    this.supportingCount,
  });

  /// Short headline.
  final String title;

  /// Explanation body.
  final String body;

  /// Number of transactions the insight is based on, when known — the
  /// confidence affordance shown alongside the card.
  final int? supportingCount;
}

/// The stream is complete; no further events follow.
final class CopilotDone extends CopilotEvent {
  /// Creates a completion marker.
  const CopilotDone();
}

/// The pipeline failed. The client maps [failure] to localized copy and
/// offers the local, deterministic insights as a fallback.
final class CopilotFailed extends CopilotEvent {
  /// Creates a failure event.
  const CopilotFailed(this.failure);

  /// What went wrong.
  final Failure failure;
}
