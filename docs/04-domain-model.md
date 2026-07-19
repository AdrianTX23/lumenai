# LUMEN AI — Domain Model & Data Design

> **Status:** Approved draft · **Owner:** Backend Architect / Software Architect · **Last updated:** 2026-07-18

## 1. Aggregates & entities (core_domain)

```
Account            Transaction              Budget                Conversation
├─ id (VO)         ├─ id (VO)               ├─ id                 ├─ id
├─ name            ├─ accountId             ├─ category           ├─ messages[]
├─ type            ├─ amount: Money (VO)    ├─ limit: Money       │   ├─ role
│  (checking/      ├─ merchant (VO)         ├─ period (monthly)   │   ├─ content
│   savings/       ├─ category              ├─ startDate          │   └─ evidence[] ──▶ Transaction ids
│   credit/cash)   ├─ timestamp             └─ rollover: bool     └─ createdAt
├─ currency        ├─ status (pending/
├─ balance: Money  │   settled)             Insight (derived, not stored)
└─ cardMeta?       ├─ note?                 ├─ kind (anomaly/subscription/
   (last4, skin,   └─ categorySource       │   forecast/summary)
    network)          (rule|ai|user)        └─ payload (sealed union per kind)
```

### Value objects (the senior-signal details)
- **`Money`** — amount as **minor units (int)** + currency code. Never `double` for money. All arithmetic and formatting lives here; `AmountText` in core_ui is its only renderer.
- **`Merchant`** — normalized name + raw descriptor + logo ref. Normalization ("AMZN MKTP ES*2K3" → "Amazon") is a pure domain service with table-driven rules; great unit-test surface.
- **`Category`** — closed enum of 14 (Groceries, Dining, Transport, Subscriptions, Housing, Utilities, Health, Shopping, Travel, Entertainment, Income, Transfers, Fees, Other) with icon + color token mapping in core_ui.
- **`Period`** — month-anchored date range with user-configurable start day (salary-cycle aware). All analytics group by `Period`, so the logic exists once.

## 2. Use cases (application services)

`ObserveNetWorth` · `ObserveAccounts` · `ObserveTransactions(filter)` · `SearchTransactions` · `RecategorizeTransaction` · `ObserveSpendingBreakdown(period)` · `DetectSubscriptions` · `ForecastCashflow` · `CreateBudget` / `ObserveBudgetPace` · `AskCopilot(question)` · `SeedDemoData` / `ResetData`.

Each use case: single class, single `call()`, constructor-injected repos, pure or stream-returning. `DetectSubscriptions` and `ForecastCashflow` are deliberately implemented as **transparent local algorithms** (recurrence detection via interval clustering; forecast via trailing-median burn rate) — the AI *explains and converses*, deterministic code *computes*. That division is an explicit design principle: numbers must be reproducible.

## 3. Persistence schema (Drift)

Tables: `accounts`, `transactions` (indexed on `(account_id, timestamp)`, `category`), `budgets`, `conversations`, `messages`, `merchant_rules`, `app_meta` (schema/seed version).

- Analytics run as **SQL aggregations** (`GROUP BY category/period`), not in-memory folds — scales to years of data, and the queries are integration-tested against known seed fixtures with exact expected totals.
- Migration strategy from schema v1 (`onUpgrade` with stepwise migrations, tested).

## 4. Seed engine

Deterministic generator (fixed seed) producing ~18 months / ~2,400 transactions: salary on cycle, rent, 6 subscriptions (one with a sneaky price increase — an anomaly for the AI to find), groceries with weekly rhythm, travel spikes, one duplicate-charge anomaly. Fixtures double as the **golden dataset for analytics tests** — expected monthly totals are asserted exactly.

## 5. AI integration contract (client side)

```
CopilotRepository
└─ Stream<CopilotEvent> ask(ConversationId, String question)
     CopilotEvent = tokenDelta | evidence(List<TransactionId>) | insightCard | done | failure
```

- The client sends the question + a **server-assembled context** (see `05-backend-and-ai.md`); it never sends the raw full ledger.
- Mock implementation ships first (scripted streaming answers over seed data) so the entire copilot UI, streaming rendering and evidence-highlighting are built and golden-tested **before** any network call exists. The real proxy impl then swaps in behind the same interface.
