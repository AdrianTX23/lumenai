# LUMEN AI — Backend & AI Architecture

> **Status:** Approved draft · **Owner:** Backend Architect / DevOps · **Last updated:** 2026-07-18

## 1. Philosophy: local-first, backend-minimal

The MVP is **local-first**: all financial data lives on-device in SQLite. This is honest (no fake bank integration), private by default (a real product differentiator to talk about in interviews), and demo-proof (works offline on stage). The only backend surface in v1 is the **AI proxy** — because shipping an Anthropic API key inside a mobile binary is disqualifying.

```
Flutter app ──HTTPS──▶ Lumen AI Proxy (single service) ──▶ Claude API
                        ├─ auth: signed app token (v1: static per-build token
                        │        + rate limit; v2: real user auth)
                        ├─ prompt assembly + guardrails
                        ├─ rate limiting / cost caps
                        └─ zero persistence of financial data (stateless)
```

## 2. AI proxy service

- **Runtime:** small **TypeScript (Hono/Fastify)** service. *Rejected:* full NestJS (overkill for one endpoint), Firebase Functions (cold starts hurt streaming UX).
- **Endpoint:** `POST /v1/copilot` → **SSE stream** of the same `CopilotEvent` union the client defines. One contract, documented in `docs/api/openapi.yaml`.
- **Model:** `claude-sonnet-5` for conversational quality/cost balance; `claude-haiku-4-5` for the batch categorization endpoint. Model ids are config, not code.
- **Deploy:** containerized (Dockerfile), deployed on Fly.io or Railway; IaC kept to a minimal, readable `fly.toml` + GitHub Actions deploy job.

## 3. Prompt & context architecture (the interesting part)

The client does **not** ship the whole ledger to the model. Instead:

1. Client computes a **compact financial context pack** locally (Drift SQL): per-category monthly totals for trailing 6 months, active subscriptions, top merchants, budget states, plus the N transactions matching the question's entities (date/merchant/category extraction done locally).
2. Proxy wraps it in a system prompt with strict rules: answer only from provided data, cite transaction ids for every claim (→ becomes the **evidence-highlight UX**), refuse investment advice, currency-format via provided locale.
3. Responses are structured: prose stream + optional `insight_card` JSON blocks (tool-use style) the client renders natively.

This design gives three interview-ready talking points: **privacy-preserving context minimization**, **grounded-with-citations UX**, and **deterministic math / generative explanation split**.

## 4. AI feature matrix

| Feature | Mechanism | Fallback if offline |
|---|---|---|
| Transaction categorization | Local rules first; Haiku batch for unknowns | Rules + "Other" |
| Subscription & anomaly detection | **Local algorithms** (deterministic) | Fully functional |
| Cash-flow forecast | Local (trailing median burn) | Fully functional |
| Copilot Q&A | Sonnet via proxy, SSE | Graceful offline state with suggested local insights |
| Monthly narrative ("Your July, explained") | Sonnet, generated once per period, cached locally | Last cached narrative |

## 5. Security checklist (v1)

- No secrets in the client — enforced by CI secret scan (gitleaks).
- Certificate pinning on the proxy domain.
- Biometric app-lock (local auth), SQLite encrypted at rest (SQLCipher via drift).
- Proxy: rate limit per token, hard monthly cost cap, structured logs *without* payload bodies.
- Threat-model one-pager in `docs/security.md` (STRIDE-lite) — writing it down is the senior move.
