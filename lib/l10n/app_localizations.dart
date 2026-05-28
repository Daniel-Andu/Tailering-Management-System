import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
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
  AppLocalizations(String locale) : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate = _AppLocalizationsDelegate();

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
  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates = <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  /// A list of this localizations delegate's supported locales.
  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en')
  ];

  /// No description provided for @appTitle.
  ///
  /// In en, this message translates to:
  /// **'Tailoring Management System'**
  String get appTitle;

  /// No description provided for @appSubtitle.
  ///
  /// In en, this message translates to:
  /// **'Professional Tailoring Business Management'**
  String get appSubtitle;

  /// No description provided for @menuDashboard.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get menuDashboard;

  /// No description provided for @menuCustomers.
  ///
  /// In en, this message translates to:
  /// **'Customers'**
  String get menuCustomers;

  /// No description provided for @menuOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get menuOrders;

  /// No description provided for @menuAddCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get menuAddCustomer;

  /// No description provided for @menuAddOrder.
  ///
  /// In en, this message translates to:
  /// **'Add Order'**
  String get menuAddOrder;

  /// No description provided for @menuReports.
  ///
  /// In en, this message translates to:
  /// **'Reports'**
  String get menuReports;

  /// No description provided for @menuBilling.
  ///
  /// In en, this message translates to:
  /// **'Billing'**
  String get menuBilling;

  /// No description provided for @menuExit.
  ///
  /// In en, this message translates to:
  /// **'Exit'**
  String get menuExit;

  /// No description provided for @menuAppointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get menuAppointments;

  /// No description provided for @menuInventory.
  ///
  /// In en, this message translates to:
  /// **'Inventory'**
  String get menuInventory;

  /// No description provided for @menuNotifications.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get menuNotifications;

  /// No description provided for @menuStaff.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get menuStaff;

  /// No description provided for @menuSettings.
  ///
  /// In en, this message translates to:
  /// **'Settings'**
  String get menuSettings;

  /// No description provided for @menuMore.
  ///
  /// In en, this message translates to:
  /// **'More'**
  String get menuMore;

  /// No description provided for @dashboardTitle.
  ///
  /// In en, this message translates to:
  /// **'Dashboard'**
  String get dashboardTitle;

  /// No description provided for @dashboardBackToMain.
  ///
  /// In en, this message translates to:
  /// **'Back to Main Menu'**
  String get dashboardBackToMain;

  /// No description provided for @dashboardTotalCustomers.
  ///
  /// In en, this message translates to:
  /// **'Total Customers'**
  String get dashboardTotalCustomers;

  /// No description provided for @dashboardTotalOrders.
  ///
  /// In en, this message translates to:
  /// **'Total Orders'**
  String get dashboardTotalOrders;

  /// No description provided for @dashboardPendingOrders.
  ///
  /// In en, this message translates to:
  /// **'Pending Orders'**
  String get dashboardPendingOrders;

  /// No description provided for @dashboardCompletedOrders.
  ///
  /// In en, this message translates to:
  /// **'Completed Orders'**
  String get dashboardCompletedOrders;

  /// No description provided for @dashboardTotalRevenue.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue'**
  String get dashboardTotalRevenue;

  /// No description provided for @dashboardBusinessOverview.
  ///
  /// In en, this message translates to:
  /// **'Business Overview'**
  String get dashboardBusinessOverview;

  /// No description provided for @dashboardOrdersByStatus.
  ///
  /// In en, this message translates to:
  /// **'Orders by Status'**
  String get dashboardOrdersByStatus;

  /// No description provided for @dashboardStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get dashboardStatus;

  /// No description provided for @dashboardCount.
  ///
  /// In en, this message translates to:
  /// **'Count'**
  String get dashboardCount;

  /// No description provided for @dashboardOrders.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get dashboardOrders;

  /// No description provided for @dashboardRevenueSummary.
  ///
  /// In en, this message translates to:
  /// **'Revenue Summary'**
  String get dashboardRevenueSummary;

  /// No description provided for @dashboardTotalRevenueCompleted.
  ///
  /// In en, this message translates to:
  /// **'Total Revenue from Completed Orders'**
  String get dashboardTotalRevenueCompleted;

  /// No description provided for @dashboardManageCustomers.
  ///
  /// In en, this message translates to:
  /// **'Manage Customers'**
  String get dashboardManageCustomers;

  /// No description provided for @dashboardManageOrders.
  ///
  /// In en, this message translates to:
  /// **'Manage Orders'**
  String get dashboardManageOrders;

  /// No description provided for @dashboardAddNewCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add New Customer'**
  String get dashboardAddNewCustomer;

  /// No description provided for @dashboardAddNewOrder.
  ///
  /// In en, this message translates to:
  /// **'Add New Order'**
  String get dashboardAddNewOrder;

  /// No description provided for @customerFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Customer'**
  String get customerFormTitle;

  /// No description provided for @customerFormBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get customerFormBack;

  /// No description provided for @customerFormSaveCustomer.
  ///
  /// In en, this message translates to:
  /// **'Save Customer'**
  String get customerFormSaveCustomer;

  /// No description provided for @customerFormCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get customerFormCancel;

  /// No description provided for @customerFormName.
  ///
  /// In en, this message translates to:
  /// **'Name'**
  String get customerFormName;

  /// No description provided for @customerFormPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get customerFormPhone;

  /// No description provided for @customerFormChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get customerFormChest;

  /// No description provided for @customerFormWaist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get customerFormWaist;

  /// No description provided for @customerFormLength.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get customerFormLength;

  /// No description provided for @customerFormNameRequired.
  ///
  /// In en, this message translates to:
  /// **'Name is required'**
  String get customerFormNameRequired;

  /// No description provided for @customerFormMeasurementsValid.
  ///
  /// In en, this message translates to:
  /// **'Measurements must be valid numbers'**
  String get customerFormMeasurementsValid;

  /// No description provided for @customerFormSuccess.
  ///
  /// In en, this message translates to:
  /// **'Customer saved successfully'**
  String get customerFormSuccess;

  /// No description provided for @customerFormDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get customerFormDelete;

  /// No description provided for @customerFormRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get customerFormRefresh;

  /// No description provided for @customerListTitle.
  ///
  /// In en, this message translates to:
  /// **'Customer List'**
  String get customerListTitle;

  /// No description provided for @customerListSearch.
  ///
  /// In en, this message translates to:
  /// **'Search customers'**
  String get customerListSearch;

  /// No description provided for @customerListBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get customerListBack;

  /// No description provided for @customerListAddCustomer.
  ///
  /// In en, this message translates to:
  /// **'Add Customer'**
  String get customerListAddCustomer;

  /// No description provided for @customerListEdit.
  ///
  /// In en, this message translates to:
  /// **'Edit'**
  String get customerListEdit;

  /// No description provided for @customerListDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get customerListDelete;

  /// No description provided for @customerListRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get customerListRefresh;

  /// No description provided for @customerListNoSelection.
  ///
  /// In en, this message translates to:
  /// **'No customer selected'**
  String get customerListNoSelection;

  /// No description provided for @customerListConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Confirm Delete'**
  String get customerListConfirmDelete;

  /// No description provided for @customerListDeleteMessage.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this customer'**
  String get customerListDeleteMessage;

  /// No description provided for @alertWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get alertWarning;

  /// No description provided for @alertError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get alertError;

  /// No description provided for @alertInformation.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get alertInformation;

  /// No description provided for @alertSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get alertSuccess;

  /// No description provided for @orderFormTitle.
  ///
  /// In en, this message translates to:
  /// **'Add New Order'**
  String get orderFormTitle;

  /// No description provided for @orderFormBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get orderFormBack;

  /// No description provided for @orderFormSaveOrder.
  ///
  /// In en, this message translates to:
  /// **'Save Order'**
  String get orderFormSaveOrder;

  /// No description provided for @orderFormCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get orderFormCancel;

  /// No description provided for @orderFormSelectCustomer.
  ///
  /// In en, this message translates to:
  /// **'Select Customer'**
  String get orderFormSelectCustomer;

  /// No description provided for @orderFormClothType.
  ///
  /// In en, this message translates to:
  /// **'Cloth Type'**
  String get orderFormClothType;

  /// No description provided for @orderFormPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get orderFormPrice;

  /// No description provided for @orderFormDeliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Delivery Date'**
  String get orderFormDeliveryDate;

  /// No description provided for @orderFormStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get orderFormStatus;

  /// No description provided for @orderListTitle.
  ///
  /// In en, this message translates to:
  /// **'Order Management'**
  String get orderListTitle;

  /// No description provided for @orderListBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get orderListBack;

  /// No description provided for @orderListAddOrder.
  ///
  /// In en, this message translates to:
  /// **'Add Order'**
  String get orderListAddOrder;

  /// No description provided for @orderListEditStatus.
  ///
  /// In en, this message translates to:
  /// **'Edit Status'**
  String get orderListEditStatus;

  /// No description provided for @orderListDelete.
  ///
  /// In en, this message translates to:
  /// **'Delete'**
  String get orderListDelete;

  /// No description provided for @orderListRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get orderListRefresh;

  /// No description provided for @orderListFilterByStatus.
  ///
  /// In en, this message translates to:
  /// **'Filter by Status'**
  String get orderListFilterByStatus;

  /// No description provided for @orderListAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get orderListAll;

  /// No description provided for @orderListPending.
  ///
  /// In en, this message translates to:
  /// **'Pending'**
  String get orderListPending;

  /// No description provided for @orderListInProgress.
  ///
  /// In en, this message translates to:
  /// **'In Progress'**
  String get orderListInProgress;

  /// No description provided for @orderListCompleted.
  ///
  /// In en, this message translates to:
  /// **'Completed'**
  String get orderListCompleted;

  /// No description provided for @orderListDelivered.
  ///
  /// In en, this message translates to:
  /// **'Delivered'**
  String get orderListDelivered;

  /// No description provided for @orderListCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get orderListCustomer;

  /// No description provided for @orderListClothType.
  ///
  /// In en, this message translates to:
  /// **'Cloth Type'**
  String get orderListClothType;

  /// No description provided for @orderListPrice.
  ///
  /// In en, this message translates to:
  /// **'Price'**
  String get orderListPrice;

  /// No description provided for @orderListStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get orderListStatus;

  /// No description provided for @orderListDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get orderListDate;

  /// No description provided for @orderListLoadError.
  ///
  /// In en, this message translates to:
  /// **'Failed to load orders'**
  String get orderListLoadError;

  /// No description provided for @orderListFilterError.
  ///
  /// In en, this message translates to:
  /// **'Filter error'**
  String get orderListFilterError;

  /// No description provided for @orderListNoSelection.
  ///
  /// In en, this message translates to:
  /// **'Please select an order'**
  String get orderListNoSelection;

  /// No description provided for @orderListEditStatusHeader.
  ///
  /// In en, this message translates to:
  /// **'Edit Order Status'**
  String get orderListEditStatusHeader;

  /// No description provided for @orderListNewStatus.
  ///
  /// In en, this message translates to:
  /// **'New Status'**
  String get orderListNewStatus;

  /// No description provided for @orderListStatusUpdated.
  ///
  /// In en, this message translates to:
  /// **'Status updated'**
  String get orderListStatusUpdated;

  /// No description provided for @orderListConfirmDeleteHeader.
  ///
  /// In en, this message translates to:
  /// **'Delete Order Confirmation'**
  String get orderListConfirmDeleteHeader;

  /// No description provided for @orderListDeleteConfirmation.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this order'**
  String get orderListDeleteConfirmation;

  /// No description provided for @orderListOrderDeleted.
  ///
  /// In en, this message translates to:
  /// **'Order deleted'**
  String get orderListOrderDeleted;

  /// No description provided for @billingTitle.
  ///
  /// In en, this message translates to:
  /// **'Billing & Invoicing'**
  String get billingTitle;

  /// No description provided for @billingBack.
  ///
  /// In en, this message translates to:
  /// **'Back'**
  String get billingBack;

  /// No description provided for @billingFrom.
  ///
  /// In en, this message translates to:
  /// **'From'**
  String get billingFrom;

  /// No description provided for @billingTo.
  ///
  /// In en, this message translates to:
  /// **'To'**
  String get billingTo;

  /// No description provided for @billingFilter.
  ///
  /// In en, this message translates to:
  /// **'Filter'**
  String get billingFilter;

  /// No description provided for @billingTotalAmount.
  ///
  /// In en, this message translates to:
  /// **'Total Amount'**
  String get billingTotalAmount;

  /// No description provided for @billingGenerateInvoice.
  ///
  /// In en, this message translates to:
  /// **'Generate Invoice'**
  String get billingGenerateInvoice;

  /// No description provided for @billingMarkAsPaid.
  ///
  /// In en, this message translates to:
  /// **'Mark as Paid'**
  String get billingMarkAsPaid;

  /// No description provided for @billingPrint.
  ///
  /// In en, this message translates to:
  /// **'Print'**
  String get billingPrint;

  /// No description provided for @reportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Business Reports'**
  String get reportsTitle;

  /// No description provided for @reportsBack.
  ///
  /// In en, this message translates to:
  /// **'Back to Main Menu'**
  String get reportsBack;

  /// No description provided for @reportsRevenueReport.
  ///
  /// In en, this message translates to:
  /// **'Revenue Report'**
  String get reportsRevenueReport;

  /// No description provided for @reportsCustomerAnalysis.
  ///
  /// In en, this message translates to:
  /// **'Customer Analysis'**
  String get reportsCustomerAnalysis;

  /// No description provided for @reportsOrderTrends.
  ///
  /// In en, this message translates to:
  /// **'Order Trends'**
  String get reportsOrderTrends;

  /// No description provided for @commonSuccess.
  ///
  /// In en, this message translates to:
  /// **'Success'**
  String get commonSuccess;

  /// No description provided for @commonError.
  ///
  /// In en, this message translates to:
  /// **'Error'**
  String get commonError;

  /// No description provided for @commonWarning.
  ///
  /// In en, this message translates to:
  /// **'Warning'**
  String get commonWarning;

  /// No description provided for @commonInfo.
  ///
  /// In en, this message translates to:
  /// **'Information'**
  String get commonInfo;

  /// No description provided for @commonNoSelection.
  ///
  /// In en, this message translates to:
  /// **'Please select an item to proceed'**
  String get commonNoSelection;

  /// No description provided for @commonConfirmDelete.
  ///
  /// In en, this message translates to:
  /// **'Are you sure you want to delete this item'**
  String get commonConfirmDelete;

  /// No description provided for @licenseTitle.
  ///
  /// In en, this message translates to:
  /// **'License'**
  String get licenseTitle;

  /// No description provided for @licenseTrial.
  ///
  /// In en, this message translates to:
  /// **'Trial Version'**
  String get licenseTrial;

  /// No description provided for @licenseTrialDays.
  ///
  /// In en, this message translates to:
  /// **'Days Remaining'**
  String get licenseTrialDays;

  /// No description provided for @licenseTrialExpired.
  ///
  /// In en, this message translates to:
  /// **'Trial Expired'**
  String get licenseTrialExpired;

  /// No description provided for @licenseActivate.
  ///
  /// In en, this message translates to:
  /// **'Activate License'**
  String get licenseActivate;

  /// No description provided for @licenseEnterKey.
  ///
  /// In en, this message translates to:
  /// **'Enter License Key'**
  String get licenseEnterKey;

  /// No description provided for @licenseActivateButton.
  ///
  /// In en, this message translates to:
  /// **'Activate'**
  String get licenseActivateButton;

  /// No description provided for @licenseContinueTrial.
  ///
  /// In en, this message translates to:
  /// **'Continue Trial'**
  String get licenseContinueTrial;

  /// No description provided for @licenseContact.
  ///
  /// In en, this message translates to:
  /// **'Need a license? Contact us'**
  String get licenseContact;

  /// No description provided for @licenseContactInfo.
  ///
  /// In en, this message translates to:
  /// **'Email: your-email@example.com\nPhone: +XXX-XXX-XXX'**
  String get licenseContactInfo;

  /// No description provided for @licenseInvalidKey.
  ///
  /// In en, this message translates to:
  /// **'Invalid license key'**
  String get licenseInvalidKey;

  /// No description provided for @licenseActivationSuccess.
  ///
  /// In en, this message translates to:
  /// **'License activated successfully'**
  String get licenseActivationSuccess;

  /// No description provided for @licenseLicenseRequired.
  ///
  /// In en, this message translates to:
  /// **'License required to use this application'**
  String get licenseLicenseRequired;

  /// No description provided for @companyName.
  ///
  /// In en, this message translates to:
  /// **'Company Name'**
  String get companyName;

  /// No description provided for @companyNameHint.
  ///
  /// In en, this message translates to:
  /// **'Enter your tailoring business name'**
  String get companyNameHint;

  /// No description provided for @staffTitle.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staffTitle;

  /// No description provided for @staffAdd.
  ///
  /// In en, this message translates to:
  /// **'Staff'**
  String get staffAdd;

  /// No description provided for @staffRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get staffRefresh;

  /// No description provided for @staffNoStaff.
  ///
  /// In en, this message translates to:
  /// **'No staff registered'**
  String get staffNoStaff;

  /// No description provided for @staffNewMember.
  ///
  /// In en, this message translates to:
  /// **'New Staff Member'**
  String get staffNewMember;

  /// No description provided for @staffFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get staffFullName;

  /// No description provided for @staffRole.
  ///
  /// In en, this message translates to:
  /// **'Role'**
  String get staffRole;

  /// No description provided for @staffPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get staffPhone;

  /// No description provided for @staffEmployeeCode.
  ///
  /// In en, this message translates to:
  /// **'Employee Code'**
  String get staffEmployeeCode;

  /// No description provided for @financialReportsTitle.
  ///
  /// In en, this message translates to:
  /// **'Financial Reports'**
  String get financialReportsTitle;

  /// No description provided for @financialReportsNoData.
  ///
  /// In en, this message translates to:
  /// **'No report data'**
  String get financialReportsNoData;

  /// No description provided for @financialReportsPaymentsByMethod.
  ///
  /// In en, this message translates to:
  /// **'Payments By Method'**
  String get financialReportsPaymentsByMethod;

  /// No description provided for @financialReportsPayments.
  ///
  /// In en, this message translates to:
  /// **'payments'**
  String get financialReportsPayments;

  /// No description provided for @financialReportsUnpaidBalances.
  ///
  /// In en, this message translates to:
  /// **'Unpaid Balances'**
  String get financialReportsUnpaidBalances;

  /// No description provided for @shopSettingsTitle.
  ///
  /// In en, this message translates to:
  /// **'Shop Settings'**
  String get shopSettingsTitle;

  /// No description provided for @shopSettingsSave.
  ///
  /// In en, this message translates to:
  /// **'Save Settings'**
  String get shopSettingsSave;

  /// No description provided for @shopSettingsShopName.
  ///
  /// In en, this message translates to:
  /// **'Shop name'**
  String get shopSettingsShopName;

  /// No description provided for @shopSettingsShopPhone.
  ///
  /// In en, this message translates to:
  /// **'Shop phone'**
  String get shopSettingsShopPhone;

  /// No description provided for @shopSettingsAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get shopSettingsAddress;

  /// No description provided for @shopSettingsReceiptFooter.
  ///
  /// In en, this message translates to:
  /// **'Receipt footer'**
  String get shopSettingsReceiptFooter;

  /// No description provided for @ordersTitle.
  ///
  /// In en, this message translates to:
  /// **'Orders'**
  String get ordersTitle;

  /// No description provided for @ordersAdd.
  ///
  /// In en, this message translates to:
  /// **'Order'**
  String get ordersAdd;

  /// No description provided for @ordersRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get ordersRefresh;

  /// No description provided for @ordersSearch.
  ///
  /// In en, this message translates to:
  /// **'Search order, customer, phone, cloth'**
  String get ordersSearch;

  /// No description provided for @ordersAll.
  ///
  /// In en, this message translates to:
  /// **'All'**
  String get ordersAll;

  /// No description provided for @ordersNoOrders.
  ///
  /// In en, this message translates to:
  /// **'No orders found'**
  String get ordersNoOrders;

  /// No description provided for @ordersNewOrder.
  ///
  /// In en, this message translates to:
  /// **'New Order'**
  String get ordersNewOrder;

  /// No description provided for @ordersBasicInfo.
  ///
  /// In en, this message translates to:
  /// **'Basic Information'**
  String get ordersBasicInfo;

  /// No description provided for @ordersCustomerId.
  ///
  /// In en, this message translates to:
  /// **'Customer ID'**
  String get ordersCustomerId;

  /// No description provided for @ordersClothType.
  ///
  /// In en, this message translates to:
  /// **'Cloth type'**
  String get ordersClothType;

  /// No description provided for @ordersGender.
  ///
  /// In en, this message translates to:
  /// **'Gender'**
  String get ordersGender;

  /// No description provided for @ordersPrice.
  ///
  /// In en, this message translates to:
  /// **'Price (ETB)'**
  String get ordersPrice;

  /// No description provided for @ordersMeasurements.
  ///
  /// In en, this message translates to:
  /// **'Measurements (cm)'**
  String get ordersMeasurements;

  /// No description provided for @ordersChest.
  ///
  /// In en, this message translates to:
  /// **'Chest'**
  String get ordersChest;

  /// No description provided for @ordersShoulder.
  ///
  /// In en, this message translates to:
  /// **'Shoulder'**
  String get ordersShoulder;

  /// No description provided for @ordersHip.
  ///
  /// In en, this message translates to:
  /// **'Hip'**
  String get ordersHip;

  /// No description provided for @ordersBreast.
  ///
  /// In en, this message translates to:
  /// **'Breast'**
  String get ordersBreast;

  /// No description provided for @ordersWaist.
  ///
  /// In en, this message translates to:
  /// **'Waist'**
  String get ordersWaist;

  /// No description provided for @ordersLength.
  ///
  /// In en, this message translates to:
  /// **'Length'**
  String get ordersLength;

  /// No description provided for @ordersSleeve.
  ///
  /// In en, this message translates to:
  /// **'Sleeve'**
  String get ordersSleeve;

  /// No description provided for @ordersNeck.
  ///
  /// In en, this message translates to:
  /// **'Neck'**
  String get ordersNeck;

  /// No description provided for @ordersUploadPhoto.
  ///
  /// In en, this message translates to:
  /// **'Upload cloth photo'**
  String get ordersUploadPhoto;

  /// No description provided for @ordersNoPhoto.
  ///
  /// In en, this message translates to:
  /// **'No photo selected'**
  String get ordersNoPhoto;

  /// No description provided for @ordersOrderDetails.
  ///
  /// In en, this message translates to:
  /// **'Order Details'**
  String get ordersOrderDetails;

  /// No description provided for @ordersPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get ordersPriority;

  /// No description provided for @ordersUrgency.
  ///
  /// In en, this message translates to:
  /// **'Urgency'**
  String get ordersUrgency;

  /// No description provided for @ordersDeliveryDate.
  ///
  /// In en, this message translates to:
  /// **'Delivery date'**
  String get ordersDeliveryDate;

  /// No description provided for @ordersNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get ordersNotes;

  /// No description provided for @ordersCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get ordersCancel;

  /// No description provided for @ordersCreateOrder.
  ///
  /// In en, this message translates to:
  /// **'Create Order'**
  String get ordersCreateOrder;

  /// No description provided for @ordersPleaseSelectCustomer.
  ///
  /// In en, this message translates to:
  /// **'Please select a customer'**
  String get ordersPleaseSelectCustomer;

  /// No description provided for @ordersErrorSaving.
  ///
  /// In en, this message translates to:
  /// **'Error saving order'**
  String get ordersErrorSaving;

  /// No description provided for @ordersRecordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get ordersRecordPayment;

  /// No description provided for @ordersPaymentAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get ordersPaymentAmount;

  /// No description provided for @ordersPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get ordersPaymentMethod;

  /// No description provided for @ordersPaymentReference.
  ///
  /// In en, this message translates to:
  /// **'Reference / transaction ID'**
  String get ordersPaymentReference;

  /// No description provided for @ordersSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get ordersSave;

  /// No description provided for @ordersBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get ordersBalance;

  /// No description provided for @ordersChangeStatus.
  ///
  /// In en, this message translates to:
  /// **'Change status'**
  String get ordersChangeStatus;

  /// No description provided for @customerListId.
  ///
  /// In en, this message translates to:
  /// **'ID'**
  String get customerListId;

  /// No description provided for @customerListPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get customerListPhone;

  /// No description provided for @customerListEmail.
  ///
  /// In en, this message translates to:
  /// **'Email'**
  String get customerListEmail;

  /// No description provided for @customersNewCustomer.
  ///
  /// In en, this message translates to:
  /// **'New Customer'**
  String get customersNewCustomer;

  /// No description provided for @customersFullName.
  ///
  /// In en, this message translates to:
  /// **'Full Name'**
  String get customersFullName;

  /// No description provided for @customersPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get customersPhone;

  /// No description provided for @customersBusinessName.
  ///
  /// In en, this message translates to:
  /// **'Business name'**
  String get customersBusinessName;

  /// No description provided for @customersAddress.
  ///
  /// In en, this message translates to:
  /// **'Address'**
  String get customersAddress;

  /// No description provided for @customersCategory.
  ///
  /// In en, this message translates to:
  /// **'Category'**
  String get customersCategory;

  /// No description provided for @customersLanguage.
  ///
  /// In en, this message translates to:
  /// **'Language'**
  String get customersLanguage;

  /// No description provided for @customersNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get customersNotes;

  /// No description provided for @customersRegular.
  ///
  /// In en, this message translates to:
  /// **'Regular'**
  String get customersRegular;

  /// No description provided for @customersVIP.
  ///
  /// In en, this message translates to:
  /// **'VIP'**
  String get customersVIP;

  /// No description provided for @customersOrganization.
  ///
  /// In en, this message translates to:
  /// **'Organization'**
  String get customersOrganization;

  /// No description provided for @customersAmharic.
  ///
  /// In en, this message translates to:
  /// **'Amharic'**
  String get customersAmharic;

  /// No description provided for @customersEnglish.
  ///
  /// In en, this message translates to:
  /// **'English'**
  String get customersEnglish;

  /// No description provided for @customersCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get customersCancel;

  /// No description provided for @customersCreateCustomer.
  ///
  /// In en, this message translates to:
  /// **'Create Customer'**
  String get customersCreateCustomer;

  /// No description provided for @customersEditCustomer.
  ///
  /// In en, this message translates to:
  /// **'Edit Customer'**
  String get customersEditCustomer;

  /// No description provided for @customersSaveChanges.
  ///
  /// In en, this message translates to:
  /// **'Save Changes'**
  String get customersSaveChanges;

  /// No description provided for @notificationsTitle.
  ///
  /// In en, this message translates to:
  /// **'Notifications'**
  String get notificationsTitle;

  /// No description provided for @notificationsSendPending.
  ///
  /// In en, this message translates to:
  /// **'Send Pending'**
  String get notificationsSendPending;

  /// No description provided for @notificationsRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get notificationsRefresh;

  /// No description provided for @notificationsNoPending.
  ///
  /// In en, this message translates to:
  /// **'No pending notifications'**
  String get notificationsNoPending;

  /// No description provided for @ordersPaymentSection.
  ///
  /// In en, this message translates to:
  /// **'Payment Information'**
  String get ordersPaymentSection;

  /// No description provided for @ordersPaidAmount.
  ///
  /// In en, this message translates to:
  /// **'Paid Amount'**
  String get ordersPaidAmount;

  /// No description provided for @ordersPaidAmountHint.
  ///
  /// In en, this message translates to:
  /// **'Enter amount paid upfront'**
  String get ordersPaidAmountHint;

  /// No description provided for @ordersRemainingBalance.
  ///
  /// In en, this message translates to:
  /// **'Remaining Balance'**
  String get ordersRemainingBalance;

  /// No description provided for @orderDetailSummary.
  ///
  /// In en, this message translates to:
  /// **'Summary'**
  String get orderDetailSummary;

  /// No description provided for @orderDetailPayments.
  ///
  /// In en, this message translates to:
  /// **'Payments'**
  String get orderDetailPayments;

  /// No description provided for @orderDetailTimeline.
  ///
  /// In en, this message translates to:
  /// **'Timeline'**
  String get orderDetailTimeline;

  /// No description provided for @orderDetailAppointments.
  ///
  /// In en, this message translates to:
  /// **'Appointments'**
  String get orderDetailAppointments;

  /// No description provided for @orderDetailMessages.
  ///
  /// In en, this message translates to:
  /// **'Messages'**
  String get orderDetailMessages;

  /// No description provided for @orderDetailRefresh.
  ///
  /// In en, this message translates to:
  /// **'Refresh'**
  String get orderDetailRefresh;

  /// No description provided for @orderDetailChangeStatus.
  ///
  /// In en, this message translates to:
  /// **'Change status'**
  String get orderDetailChangeStatus;

  /// No description provided for @orderDetailOrderNotFound.
  ///
  /// In en, this message translates to:
  /// **'Order not found'**
  String get orderDetailOrderNotFound;

  /// No description provided for @orderDetailRecordPayment.
  ///
  /// In en, this message translates to:
  /// **'Record Payment'**
  String get orderDetailRecordPayment;

  /// No description provided for @orderDetailAmount.
  ///
  /// In en, this message translates to:
  /// **'Amount'**
  String get orderDetailAmount;

  /// No description provided for @orderDetailPaymentMethod.
  ///
  /// In en, this message translates to:
  /// **'Payment method'**
  String get orderDetailPaymentMethod;

  /// No description provided for @orderDetailReference.
  ///
  /// In en, this message translates to:
  /// **'Reference'**
  String get orderDetailReference;

  /// No description provided for @orderDetailCancel.
  ///
  /// In en, this message translates to:
  /// **'Cancel'**
  String get orderDetailCancel;

  /// No description provided for @orderDetailSave.
  ///
  /// In en, this message translates to:
  /// **'Save'**
  String get orderDetailSave;

  /// No description provided for @orderDetailScheduleAppointment.
  ///
  /// In en, this message translates to:
  /// **'Schedule Appointment'**
  String get orderDetailScheduleAppointment;

  /// No description provided for @orderDetailType.
  ///
  /// In en, this message translates to:
  /// **'Type'**
  String get orderDetailType;

  /// No description provided for @orderDetailNotes.
  ///
  /// In en, this message translates to:
  /// **'Notes'**
  String get orderDetailNotes;

  /// No description provided for @orderDetailDate.
  ///
  /// In en, this message translates to:
  /// **'Date'**
  String get orderDetailDate;

  /// No description provided for @orderDetailCustomer.
  ///
  /// In en, this message translates to:
  /// **'Customer'**
  String get orderDetailCustomer;

  /// No description provided for @orderDetailPhone.
  ///
  /// In en, this message translates to:
  /// **'Phone'**
  String get orderDetailPhone;

  /// No description provided for @orderDetailStatus.
  ///
  /// In en, this message translates to:
  /// **'Status'**
  String get orderDetailStatus;

  /// No description provided for @orderDetailPriority.
  ///
  /// In en, this message translates to:
  /// **'Priority'**
  String get orderDetailPriority;

  /// No description provided for @orderDetailUrgency.
  ///
  /// In en, this message translates to:
  /// **'Urgency'**
  String get orderDetailUrgency;

  /// No description provided for @orderDetailDelivery.
  ///
  /// In en, this message translates to:
  /// **'Delivery'**
  String get orderDetailDelivery;

  /// No description provided for @orderDetailTotal.
  ///
  /// In en, this message translates to:
  /// **'Total'**
  String get orderDetailTotal;

  /// No description provided for @orderDetailBalance.
  ///
  /// In en, this message translates to:
  /// **'Balance'**
  String get orderDetailBalance;

  /// No description provided for @orderDetailItems.
  ///
  /// In en, this message translates to:
  /// **'Items'**
  String get orderDetailItems;

  /// No description provided for @orderDetailNoPaymentsYet.
  ///
  /// In en, this message translates to:
  /// **'No payments yet'**
  String get orderDetailNoPaymentsYet;

  /// No description provided for @orderDetailNoTimelineYet.
  ///
  /// In en, this message translates to:
  /// **'No timeline yet'**
  String get orderDetailNoTimelineYet;

  /// No description provided for @orderDetailNoAppointments.
  ///
  /// In en, this message translates to:
  /// **'No appointments'**
  String get orderDetailNoAppointments;

  /// No description provided for @orderDetailNoMessagesQueued.
  ///
  /// In en, this message translates to:
  /// **'No messages queued'**
  String get orderDetailNoMessagesQueued;
}

class _AppLocalizationsDelegate extends LocalizationsDelegate<AppLocalizations> {
  const _AppLocalizationsDelegate();

  @override
  Future<AppLocalizations> load(Locale locale) {
    return SynchronousFuture<AppLocalizations>(lookupAppLocalizations(locale));
  }

  @override
  bool isSupported(Locale locale) => <String>['am', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {


  // Lookup logic when only language code is specified.
  switch (locale.languageCode) {
    case 'am': return AppLocalizationsAm();
    case 'en': return AppLocalizationsEn();
  }

  throw FlutterError(
    'AppLocalizations.delegate failed to load unsupported locale "$locale". This is likely '
    'an issue with the localizations generation tool. Please file an issue '
    'on GitHub with a reproducible sample app and the gen-l10n configuration '
    'that was used.'
  );
}
