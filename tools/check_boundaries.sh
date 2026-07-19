#!/usr/bin/env bash
# Enforces the architecture dependency matrix (docs/02-architecture.md §4).
# Package-level boundaries are already compile-enforced by pubspecs; this
# script catches the cases pubspecs cannot express:
#   1. core_domain must import nothing but itself (pure Dart).
#   2. core_ui must not import any internal package.
#   3. core_data must not import core_ui / core_l10n.
#   4. App feature code must not import core_data (only di/ and bootstrap may).
#   5. A feature must not import another feature's internals.
set -euo pipefail
cd "$(dirname "$0")/.."

fail=0
err() {
  echo "BOUNDARY VIOLATION: $1"
  echo "$2" | sed 's/^/  /'
  fail=1
}

# 1. core_domain: only dart: and its own package.
if hits=$(grep -rnE "^import 'package:(?!core_domain/)" -P packages/core_domain/lib 2>/dev/null); [ -n "${hits:-}" ]; then
  err "core_domain must have zero dependencies (L1 is pure Dart)" "$hits"
fi

# 2. core_ui: Flutter only — no internal packages.
if hits=$(grep -rnE "^import 'package:(core_domain|core_data|core_l10n|core_telemetry)/" packages/core_ui/lib 2>/dev/null); [ -n "${hits:-}" ]; then
  err "core_ui may depend on Flutter only (design system is business-logic free)" "$hits"
fi

# 3. core_data: adapters never touch presentation or l10n.
if hits=$(grep -rnE "^import 'package:(core_ui|core_l10n)/" packages/core_data/lib 2>/dev/null); [ -n "${hits:-}" ]; then
  err "core_data must not import core_ui or core_l10n" "$hits"
fi

# 4. Presentation never sees infrastructure; only the composition root binds it.
if hits=$(grep -rnE "^import 'package:core_data/" app/lib 2>/dev/null | grep -vE "app/lib/(di/|bootstrap\.dart)"); [ -n "${hits:-}" ]; then
  err "feature code must not import core_data (bind adapters in app/lib/di/ only)" "$hits"
fi

# 5. Features are isolated slices: no cross-feature imports.
if [ -d app/lib/features ]; then
  for dir in app/lib/features/*/; do
    feature=$(basename "$dir")
    if hits=$(grep -rnE "^import 'package:[a-z_]+/features/" "$dir" 2>/dev/null | grep -v "/features/$feature/"); [ -n "${hits:-}" ]; then
      err "feature '$feature' imports another feature's internals (communicate via router or domain)" "$hits"
    fi
  done
fi

if [ "$fail" -ne 0 ]; then
  echo
  echo "See docs/02-architecture.md §3–4 for the dependency rules."
  exit 1
fi
echo "Architecture boundaries OK."
