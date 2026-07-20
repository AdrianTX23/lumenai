import 'package:core_domain/src/value_objects/category.dart';
import 'package:core_domain/src/value_objects/money.dart';

/// A merchant charge that recurs on a roughly monthly cadence, detected
/// from transaction history.
///
/// Deliberately not limited to `Category.subscriptions`: a gym
/// membership (health) or a bank management fee (fees) is just as much
/// a recurring charge as a streaming service, and surfacing the ones the
/// user forgot about is the point.
final class SubscriptionInsight {
  /// Creates a recurring-charge insight.
  const SubscriptionInsight({
    required this.merchantName,
    required this.category,
    required this.occurrences,
    required this.firstAmount,
    required this.latestAmount,
    required this.lastChargedAt,
    required this.percentChange,
  });

  /// Normalized merchant name.
  final String merchantName;

  /// Category of the most recent charge.
  final Category category;

  /// Number of charges the detector used to establish the pattern.
  final int occurrences;

  /// Magnitude of the earliest charge on record.
  final Money firstAmount;

  /// Magnitude of the most recent charge.
  final Money latestAmount;

  /// When the merchant last charged.
  final DateTime lastChargedAt;

  /// Signed percent change from [firstAmount] to [latestAmount]
  /// (positive = the charge grew). Zero when the amount never moved.
  final double percentChange;

  /// Whether the change is large enough to be worth flagging to the
  /// user — small drift (rounding, FX) stays quiet.
  bool get hasNotableChange => percentChange.abs() >= 3;
}
