import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_en.dart';
import 'app_localizations_es.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'generated/app_localizations.dart';
///
/// return MaterialApp(
///   localizationsDelegates: AppLocalizations.localizationsDelegates,
///   supportedLocales: AppLocalizations.supportedLocales,
///   home: MyApplicationHome(),
/// );
/// ```
///
/// ## Update pubspec.yaml
///
/// Please make sure to update your pubspec.yaml to include the following
/// packages:
///
/// ```yaml
/// dependencies:
///   # Internationalization support.
///   flutter_localizations:
///     sdk: flutter
///   intl: any # Use the pinned version from flutter_localizations
///
///   # Rest of dependencies
/// ```
///
/// ## iOS Applications
///
/// iOS applications define key application metadata, including supported
/// locales, in an Info.plist file that is built into the application bundle.
/// To configure the locales supported by your app, you’ll need to edit this
/// file.
///
/// First, open your project’s ios/Runner.xcworkspace Xcode workspace file.
/// Then, in the Project Navigator, open the Info.plist file under the Runner
/// project’s Runner folder.
///
/// Next, select the Information Property List item, select Add Item from the
/// Editor menu, then select Localizations from the pop-up menu.
///
/// Select and expand the newly-created Localizations item then, for each
/// locale your application supports, add a new item and select the locale
/// you wish to add from the pop-up menu in the Value field. This list should
/// be consistent with the languages listed in the AppLocalizations.supportedLocales
/// property.
abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations)!;
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  /// A list of this localizations delegate along with the default localizations
  /// delegates.
  ///
  /// Returns a list of localizations delegates containing this delegate along with
  /// GlobalMaterialLocalizations.delegate, GlobalCupertinoLocalizations.delegate,
  /// and GlobalWidgetsLocalizations.delegate.
  ///
  /// Additional delegates can be added by appending to this list in
  /// MaterialApp. This list does not have to be used at all if a custom list
  /// of delegates is preferred or required.
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('en'),
    Locale('es')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'LUMEN AI'**
  String get appTitle;

  /// No description provided for @tabHome.
  ///
  /// In en, this message translates to:
  /// **'Home'**
  String get tabHome;

  /// No description provided for @tabActivity.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get tabActivity;

  /// No description provided for @tabInsights.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get tabInsights;

  /// No description provided for @tabCopilot.
  ///
  /// In en, this message translates to:
  /// **'Copilot'**
  String get tabCopilot;

  /// No description provided for @homeNetWorth.
  ///
  /// In en, this message translates to:
  /// **'Net worth'**
  String get homeNetWorth;

  /// No description provided for @homeAccounts.
  ///
  /// In en, this message translates to:
  /// **'Accounts'**
  String get homeAccounts;

  /// No description provided for @homeRecentActivity.
  ///
  /// In en, this message translates to:
  /// **'Recent activity'**
  String get homeRecentActivity;

  /// No description provided for @homeSeeAll.
  ///
  /// In en, this message translates to:
  /// **'See all'**
  String get homeSeeAll;

  /// No description provided for @activityTitle.
  ///
  /// In en, this message translates to:
  /// **'Activity'**
  String get activityTitle;

  /// No description provided for @activitySearchHint.
  ///
  /// In en, this message translates to:
  /// **'Search merchants or notes'**
  String get activitySearchHint;

  /// No description provided for @activityFilterAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get activityFilterAll;

  /// No description provided for @activityEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No transactions found'**
  String get activityEmptyTitle;

  /// No description provided for @activityEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Try a different search or filter.'**
  String get activityEmptyMessage;

  /// No description provided for @detailCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get detailCategory;

  /// No description provided for @detailAccount.
  ///
  /// In en, this message translates to:
  /// **'Account'**
  String get detailAccount;

  /// No description provided for @detailDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get detailDate;

  /// No description provided for @detailNote.
  ///
  /// In en, this message translates to:
  /// **'Note'**
  String get detailNote;

  /// No description provided for @detailRecategorize.
  ///
  /// In en, this message translates to:
  /// **'Change category'**
  String get detailRecategorize;

  /// No description provided for @snackRecategorized.
  ///
  /// In en, this message translates to:
  /// **'Category updated'**
  String get snackRecategorized;

  /// No description provided for @snackRecategorizeFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t update the category'**
  String get snackRecategorizeFailed;

  /// No description provided for @errorTitle.
  ///
  /// In en, this message translates to:
  /// **'Something went wrong'**
  String get errorTitle;

  /// No description provided for @errorMessage.
  ///
  /// In en, this message translates to:
  /// **'We couldn\'t load your data.'**
  String get errorMessage;

  /// No description provided for @errorRetry.
  ///
  /// In en, this message translates to:
  /// **'Try again'**
  String get errorRetry;

  /// No description provided for @comingSoonTitle.
  ///
  /// In en, this message translates to:
  /// **'Coming soon'**
  String get comingSoonTitle;

  /// No description provided for @comingSoonCopilot.
  ///
  /// In en, this message translates to:
  /// **'Your financial copilot is on its way.'**
  String get comingSoonCopilot;

  /// No description provided for @insightsTitle.
  ///
  /// In en, this message translates to:
  /// **'Insights'**
  String get insightsTitle;

  /// No description provided for @insightsThisMonth.
  ///
  /// In en, this message translates to:
  /// **'This month'**
  String get insightsThisMonth;

  /// No description provided for @insightsSpendingByCategory.
  ///
  /// In en, this message translates to:
  /// **'Spending by category'**
  String get insightsSpendingByCategory;

  /// No description provided for @insightsEmptyBreakdown.
  ///
  /// In en, this message translates to:
  /// **'No spending yet this month'**
  String get insightsEmptyBreakdown;

  /// No description provided for @insightsCashflowTitle.
  ///
  /// In en, this message translates to:
  /// **'Income vs. spend'**
  String get insightsCashflowTitle;

  /// No description provided for @insightsIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get insightsIncome;

  /// No description provided for @insightsSpend.
  ///
  /// In en, this message translates to:
  /// **'Spend'**
  String get insightsSpend;

  /// No description provided for @insightsSubscriptionsTitle.
  ///
  /// In en, this message translates to:
  /// **'Recurring charges'**
  String get insightsSubscriptionsTitle;

  /// No description provided for @insightsSubscriptionsEmpty.
  ///
  /// In en, this message translates to:
  /// **'No recurring charges detected yet'**
  String get insightsSubscriptionsEmpty;

  /// No description provided for @insightsForecastTitle.
  ///
  /// In en, this message translates to:
  /// **'Next month'**
  String get insightsForecastTitle;

  /// No description provided for @insightsForecastCaption.
  ///
  /// In en, this message translates to:
  /// **'Projected spend, based on your recent months'**
  String get insightsForecastCaption;

  /// No description provided for @insightsPriceUp.
  ///
  /// In en, this message translates to:
  /// **'Price up'**
  String get insightsPriceUp;

  /// No description provided for @budgetsTitle.
  ///
  /// In en, this message translates to:
  /// **'Budgets'**
  String get budgetsTitle;

  /// No description provided for @budgetsEmptyTitle.
  ///
  /// In en, this message translates to:
  /// **'No budgets yet'**
  String get budgetsEmptyTitle;

  /// No description provided for @budgetsEmptyMessage.
  ///
  /// In en, this message translates to:
  /// **'Set a monthly limit for a category to track your pace.'**
  String get budgetsEmptyMessage;

  /// No description provided for @budgetsAdd.
  ///
  /// In en, this message translates to:
  /// **'Add budget'**
  String get budgetsAdd;

  /// No description provided for @budgetsNewTitle.
  ///
  /// In en, this message translates to:
  /// **'New budget'**
  String get budgetsNewTitle;

  /// No description provided for @budgetsCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get budgetsCategory;

  /// No description provided for @budgetsLimit.
  ///
  /// In en, this message translates to:
  /// **'Monthly limit'**
  String get budgetsLimit;

  /// No description provided for @budgetsLimitHint.
  ///
  /// In en, this message translates to:
  /// **'0'**
  String get budgetsLimitHint;

  /// No description provided for @budgetsSave.
  ///
  /// In en, this message translates to:
  /// **'Save budget'**
  String get budgetsSave;

  /// No description provided for @budgetsDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get budgetsDelete;

  /// No description provided for @budgetsOverBudget.
  ///
  /// In en, this message translates to:
  /// **'Over budget'**
  String get budgetsOverBudget;

  /// No description provided for @budgetsNearLimit.
  ///
  /// In en, this message translates to:
  /// **'Near limit'**
  String get budgetsNearLimit;

  /// No description provided for @budgetsCreated.
  ///
  /// In en, this message translates to:
  /// **'Budget saved'**
  String get budgetsCreated;

  /// No description provided for @budgetsCreateFailed.
  ///
  /// In en, this message translates to:
  /// **'Couldn\'t save the budget'**
  String get budgetsCreateFailed;

  /// No description provided for @budgetsDeleted.
  ///
  /// In en, this message translates to:
  /// **'Budget deleted'**
  String get budgetsDeleted;

  /// No description provided for @budgetsInvalidLimit.
  ///
  /// In en, this message translates to:
  /// **'Enter an amount greater than zero'**
  String get budgetsInvalidLimit;

  /// No description provided for @budgetsSelectCategory.
  ///
  /// In en, this message translates to:
  /// **'Choose a category'**
  String get budgetsSelectCategory;

  /// No description provided for @categoryGroceries.
  ///
  /// In en, this message translates to:
  /// **'Groceries'**
  String get categoryGroceries;

  /// No description provided for @categoryDining.
  ///
  /// In en, this message translates to:
  /// **'Dining'**
  String get categoryDining;

  /// No description provided for @categoryTransport.
  ///
  /// In en, this message translates to:
  /// **'Transport'**
  String get categoryTransport;

  /// No description provided for @categorySubscriptions.
  ///
  /// In en, this message translates to:
  /// **'Subscriptions'**
  String get categorySubscriptions;

  /// No description provided for @categoryHousing.
  ///
  /// In en, this message translates to:
  /// **'Housing'**
  String get categoryHousing;

  /// No description provided for @categoryUtilities.
  ///
  /// In en, this message translates to:
  /// **'Utilities'**
  String get categoryUtilities;

  /// No description provided for @categoryHealth.
  ///
  /// In en, this message translates to:
  /// **'Health'**
  String get categoryHealth;

  /// No description provided for @categoryShopping.
  ///
  /// In en, this message translates to:
  /// **'Shopping'**
  String get categoryShopping;

  /// No description provided for @categoryTravel.
  ///
  /// In en, this message translates to:
  /// **'Travel'**
  String get categoryTravel;

  /// No description provided for @categoryEntertainment.
  ///
  /// In en, this message translates to:
  /// **'Entertainment'**
  String get categoryEntertainment;

  /// No description provided for @categoryIncome.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get categoryIncome;

  /// No description provided for @categoryTransfers.
  ///
  /// In en, this message translates to:
  /// **'Transfers'**
  String get categoryTransfers;

  /// No description provided for @categoryFees.
  ///
  /// In en, this message translates to:
  /// **'Fees'**
  String get categoryFees;

  /// No description provided for @categoryOther.
  ///
  /// In en, this message translates to:
  /// **'Other'**
  String get categoryOther;
}

class _AppLocalizationsDelegate
    extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) =>
      <String>['en', 'es'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'en':
      return AppLocalizationsEn();
    case 'es':
      return AppLocalizationsEs();
  }

  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
      'an issue with the localizations generation tool. Please file an issue '
      'on GitHub with a reproducible sample app and the gen-l10n configuration '
      'that was used.');
}
