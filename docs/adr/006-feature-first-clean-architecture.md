# ADR-006: Feature-first Clean Architecture

- **Status:** Accepted · **Date:** 2026-07-18

## Context

We need strict layering (ADR-001 enforces it physically) *and* a codebase
navigable by product concept. Classic layer-first trees (`presentation/`,
`domain/`, `data/` at the top) scatter one feature across three distant
hierarchies.

## Decision

Layers live in packages; **presentation is sliced by feature**
(`app/lib/features/{home,transactions,insights,budgets,copilot,settings}`),
each slice containing only screens, feature-private widgets and
controllers. Domain is organized by **aggregate** (Account, Transaction,
Budget, Conversation), not by screen — screens churn, the model endures.
Features may not import each other's internals (boundary script rule 5);
they communicate via the router or shared domain observation.

## Alternatives considered

- **Layer-first folders** — correct layering, poor locality; rejected.
- **Feature packages** (one Dart package per feature) — maximal isolation,
  but pubspec ceremony per screen-group outweighs benefit at this team
  size; the boundary script gives us the same guarantee cheaper.

## Consequences

- (+) A feature is one folder: additive to create, trivial to delete;
  the tree "screams" what the product does.
- (−) Judgment needed on where shared UI goes — rule: promote a widget to
  core_ui only when a second feature needs it.
