/// LUMEN AI domain layer: pure Dart business model.
///
/// This package holds entities, value objects, repository interfaces
/// (ports), use cases and domain services. It depends on nothing — no
/// Flutter, no IO, no serialization. See `docs/02-architecture.md` §3.
library;

export 'src/entities/account.dart';
export 'src/entities/analytics.dart';
export 'src/entities/budget.dart';
export 'src/entities/cashflow_forecast.dart';
export 'src/entities/subscription_insight.dart';
export 'src/entities/transaction.dart';
export 'src/failures/failure.dart';
export 'src/failures/result.dart';
export 'src/repositories/account_repository.dart';
export 'src/repositories/analytics_repository.dart';
export 'src/repositories/budget_repository.dart';
export 'src/repositories/seed_repository.dart';
export 'src/repositories/transaction_repository.dart';
export 'src/services/cashflow_forecaster.dart';
export 'src/services/merchant_normalizer.dart';
export 'src/services/recurring_charge_detector.dart';
export 'src/usecases/accounts/observe_accounts.dart';
export 'src/usecases/accounts/observe_net_worth.dart';
export 'src/usecases/budgets/create_budget.dart';
export 'src/usecases/budgets/delete_budget.dart';
export 'src/usecases/budgets/observe_budgets.dart';
export 'src/usecases/insights/detect_subscriptions.dart';
export 'src/usecases/insights/forecast_cashflow.dart';
export 'src/usecases/insights/observe_monthly_cashflow.dart';
export 'src/usecases/insights/observe_spending_breakdown.dart';
export 'src/usecases/seed/reset_data.dart';
export 'src/usecases/seed/seed_demo_data.dart';
export 'src/usecases/transactions/observe_transactions.dart';
export 'src/usecases/transactions/recategorize_transaction.dart';
export 'src/value_objects/category.dart';
export 'src/value_objects/identifiers.dart';
export 'src/value_objects/money.dart';
export 'src/value_objects/period.dart';
