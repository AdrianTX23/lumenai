import 'package:core_domain/core_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen_app/common/period_providers.dart';
import 'package:lumen_app/di/di.dart';

/// All budgets.
final budgetsProvider = StreamProvider<List<Budget>>(
  (ref) => ref.watch(observeBudgetsProvider)(),
);

/// Spend so far in the current period, keyed by category — the same SQL
/// aggregation Insights uses for its breakdown, reused here for pace.
final budgetSpendProvider = StreamProvider<Map<Category, Money>>((ref) {
  final period = ref.watch(currentPeriodProvider);
  return ref.watch(observeSpendingBreakdownProvider)(period).map(
        (entries) => {for (final entry in entries) entry.category: entry.total},
      );
});
