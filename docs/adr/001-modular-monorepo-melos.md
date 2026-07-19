# ADR-001: Modular monorepo with Melos

- **Status:** Accepted · **Date:** 2026-07-18

## Context

Clean layering that exists only as folder convention erodes under deadline
pressure — nothing stops a widget from importing the database. We need the
architecture (docs/02-architecture.md) to be *mechanically* enforced, and we
need the design system to be buildable/testable in isolation.

## Decision

One repository, multiple Dart packages (`core_domain`, `core_data`,
`core_ui`, `core_l10n`, `core_telemetry`, `app`, `widgetbook`) orchestrated
with Melos as a root dev dependency (`dart run melos …`, no global install).
Inter-package dependencies are explicit `path:` entries; an illegal import is
a compile error. `tools/check_boundaries.sh` covers the rules pubspecs cannot
express (e.g. app features must not import `core_data`).

## Alternatives considered

- **Single package with folders** — no compile-time enforcement; rejected.
- **Multiple repositories** — versioning/CI overhead absurd for one product.
- **Pub workspaces (native)** — attractive, but Melos adds the script runner
  and package filtering we want for CI; revisit when tooling matures.

## Consequences

- (+) Boundaries self-enforce; per-package tests/coverage; parallel CI.
- (−) Slightly more pubspec ceremony; contributors must learn `melos run`.
