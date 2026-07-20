import 'dart:async';

import 'package:core_domain/core_domain.dart';
import 'package:core_l10n/core_l10n.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen_app/common/account_ui.dart';
import 'package:lumen_app/common/money_locale.dart';
import 'package:lumen_app/di/di.dart';
import 'package:uuid/uuid.dart';

/// Opens the add-account sheet. Reachable from both Home (empty state)
/// and Settings — lives in `common/` because features may not import
/// each other's internals (tools/check_boundaries.sh).
Future<void> showAddAccountSheet(BuildContext context) {
  return showLdsSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => const _AddAccountContent(),
  );
}

class _AddAccountContent extends ConsumerStatefulWidget {
  const _AddAccountContent();

  @override
  ConsumerState<_AddAccountContent> createState() => _AddAccountContentState();
}

class _AddAccountContentState extends ConsumerState<_AddAccountContent> {
  final _nameController = TextEditingController();
  final _balanceController = TextEditingController();
  AccountType? _type;

  @override
  void dispose() {
    _nameController.dispose();
    _balanceController.dispose();
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
          Text(l10n.accountsAddTitle, style: lds.typography.title),
          const SizedBox(height: LdsSpacing.lg),
          Text(l10n.accountsNameLabel, style: lds.typography.label),
          const SizedBox(height: LdsSpacing.xs),
          TextField(
            controller: _nameController,
            style: lds.typography.body,
            decoration: InputDecoration(
              hintText: l10n.accountsNameHint,
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
          const SizedBox(height: LdsSpacing.lg),
          Text(l10n.accountsTypeLabel, style: lds.typography.label),
          const SizedBox(height: LdsSpacing.xs),
          Wrap(
            spacing: LdsSpacing.xs,
            runSpacing: LdsSpacing.xs,
            children: [
              for (final type in AccountType.values)
                GestureDetector(
                  onTap: () {
                    unawaited(LdsHaptics.tap());
                    setState(() => _type = type);
                  },
                  child: Container(
                    padding: const EdgeInsets.symmetric(
                      horizontal: LdsSpacing.sm,
                      vertical: LdsSpacing.xs,
                    ),
                    decoration: BoxDecoration(
                      color: _type == type
                          ? lds.colors.accent
                          : lds.colors.surfaceElevated,
                      borderRadius: BorderRadius.circular(LdsRadius.full),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(
                          type.icon,
                          size: 16,
                          color: _type == type
                              ? lds.colors.onAccent
                              : lds.colors.textMuted,
                        ),
                        const SizedBox(width: LdsSpacing.xxs),
                        Text(
                          type.label(l10n),
                          style: lds.typography.label.copyWith(
                            color: _type == type
                                ? lds.colors.onAccent
                                : lds.colors.textPrimary,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
            ],
          ),
          const SizedBox(height: LdsSpacing.lg),
          Text(l10n.accountsOpeningBalanceLabel, style: lds.typography.label),
          const SizedBox(height: LdsSpacing.xs),
          TextField(
            controller: _balanceController,
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
          const SizedBox(height: LdsSpacing.xl),
          LdsButton(
            label: l10n.accountsSave,
            expand: true,
            onPressed: () => _submit(context),
          ),
        ],
      ),
    );
  }

  Future<void> _submit(BuildContext context) async {
    final l10n = context.l10n;
    final name = _nameController.text.trim();
    if (name.isEmpty) {
      LdsSnack.show(
        context,
        l10n.accountsInvalidName,
        variant: LdsSnackVariant.error,
      );
      return;
    }
    final type = _type;
    if (type == null) {
      LdsSnack.show(
        context,
        l10n.accountsSelectType,
        variant: LdsSnackVariant.error,
      );
      return;
    }
    final balance = int.tryParse(_balanceController.text.trim()) ?? 0;

    final account = Account(
      id: AccountId(const Uuid().v4()),
      name: name,
      type: type,
      currencyCode: appCurrencyCode,
      openingBalance: Money.minor(balance, appCurrencyCode),
    );
    final result = await ref.read(createAccountProvider)(account);

    if (!context.mounted) return;
    result.fold(
      onOk: (_) {
        LdsSnack.show(
          context,
          l10n.accountsCreated,
          variant: LdsSnackVariant.success,
        );
        Navigator.of(context).pop();
      },
      onErr: (_) => LdsSnack.show(
        context,
        l10n.accountsCreateFailed,
        variant: LdsSnackVariant.error,
      ),
    );
  }
}
