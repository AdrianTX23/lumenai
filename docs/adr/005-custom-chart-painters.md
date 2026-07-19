# ADR-005: Custom chart painters over charting libraries

- **Status:** Accepted · **Date:** 2026-07-18

## Context

Charts (donut, cashflow bars, sparkline, pace bar, heat calendar) are the
visual heart of Insights. They must match LDS tokens exactly, animate on
entry, support scrubbing/tooltips, expose semantics for screen readers,
and hold 60fps.

## Decision

Hand-built `CustomPainter` charts inside `core_ui/charts`, driven by plain
display models, with animation controllers owned by thin wrapper widgets.
Each chart ships with Widgetbook use cases, golden tests (light+dark) and
semantics nodes carrying the underlying values.

## Alternatives considered

- **fl_chart / syncfusion / graphic** — fast to start, but themed via
  their own config surfaces (fighting the token system), limited gesture
  customization, and visually recognizable as stock charts — the opposite
  of the craft signal this project exists to demonstrate.

## Consequences

- (+) Pixel-exact brand fit; full control of motion/gestures/a11y; strong
  portfolio evidence of rendering-layer competence.
- (−) More effort per chart — mitigated by timeboxing (donut and bars are
  must-have; heat calendar is a stretch goal, per the risk register).
