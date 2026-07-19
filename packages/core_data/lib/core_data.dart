/// LUMEN AI infrastructure layer.
///
/// Repository implementations (adapters) for the ports declared in
/// `core_domain`, backed by Drift/SQLite locally and the AI proxy remotely.
/// Exceptions from underlying technologies are translated to domain
/// `Failure`s at this boundary — see `docs/02-architecture.md` §3 (L3).
library;

export 'src/database/lumen_database.dart';
export 'src/database/open_database.dart';
export 'src/repositories/drift_account_repository.dart';
export 'src/repositories/drift_analytics_repository.dart';
export 'src/repositories/drift_budget_repository.dart';
export 'src/repositories/drift_seed_repository.dart';
export 'src/repositories/drift_transaction_repository.dart';
export 'src/seed/seed_engine.dart';
