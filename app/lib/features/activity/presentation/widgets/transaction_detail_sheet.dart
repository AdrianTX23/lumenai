import 'package:core_domain/core_domain.dart';
import 'package:core_l10n/core_l10n.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:intl/intl.dart';
import 'package:lumen_app/common/category_ui.dart';
import 'package:lumen_app/features/activity/presentation/controllers/activity_controller.dart';

/// Opens the transaction detail sheet with the recategorize flow.
Future<void> showTransactionDetailSheet(
  BuildContext context,
  Transaction transaction,
) {
  return showLdsSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _DetailContent(transaction: transaction),
  );
}

class _DetailContent extends ConsumerWidget {
  const _DetailContent({required this.transaction});

  final Transaction transaction;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lds = context.lds;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Padding(
      padding: const EdgeInsets.fromLTRB(
        LdsSpacing.xl,
        LdsSpacing.xs,
        LdsSpacing.xl,
        LdsSpacing.xl,
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              LdsAvatar(
                label: transaction.merchantName,
                icon: transaction.category.icon,
                size: 48,
              ),
              const SizedBox(width: LdsSpacing.sm),
              Expanded(
                child: Text(
                  transaction.merchantName,
                  style: lds.typography.title,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
          const SizedBox(height: LdsSpacing.md),
          AmountText(
            transaction.amount.minorUnits,
            currencyCode: transaction.amount.currencyCode,
            emphasis: AmountEmphasis.hero,
          ),
          const SizedBox(height: LdsSpacing.lg),
          _DetailRow(
            label: l10n.detailCategory,
            child: CategoryChip(
              label: transaction.category.label(l10n),
              paletteIndex: transaction.category.paletteIndex,
              icon: transaction.category.icon,
            ),
          ),
          _DetailRow(
            label: l10n.detailDate,
            child: Text(
              DateFormat.yMMMMd(locale).add_Hm().format(transaction.timestamp),
              style: lds.typography.body,
            ),
          ),
          if (transaction.note != null)
            _DetailRow(
              label: l10n.detailNote,
              child: Text(transaction.note!, style: lds.typography.body),
            ),
          const SizedBox(height: LdsSpacing.lg),
          Text(l10n.detailRecategorize, style: lds.typography.label),
          const SizedBox(height: LdsSpacing.xs),
          Wrap(
            spacing: LdsSpacing.xs,
            runSpacing: LdsSpacing.xs,
            children: [
              for (final category in Category.values)
                if (category.isSpending)
                  GestureDetector(
                    onTap: () => _recategorize(context, ref, category),
                    child: CategoryChip(
                      label: category.label(l10n),
                      paletteIndex: category.paletteIndex,
                      icon: category.icon,
                    ),
                  ),
            ],
          ),
        ],
      ),
    );
  }

  Future<void> _recategorize(
    BuildContext context,
    WidgetRef ref,
    Category category,
  ) async {
    final l10n = context.l10n;
    final messenger = Navigator.of(context);
    final result =
        await ref.read(recategorizeProvider)(transaction.id, category);

    if (!context.mounted) return;
    result.fold(
      onOk: (_) {
        LdsSnack.show(
          context,
          l10n.snackRecategorized,
          variant: LdsSnackVariant.success,
        );
        messenger.pop();
      },
      onErr: (_) => LdsSnack.show(
        context,
        l10n.snackRecategorizeFailed,
        variant: LdsSnackVariant.error,
      ),
    );
  }
}

class _DetailRow extends StatelessWidget {
  const _DetailRow({required this.label, required this.child});

  final String label;
  final Widget child;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    return Padding(
      padding: const EdgeInsets.only(bottom: LdsSpacing.sm),
      child: Row(
        children: [
          SizedBox(
            width: 96,
            child: Text(label, style: lds.typography.caption),
          ),
          Expanded(child: child),
        ],
      ),
    );
  }
}
