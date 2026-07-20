import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart';
import 'package:core_telemetry/core_telemetry.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen_app/di/app_flavor.dart';

/// The active build flavor. Overridden in [overridesFor]; reading it before
/// bootstrap wires it is a programming error, hence no default.
final flavorProvider = Provider<AppFlavor>(
  (ref) => throw UnimplementedError('flavorProvider must be overridden'),
);

/// Logging port. Console adapter for now; a release adapter (crash
/// reporting vendor) will replace it per flavor without touching consumers.
final loggerProvider = Provider<Logger>((ref) => ConsoleLogger());

/// The database. Overridden per flavor in [overridesFor] and with an
/// in-memory instance in tests.
final databaseProvider = Provider<LumenDatabase>(
  (ref) => throw UnimplementedError('databaseProvider must be overridden'),
);

// ── Ports → adapters ─────────────────────────────────────────────────────

/// Account reads.
final accountRepositoryProvider = Provider<AccountRepository>(
  (ref) => DriftAccountRepository(ref.watch(databaseProvider)),
);

/// Transaction reads and category writes.
final transactionRepositoryProvider = Provider<TransactionRepository>(
  (ref) => DriftTransactionRepository(ref.watch(databaseProvider)),
);

/// SQL-backed analytics.
final analyticsRepositoryProvider = Provider<AnalyticsRepository>(
  (ref) => DriftAnalyticsRepository(ref.watch(databaseProvider)),
);

/// Budget storage.
final budgetRepositoryProvider = Provider<BudgetRepository>(
  (ref) => DriftBudgetRepository(ref.watch(databaseProvider)),
);

/// Demo-data lifecycle.
final seedRepositoryProvider = Provider<SeedRepository>(
  (ref) => DriftSeedRepository(ref.watch(databaseProvider)),
);

/// The copilot pipeline. Mock in every flavor today — Phase 5 swaps this
/// for the real SSE proxy client behind the same port, per
/// docs/05-backend-and-ai.md.
final copilotRepositoryProvider = Provider<CopilotRepository>(
  (ref) => MockCopilotRepository(
    analytics: ref.watch(analyticsRepositoryProvider),
    transactions: ref.watch(transactionRepositoryProvider),
  ),
);

// ── Use cases ────────────────────────────────────────────────────────────

/// Streams accounts with balances.
final observeAccountsProvider = Provider<ObserveAccounts>(
  (ref) => ObserveAccounts(ref.watch(accountRepositoryProvider)),
);

/// Streams total net worth.
final observeNetWorthProvider = Provider<ObserveNetWorth>(
  (ref) => ObserveNetWorth(ref.watch(analyticsRepositoryProvider)),
);

/// Streams the filtered transaction feed.
final observeTransactionsProvider = Provider<ObserveTransactions>(
  (ref) => ObserveTransactions(ref.watch(transactionRepositoryProvider)),
);

/// Applies a user recategorization.
final recategorizeTransactionProvider = Provider<RecategorizeTransaction>(
  (ref) => RecategorizeTransaction(ref.watch(transactionRepositoryProvider)),
);

/// Seeds the demo dataset when needed.
final seedDemoDataProvider = Provider<SeedDemoData>(
  (ref) => SeedDemoData(ref.watch(seedRepositoryProvider)),
);

/// Streams category spend for a period.
final observeSpendingBreakdownProvider = Provider<ObserveSpendingBreakdown>(
  (ref) => ObserveSpendingBreakdown(ref.watch(analyticsRepositoryProvider)),
);

/// Streams income vs. spend across trailing months.
final observeMonthlyCashflowProvider = Provider<ObserveMonthlyCashflow>(
  (ref) => ObserveMonthlyCashflow(ref.watch(analyticsRepositoryProvider)),
);

/// Streams detected recurring charges.
final detectSubscriptionsProvider = Provider<DetectSubscriptions>(
  (ref) => DetectSubscriptions(ref.watch(transactionRepositoryProvider)),
);

/// Streams a projection of next period's spend.
final forecastCashflowProvider = Provider<ForecastCashflow>(
  (ref) => ForecastCashflow(ref.watch(analyticsRepositoryProvider)),
);

/// Streams all budgets.
final observeBudgetsProvider = Provider<ObserveBudgets>(
  (ref) => ObserveBudgets(ref.watch(budgetRepositoryProvider)),
);

/// Validates and persists a budget.
final createBudgetProvider = Provider<CreateBudget>(
  (ref) => CreateBudget(ref.watch(budgetRepositoryProvider)),
);

/// Removes a budget.
final deleteBudgetProvider = Provider<DeleteBudget>(
  (ref) => DeleteBudget(ref.watch(budgetRepositoryProvider)),
);

/// Streams the copilot's answer to a question.
final askCopilotProvider = Provider<AskCopilot>(
  (ref) => AskCopilot(ref.watch(copilotRepositoryProvider)),
);

/// The single place where ports are bound to adapters (composition root).
List<Override> overridesFor(AppFlavor flavor) {
  return [
    flavorProvider.overrideWithValue(flavor),
    databaseProvider.overrideWith((ref) {
      final db = openAppDatabase(
        fileName: flavor == AppFlavor.dev ? 'lumen_dev.db' : 'lumen.db',
      );
      ref.onDispose(db.close);
      return db;
    }),
    // Phase 5+: CopilotRepository → mock (dev) | SSE proxy (prod).
  ];
}
