import 'package:core_domain/src/entities/account.dart';
import 'package:core_domain/src/failures/failure.dart';
import 'package:core_domain/src/failures/result.dart';
import 'package:core_domain/src/repositories/account_repository.dart';

/// Validates and persists a manually-entered account.
final class CreateAccount {
  /// Creates the use case.
  const CreateAccount(this._accounts);

  final AccountRepository _accounts;

  /// Validates [account] and stores it.
  Future<Result<void>> call(Account account) async {
    if (account.name.trim().isEmpty) {
      return const Result.err(
        ValidationFailure('account name must not be empty'),
      );
    }
    return _accounts.createAccount(account);
  }
}
