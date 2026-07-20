# LUMEN AI

> An AI-native personal finance app — a beautifully designed wallet that understands your spending and gives you a financial copilot you can talk to.

Built solo, end to end: product framing, a from-scratch design system,
domain modeling, a reactive local-first data layer, custom chart
painters, and a grounded conversational AI — across mobile (iOS/Android)
and a fully working web build, all sharing one codebase.

**[Try the live demo →](https://adriantx23.github.io/lumenai/)** · [Design-system catalog (Widgetbook) →](https://adriantx23.github.io/lumenai/widgetbook/) · Or run it yourself in under a minute, see [Getting started](#getting-started).

## Screenshots

| | |
|---|---|
| ![Home](docs/screenshots/home-dark.png) | ![Activity](docs/screenshots/activity-dark.png) |
| ![Insights](docs/screenshots/insights-dark.png) | ![Copilot](docs/screenshots/copilot-answer-dark.png) |
| ![Settings](docs/screenshots/settings-dark.png) | ![Home, light theme](docs/screenshots/home-light.png) |

All seven screens come from the real, running app on a fresh seeded
dataset — not mockups.

## What this is

LUMEN AI is the intelligence layer on top of your financial life: it
unifies accounts and cards, understands spending patterns with
deterministic local algorithms, and answers questions about your money
through a conversational copilot that only ever cites real transactions
— never a hallucinated figure. It does **not** try to be a bank: no real
banking connections, no payments, no KYC. That's deliberate — it keeps
the project credible as a portfolio piece, and lets the engineering and
design quality carry the story. See
[docs/01-product-vision.md](docs/01-product-vision.md) for the full
positioning.

The app ships with a realistic seeded demo dataset (Colombian market:
COP, local merchants, salary/rent cycles, a couple of planted anomalies
for the copilot to find) so it's immediately explorable — and, per the
Phase "manual entry" milestone, you can add your own real accounts and
transactions on top of it. On the web build, everything you enter stays
entirely in **your own browser's local storage** — nothing is sent
anywhere, because there is no backend for this in v1, by design.

## Architecture

Feature-first Clean Architecture over a modular monorepo, with Ports &
Adapters at the edges and a stream-first, unidirectional data flow. Full
rationale in [docs/02-architecture.md](docs/02-architecture.md) and
[ADRs 001–007](docs/adr/); the short version:

```mermaid
graph TD
    subgraph L4["L4 · Presentation — app/lib/features/*"]
        UI[Screens & Controllers<br/>Home · Activity · Insights · Budgets · Copilot · Settings]
    end
    subgraph L2["L1+L2 · Domain — packages/core_domain (pure Dart)"]
        DOM[Entities & Value Objects<br/>Money · Merchant · Period]
        UC[Use Cases<br/>ObserveNetWorth · AskCopilot · CreateBudget …]
        PORTS[Ports<br/>TransactionRepository · CopilotRepository …]
    end
    subgraph L3["L3 · Infrastructure — packages/core_data"]
        DRIFT[Drift SQLite / WasmDatabase<br/>DAOs · SQL analytics]
        ADAPT[Repository Adapters]
        SEED[Deterministic seed engine]
    end
    subgraph CROSS["Cross-cutting (Flutter-only, no domain/data imports)"]
        CUI[core_ui — Design System<br/>tokens · theme · components · charts]
        L10N[core_l10n — EN/ES]
        TEL[core_telemetry — logging port]
    end
    subgraph ROOT["L5 · Composition root — app/lib/di, bootstrap.dart"]
        DI[Riverpod overrides<br/>bind ports → adapters, per flavor]
    end

    UI -->|calls| UC
    UI -->|renders with| CUI
    UI -->|strings from| L10N
    UC --> DOM
    UC -->|depends on| PORTS
    ADAPT -->|implements| PORTS
    ADAPT --> DRIFT
    ADAPT --> SEED
    DI -->|binds| PORTS
    DI -->|to| ADAPT
    DI -->|assembles| UI

    style DOM fill:#0B8A7A,color:#fff
    style UC fill:#0B8A7A,color:#fff
    style PORTS fill:#0B8A7A,color:#fff
    style CUI fill:#4A2FA5,color:#fff
```

`core_domain` depends on nothing; `core_ui` depends on nothing but
Flutter. Every arrow points inward — enforced at compile time by
package boundaries and checked in CI by `tools/check_boundaries.sh`. An
illegal import is a build failure, not a review comment.

### The copilot's grounded-answer path

```mermaid
sequenceDiagram
    participant U as User
    participant Ctrl as CopilotController
    participant UC as AskCopilot (use case)
    participant Repo as CopilotRepository
    participant SQL as Local SQL (context pack)
    participant Proxy as AI proxy (Hono, SSE)
    participant Model as Claude

    U->>Ctrl: "¿Cuánto gasté en restaurantes?"
    Ctrl->>UC: call(conversationId, question)
    UC->>Repo: ask(conversationId, question)
    Repo->>SQL: aggregate 6-mo history, subscriptions, matching txs
    SQL-->>Repo: minimized context pack (never the full ledger)
    Repo->>Proxy: POST /v1/copilot (question + context pack)
    Proxy->>Model: prompt + context pack
    Model-->>Proxy: streamed tokens + cited transaction ids
    Proxy-->>Repo: SSE: tokenDelta*, evidence(ids), done
    Repo-->>Ctrl: Stream<CopilotEvent>
    Ctrl-->>U: streaming bubble + evidence chip
    U->>Ctrl: taps evidence chip
    Ctrl-->>U: navigates to Activity, filtered to those exact ids
```

The dev/demo build (including this web build) swaps `Proxy`/`Model` for
`MockCopilotRepository` — a keyword router over the same local use cases
— so the model, real or mocked, never invents a number: every figure the
copilot says is queried from the same deterministic pipeline the rest of
the app uses.

## Deep dives

Three decisions worth reading if you want to see the reasoning, not just
the result:

1. [Why `Money` is 25 lines and has no `double` in it](docs/case-study/01-money-value-object.md)
2. [A copilot that has to show its work](docs/case-study/02-grounded-ai-copilot.md)
3. [Testing a design system with screenshots, on purpose](docs/case-study/03-golden-test-strategy.md)

## Tech stack

Flutter 3.x / Dart 3 · Melos monorepo · Riverpod 2 (state + DI) ·
go_router (typed) · freezed sealed unions · Drift (SQLite native,
WasmDatabase on web) · custom-painter charts · Widgetbook + alchemist
goldens · TypeScript (Hono) AI proxy · GitHub Actions CI.

## Workspace

```
app/         Composition root + feature presentation slices (iOS · Android · Web)
packages/    core_domain · core_data · core_ui · core_l10n · core_telemetry
widgetbook/  Living design-system gallery
docs/        Planning suite, ADRs, and this case study
```

## Getting started

```sh
dart pub get              # resolves the workspace (melos is a root dev dependency)
dart run melos bootstrap
dart run melos run analyze
dart run melos run test

# Run on a simulator/device
flutter run --flavor dev -t app/lib/main_dev.dart

# Run in a browser
flutter build web -t app/lib/main_web.dart --output app/build/web
python3 -m http.server 4173 --directory app/build/web
```

## Status

Phases 0–7 complete: design system, domain + data layer, wallet &
activity, insights & budgets, the Lumen Copilot, onboarding/security/
polish, manual account & transaction entry, and this web build. See
[docs/07-roadmap.md](docs/07-roadmap.md) for the full phased history and
exit criteria per phase.

## License

[MIT](LICENSE)
