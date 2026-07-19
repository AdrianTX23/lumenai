## What

<!-- One paragraph: what this PR does, in product terms when applicable. -->

## Why

<!-- Motivation / linked phase in docs/07-roadmap.md or issue. -->

## Screenshots

<!-- REQUIRED for UI changes: light + dark. Delete section otherwise. -->

| Dark | Light |
|---|---|
| | |

## Checklist

- [ ] Follows the dependency matrix (docs/02-architecture.md §4) — `melos run boundaries` passes
- [ ] Sealed-state controllers tested for every transition (if presentation)
- [ ] New/changed core_ui components have Widgetbook use cases + goldens (light & dark)
- [ ] No hardcoded copy (EN + ES strings) · no raw colors/text styles/paddings
- [ ] Zero analyzer warnings · `melos run test` green locally
- [ ] ADR added/updated if a non-obvious decision was made
