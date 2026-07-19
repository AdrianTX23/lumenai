/// LUMEN AI infrastructure layer.
///
/// Repository implementations (adapters) for the ports declared in
/// `core_domain`, backed by Drift/SQLite locally and the AI proxy remotely.
/// Exceptions from underlying technologies are translated to domain
/// `Failure`s at this boundary — see `docs/02-architecture.md` §3 (L3).
///
/// Populated in Phase 2 (database, seed engine) and Phase 5 (remote).
library;
