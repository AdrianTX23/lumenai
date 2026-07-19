# LUMEN AI — Engineering Standards, DevOps & Quality

> **Status:** Approved draft · **Owner:** Tech Lead / DevOps · **Last updated:** 2026-07-18

## 1. Repository discipline

- **Trunk-based:** short-lived branches → PR → squash-merge to `main`. `main` is always demo-able.
- **Conventional Commits** (`feat(insights): …`, `fix(core_ui): …`) — enables changelog automation and reads professionally in history.
- **PR template** with: what/why, screenshots (light+dark) for UI changes, test evidence.
- Every PR reviewed against a written checklist (`docs/checklists/pr-review.md`) even when solo — the discipline shows in the history.

## 2. Static quality gates

- `very_good_analysis` lint set + custom rules; `dart format` enforced.
- **Import boundaries** enforced (no `features/*` cross-imports; `core_ui` cannot import data/domain) via `dart_code_metrics`-style banned-import config.
- `dart analyze --fatal-infos` in CI — zero-warning policy from commit one (retrofitting this later is impossible).

## 3. CI/CD (GitHub Actions)

```
on: pull_request → main
├─ setup (Flutter pinned via fvm, melos bootstrap, cache)
├─ analyze        (fatal-infos, format check)
├─ test           (unit + widget, per-package, coverage → Codecov badge)
├─ goldens        (alchemist CI mode, light+dark)
├─ secret-scan    (gitleaks)
└─ build          (Android APK + iOS no-codesign — proves both compile)

on: tag v* → release
├─ all of the above
├─ build signed Android APK/AAB artifact
├─ deploy AI proxy (Fly.io) when proxy/ changed
└─ GitHub Release with auto-changelog
```

Status badges (build, coverage, license) at the top of the README.

## 4. Performance budget

- 60fps on signature interactions — verified with `flutter drive --profile` timeline tests on the card stack and chart animations.
- Cold start < 2s to interactive home (seeded DB warm path).
- No jank on 2,400-transaction feed: `ListView` slivers + `RepaintBoundary` audit + const discipline.
- App size tracked per release (`--analyze-size` in CI job artifact).

## 5. Definition of Done (every feature)

1. Sealed-state controller with unit tests for every transition.
2. UI built only from `core_ui` tokens/components; any new component lands in Widgetbook + goldens first.
3. Dark & light verified; dynamic type 1.0×/1.4× verified; semantics audit.
4. EN + ES strings (no hardcoded copy).
5. Zero analyzer warnings; CI green; screenshots in PR.

## 6. Portfolio packaging (planned from day one, not an afterthought)

- **README** as a case study: hero GIF, architecture diagram (mermaid), design-system screenshots, "decisions & trade-offs" section linking ADRs, honest "what I'd do next".
- **90-second demo video** script: launch → net-worth count-up → card fan → donut drill-down → budget pace → copilot answering with evidence highlights.
- Widgetbook deployed as a **web build on GitHub Pages** — reviewers can play with the design system without installing anything.
- `docs/` suite (these files) linked prominently — the planning itself is exhibit A.
