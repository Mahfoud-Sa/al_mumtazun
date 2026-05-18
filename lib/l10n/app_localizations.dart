import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_ar.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

/// Callers can lookup localized strings with an instance of AppLocalizations
/// returned by `AppLocalizations.of(context)`.
///
/// Applications need to include `AppLocalizations.delegate()` in their app's
/// `localizationDelegates` list, and the locales they support in the app's
/// `supportedLocales` list. For example:
///
/// ```dart
/// import 'l10n/app_localizations.dart';
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

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
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
    Locale('ar'),
    Locale('en'),
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Engineering Ops'**
  String get appTitle;

  /// No description provided for @appBarTitle.
  ///
  /// In en, this message translates to:
  /// **'ENGINEERING OPS'**
  String get appBarTitle;

  /// No description provided for @dashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboard;

  /// No description provided for @income.
  ///
  /// In en, this message translates to:
  /// **'Income'**
  String get income;

  /// No description provided for @inventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get inventory;

  /// No description provided for @engineering.
  ///
  /// In en, this message translates to:
  /// **'Engineering'**
  String get engineering;

  /// No description provided for @admin.
  ///
  /// In en, this message translates to:
  /// **'Admin'**
  String get admin;

  /// No description provided for @managementSystem.
  ///
  /// In en, this message translates to:
  /// **'Management System'**
  String get managementSystem;

  /// No description provided for @dashboardInsights.
  ///
  /// In en, this message translates to:
  /// **'Dashboard Insights'**
  String get dashboardInsights;

  /// No description provided for @dashboardOverview.
  ///
  /// In en, this message translates to:
  /// **'Dashboard Overview'**
  String get dashboardOverview;

  /// No description provided for @weekly.
  ///
  /// In en, this message translates to:
  /// **'Weekly'**
  String get weekly;

  /// No description provided for @last30Days.
  ///
  /// In en, this message translates to:
  /// **'Last 30 Days'**
  String get last30Days;

  /// No description provided for @yearly.
  ///
  /// In en, this message translates to:
  /// **'Yearly'**
  String get yearly;

  /// No description provided for @totalIncome.
  ///
  /// In en, this message translates to:
  /// **'Total Income'**
  String get totalIncome;

  /// No description provided for @incomeDelta.
  ///
  /// In en, this message translates to:
  /// **'+12.4% vs last month'**
  String get incomeDelta;

  /// No description provided for @logisticsPerformance.
  ///
  /// In en, this message translates to:
  /// **'Logistics Performance'**
  String get logisticsPerformance;

  /// No description provided for @inventoryTurnoverRate.
  ///
  /// In en, this message translates to:
  /// **'Inventory Turnover Rate'**
  String get inventoryTurnoverRate;

  /// No description provided for @turnoverValue.
  ///
  /// In en, this message translates to:
  /// **'4.2x / Month'**
  String get turnoverValue;

  /// No description provided for @efficiency.
  ///
  /// In en, this message translates to:
  /// **'Efficiency'**
  String get efficiency;

  /// No description provided for @efficiencyValue.
  ///
  /// In en, this message translates to:
  /// **'98.2%'**
  String get efficiencyValue;

  /// No description provided for @efficiencyDelta.
  ///
  /// In en, this message translates to:
  /// **'2.1%'**
  String get efficiencyDelta;

  /// No description provided for @resourceAllocation.
  ///
  /// In en, this message translates to:
  /// **'Resource Allocation'**
  String get resourceAllocation;

  /// No description provided for @capacity.
  ///
  /// In en, this message translates to:
  /// **'Capacity'**
  String get capacity;

  /// No description provided for @active.
  ///
  /// In en, this message translates to:
  /// **'Active'**
  String get active;

  /// No description provided for @onLeave.
  ///
  /// In en, this message translates to:
  /// **'On Leave'**
  String get onLeave;

  /// No description provided for @available.
  ///
  /// In en, this message translates to:
  /// **'Available'**
  String get available;

  /// No description provided for @avgResponseTime.
  ///
  /// In en, this message translates to:
  /// **'Avg Response Time'**
  String get avgResponseTime;

  /// No description provided for @avgResponseValue.
  ///
  /// In en, this message translates to:
  /// **'12.4m'**
  String get avgResponseValue;

  /// No description provided for @criticalEngineeringLogs.
  ///
  /// In en, this message translates to:
  /// **'Critical Engineering Logs'**
  String get criticalEngineeringLogs;

  /// No description provided for @engineeringOverview.
  ///
  /// In en, this message translates to:
  /// **'Engineering Overview'**
  String get engineeringOverview;

  /// No description provided for @components.
  ///
  /// In en, this message translates to:
  /// **'Spare Parts'**
  String get components;

  /// No description provided for @invoices.
  ///
  /// In en, this message translates to:
  /// **'Invoices'**
  String get invoices;

  /// No description provided for @received.
  ///
  /// In en, this message translates to:
  /// **'Received'**
  String get received;

  /// No description provided for @waiting.
  ///
  /// In en, this message translates to:
  /// **'Waiting'**
  String get waiting;

  /// No description provided for @inMaintenance.
  ///
  /// In en, this message translates to:
  /// **'In Maintenance'**
  String get inMaintenance;

  /// No description provided for @completed.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get completed;

  /// No description provided for @delivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get delivered;

  /// No description provided for @thisMonth.
  ///
  /// In en, this message translates to:
  /// **'This Month'**
  String get thisMonth;

  /// No description provided for @incomeChart.
  ///
  /// In en, this message translates to:
  /// **'Income Chart'**
  String get incomeChart;

  /// No description provided for @deviceOverheatingDetected.
  ///
  /// In en, this message translates to:
  /// **'Device overheating detected'**
  String get deviceOverheatingDetected;

  /// No description provided for @deviceOverheatingSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Device #A21 in maintenance room'**
  String get deviceOverheatingSubtitle;

  /// No description provided for @lowStockAlert.
  ///
  /// In en, this message translates to:
  /// **'Low stock alert'**
  String get lowStockAlert;

  /// No description provided for @lowStockSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Spare parts below threshold'**
  String get lowStockSubtitle;

  /// No description provided for @repairCompleted.
  ///
  /// In en, this message translates to:
  /// **'Repair completed'**
  String get repairCompleted;

  /// No description provided for @repairCompletedSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Device #B11 successfully fixed'**
  String get repairCompletedSubtitle;

  /// No description provided for @viewAll.
  ///
  /// In en, this message translates to:
  /// **'View All'**
  String get viewAll;

  /// No description provided for @log1Title.
  ///
  /// In en, this message translates to:
  /// **'System Failure: Node #042'**
  String get log1Title;

  /// No description provided for @log1Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Warehouse A - Sector 7 • 12m ago'**
  String get log1Subtitle;

  /// No description provided for @log1Chip.
  ///
  /// In en, this message translates to:
  /// **'Critical'**
  String get log1Chip;

  /// No description provided for @log2Title.
  ///
  /// In en, this message translates to:
  /// **'Restock Required: Lithium Core'**
  String get log2Title;

  /// No description provided for @log2Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Global Inventory Management • 45m ago'**
  String get log2Subtitle;

  /// No description provided for @log2Chip.
  ///
  /// In en, this message translates to:
  /// **'Action'**
  String get log2Chip;

  /// No description provided for @log3Title.
  ///
  /// In en, this message translates to:
  /// **'Security Alert: Perimeter Breach'**
  String get log3Title;

  /// No description provided for @log3Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Facility Security Log • 2h ago'**
  String get log3Subtitle;

  /// No description provided for @log3Chip.
  ///
  /// In en, this message translates to:
  /// **'Alert'**
  String get log3Chip;

  /// No description provided for @log4Title.
  ///
  /// In en, this message translates to:
  /// **'Maintenance Complete: HVAC'**
  String get log4Title;

  /// No description provided for @log4Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Facility Engineering • 4h ago'**
  String get log4Subtitle;

  /// No description provided for @log4Chip.
  ///
  /// In en, this message translates to:
  /// **'Done'**
  String get log4Chip;

  /// No description provided for @log5Title.
  ///
  /// In en, this message translates to:
  /// **'Protocol Violation Detected'**
  String get log5Title;

  /// No description provided for @log5Subtitle.
  ///
  /// In en, this message translates to:
  /// **'Compliance Monitoring • 6h ago'**
  String get log5Subtitle;

  /// No description provided for @log5Chip.
  ///
  /// In en, this message translates to:
  /// **'High'**
  String get log5Chip;

  /// No description provided for @language.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get language;

  /// No description provided for @english.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get english;

  /// No description provided for @arabic.
  ///
  /// In en, this message translates to:
  /// **'Arabic'**
  String get arabic;

  /// No description provided for @signIn.
  ///
  /// In en, this message translates to:
  /// **'Sign in'**
  String get signIn;

  /// No description provided for @email.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get email;

  /// No description provided for @password.
  ///
  /// In en, this message translates to:
  /// **'Password'**
  String get password;

  /// No description provided for @forgotPassword.
  ///
  /// In en, this message translates to:
  /// **'Forgot password?'**
  String get forgotPassword;

  /// No description provided for @sendResetLink.
  ///
  /// In en, this message translates to:
  /// **'Send reset link'**
  String get sendResetLink;

  /// No description provided for @resetLinkSent.
  ///
  /// In en, this message translates to:
  /// **'If an account exists we sent a reset link to your email.'**
  String get resetLinkSent;
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
      <String>['ar', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'ar':
      return AppLocalizationsAr();
    case 'en':
      return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.',
  );
}
