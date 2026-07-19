# ADR-002: Riverpod for state management and dependency injection

- **Status:** Accepted · **Date:** 2026-07-18

## Context

We need (a) UI state management with sealed, testable state machines and
(b) dependency injection that can bind ports→adapters per flavor and per
test. Using different tools for the two adds seams and ceremony.

## Decision

Riverpod 2 for both. Controllers are `Notifier`s exposing freezed sealed
states; ports are `Provider`s overridden in the composition root
(`app/lib/di/di.dart`) per flavor, and in `ProviderContainer` overrides in
tests — the same mechanism everywhere. Codegen (`@riverpod`) adopted when
freezed/build_runner land in Phase 2.

## Alternatives considered

- **Bloc** — sound, but separate DI story (get_it/injectable) and more
  event/state ceremony for equivalent guarantees.
- **GetX** — global service locator, implicit magic, poor testability.
- **Provider alone** — no compile-safe combination/override semantics.

## Consequences

- (+) One mental model; compile-safe graph; trivial test overrides.
- (−) Riverpod idioms (ref, providers) have a learning curve; discipline
  needed to keep controllers free of business logic (review checklist item).
