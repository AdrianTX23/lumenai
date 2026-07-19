# PR Review Checklist

Applied to every PR — including solo PRs. The discipline is the point.

## Architecture
- [ ] Dependencies point inward only; no new boundary violations
- [ ] Business rules live in core_domain (not controllers, not widgets)
- [ ] Exceptions translated to `Failure`s at adapter boundaries
- [ ] New ports justified; adapters bound only in `app/lib/di/`

## Quality
- [ ] Naming matches surrounding code; no dead code, no commented-out code
- [ ] Tests assert behavior (state transitions, exact values), not implementation
- [ ] Failure/empty/loading paths covered, not just happy path

## UI (when applicable)
- [ ] Built exclusively from core_ui tokens/components
- [ ] Light + dark verified; dynamic type 1.0×/1.4×; semantics labels
- [ ] Motion respects reduced-motion; 60fps on profile build for new interactions

## Product
- [ ] Copy localized EN + ES, reviewed for tone (calm, clear, no jargon)
- [ ] Matches the screen spec in docs/design/ (or the spec was updated first)
