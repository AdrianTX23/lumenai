import 'package:core_domain/core_domain.dart';
import 'package:test/test.dart';

final class _RecordingBudgetRepository implements BudgetRepository {
  final upserts = <Budget>[];

  @override
  Stream<List<Budget>> watchBudgets() => const Stream.empty();

  @override
  Future<Result<void>> upsertBudget(Budget budget) async {
    upserts.add(budget);
    return const Result.ok(null);
  }

  @override
  Future<Result<void>> deleteBudget(BudgetId id) async => const Result.ok(null);
}

Budget _budget({
  Category category = Category.groceries,
  int limitMinor = 30000,
  int anchorDay = 1,
}) {
  return Budget(
    id: const BudgetId('b1'),
    category: category,
    limit: Money.minor(limitMinor, 'EUR'),
    anchorDay: anchorDay,
    createdAt: DateTime(2026, 7, 19),
  );
}

void main() {
  group('CreateBudget', () {
    late _RecordingBudgetRepository repo;
    late CreateBudget createBudget;

    setUp(() {
      repo = _RecordingBudgetRepository();
      createBudget = CreateBudget(repo);
    });

    test('persists a valid budget', () async {
      final result = await createBudget(_budget());

      expect(result.isOk, isTrue);
      expect(repo.upserts, hasLength(1));
    });

    test('rejects non-positive limits', () async {
      final result = await createBudget(_budget(limitMinor: 0));

      expect(result.isErr, isTrue);
      expect(
        (result as Err<void>).failure,
        isA<ValidationFailure>(),
      );
      expect(repo.upserts, isEmpty);
    });

    test('rejects income and transfer categories', () async {
      for (final category in [Category.income, Category.transfers]) {
        final result = await createBudget(_budget(category: category));
        expect(result.isErr, isTrue, reason: '$category must be rejected');
      }
      expect(repo.upserts, isEmpty);
    });

    test('rejects out-of-range anchor days', () async {
      for (final day in [0, 32]) {
        final result = await createBudget(_budget(anchorDay: day));
        expect(result.isErr, isTrue, reason: 'anchor $day must be rejected');
      }
      expect(repo.upserts, isEmpty);
    });
  });
}
