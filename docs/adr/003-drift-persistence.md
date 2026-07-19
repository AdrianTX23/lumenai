# ADR-003: Drift (SQLite) for local persistence

- **Status:** Accepted · **Date:** 2026-07-18

## Context

LUMEN's core value is spending analytics: grouping by period/category,
top-merchant queries, budget pacing over 18+ months of transactions. The
store must support real aggregation, reactive reads (UI converges on any
write), migrations, and encryption at rest.

## Decision

Drift over SQLite. Analytics run as SQL (`GROUP BY`, indexes on
`(account_id, timestamp)` and `category`); watched queries provide the
stream-first read path (ADR-007); schema migrations are explicit and
tested; SQLCipher provides encryption in prod. Tests run against in-memory
databases with exact-value assertions on the seeded dataset.

## Alternatives considered

- **Isar / Hive / ObjectBox** — fast key-value/object stores, but weak or
  absent aggregation; analytics would move to in-memory Dart folds that
  degrade with data size and duplicate SQL's job.
- **sqflite raw** — no type-safe queries, no watched streams; hand-rolling
  both is Drift with extra bugs.

## Consequences

- (+) Analytics correctness is testable SQL; reactivity for free; a real
  migration story for years of schema evolution.
- (−) Codegen step (build_runner); SQL knowledge required — acceptable, and
  frankly a feature for a portfolio project.
