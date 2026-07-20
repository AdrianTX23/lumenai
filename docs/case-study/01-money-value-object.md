# Why `Money` is 25 lines and has no `double` in it

Every finance app eventually gets a bug report that looks like this: a
balance off by one cent, a total that doesn't match the sum of its parts,
a discount that rounds differently on the receipt than in the cart. Almost
all of them trace back to the same root cause — someone modeled money as
a floating-point number.

`0.1 + 0.2 != 0.3` in IEEE 754 binary floating point. That's not a Dart
quirk; it's true in every language that uses `double` for currency. COP
(Colombian pesos) makes the failure mode worse, not better: prices are
often quoted in round thousands, so the temptation to treat amounts as
"just numbers" is stronger, and the eventual rounding drift is more
visible to a user staring at a total.

LUMEN's rule, stated in the domain doc before a line of UI existed
(`docs/04-domain-model.md §1`): **amounts are minor units (an `int`) plus
a currency code, always.** [`Money`](../../packages/core_domain/lib/src/value_objects/money.dart)
is the entire implementation:

```dart
final class Money implements Comparable<Money> {
  const Money.minor(this.minorUnits, this.currencyCode);
  const Money.zero(this.currencyCode) : minorUnits = 0;

  final int minorUnits;
  final String currencyCode;

  Money operator +(Money other) {
    _guardCurrency(other);
    return Money.minor(minorUnits + other.minorUnits, currencyCode);
  }
  // -, unary -, abs(), compareTo, ==, hashCode, toString
}
```

That's the whole value object. No formatting logic, no locale awareness,
no persistence annotations. It does exactly one job — safe arithmetic on
an exact integer — and refuses every other job by construction.

## The currency guard is the interesting part

`_guardCurrency` throws `ArgumentError` the moment you try to add EUR to
COP. That's a deliberate asymmetry with the rest of the codebase, which
almost never throws — everywhere else, failure is a value
(`Result<Failure, T>`), because a user can recover from "insufficient
funds" or "network unreachable." A currency mismatch inside `Money`
arithmetic is different: it's not a state the *user* caused, it's a
*programmer* error — a code path that mixed two accounts' currencies
without converting first. Throwing turns that into a loud test failure
during development instead of a silently wrong net-worth figure in
production. `Result` is for the outside world; exceptions are for
invariants the type system couldn't express but the domain still owns.

## What `Money` deliberately doesn't do

It doesn't format itself. [`LdsMoneyFormat`](../../packages/core_ui/lib/src/utils/lds_money_format.dart)
in `core_ui` owns that, because formatting is a *presentation* concern —
it needs a `locale`, it needs to know COP is conventionally rendered with
zero decimal places while EUR uses two, it needs compact notation for a
card face versus full precision for a transaction detail sheet. None of
that belongs on the value object; bolting it on would drag Flutter's
`intl` dependency into `core_domain`, which is not allowed to know Flutter
exists (`docs/02-architecture.md §3, L1`). Every renderer goes through one
formatter, which is why a whole class of "this screen shows €12,50 and
that screen shows €12.50" bugs simply cannot occur here — there's only
one code path that turns minor units into a string.

It also doesn't know about the database. `core_data`'s Drift schema
stores `minorUnits` as an `INTEGER` column and `currencyCode` as `TEXT`;
the mapper reconstructs a `Money` on the way out. `Money` never gains a
`toJson`/`fromDb` pair, which is the same L1 purity rule applied
consistently: the domain model has zero opinions about how it's
persisted or transmitted, so a future migration to a different database
— or a server — never touches this file.

## The bug this exact design caught, live

This wasn't theoretical. During Phase 2, the wallet-card component
(`PaymentCard`/`CardStack`) defaulted its `currencyCode`/`locale`
parameters to `'EUR'`/`'en'` when nothing was explicitly passed in —
reasonable component defaults for a design-system piece meant to be
generic. `home_screen.dart` never threaded the account's real
`currencyCode`/`locale` through, so on the web build the balance card
rendered `-€165,605.75` for what should have been a Colombian-peso
figure. It surfaced immediately, in the first minute of browser testing,
because there is exactly **one** formatter and **one** value object in
the whole app — there was nowhere else for the currency to quietly leak
in from, and nowhere else to fix it but the three call sites that
weren't passing it through. Threading `currencyCode`/`locale` from
`home_screen.dart` → `CardStackItem` → `PaymentCard` closed it; the
existing golden and component tests caught the regression risk on the
way out.

That's the actual payoff of a 25-line value object: not that it prevents
every bug, but that when a money bug does happen, there is exactly one
place to look, and exactly one place to fix it.
