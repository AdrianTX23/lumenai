import 'package:core_data/src/database/lumen_database.dart';
import 'package:core_data/src/mappers/row_mappers.dart';
import 'package:core_domain/core_domain.dart';
import 'package:drift/drift.dart';

/// Drift adapter for [AccountRepository].
final class DriftAccountRepository implements AccountRepository {
  /// Creates the adapter over the database.
  const DriftAccountRepository(this._db);

  final LumenDatabase _db;

  @override
  Stream<List<AccountSnapshot>> watchAccounts() {
    return _db.watchAccountsWithBalances().map(
          (rows) => rows
              .map(
                (row) => AccountSnapshot(
                  account: row.$1.toEntity(),
                  balance: Money.minor(row.$2, row.$1.currencyCode),
                ),
              )
              .toList(),
        );
  }

  @override
  Future<Result<void>> createAccount(Account account) async {
    try {
      final cardMeta = account.cardMeta;
      await _db.into(_db.accounts).insert(
            AccountsCompanion.insert(
              id: account.id.value,
              name: account.name,
              type: account.type,
              currencyCode: account.currencyCode,
              openingBalanceMinor: account.openingBalance.minorUnits,
              cardLast4: Value(cardMeta?.last4),
              cardNetwork: Value(cardMeta?.network),
              cardSkinIndex: Value(cardMeta?.skinIndex),
            ),
          );
      return const Result.ok(null);
    } on Exception catch (e) {
      return Result.err(StorageFailure('create account failed: $e'));
    }
  }
}
