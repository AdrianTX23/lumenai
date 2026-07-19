import 'package:core_domain/src/entities/analytics.dart';
import 'package:core_domain/src/repositories/analytics_repository.dart';

/// Streams the total balance across all accounts.
final class ObserveNetWorth {
  /// Creates the use case.
  const ObserveNetWorth(this._analytics);

  final AnalyticsRepository _analytics;

  /// Subscribes to the live net-worth figure.
  Stream<NetWorth> call() => _analytics.watchNetWorth();
}
