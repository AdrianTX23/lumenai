# LUMEN AI — Product Vision

> **Status:** Approved draft · **Owner:** Product Design / Tech Lead · **Last updated:** 2026-07-18

## 1. One-liner

**LUMEN AI is an AI-native personal finance app**: a beautifully designed wallet that unifies your accounts and cards, understands your spending, and gives you a financial copilot you can actually talk to.

## 2. Positioning

| | Revolut / Monzo | Apple Wallet | **LUMEN AI** |
|---|---|---|---|
| Core job | Banking + payments | Card & pass storage | **Understanding your money** |
| Intelligence | Rule-based insights | None | **LLM-powered copilot** |
| Design language | Bold neobank | Native minimalism | **Dark-first, luminous, calm** |

LUMEN does not try to *be* a bank. It is the **intelligence layer** on top of your financial life. This framing is deliberate: it keeps the product credible as a portfolio piece (no banking license needed) while letting the engineering and design quality carry the story.

## 3. Target user

- **Persona:** "Ana, 27, tech professional." Multiple accounts and cards, spends across subscriptions/travel/food, has zero time for spreadsheets, distrusts generic budgeting apps that nag.
- **Job to be done:** *"Tell me where my money goes and what to do about it — without making me work for it."*

## 4. Product pillars

1. **Clarity** — Every screen answers one question. No dashboards that vomit numbers.
2. **Intelligence** — The AI is contextual, not a gimmick: auto-categorization, anomaly detection, forecast, conversational answers grounded in the user's real data.
3. **Craft** — Motion, haptics, typography and spacing tuned to the standard of Apple's HIG. This is where the portfolio impression is won.
4. **Trust** — Privacy-first architecture; AI calls proxied server-side, no secrets in the client, biometric lock.

## 5. Feature scope

### MVP (portfolio release)
- **Onboarding** — value-proposition carousel, biometric setup, demo-data seeding.
- **Home / Wallet** — net worth hero, account & card stack (Apple-Wallet-style interaction), recent activity.
- **Transactions** — infinite feed, search, filters, merchant enrichment, AI categorization.
- **Insights** — spending breakdown (category/merchant/time), month-over-month deltas, subscription detection, cash-flow forecast.
- **Budgets** — per-category envelopes with pace indicators ("you're 12% ahead of your usual pace").
- **Lumen Copilot** — conversational AI over the user's data: *"How much did I spend on food delivery this quarter?"*, *"What can I cut to save €200/month?"*
- **Settings** — appearance, security (biometrics, app lock), data reset/reseed.

### Explicitly out of scope (v1)
Real bank connections (Plaid/Tink), payments/transfers, multi-user, real KYC. The data layer is architected so any of these can be added without touching domain or presentation layers — that abstraction *is* the point demonstrated to reviewers.

### v2 candidates
Open-banking aggregation (Tink/Plaid sandbox), shared budgets, savings goals with round-ups, home-screen widgets, watchOS/wearable companion.

## 6. Demo data strategy

A portfolio app is judged in the first 60 seconds of a demo. LUMEN ships with a **deterministic, realistic seeded dataset**: ~18 months of transactions across recognizable merchant names, plausible salary/rent/subscription cycles, and intentional anomalies for the AI to find. Seeding is versioned and reproducible (fixed RNG seed) so screenshots, golden tests and demo videos stay consistent.

## 7. Success criteria

- A senior engineer reviewing the repo finds: clean layering, a real design system, meaningful tests, CI, and honest documentation of trade-offs.
- A designer opening the app finds: coherent tokens, 60fps motion, dark/light parity, accessibility (contrast, dynamic type, semantics).
- A recruiter watching a 90-second demo understands the product without narration.
