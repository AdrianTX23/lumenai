import 'package:core_domain/core_domain.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen_app/di/di.dart';

/// All accounts with live balances. Shared here (not owned by Home)
/// since the add-transaction and add-account flows also need the
/// account list, and features may not import each other's internals.
final accountsStreamProvider = StreamProvider<List<AccountSnapshot>>(
  (ref) => ref.watch(observeAccountsProvider)(),
);
