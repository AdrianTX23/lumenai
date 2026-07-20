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
  String get homeSettings => 'Settings';

  @override
  String get homeNoAccountsTitle => 'No accounts yet';

  @override
  String get homeNoAccountsMessage =>
      'Add an account to start tracking your money.';

  @override
  String get homeAddAccount => 'Add account';

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
  String get activityAdd => 'Add transaction';

  @override
  String get activityAddTitle => 'New transaction';

  @override
  String get activityAmountLabel => 'Amount';

  @override
  String get activityMerchantLabel => 'Merchant or description';

  @override
  String get activityMerchantHint => 'e.g. Whole Foods, Uber, Payroll';

  @override
  String get activityAccountLabel => 'Account';

  @override
  String get activityDateLabel => 'Date';

  @override
  String get activityNoteLabel => 'Note (optional)';

  @override
  String get activitySpend => 'Spend';

  @override
  String get activityIncome => 'Income';

  @override
  String get activitySave => 'Save transaction';

  @override
  String get activityCreated => 'Transaction saved';

  @override
  String get activityCreateFailed => 'Couldn\'t save the transaction';

  @override
  String get activityInvalidAmount => 'Enter an amount greater than zero';

  @override
  String get activitySelectAccount => 'Choose an account';

  @override
  String get activityNoAccountsYet => 'Add an account first';

  @override
  String get activityDelete => 'Delete transaction';

  @override
  String get activityDeleted => 'Transaction deleted';

  @override
  String get activityDeleteFailed => 'Couldn\'t delete the transaction';

  @override
  String get activityDeleteConfirmTitle => 'Delete this transaction?';

  @override
  String get activityDeleteConfirmBody => 'This can\'t be undone.';

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

  @override
  String get onboardingSkip => 'Skip';

  @override
  String get onboardingNext => 'Next';

  @override
  String get onboardingGetStarted => 'Get started';

  @override
  String get onboardingPage1Title => 'All your money, one clear view';

  @override
  String get onboardingPage1Body =>
      'Accounts, cards and spending together — no more switching between apps.';

  @override
  String get onboardingPage2Title => 'Insights that actually help';

  @override
  String get onboardingPage2Body =>
      'Spending trends, recurring charges and a forecast for next month, surfaced automatically.';

  @override
  String get onboardingPage3Title => 'Ask Lumen anything';

  @override
  String get onboardingPage3Body =>
      'A conversational copilot grounded in your real transactions — every answer is traceable.';

  @override
  String get onboardingSecurityTitle => 'Protect your app';

  @override
  String get onboardingSecurityBody =>
      'Turn on biometric lock to keep your finances private, even if someone else picks up your phone.';

  @override
  String get onboardingEnableBiometrics => 'Enable Face ID / fingerprint lock';

  @override
  String get onboardingBiometricReason =>
      'Confirm it\'s you to protect LUMEN AI';

  @override
  String get onboardingBiometricUnavailable =>
      'Biometrics aren\'t available on this device';

  @override
  String get lockTitle => 'LUMEN AI is locked';

  @override
  String get lockSubtitle => 'Use Face ID or your fingerprint to continue';

  @override
  String get lockUnlockButton => 'Unlock';

  @override
  String get lockReason => 'Confirm it\'s you to open LUMEN AI';

  @override
  String get lockFailed => 'Couldn\'t verify it\'s you — try again';

  @override
  String get settingsTitle => 'Settings';

  @override
  String get settingsAppearance => 'Appearance';

  @override
  String get settingsAppearanceCaption =>
      'Follows your system\'s light/dark setting';

  @override
  String get settingsThemeSystem => 'System';

  @override
  String get settingsThemeLight => 'Light';

  @override
  String get settingsThemeDark => 'Dark';

  @override
  String get settingsSecurity => 'Security';

  @override
  String get settingsBiometricLock => 'Biometric lock';

  @override
  String get settingsBiometricUnavailable =>
      'This device doesn\'t have biometrics available';

  @override
  String get settingsData => 'Data';

  @override
  String get settingsResetData => 'Reset demo data';

  @override
  String get settingsResetConfirmTitle => 'Reset all data?';

  @override
  String get settingsResetConfirmBody =>
      'This wipes and regenerates the demo dataset. This can\'t be undone.';

  @override
  String get settingsResetConfirmAction => 'Reset';

  @override
  String get settingsCancel => 'Cancel';

  @override
  String get settingsResetSuccess => 'Data reset';

  @override
  String get settingsResetFailed => 'Couldn\'t reset the data';

  @override
  String get settingsAccounts => 'Accounts';

  @override
  String get accountTypeChecking => 'Checking';

  @override
  String get accountTypeSavings => 'Savings';

  @override
  String get accountTypeCredit => 'Credit card';

  @override
  String get accountTypeCash => 'Cash';

  @override
  String get accountsAddTitle => 'New account';

  @override
  String get accountsNameLabel => 'Name';

  @override
  String get accountsNameHint => 'e.g. Chase Checking';

  @override
  String get accountsTypeLabel => 'Type';

  @override
  String get accountsOpeningBalanceLabel => 'Opening balance';

  @override
  String get accountsSave => 'Save account';

  @override
  String get accountsCreated => 'Account created';

  @override
  String get accountsCreateFailed => 'Couldn\'t create the account';

  @override
  String get accountsInvalidName => 'Enter a name';

  @override
  String get accountsSelectType => 'Choose an account type';
}
