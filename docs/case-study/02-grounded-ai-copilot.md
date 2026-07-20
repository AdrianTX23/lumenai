# A copilot that has to show its work

"How much did I spend on restaurants this month?" is an easy prompt for
a chat model to *answer* — LLMs are fluent, confident, and will happily
produce a plausible-sounding number. It is a much harder prompt to answer
*correctly*, because the correct answer isn't language, it's arithmetic
over rows the model has never seen unless something puts them in front
of it. A finance copilot that hallucinates a total is worse than no
copilot at all — it's actively misleading about the one thing the user
came to check.

LUMEN's answer to that problem is architectural, not promptcraft: **the
model never computes.** Every number the copilot says comes out of the
same deterministic, unit-tested pipeline the rest of the app uses —
`ObserveSpendingBreakdown`, `DetectSubscriptions`, `ForecastCashflow` —
and the model's only job (in the real, proxy-backed implementation) is
to turn that pipeline's structured output into fluent, conversational
prose. Ask the same question ten times and the *figure* is identical
every time, because it was never generated — it was queried.

## The contract that makes this swappable

```dart
sealed class CopilotEvent {}
final class CopilotTokenDelta extends CopilotEvent { final String text; }
final class CopilotEvidence   extends CopilotEvent { final List<TransactionId> transactionIds; }
final class CopilotInsightCard extends CopilotEvent { final String title, body; final int? supportingCount; }
final class CopilotDone       extends CopilotEvent {}
final class CopilotFailed     extends CopilotEvent { final Failure failure; }
```

([`copilot_event.dart`](../../packages/core_domain/lib/src/entities/copilot_event.dart))
This sealed union is the entire surface between "what answered the
question" and "how the UI shows an answer." Streaming prose and cited
evidence are two *separate* event types, not fields bolted onto a prose
string — the UI can render the evidence chip the instant transaction IDs
arrive, independent of whether the text is still streaming in. And
critically: `CopilotEvidence` carries `TransactionId`s, not a rendered
string of merchant names. The evidence is the actual foreign key into
the ledger. Tapping the evidence chip in the app (`copilot_screen.dart`
→ `context.push` into Activity, filtered to those exact IDs) is not a
search-by-text-match — it is a direct navigation to the literal rows the
claim is about.

## Why the mock isn't a placeholder

[`MockCopilotRepository`](../../packages/core_data/lib/src/repositories/mock_copilot_repository.dart)
is a small keyword router over the same repositories (`AnalyticsRepository`,
`TransactionRepository`) every other screen already depends on:

```dart
Stream<CopilotEvent> _answerCategorySpend(Category category) async* {
  final breakdown = await _analytics.watchSpendingBreakdown(period).first;
  // ... find `category`'s total ...
  final thisPeriod = categoryTxs.where((t) => period.contains(t.timestamp));
  yield* _typeOut(
    'Has gastado ${_formatCop(total)} en $label este mes, en '
    '${thisPeriod.length} transacciones.',
    evidence: thisPeriod.map((t) => t.id).toList(),
  );
}
```

It is not a stand-in for "real AI" that gets thrown away later — it's the
UX contract's reference implementation. It exists so the entire
conversational surface (streaming bubbles, evidence highlighting, insight
cards, suggestion chips, the empty/error states) can be built,
interacted with, and golden-tested against `CopilotEvent` before any
network call or API key exists (`docs/05-backend-and-ai.md §3`). Phase 5
of the roadmap shipped the mock first *on purpose* — by the time the real
SSE-backed proxy adapter lands behind the same `CopilotRepository` port,
every pixel of the UI has already been proven against real seed data,
and the only thing left to change is which adapter answers.

That's also why it never guesses: unmatched questions fall through to
`_answerFallback()` — a clear "I don't have a good answer for that yet,"
never a fabricated number. A mock that occasionally lies to look smarter
would defeat the entire point of building this pipeline in the first
place.

## What the real proxy adds — and deliberately doesn't

The production adapter (`docs/05-backend-and-ai.md`, `proxy/`) swaps the
keyword router for a real model call, but the *contract* doesn't change:
the client still assembles a **local, minimized context pack** — six
months of aggregates, detected subscriptions, matching transactions —
never the full ledger, and sends that alongside the question. The
model's job stays narrow: read the context pack, write fluent prose, and
emit the same `CopilotEvidence`/`CopilotInsightCard` events citing the
transaction IDs *it was given*, not ones it invents. Guardrails, a hard
cost cap, and rate limiting live in the proxy from day one (roadmap risk
register) — a public-facing demo that lets anyone spend real API budget
on unbounded prompts is a self-inflicted incident, not a hypothetical
one.

The result a user actually experiences: ask "¿cuál es mi pronóstico para
el próximo mes?" and the copilot doesn't riff — it reads
`CashflowForecaster`'s trailing-median projection, the same number
`Insights` would show you, and says so in a sentence. Tap the evidence
and you land, filtered, on the exact transactions behind it. The
copilot's value isn't in being clever about money; it's in never being
wrong about it.
