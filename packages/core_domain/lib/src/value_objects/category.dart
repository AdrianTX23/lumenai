/// Closed set of spending categories.
///
/// Deliberately an enum, not user-defined tags: the AI categorizer, the
/// analytics SQL and the design-system color/icon mapping all rely on a
/// stable, finite vocabulary.
enum Category {
  /// Supermarkets and food shops.
  groceries,

  /// Restaurants, cafés, delivery.
  dining,

  /// Public transport, ride-hailing, fuel.
  transport,

  /// Recurring digital and membership services.
  subscriptions,

  /// Rent and mortgage.
  housing,

  /// Power, water, internet, phone.
  utilities,

  /// Pharmacy, medical, fitness.
  health,

  /// Retail and online shopping.
  shopping,

  /// Flights, hotels, holidays.
  travel,

  /// Cinema, events, games.
  entertainment,

  /// Salary and other inflows.
  income,

  /// Movements between own accounts — excluded from spend analytics.
  transfers,

  /// Bank fees and interest.
  fees,

  /// Anything unclassified.
  other;

  /// Whether this category counts toward spending analytics.
  bool get isSpending => this != income && this != transfers;

  /// Whether the same merchant charging repeatedly in this category is
  /// typically a meaningful signal (a bill, a membership) rather than
  /// coincidental repeat visits to a favorite grocery store or
  /// restaurant. Recurrence detection (`RecurringChargeDetector`) uses
  /// this to avoid flagging habitual-but-variable spending as a
  /// "recurring charge" — the interval math alone can't tell the
  /// difference, but the category usually can.
  bool get isTypicallyRecurring => switch (this) {
        Category.subscriptions ||
        Category.housing ||
        Category.utilities ||
        Category.health ||
        Category.fees =>
          true,
        _ => false,
      };
}
