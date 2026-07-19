# LUMEN Design System (LDS)

> **Status:** Approved draft · **Owner:** UI/UX Designer / Senior Flutter Engineer · **Last updated:** 2026-07-18

The design system is a **standalone package (`core_ui`) with its own gallery app (Widgetbook)**. No screen may use a raw color, raw `TextStyle`, magic-number padding, or ad-hoc button. If it's not a token or a component, it doesn't ship.

## 1. Brand concept — "Light in the dark"

*Lumen* = the unit of light. The brand metaphor: **your finances are opaque; LUMEN illuminates them.** Visual language: deep near-black surfaces, luminous accent gradients, soft glows on focal data. Dark-first (finance apps live in dark mode), full light-mode parity.

## 2. Token architecture (3 tiers)

```
Primitive tokens  ──▶  Semantic tokens  ──▶  Component tokens
(palette, scale)       (surface, accent,      (button.height,
 never used directly    danger, textMuted…)    card.radius…)
```

Implemented as `ThemeExtension`s so both themes resolve through one API: `context.lds.colors.surfaceElevated`, `context.lds.spacing.md`, `context.lds.motion.emphasized`.

### 2.1 Color

- **Neutrals:** true-dark scale from `#070A0F` (base) → elevated surfaces via *lightness steps, not opacity hacks* (12 steps).
- **Accent — "Lumen glow":** electric mint→cyan gradient (`#B8FFD9 → #38E1C6 → #22B8CF`) reserved for *money-positive and focal* moments only.
- **Semantic:** `positive` (gains/income), `negative` (spend — a warm coral, **not** aggressive red; calm pillar), `warning`, `info`.
- **Data-viz palette:** 8 categorical hues tuned for dark surfaces, contrast-checked (≥3:1 against surface), colorblind-safe ordering.
- Every fg/bg pair documented with its WCAG ratio; AA is the floor, AAA for body text.

### 2.2 Typography

- **Display/numbers:** a grotesque with tabular figures (e.g. *Inter* with `tnum`/`ss01`, or *Söhne*-class alternative). **Tabular numerals are non-negotiable** — amounts must not jitter as they change.
- Scale (1.250 ratio): `display-xl 48/56` (net-worth hero) · `display 34/40` · `title 24/30` · `heading 18/24` · `body 15/22` · `label 13/18` · `caption 11/16`.
- Full dynamic-type support: scale respects OS text-size settings up to 1.4× with tested layouts.

### 2.3 Space, shape, elevation

- Spacing: 4-pt base scale `4 / 8 / 12 / 16 / 20 / 24 / 32 / 40 / 56`.
- Radius: `sm 10 · md 16 · lg 24 · card 28 · full` (continuous/squircle corners via `ContinuousRectangleBorder`-style shapes — the Apple detail).
- Elevation in dark mode = **surface lightness + subtle 1px inner border**, never drop shadows on dark.

### 2.4 Motion

- Duration tokens: `fast 120ms · standard 240ms · emphasized 400ms · celebratory 600ms`.
- Curves: `standardEasing (0.2,0,0,1)` · `emphasized (0.05,0.7,0.1,1)` · spring configs for gestural surfaces (card stack, sheets).
- Rules: motion always spatial (things come *from* somewhere), 60fps enforced (perf tests), `MediaQuery.disableAnimations` respected.

## 3. Component inventory (all in Widgetbook, all golden-tested, light+dark)

**Foundations:** `LdsScaffold`, responsive grid, safe-area handling.
**Actions:** `LdsButton` (primary/secondary/ghost/destructive × 3 sizes, loading & disabled states, haptic on press), `LdsIconButton`, `LdsSegmentedControl`.
**Data display:** `AmountText` (tabular, animated count-up, sign/color logic in ONE place), `TransactionTile` (merchant logo, category chip, amount), `LdsCard`, `CategoryChip`, `TrendBadge` (▲ 12% styling), `LdsAvatar`/merchant logo with fallback monogram.
**Wallet:** `PaymentCard` (the visual credit card — gradient skins, number masking), `CardStack` (Apple-Wallet drag/fan interaction).
**Charts (custom painters):** `SpendDonut`, `CashflowBars` (income vs spend), `SparkLine`, `BudgetPaceBar`, `HeatCalendar` (spend-per-day). All animate on first paint, all support scrub/tooltip.
**Feedback:** `LdsSnack`, `LdsSheet` (modal bottom sheet with drag + snap), `LdsEmptyState`, `LdsSkeleton` (shimmer that matches real layout), `LdsErrorState` (with retry).
**Copilot:** `ChatBubble` (user/assistant, streaming-text state), `InsightCard` (AI insight w/ confidence affordance), `PromptSuggestionChip`.
**Navigation:** `LdsBottomBar` (floating, blurred, animated selection), `LdsAppBar` (large-title collapse behavior).

## 4. UX architecture

- **IA:** 4 tabs — **Home · Activity · Insights · Copilot** (+ Settings via profile). Budgets live inside Insights; a 5th tab would dilute.
- **Navigation grammar:** push = drill-in detail · sheet = quick action/glanceable detail · full-screen modal = flows (onboarding, budget creation).
- **Key screens spec'd before build** (low-fi in `docs/design/` first): Home, Transaction detail (sheet), Insights, Budget detail, Copilot thread, Onboarding (3 steps + biometrics).
- **Signature interactions** (the demo moments): card-stack fan-out; net-worth count-up on launch; donut→category drill with shared-element transition; copilot streaming answer that *highlights the transactions it used as evidence*.

## 5. Accessibility bar

Semantics labels on all custom-painted charts (values readable by screen reader), contrast AA minimum, touch targets ≥44pt, `Semantics` traversal order audited per screen, reduced-motion parity, ES + EN localization from day one.
