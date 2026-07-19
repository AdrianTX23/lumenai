# ADR-004: Local-first data with a server-proxied AI

- **Status:** Accepted · **Date:** 2026-07-18

## Context

v1 has no real banking connections; all financial data is device-local.
The copilot needs a frontier LLM (Claude), and API keys must never ship in
a client binary. We also refuse to upload a user's full ledger to any
server — privacy is a product pillar.

## Decision

All financial data stays in on-device SQLite. The only backend is a
stateless TypeScript proxy exposing `POST /v1/copilot` (SSE). The client
assembles a **minimized context pack locally** (aggregates for trailing
months, active subscriptions, transactions matching the question) and sends
only that. The proxy holds the API key, applies guardrails/rate/cost caps,
persists nothing. Deterministic computations (forecast, subscription and
anomaly detection) run **locally in core_domain** — the AI explains and
converses; it never invents numbers we can compute.

## Alternatives considered

- **Key in the app** — disqualifying (extractable in minutes).
- **Full backend (accounts, sync)** — scope explosion with no v1 payoff;
  ports make it a future adapter, not a rewrite.
- **On-device LLM** — quality insufficient for grounded financial Q&A.

## Consequences

- (+) Privacy story is real and demonstrable; offline app remains fully
  functional except conversational Q&A; one tiny service to operate.
- (−) Copilot requires connectivity; context minimization logic must be
  maintained as features grow (owned by core_data `remote/`).
