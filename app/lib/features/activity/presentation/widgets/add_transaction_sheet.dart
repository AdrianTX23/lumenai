import 'dart:async';

import 'package:core_domain/core_domain.dart';
import 'package:core_l10n/core_l10n.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lumen_app/common/accounts_provider.dart';
import 'package:lumen_app/common/category_ui.dart';
import 'package:lumen_app/common/money_locale.dart';
import 'package:lumen_app/di/di.dart';
import 'package:uuid/uuid.dart';

/// Opens the add-transaction sheet.
Future<void> showAddTransactionSheet(BuildContext context) {
  return showLdsSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _AddTransactionContent(),
  );
}

enum _Direction { spend, income }

class _AddTransactionContent extends ConsumerStatefulWidget {
  const _AddTransactionContent();

  @override
  ConsumerState<_AddTransactionContent> createState() =>
      _AddTransactionContentState();
}

class _AddTransactionContentState
    extends ConsumerState<_AddTransactionContent> {
  final _amountController = TextEditingController();
  final _merchantController = TextEditingController();
  final _noteController = TextEditingController();
  _Direction _direction = _Direction.spend;
  Category? _category;
  AccountId? _accountId;
  DateTime _date = DateTime.now();

  @override
  void dispose() {
    _amountController.dispose();
    _merchantController.dispose();
    _noteController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = context.l10n;
    final lds = context.lds;
    final accounts = ref.watch(accountsStreamProvider);
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Padding(
      padding: EdgeInsets.fromLTRB(
        LdsSpacing.xl,
        LdsSpacing.xs,
        LdsSpacing.xl,
        LdsSpacing.xl + MediaQuery.of(context).viewInsets.bottom,
      ),
      child: SingleChildScrollView(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(l10n.activityAddTitle, style: lds.typography.title),
            const SizedBox(height: LdsSpacing.lg),
            Row(
              children: [
                Expanded(
                  child: _DirectionChip(
                    label: l10n.activitySpend,
                    selected: _direction == _Direction.spend,
                    onTap: () => setState(() => _direction = _Direction.spend),
                  ),
                ),
                const SizedBox(width: LdsSpacing.xs),
                Expanded(
                  child: _DirectionChip(
                    label: l10n.activityIncome,
                    selected: _direction == _Direction.income,
                    onTap: () => setState(() => _direction = _Direction.income),
                  ),
                ),
              ],
            ),
            const SizedBox(height: LdsSpacing.lg),
            Text(l10n.activityAmountLabel, style: lds.typography.label),
            const SizedBox(height: LdsSpacing.xs),
            TextField(
              controller: _amountController,
              keyboardType: TextInputType.number,
              inputFormatters: [FilteringTextInputFormatter.digitsOnly],
              style: lds.typography.moneyXl,
              decoration: InputDecoration(
                hintText: '0',
                hintStyle: lds.typography.moneyXl.copyWith(
                  color: lds.colors.textFaint,
                ),
                border: InputBorder.none,
              ),
            ),
            const SizedBox(height: LdsSpacing.lg),
            Text(l10n.activityMerchantLabel, style: lds.typography.label),
            const SizedBox(height: LdsSpacing.xs),
            TextField(
              controller: _merchantController,
              style: lds.typography.body,
              decoration: InputDecoration(
                hintText: l10n.activityMerchantHint,
                hintStyle: lds.typography.bodyMuted,
                border: InputBorder.none,
                filled: true,
                fillColor: lds.colors.surfaceElevated,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: LdsSpacing.md,
                  vertical: LdsSpacing.sm,
                ),
              ),
            ),
            if (_direction == _Direction.spend) ...[
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
                        onTap: () {
                          unawaited(LdsHaptics.tap());
                          setState(() => _category = category);
                        },
                        child: Container(
                          padding: const EdgeInsets.all(2),
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              LdsRadius.full,
                            ),
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
            ],
            const SizedBox(height: LdsSpacing.lg),
            Text(l10n.activityAccountLabel, style: lds.typography.label),
            const SizedBox(height: LdsSpacing.xs),
            switch (accounts) {
              AsyncData(:final value) when value.isEmpty => Text(
                  l10n.activityNoAccountsYet,
                  style: lds.typography.caption,
                ),
              AsyncData(:final value) => Wrap(
                  spacing: LdsSpacing.xs,
                  runSpacing: LdsSpacing.xs,
                  children: [
                    for (final snapshot in value)
                      GestureDetector(
                        onTap: () {
                          unawaited(LdsHaptics.tap());
                          setState(() => _accountId = snapshot.account.id);
                        },
                        child: Container(
                          padding: const EdgeInsets.symmetric(
                            horizontal: LdsSpacing.sm,
                            vertical: LdsSpacing.xs,
                          ),
                          decoration: BoxDecoration(
                            color: _accountId == snapshot.account.id
                                ? lds.colors.accent
                                : lds.colors.surfaceElevated,
                            borderRadius: BorderRadius.circular(
                              LdsRadius.full,
                            ),
                          ),
                          child: Text(
                            snapshot.account.name,
                            style: lds.typography.label.copyWith(
                              color: _accountId == snapshot.account.id
                                  ? lds.colors.onAccent
                                  : lds.colors.textPrimary,
                            ),
                          ),
                        ),
                      ),
                  ],
                ),
              _ => const LdsSkeleton(height: 32, width: 120),
            },
            const SizedBox(height: LdsSpacing.lg),
            Text(l10n.activityDateLabel, style: lds.typography.label),
            const SizedBox(height: LdsSpacing.xs),
            GestureDetector(
              onTap: () => unawaited(_pickDate(context, locale)),
              child: Container(
                padding: const EdgeInsets.symmetric(
                  horizontal: LdsSpacing.md,
                  vertical: LdsSpacing.sm,
                ),
                decoration: BoxDecoration(
                  color: lds.colors.surfaceElevated,
                  borderRadius: BorderRadius.circular(LdsRadius.lg),
                ),
                child: Row(
                  children: [
                    Icon(
                      Icons.calendar_today_rounded,
                      size: 16,
                      color: lds.colors.textMuted,
                    ),
                    const SizedBox(width: LdsSpacing.xs),
                    Text(
                      DateFormat.yMMMd(locale).format(_date),
                      style: lds.typography.body,
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: LdsSpacing.lg),
            Text(l10n.activityNoteLabel, style: lds.typography.label),
            const SizedBox(height: LdsSpacing.xs),
            TextField(
              controller: _noteController,
              style: lds.typography.body,
              decoration: InputDecoration(
                border: InputBorder.none,
                filled: true,
                fillColor: lds.colors.surfaceElevated,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: LdsSpacing.md,
                  vertical: LdsSpacing.sm,
                ),
              ),
            ),
            const SizedBox(height: LdsSpacing.xl),
            LdsButton(
              label: l10n.activitySave,
              expand: true,
              onPressed: () => _submit(context),
            ),
          ],
        ),
      ),
    );
  }

  Future<void> _pickDate(BuildContext context, String locale) async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _date,
      firstDate: DateTime(2000),
      lastDate: DateTime.now(),
    );
    if (picked != null) setState(() => _date = picked);
  }

  Future<void> _submit(BuildContext context) async {
    final l10n = context.l10n;
    final merchant = _merchantController.text.trim();
    if (merchant.isEmpty) {
      LdsSnack.show(
        context,
        l10n.activityMerchantLabel,
        variant: LdsSnackVariant.error,
      );
      return;
    }
    final amount = int.tryParse(_amountController.text.trim()) ?? 0;
    if (amount <= 0) {
      LdsSnack.show(
        context,
        l10n.activityInvalidAmount,
        variant: LdsSnackVariant.error,
      );
      return;
    }
    final accountId = _accountId;
    if (accountId == null) {
      LdsSnack.show(
        context,
        l10n.activitySelectAccount,
        variant: LdsSnackVariant.error,
      );
      return;
    }
    if (_direction == _Direction.spend && _category == null) {
      LdsSnack.show(
        context,
        l10n.budgetsSelectCategory,
        variant: LdsSnackVariant.error,
      );
      return;
    }

    final signedMinor = _direction == _Direction.spend ? -amount : amount;
    final transaction = Transaction(
      id: TransactionId(const Uuid().v4()),
      accountId: accountId,
      amount: Money.minor(signedMinor, appCurrencyCode),
      merchantName: merchant,
      merchantRaw: merchant,
      category: _direction == _Direction.spend ? _category! : Category.income,
      timestamp: _date,
      status: TransactionStatus.settled,
      categorySource: CategorySource.user,
      note: _noteController.text.trim().isEmpty
          ? null
          : _noteController.text.trim(),
    );
    final result = await ref.read(createTransactionProvider)(transaction);

    if (!context.mounted) return;
    result.fold(
      onOk: (_) {
        LdsSnack.show(
          context,
          l10n.activityCreated,
          variant: LdsSnackVariant.success,
        );
        Navigator.of(context).pop();
      },
      onErr: (_) => LdsSnack.show(
        context,
        l10n.activityCreateFailed,
        variant: LdsSnackVariant.error,
      ),
    );
  }
}

class _DirectionChip extends StatelessWidget {
  const _DirectionChip({
    required this.label,
    required this.selected,
    required this.onTap,
  });

  final String label;
  final bool selected;
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    return GestureDetector(
      onTap: () {
        unawaited(LdsHaptics.tap());
        onTap();
      },
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: LdsSpacing.sm),
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: selected ? lds.colors.accent : lds.colors.surfaceElevated,
          borderRadius: BorderRadius.circular(LdsRadius.md),
        ),
        child: Text(
          label,
          style: lds.typography.label.copyWith(
            color: selected ? lds.colors.onAccent : lds.colors.textPrimary,
          ),
        ),
      ),
    );
  }
}
