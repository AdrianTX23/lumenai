import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'LUMEN AI';

  @override
  String get tabHome => 'Home';

  @override
  String get tabActivity => 'Activity';

  @override
  String get tabInsights => 'Insights';

  @override
  String get tabCopilot => 'Copilot';

  @override
  String get homeNetWorth => 'Net worth';

  @override
  String get homeAccounts => 'Accounts';

  @override
  String get homeRecentActivity => 'Recent activity';

  @override
  String get homeSeeAll => 'See all';

  @override
  String get activityTitle => 'Activity';

  @override
  String get activitySearchHint => 'Search merchants or notes';

  @override
  String get activityFilterAll => 'All';

  @override
  String get activityEmptyTitle => 'No transactions found';

  @override
  String get activityEmptyMessage => 'Try a different search or filter.';

  @override
  String get detailCategory => 'Category';

  @override
  String get detailAccount => 'Account';

  @override
  String get detailDate => 'Date';

  @override
  String get detailNote => 'Note';

  @override
  String get detailRecategorize => 'Change category';

  @override
  String get snackRecategorized => 'Category updated';

  @override
  String get snackRecategorizeFailed => 'Couldn\'t update the category';

  @override
  String get errorTitle => 'Something went wrong';

  @override
  String get errorMessage => 'We couldn\'t load your data.';

  @override
  String get errorRetry => 'Try again';

  @override
  String get comingSoonTitle => 'Coming soon';

  @override
  String get comingSoonCopilot => 'Your financial copilot is on its way.';

  @override
  String get insightsTitle => 'Insights';

  @override
  String get insightsThisMonth => 'This month';

  @override
  String get insightsSpendingByCategory => 'Spending by category';

  @override
  String get insightsEmptyBreakdown => 'No spending yet this month';

  @override
  String get insightsCashflowTitle => 'Income vs. spend';

  @override
  String get insightsIncome => 'Income';

  @override
  String get insightsSpend => 'Spend';

  @override
  String get insightsSubscriptionsTitle => 'Recurring charges';

  @override
  String get insightsSubscriptionsEmpty => 'No recurring charges detected yet';

  @override
  String get insightsForecastTitle => 'Next month';

  @override
  String get insightsForecastCaption =>
      'Projected spend, based on your recent months';

  @override
  String get insightsPriceUp => 'Price up';

  @override
  String get budgetsTitle => 'Budgets';

  @override
  String get budgetsEmptyTitle => 'No budgets yet';

  @override
  String get budgetsEmptyMessage =>
      'Set a monthly limit for a category to track your pace.';

  @override
  String get budgetsAdd => 'Add budget';

  @override
  String get budgetsNewTitle => 'New budget';

  @override
  String get budgetsCategory => 'Category';

  @override
  String get budgetsLimit => 'Monthly limit';

  @override
  String get budgetsLimitHint => '0';

  @override
  String get budgetsSave => 'Save budget';

  @override
  String get budgetsDelete => 'Delete';

  @override
  String get budgetsOverBudget => 'Over budget';

  @override
  String get budgetsNearLimit => 'Near limit';

  @override
  String get budgetsCreated => 'Budget saved';

  @override
  String get budgetsCreateFailed => 'Couldn\'t save the budget';

  @override
  String get budgetsDeleted => 'Budget deleted';

  @override
  String get budgetsInvalidLimit => 'Enter an amount greater than zero';

  @override
  String get budgetsSelectCategory => 'Choose a category';

  @override
  String get copilotInputHint => 'Ask about your money';

  @override
  String get copilotSendLabel => 'Send';

  @override
  String get copilotWelcomeTitle => 'Ask Lumen';

  @override
  String get copilotWelcomeMessage =>
      'I can help you understand your spending — try one of these.';

  @override
  String get copilotSuggestionDining => 'How much on dining this month?';

  @override
  String get copilotSuggestionSubscriptions =>
      'Any subscriptions I should know about?';

  @override
  String get copilotSuggestionForecast => 'What\'s my forecast for next month?';

  @override
  String get copilotSourceSingular => 'source';

  @override
  String get copilotSourcePlural => 'sources';

  @override
  String get copilotEvidenceSheetTitle => 'Cited transactions';

  @override
  String get categoryGroceries => 'Groceries';

  @override
  String get categoryDining => 'Dining';

  @override
  String get categoryTransport => 'Transport';

  @override
  String get categorySubscriptions => 'Subscriptions';

  @override
  String get categoryHousing => 'Housing';

  @override
  String get categoryUtilities => 'Utilities';

  @override
  String get categoryHealth => 'Health';

  @override
  String get categoryShopping => 'Shopping';

  @override
  String get categoryTravel => 'Travel';

  @override
  String get categoryEntertainment => 'Entertainment';

  @override
  String get categoryIncome => 'Income';

  @override
  String get categoryTransfers => 'Transfers';

  @override
  String get categoryFees => 'Fees';

  @override
  String get categoryOther => 'Other';
}
