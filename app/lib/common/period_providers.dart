import 'package:core_domain/core_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The period Insights and Budgets report on — the calendar month
/// containing now. Shared here (not owned by either feature) since
/// features may not import each other's internals.
final currentPeriodProvider = Provider<Period>(
  (ref) => Period.monthly(containing: DateTime.now()),
);
