import 'package:core_domain/core_domain.dart';
import 'package:core_l10n/core_l10n.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen_app/common/category_ui.dart';
import 'package:lumen_app/common/money_locale.dart';
import 'package:lumen_app/di/di.dart';

/// Opens the create-budget sheet.
Future<void> showCreateBudgetSheet(BuildContext context) {
  return showLdsSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _CreateBudgetContent(),
  );
}

class _CreateBudgetContent extends ConsumerStatefulWidget {
  const _CreateBudgetContent();

  @override
  ConsumerState<_CreateBudgetContent> createState() =>
      _CreateBudgetContentState();
}

class _CreateBudgetContentState extends ConsumerState<_CreateBudgetContent> {
  Category? _category;
  final _limitController = TextEditingController();

  @override
  void dispose() {
    _limitController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lds = context.lds;

    return Padding(
      padding: EdgeInsets.fromLTRB(
        LdsSpacing.xl,
        LdsSpacing.xs,
        LdsSpacing.xl,
        LdsSpacing.xl + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(l10n.budgetsNewTitle, style: lds.typography.title),
          const SizedBox(height: LdsSpacing.lg),
          Text(l10n.budgetsCategory, style: lds.typography.label),
          const SizedBox(height: LdsSpacing.xs),
          Wrap(
            spacing: LdsSpacing.xs,
            runSpacing: LdsSpacing.xs,
            children: [
              for (final category in Category.values)
                if (category.isSpending)
                  GestureDetector(
                    onTap: () => setState(() => _category = category),
                    child: Container(
                      padding: const EdgeInsets.all(2),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(LdsRadius.full),
                        border: Border.all(
                          color: _category == category
                              ? lds.colors.accent
                              : Colors.transparent,
                        ),
                      ),
                      child: CategoryChip(
                        label: category.label(l10n),
                        paletteIndex: category.paletteIndex,
                        icon: category.icon,
                      ),
                    ),
                  ),
            ],
          ),
          const SizedBox(height: LdsSpacing.lg),
          Text(l10n.budgetsLimit, style: lds.typography.label),
          const SizedBox(height: LdsSpacing.xs),
          TextField(
            controller: _limitController,
            keyboardType: TextInputType.number,
            inputFormatters: [FilteringTextInputFormatter.digitsOnly],
            style: lds.typography.moneyXl,
            decoration: InputDecoration(
              hintText: l10n.budgetsLimitHint,
              hintStyle: lds.typography.moneyXl.copyWith(
                color: lds.colors.textFaint,
              ),
              border: InputBorder.none,
            ),
          ),
          const SizedBox(height: LdsSpacing.xl),
          LdsButton(
            label: l10n.budgetsSave,
            expand: true,
            onPressed: () => _submit(context),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final l10n = context.l10n;
    final category = _category;
    if (category == null) {
      LdsSnack.show(
        context,
        l10n.budgetsSelectCategory,
        variant: LdsSnackVariant.error,
      );
      return;
    }
    final amount = int.tryParse(_limitController.text.trim());
    if (amount == null || amount <= 0) {
      LdsSnack.show(
        context,
        l10n.budgetsInvalidLimit,
        variant: LdsSnackVariant.error,
      );
      return;
    }

    final budget = Budget(
      id: BudgetId('budget-${category.name}'),
      category: category,
      limit: Money.minor(amount, appCurrencyCode),
      anchorDay: 1,
      createdAt: DateTime.now(),
    );
    final result = await ref.read(createBudgetProvider)(budget);

    if (!context.mounted) return;
    result.fold(
      onOk: (_) {
        LdsSnack.show(
          context,
          l10n.budgetsCreated,
          variant: LdsSnackVariant.success,
        );
        Navigator.of(context).pop();
      },
      onErr: (_) => LdsSnack.show(
        context,
        l10n.budgetsCreateFailed,
        variant: LdsSnackVariant.error,
      ),
    );
  }
}
