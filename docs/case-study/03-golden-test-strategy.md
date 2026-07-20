# Testing a design system with screenshots, on purpose

Widget tests answer "did the right text render and did the button call
the right handler." They cannot answer "does this still look right" —
and for a design system, *looks right* is the actual product. A
`LdsButton` can pass every semantic assertion in its test suite and
still ship with the wrong border radius, a token regression that
desaturated every accent color, or 2px of padding that got hand-edited
back in during a merge conflict. None of that trips a `find.text()`
assertion. It trips a human eye — or a pixel diff.

LUMEN's `core_ui` package runs both kinds of test, deliberately kept
separate:

- **Behavior tests** (`test/components/*_test.dart`) — does `LdsButton`
  fire `onPressed`, does `CardStack` bring the tapped card to front,
  does `LdsSearchField` clear on the suffix button. Fast, no rendering
  concerns, one assertion per interaction.
- **Golden tests** (`test/goldens/*_test.dart`, via
  [alchemist](https://pub.dev/packages/alchemist)) — does this component
  render *pixel-identical* to its last approved snapshot, in **both**
  light and dark theme, for every documented scenario.

## One helper, so nothing skips the pair

```dart
void ldsGoldenPair({
  required String fileName,
  required Map<String, Widget> scenarios,
  BoxConstraints? constraints,
}) {
  for (final (suffix, dark) in [('dark', true), ('light', false)]) {
    goldenTest(
      '$fileName ($suffix)',
      fileName: '${fileName}_$suffix',
      pumpBeforeTest: pumpOnce,
      builder: () => GoldenTestGroup(
        scenarioConstraints: constraints ?? const BoxConstraints(maxWidth: 420),
        children: [
          for (final entry in scenarios.entries)
            GoldenTestScenario(name: entry.key, child: ldsWrap(child: entry.value, dark: dark)),
        ],
      ),
    );
  }
}
```

([`golden_helpers.dart`](../../packages/core_ui/test/helpers/golden_helpers.dart))
Every component's golden test is a `Map<String, Widget>` of named
scenarios passed once into `ldsGoldenPair`; the helper is what generates
*both* theme variants, not the test author. There is no way to add a new
`PaymentCard` skin and golden-test only the theme you happened to be
looking at — the light/dark pair is structural, not a checklist item a
reviewer has to remember. `ldsWrap` also forces
`MediaQueryData(disableAnimations: true)`, so `TweenAnimationBuilder`-driven
widgets — count-up amounts, skeleton shimmer, chart entrance animations —
render their **settled end state** in a single pump instead of
whatever mid-tween frame the test happened to catch. A golden test that
occasionally fails because it caught frame 14 of 30 is worse than no
golden test: it trains reviewers to re-run flaky CI instead of reading
the diff.

## Two baselines, one CI

Font rasterization differs by platform — the exact same widget tree
renders subtly different anti-aliasing on macOS versus Linux CI runners.
Golden tests are pixel-exact by design, so that difference is enough to
fail a comparison that has nothing to do with a real regression. The
suite keeps **two baseline sets** (`goldens/macos/`, `goldens/ci/`) and
alchemist selects the matching one per platform, so a contributor running
tests locally on a Mac and CI running on Linux are each compared against
*their own* rendering reality — not against each other's font hinting.

## What this catches that behavior tests structurally can't

The [currency-formatting bug](01-money-value-object.md) that showed
`-€165,605.75` instead of Colombian pesos would have passed every
existing behavior test — `PaymentCard` was rendering *a* balance, calling
`LdsMoneyFormat.format` with valid arguments, showing real text on
screen. The wrongness was entirely in *which* value flowed in, which is
exactly the category of bug a rendered-pixel comparison is positioned to
catch and a `find.text('some string')` assertion is not, because nobody
had written an assertion for "the currency symbol must be ₱ not €" — you
don't enumerate the ways a design system can look wrong in advance, you
compare it to what you already approved. Alongside `dart analyze
--fatal-infos` and `check_boundaries.sh` (the physical package-boundary
enforcement described in the architecture doc), this is the third leg of
the same idea: cheap, structural checks that don't rely on someone
remembering to look.
