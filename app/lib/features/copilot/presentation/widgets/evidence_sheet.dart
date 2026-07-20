import 'package:core_domain/core_domain.dart' hide Transaction;
import 'package:core_domain/core_domain.dart' as domain show Transaction;
import 'package:core_l10n/core_l10n.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:lumen_app/common/category_ui.dart';
import 'package:lumen_app/common/money_locale.dart';
import 'package:lumen_app/di/di.dart';
import 'package:lumen_app/features/activity/presentation/widgets/transaction_detail_sheet.dart';

/// Opens the sheet listing exactly the transactions an answer cited —
/// tapping a citation in a [ChatBubble] leads here, and each row opens
/// the real transaction detail. This is the "tapping evidence highlights
/// the exact transactions" behavior from the roadmap's Phase 5 exit
/// criteria.
Future<void> showEvidenceSheet(
  BuildContext context,
  List<TransactionId> transactionIds,
) {
  return showLdsSheet<void>(
    context: context,
    isScrollControlled: true,
    builder: (context) => _EvidenceSheetContent(transactionIds: transactionIds),
  );
}

class _EvidenceSheetContent extends ConsumerWidget {
  const _EvidenceSheetContent({required this.transactionIds});

  final List<TransactionId> transactionIds;

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final l10n = context.l10n;
    final lds = context.lds;
    final observeTransactions = ref.read(observeTransactionsProvider);

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
          Text(l10n.copilotEvidenceSheetTitle, style: lds.typography.title),
          const SizedBox(height: LdsSpacing.md),
          StreamBuilder<List<domain.Transaction>>(
            stream: observeTransactions(TransactionFilter(ids: transactionIds)),
            builder: (context, snapshot) {
              final results = snapshot.data ?? const [];
              if (!snapshot.hasData) {
                return const Padding(
                  padding: EdgeInsets.symmetric(vertical: LdsSpacing.xl),
                  child: Center(child: CircularProgressIndicator()),
                );
              }
              return Column(
                children: [
                  for (final tx in results)
                    TransactionTile(
                      merchantName: tx.merchantName,
                      categoryLabel: tx.category.label(l10n),
                      categoryPaletteIndex: tx.category.paletteIndex,
                      amountMinorUnits: tx.amount.minorUnits,
                      currencyCode: tx.amount.currencyCode,
                      locale: appMoneyLocale,
                      onTap: () {
                        Navigator.of(context).pop();
                        showTransactionDetailSheet(context, tx);
                      },
                    ),
                ],
              );
            },
          ),
        ],
      ),
    );
  }
}
