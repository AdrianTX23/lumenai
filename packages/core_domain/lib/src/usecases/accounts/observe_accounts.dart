import 'package:core_domain/src/entities/account.dart';
import 'package:core_domain/src/repositories/account_repository.dart';

/// Streams all accounts with live balances.
final class ObserveAccounts {
  /// Creates the use case.
  const ObserveAccounts(this._accounts);

  final AccountRepository _accounts;

  /// Subscribes to accounts, newest data always.
  Stream<List<AccountSnapshot>> call() => _accounts.watchAccounts();
}
