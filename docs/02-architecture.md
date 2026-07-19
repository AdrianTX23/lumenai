# LUMEN AI — Technical Architecture (Deep Dive)

> **Status:** Approved · **Owner:** Software Architect / Tech Lead · **Last updated:** 2026-07-18
> Supersedes the initial architecture sketch. This is the canonical architecture document.

---

## 1. Architectural style: what and why

**Chosen style:** *Feature-first Clean Architecture over a modular monorepo, with Ports & Adapters (hexagonal) at the edges and Unidirectional Reactive Data Flow (UDF) in presentation.*

That one sentence decomposes into four independent decisions, each made for longevity:

### 1.1 Clean Architecture (dependency rule at the core)
All dependencies point **inward**: UI → application → domain; infrastructure implements domain interfaces. The domain — entities like `Money`, rules like merchant normalization, use cases like `ObserveBudgetPace` — depends on **nothing**: no Flutter, no database, no network. Frameworks are details; the model of "what LUMEN knows about money" is the asset that must survive every framework migration of the next five years.

### 1.2 Ports & Adapters (hexagonal) at the edges
The domain defines **ports** (repository interfaces: `TransactionRepository`, `CopilotRepository`, …). Infrastructure provides **adapters** (Drift/SQLite, SSE client, mock copilot). Today's adapters: local DB + AI proxy. Tomorrow's: open-banking sync, real auth, server persistence — all pluggable **without touching a line above the data layer**. This is the concrete mechanism behind "an architecture that can grow for years."

### 1.3 Feature-first modularity (screaming architecture)
Presentation code is organized by **product capability** (`home`, `insights`, `copilot`…), never by technical type (`screens/`, `viewmodels/`). Reasons:
- The tree screams *finance app*, not *Flutter app* — you locate code by product concept.
- Features are additive: a new capability is a new folder, not edits scattered across type-buckets.
- Features are deletable: removing one is deleting one folder — the cheapest proof of low coupling.
- Features map to team ownership when (hypothetically) headcount grows.

### 1.4 Unidirectional reactive data flow
State flows down (DB → streams → controllers → immutable UI state → widgets); intents flow up (tap → controller method → use case → repository → DB write). The DB is the **single source of truth**; screens never hold authoritative state. Any write propagates to every subscribed screen automatically via Drift streams. No two-way bindings, no duplicated caches to drift out of sync.

### 1.5 Physical enforcement: the modular monorepo
Layering that lives only in folder conventions erodes — one deadline and someone imports the DB from a widget. Here the layers are **separate Dart packages** (Melos workspace), so an illegal import is a *compile error*, not a code-review catch. `core_ui` has no path to the database; `core_domain` cannot see Flutter. The architecture defends itself.

## 2. Alternatives analyzed and rejected

| Alternative | Verdict | Why |
|---|---|---|
| **MVVM / MVC only** (view + viewmodel + services) | Rejected | No domain isolation: business rules end up in viewmodels or "services" grab-bags. Fine for small apps; erodes over years — the exact failure mode we're designing against. |
| **Layer-first Clean** (top-level `presentation/ domain/ data/` with features scattered inside each) | Rejected | Correct layering, wrong navigation: one feature's code lives in three distant trees; features aren't additive or deletable. We keep the layers but slice presentation by feature. |
| **Bloc ecosystem** | Rejected | Sound pattern, but Riverpod gives state + compile-safe DI in one tool with less ceremony; DI story (`ProviderContainer` overrides per flavor/test) is decisive. |
| **GetX** | Rejected | Service-locator globals, implicit magic, untestable coupling. Disqualifying for this codebase's goals. |
| **Redux-style single global store** | Rejected | The DB already *is* the single source of truth; a second global store duplicates it and adds boilerplate without adding guarantees. |
| **Single-package app** (folders only, no Melos) | Rejected | No compile-time boundary enforcement; also prevents the standalone design-system gallery and per-package CI/coverage. |
| **Microservices backend** | Rejected | v1 is local-first with one stateless AI proxy. Distributed systems theater would be a *negative* signal at this scope. The ports make a real backend a future adapter, not a rewrite. |
| **Isar/Hive persistence** | Rejected | Analytics is the product; it needs real SQL aggregation (`GROUP BY` period/category, indexes, migrations). Drift provides that plus reactive streams and in-memory test databases. |

## 3. The layers — contracts and rules

Five layers. For each: responsibility, allowed dependencies, and what is **forbidden** (the forbidden list is what keeps the architecture alive).

### L1 · Domain (`packages/core_domain`) — pure Dart
- **Holds:** entities, value objects (`Money`, `Merchant`, `Period`), repository **interfaces** (ports), pure domain services (merchant normalization, recurrence/subscription detection, cash-flow forecast), sealed `Failure` hierarchy, `Result<Failure,T>`.
- **Depends on:** nothing (Dart SDK only).
- **Forbidden:** Flutter, Drift, dio, JSON, any IO. No `toJson`, no `fromDb`. If a file here imports a package, the review fails.
- **Why pure:** trivially unit-testable, portable to any future runtime (CLI tools, server-side reuse), immune to framework churn.

### L2 · Application (use cases, inside `core_domain/usecases`)
- **Holds:** one class per user-meaningful operation (`ObserveSpendingBreakdown`, `CreateBudget`, `AskCopilot`…). Orchestrates entities + ports; owns transactionality of an operation and its business validation.
- **Contract:** single public `call()`; constructor-injected ports; returns `Result` (commands) or `Stream` of domain types (queries). Controllers may **only** reach data through use cases — never a repository directly — so business rules have exactly one home.
- Kept inside `core_domain` as a subfolder (a separate package would be ceremony without benefit at this scale; the import rule is still enforced by review + lint).

### L3 · Infrastructure (`packages/core_data`) — the adapters
- **Holds:** Drift database (tables, DAOs, migrations, SQL analytics queries), repository **implementations**, DTOs, mappers (DTO ⇄ entity, in one place), the deterministic seed engine, remote clients (AI-proxy SSE client), platform services (secure storage, biometrics adapter).
- **Depends on:** `core_domain` (to implement its ports). Nothing depends on `core_data` except the composition root.
- **Rules:** exceptions **die at this boundary** — every adapter catches its technology's exceptions and returns domain `Failure`s. DTOs never leak upward; entities never gain persistence annotations.

### L4 · Presentation (`app/lib/features/*/presentation`)
- **Holds:** screens, feature-private widgets, and **controllers** (Riverpod Notifiers) that are pure UI state machines: they receive intents, invoke use cases, and reduce results/streams into **sealed, immutable UI states** (`Loading / Data / Error / Empty` per screen, freezed unions — no boolean-flag soup).
- **Depends on:** `core_domain` (use cases, entities), `core_ui` (all visuals), `core_l10n`.
- **Forbidden:** importing `core_data` (compile error), importing another feature's internals (features communicate via router or shared domain observation — never directly), raw colors/text-styles/paddings (everything from tokens), business logic in widgets *or* controllers (controllers decide *what to show*, never *what is true* — truth is computed in L1/L2).

### L5 · Composition root (`app/lib/bootstrap.dart`, `di/`, `router/`)
- **Holds:** the only place where all packages meet: binds ports → adapters via Riverpod overrides **per flavor** (dev = seeded DB + mock copilot; prod = encrypted DB + real proxy), global error funnel → `Telemetry` port, router + guards, theme wiring.
- **Why it matters:** swapping every adapter is editing one file. Tests do the same with `ProviderContainer` overrides — same mechanism, no test-only forks.

### Cross-cutting packages (horizontal, dependency-free of each other)
- **`core_ui`** — the design system: tokens → theme → components → charts. Depends on Flutter only. Cannot import domain or data: components receive plain display data, keeping them reusable, golden-testable, and Widgetbook-renderable in isolation.
- **`core_l10n`** — EN/ES ARB resources; no logic.
- **`core_telemetry`** — logging/analytics/crash **interfaces** + console impl (Sentry adapter later). Interface-first so no vendor lock-in leaks through the codebase.

## 4. Complete folder structure (annotated)

```
lumenai/
├── melos.yaml                     # Workspace: package list, shared scripts (analyze, test, goldens)
├── .fvmrc                         # Pinned Flutter SDK — reproducible builds everywhere incl. CI
├── analysis_options.yaml          # Root lints (very_good_analysis + custom); packages inherit
├── README.md                      # Portfolio case study (Phase 7)
│
├── .github/
│   ├── workflows/
│   │   ├── ci.yaml                # analyze + test + goldens + secret-scan + build (both OSes)
│   │   ├── release.yaml           # Tag-driven: signed artifacts + changelog
│   │   ├── deploy-proxy.yaml      # AI proxy deploy when proxy/ changes
│   │   └── widgetbook.yaml        # Design-system web build → GitHub Pages
│   └── PULL_REQUEST_TEMPLATE.md
│
├── docs/                          # This planning suite
│   ├── adr/                       # Architecture Decision Records (MADR)
│   ├── design/                    # Low-fi flows, screen specs, motion specs
│   └── api/openapi.yaml           # AI-proxy contract (single source for client & server)
│
├── app/                           # ── COMPOSITION ROOT + PRESENTATION ──
│   ├── lib/
│   │   ├── main_dev.dart          # Flavor entrypoints: pick the DI profile, nothing else
│   │   ├── main_prod.dart
│   │   ├── bootstrap.dart         # runZonedGuarded, error funnel, seeding trigger, DI assembly
│   │   ├── app.dart               # Root MaterialApp.router, theme from core_ui, locale wiring
│   │   ├── di/                    # Riverpod override sets per flavor (the ONLY port→adapter binding site)
│   │   ├── router/
│   │   │   ├── app_router.dart    # go_router config, shell route for bottom bar
│   │   │   ├── routes.dart        # Typed route definitions
│   │   │   └── guards/            # e.g. onboarding-completed, app-lock redirect
│   │   └── features/              # Feature-first slices — presentation ONLY
│   │       ├── onboarding/presentation/{screens,controllers,widgets}/
│   │       ├── home/presentation/{screens,controllers,widgets}/       # net worth, card stack, recent activity
│   │       ├── transactions/presentation/{screens,controllers,widgets}/ # feed, search, filters, detail sheet
│   │       ├── insights/presentation/{screens,controllers,widgets}/   # breakdowns, subscriptions, forecast
│   │       ├── budgets/presentation/{screens,controllers,widgets}/    # CRUD + pace (routed from insights)
│   │       ├── copilot/presentation/{screens,controllers,widgets}/    # thread, streaming, evidence highlights
│   │       └── settings/presentation/{screens,controllers,widgets}/   # appearance, security, data
│   ├── test/                      # Controller/widget tests mirroring lib/ 1:1
│   ├── integration_test/          # E2E flows: onboarding→home, budget lifecycle, copilot (mock AI)
│   ├── android/  ios/             # Platform shells: flavors, icons, biometric plist/manifest entries
│   └── pubspec.yaml
│
├── packages/
│   ├── core_domain/               # ── L1 + L2: PURE DART, ZERO DEPENDENCIES ──
│   │   ├── lib/src/
│   │   │   ├── entities/          # Account, Transaction, Budget, Conversation, Insight
│   │   │   ├── value_objects/     # Money, Merchant, Category, Period, ids
│   │   │   ├── repositories/      # PORTS: abstract interfaces only
│   │   │   ├── usecases/          # One class per operation, grouped by aggregate
│   │   │   │   ├── accounts/  transactions/  insights/  budgets/  copilot/  seed/
│   │   │   ├── services/          # Pure algorithms: merchant_normalizer, recurrence_detector,
│   │   │   │                      #   cashflow_forecaster — deterministic, heavily unit-tested
│   │   │   └── failures/          # Sealed Failure hierarchy + Result<Failure,T>
│   │   └── test/                  # ~100% coverage target; fixture-based
│   │
│   ├── core_data/                 # ── L3: ADAPTERS ──
│   │   ├── lib/src/
│   │   │   ├── database/
│   │   │   │   ├── tables/  daos/  migrations/
│   │   │   │   └── queries/       # SQL analytics (GROUP BY period/category) — tested vs seed fixtures
│   │   │   ├── repositories/      # drift_transaction_repository, sse_copilot_repository,
│   │   │   │                      #   mock_copilot_repository (dev/demo/tests)
│   │   │   ├── dto/  mappers/     # Wire/DB shapes and the ONLY DTO⇄entity translation site
│   │   │   ├── remote/            # AI-proxy client: SSE parsing, retry, timeouts, context-pack assembly
│   │   │   ├── seed/              # Deterministic 18-month generator + versioning (fixed RNG seed)
│   │   │   └── platform/          # secure_storage, biometric adapter, SQLCipher key mgmt
│   │   └── test/                  # In-memory Drift DB; exact-value analytics assertions
│   │
│   ├── core_ui/                   # ── DESIGN SYSTEM (LDS) — Flutter only, zero business logic ──
│   │   ├── lib/src/
│   │   │   ├── tokens/            # colors, typography, spacing, shape, elevation, motion (primitive+semantic)
│   │   │   ├── theme/             # ThemeExtension assembly; light/dark builders; context.lds API
│   │   │   ├── foundations/       # LdsScaffold, responsive grid, safe-area
│   │   │   ├── components/
│   │   │   │   ├── actions/  display/  feedback/  navigation/  wallet/  copilot/
│   │   │   ├── charts/            # Custom painters: donut, cashflow bars, sparkline, pace bar, heat calendar
│   │   │   └── utils/             # Haptics helper, Money/date formatters bound to tokens
│   │   └── test/goldens/          # Every component, light+dark (alchemist)
│   │
│   ├── core_l10n/                 # ARB files EN/ES + generated localizations
│   └── core_telemetry/            # Logger/analytics/crash PORTS + console adapter
│
├── widgetbook/                    # Living design-system gallery (depends on core_ui ONLY) → GH Pages
│
├── proxy/                         # ── AI PROXY (TypeScript/Hono) — the only server ──
│   ├── src/
│   │   ├── routes/                # POST /v1/copilot (SSE), POST /v1/categorize
│   │   ├── prompt/                # System prompts, context-pack schema validation, guardrails
│   │   ├── guards/                # Auth token, rate limit, cost cap
│   │   └── config/                # Model ids, limits — config, not code
│   ├── test/
│   └── Dockerfile  fly.toml
│
└── tools/                         # Repo scripts: boundary check, coverage merge, seed regeneration
```

**Dependency matrix (compile-enforced):**

| depends on → | core_domain | core_data | core_ui | core_l10n | core_telemetry |
|---|---|---|---|---|---|
| **app** (features) | ✔ | ✖ (only `di/` binds it) | ✔ | ✔ | ✔ (port) |
| **core_data** | ✔ | — | ✖ | ✖ | ✔ (port) |
| **core_ui** | ✖ | ✖ | — | ✖ | ✖ |
| **core_domain** | — | ✖ | ✖ | ✖ | ✖ |
| **widgetbook** | ✖ | ✖ | ✔ | ✖ | ✖ |

## 5. Data flow

### 5.1 Read path (queries — stream-first)
```
Drift DB ──emits on any change──▶ RepositoryImpl (row→entity via mapper)
        ──▶ UseCase (business shaping: periods, groupings)
        ──▶ Controller (reduce to sealed UI state)
        ──▶ Widget (watch → rebuild)
```
Screens *subscribe*, never fetch-once. When the AI recategorizes a transaction, the feed, the donut, the budget pace and the net worth all update in the same frame — no manual invalidation, no stale caches. The DB is the single source of truth; everything above it is a projection.

### 5.2 Write path (commands)
```
User intent ─▶ Controller method ─▶ UseCase (validate, apply rules)
           ─▶ Repository port ─▶ Drift write (transactional)
           ─▶ streams from 5.1 fire automatically → UI converges
```
Commands return `Result<Failure, T>` for immediate feedback (snack, inline error); the *visible data change* always arrives via the read path, so optimistic-UI bugs (showing state the DB doesn't have) are structurally impossible.

### 5.3 Copilot path (streaming AI)
```
Question ─▶ CopilotController ─▶ AskCopilot use case
        ─▶ CopilotRepository port
             ├─ context-pack assembly (LOCAL SQL: 6-mo aggregates, subscriptions,
             │   matching transactions — minimized, never the full ledger)
             ├─ POST /v1/copilot (SSE) ─▶ proxy ─▶ Claude
             └─ Stream<CopilotEvent>: tokenDelta | evidence(txIds) | insightCard | done | failure
        ─▶ controller reduces events into the thread's UI state
        ─▶ UI renders streaming text; evidence ids highlight real transactions
```
Same port, two adapters: `MockCopilotRepository` (dev/demo/tests, scripted streams) and the real SSE adapter — the entire copilot UX is built and tested before the network exists.

### 5.4 Error path
```
Adapter catches tech exception ─▶ maps to sealed Failure ─▶ Result/stream error
─▶ UseCase passes through (or compensates) ─▶ Controller maps Failure→UI copy (one table)
─▶ LdsErrorState / LdsSnack with retry
Unexpected/uncaught ─▶ bootstrap zone funnel ─▶ Telemetry port
```
No raw exception ever crosses into presentation; no stack trace ever reaches a user.

## 6. Why this grows for years — concrete scenarios

| Future demand | What changes | What doesn't |
|---|---|---|
| Real open-banking sync (Tink/Plaid) | New remote data source + sync logic in `core_data`; repository composes local+remote | Domain, use cases, every screen |
| Server-side accounts & multi-device | New adapter behind same ports; auth feature slice | Domain model, insights, copilot UX |
| New feature (savings goals) | New aggregate in domain + new feature folder | All existing features |
| Rebrand / visual refresh | Token values in `core_ui`; goldens re-baselined | Zero feature code |
| Desktop/tablet/watch surface | New presentation targets over the same packages | Domain, data |
| Swap AI vendor | `proxy/` internals + model config | The `CopilotEvent` contract and all client code |
| Team grows | Packages/features become ownership boundaries with per-package CI | The dependency matrix |

## 7. Stack summary (unchanged from initial decision, now justified in context)

Flutter 3.x / Dart 3 · Melos monorepo · Riverpod 2 codegen (state + DI) · go_router (typed) · freezed sealed unions · Drift (SQLite, SQLCipher) · dio/SSE for the proxy client · custom-painter charts · Widgetbook + alchemist goldens · TypeScript (Hono) proxy on Fly.io · GitHub Actions CI/CD.

## 8. ADR index

ADR-001 Modular monorepo (Melos) · ADR-002 Riverpod over Bloc/GetX · ADR-003 Drift over Isar/Hive · ADR-004 Local-first + server-proxied AI · ADR-005 Custom chart painters · ADR-006 Feature-first Clean Architecture · ADR-007 Stream-first single source of truth.
