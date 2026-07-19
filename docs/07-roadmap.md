# LUMEN AI — Delivery Roadmap

> **Status:** Approved draft · **Owner:** Tech Lead · **Last updated:** 2026-07-18

Phases are strictly ordered; each ends in a demo-able, CI-green `main`. No phase starts until the previous phase's Definition of Done is met. Estimates assume focused part-time work.

## Phase 0 — Foundations (repo before features)
Melos workspace, package skeletons with enforced boundaries, fvm-pinned Flutter, lints at `--fatal-infos`, CI pipeline green on an empty app, PR/ADR templates, LICENSE, initial ADRs 001–005.
**Exit:** empty app builds on CI for Android+iOS with all gates passing.

## Phase 1 — Design system core
Tokens (color/type/space/shape/motion) as ThemeExtensions; foundational components (buttons, cards, `AmountText`, tiles, chips, skeletons, snack, sheet); Widgetbook running; golden-test harness (light+dark) wired into CI.
**Exit:** Widgetbook web build deployed; every component golden-tested.

## Phase 2 — Domain & data
`core_domain` entities/VOs/use-case shells with full unit tests (Money, Merchant normalization, Period); Drift schema + reactive queries; **seed engine** with golden-dataset analytics fixtures.
**Exit:** `ObserveNetWorth` / breakdown queries return exact expected values from seed data in tests.

## Phase 3 — Wallet & activity (first real screens)
App shell (bottom bar, router), Home (net-worth hero + count-up, account list, `CardStack` interaction, recent activity), Transactions feed (slivers, search, filters, detail sheet, recategorize).
**Exit:** the 60-second core demo exists; profile-mode timeline shows 60fps on card stack.

## Phase 4 — Insights & budgets
Custom chart painters (donut, bars, sparkline, heat calendar) with scrub interactions and semantics; Insights screen (period switcher, breakdown, MoM deltas); local subscription-detection + forecast algorithms (unit-tested against seeds); budget CRUD + pace UI.
**Exit:** anomaly ("Netflix price went up") visibly surfaced from seed data.

## Phase 5 — Lumen Copilot
Copilot UI on **mock repository** first (streaming bubbles, evidence highlighting, insight cards, suggestion chips); then AI proxy service (Hono + SSE + guardrails + tests), deploy, real impl behind same interface; local context-pack assembly; offline fallback state.
**Exit:** live question → streamed grounded answer → tapping evidence highlights the exact transactions.

## Phase 6 — Onboarding, security & polish
Onboarding flow + biometric lock + SQLCipher; settings; ES localization pass; accessibility audit (semantics, contrast, reduced motion, dynamic type); haptics pass; app icon + splash; performance audit against budgets.
**Exit:** DoD checklist passes on every screen.

## Phase 7 — Portfolio release
README case study + architecture diagrams, demo video, Widgetbook Pages deploy, tagged `v1.0.0` release with signed APK, blog-style write-up of 3 deep decisions (Money VO, grounded-AI design, golden-test strategy).
**Exit:** a stranger can evaluate the project in 5 minutes without cloning it.

## Risk register (top 4)

| Risk | Mitigation |
|---|---|
| Scope creep killing polish | Phases gated; v2 list exists precisely to park ideas |
| Custom charts eat time | Timebox per chart; donut+bars are must-have, heat calendar is stretch |
| AI cost/abuse on public demo | Hard cost cap + rate limit in proxy from day one |
| Design drifts from tokens | Golden tests + "no raw values" lint review rule |
