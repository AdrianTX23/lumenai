import 'package:core_domain/core_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen_app/di/di.dart';

/// Live net worth. `AsyncValue` is the sealed loading/data/error state.
final netWorthProvider = StreamProvider<NetWorth>(
  (ref) => ref.watch(observeNetWorthProvider)(),
);

/// Live accounts with balances.
final accountsProvider = StreamProvider<List<AccountSnapshot>>(
  (ref) => ref.watch(observeAccountsProvider)(),
);

/// The five most recent transactions for the home preview.
final recentTransactionsProvider = StreamProvider<List<Transaction>>(
  (ref) => ref.watch(observeTransactionsProvider)(
    const TransactionFilter(limit: 5),
  ),
);
