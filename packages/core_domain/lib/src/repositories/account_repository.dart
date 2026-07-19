import 'package:core_domain/src/entities/account.dart';

/// Port: account reads. Implemented by core_data (Drift adapter).
// Ports legitimately start single-method; a function type would freeze the
// contract shape.
// ignore: one_member_abstracts
abstract interface class AccountRepository {
  /// All accounts with live balances. Emits on any relevant write.
  Stream<List<AccountSnapshot>> watchAccounts();
}
