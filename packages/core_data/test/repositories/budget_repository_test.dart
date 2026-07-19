import 'package:core_data/core_data.dart';
import 'package:core_domain/core_domain.dart' hide Transaction;
import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';

Budget _budget({
  String id = 'b1',
  Category category = Category.groceries,
  int limitMinor = 30000,
}) {
  return Budget(
    id: BudgetId(id),
    category: category,
    limit: Money.minor(limitMinor, 'EUR'),
    anchorDay: 1,
    createdAt: DateTime(2026, 7, 19),
  );
}

void main() {
  late LumenDatabase db;
  late DriftBudgetRepository repo;

  setUp(() {
    db = LumenDatabase(NativeDatabase.memory());
    repo = DriftBudgetRepository(db);
  });

  tearDown(() async => db.close());

  group('DriftBudgetRepository', () {
    test('upsert then watch round-trips the entity', () async {
      await repo.upsertBudget(_budget());

      final budgets = await repo.watchBudgets().first;
      final budget = budgets.single;
      expect(budget.id.value, 'b1');
      expect(budget.category, Category.groceries);
      expect(budget.limit, const Money.minor(30000, 'EUR'));
    });

    test('second upsert for the same category replaces the limit', () async {
      await repo.upsertBudget(_budget());
      await repo.upsertBudget(_budget(id: 'b2', limitMinor: 45000));

      final budgets = await repo.watchBudgets().first;
      expect(budgets, hasLength(1));
      expect(budgets.single.limit.minorUnits, 45000);
    });

    test('delete removes the budget', () async {
      await repo.upsertBudget(_budget());

      final result = await repo.deleteBudget(const BudgetId('b1'));

      expect(result.isOk, isTrue);
      expect(await repo.watchBudgets().first, isEmpty);
    });
  });
}
