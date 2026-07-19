# LUMEN AI

> An AI-native personal finance app — a beautifully designed wallet that understands your spending and gives you a financial copilot you can talk to.

**Status: Phase 0 — Foundations.** See the [planning suite](docs/README.md) for the full product vision, architecture, design system and roadmap. This README becomes the project case study at Phase 7.

## Workspace

Melos monorepo · Flutter 3.27.4 (pinned in `.fvmrc`) · see [docs/02-architecture.md](docs/02-architecture.md).

```
app/         Composition root + feature presentation slices
packages/    core_domain · core_data · core_ui · core_l10n · core_telemetry
widgetbook/  Living design-system gallery
docs/        Planning suite + ADRs
```

## Getting started

```sh
dart pub get            # resolves the workspace (melos is a root dev dependency)
dart run melos bootstrap
dart run melos run analyze
dart run melos run test
```

## License

[MIT](LICENSE)
