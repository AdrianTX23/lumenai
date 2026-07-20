import 'package:core_domain/src/entities/account.dart';
import 'package:core_domain/src/failures/result.dart';

/// Port: account reads and manual creation. Implemented by core_data
/// (Drift adapter).
abstract interface class AccountRepository {
  /// All accounts with live balances. Emits on any relevant write.
  Stream<List<AccountSnapshot>> watchAccounts();

  /// Adds a manually-entered account.
  Future<Result<void>> createAccount(Account account);
}
