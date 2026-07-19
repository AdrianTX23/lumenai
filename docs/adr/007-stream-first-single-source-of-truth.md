# ADR-007: Stream-first single source of truth

- **Status:** Accepted · **Date:** 2026-07-18

## Context

The same datum (a transaction's category, a balance) appears on many
screens simultaneously (feed, donut, budget pace, net worth). Fetch-once
patterns force manual cache invalidation across screens — the classic
source of stale-UI bugs.

## Decision

The local database is the single source of truth. All reads are **watched
queries** (Drift streams) flowing DB → repository → use case → controller →
widget. Writes go down through use cases and never mutate UI state
directly: the visible change always arrives via the read stream, so the UI
can only ever show what the database actually contains. Commands return
`Result<Failure, T>` solely for immediate feedback (snackbars, inline
validation).

## Alternatives considered

- **Fetch-on-navigate + manual refresh** — invalidation bug factory.
- **In-memory global store as truth** (Redux-style) — duplicates the DB
  and adds reconciliation; the DB already provides transactions and
  reactivity.
- **Optimistic UI mutations** — banned for financial data; correctness
  beats perceived latency at this data size (local SQLite is ~instant).

## Consequences

- (+) Cross-screen consistency by construction; recategorization by the AI
  propagates everywhere in one frame; trivially testable data flow.
- (−) Requires discipline: controllers must not cache derived data;
  aggregations belong in SQL/use cases (review checklist item).
