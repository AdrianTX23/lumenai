import 'package:core_domain/core_domain.dart';
import 'package:test/test.dart';

final class _RecordingAccountRepository implements AccountRepository {
  final created = <Account>[];

  @override
  Stream<List<AccountSnapshot>> watchAccounts() => const Stream.empty();

  @override
  Future<Result<void>> createAccount(Account account) async {
    created.add(account);
    return const Result.ok(null);
  }
}

Account _account({
  String name = 'My Wallet',
  AccountType type = AccountType.checking,
}) {
  return Account(
    id: const AccountId('a1'),
    name: name,
    type: type,
    currencyCode: 'COP',
    openingBalance: const Money.zero('COP'),
  );
}

void main() {
  group('CreateAccount', () {
    late _RecordingAccountRepository repo;
    late CreateAccount createAccount;

    setUp(() {
      repo = _RecordingAccountRepository();
      createAccount = CreateAccount(repo);
    });

    test('persists a valid account', () async {
      final result = await createAccount(_account());

      expect(result.isOk, isTrue);
      expect(repo.created, hasLength(1));
    });

    test('rejects an empty name', () async {
      final result = await createAccount(_account(name: '   '));

      expect(result.isErr, isTrue);
      expect((result as Err<void>).failure, isA<ValidationFailure>());
      expect(repo.created, isEmpty);
    });
  });
}
