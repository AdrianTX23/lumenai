import 'package:core_domain/core_domain.dart';
import 'package:core_ui/core_ui.dart';
import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:lumen_app/common/money_locale.dart';

/// One recurring charge in the Insights list: merchant, cadence, latest
/// amount, and a trend badge when the price moved.
class SubscriptionRow extends StatelessWidget {
  /// Creates a row for [insight].
  const SubscriptionRow({required this.insight, super.key});

  /// The recurring-charge insight to render.
  final SubscriptionInsight insight;

  @override
  Widget build(BuildContext context) {
    final lds = context.lds;
    final locale = Localizations.localeOf(context).toLanguageTag();

    return Padding(
      padding: const EdgeInsets.symmetric(vertical: LdsSpacing.xs),
      child: Row(
        children: [
          LdsAvatar(label: insight.merchantName),
          const SizedBox(width: LdsSpacing.sm),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  insight.merchantName,
                  style: lds.typography.body.copyWith(
                    fontWeight: FontWeight.w500,
                  ),
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                Text(
                  '${insight.occurrences}× · '
                  '${DateFormat.MMMd(locale).format(insight.lastChargedAt)}',
                  style: lds.typography.caption,
                ),
              ],
            ),
          ),
          const SizedBox(width: LdsSpacing.sm),
          Column(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              AmountText(
                -insight.latestAmount.minorUnits,
                currencyCode: insight.latestAmount.currencyCode,
                locale: appMoneyLocale,
              ),
              if (insight.hasNotableChange) ...[
                const SizedBox(height: 2),
                TrendBadge(percent: insight.percentChange, upIsGood: false),
              ],
            ],
          ),
        ],
      ),
    );
  }
}
