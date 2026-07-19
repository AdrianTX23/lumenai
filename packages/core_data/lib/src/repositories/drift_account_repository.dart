import 'package:core_data/src/database/lumen_database.dart';
import 'package:core_data/src/mappers/row_mappers.dart';
import 'package:core_domain/core_domain.dart';

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
}
