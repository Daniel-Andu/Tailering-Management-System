import 'dart:async';

import 'package:flutter/foundation.dart';
import 'package:flutter/widgets.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:intl/intl.dart' as intl;

import 'app_localizations_am.dart';
import 'app_localizations_en.dart';

// ignore_for_file: type=lint

abstract class AppLocalizations {
  AppLocalizations(String locale)
      : localeName = intl.Intl.canonicalizedLocale(locale.toString());

  final String localeName;

  static AppLocalizations? of(BuildContext context) {
    return Localizations.of<AppLocalizations>(context, AppLocalizations);
  }

  static const LocalizationsDelegate<AppLocalizations> delegate =
      _AppLocalizationsDelegate();

  static const List<LocalizationsDelegate<dynamic>> localizationsDelegates =
      <LocalizationsDelegate<dynamic>>[
    delegate,
    GlobalMaterialLocalizations.delegate,
    GlobalCupertinoLocalizations.delegate,
    GlobalWidgetsLocalizations.delegate,
  ];

  static const List<Locale> supportedLocales = <Locale>[
    Locale('am'),
    Locale('en')
  ];

  // ── App ──────────────────────────────────────────────────────────────────
  String get appTitle;
  String get appSubtitle;

  // ── Menu ─────────────────────────────────────────────────────────────────
  String get menuDashboard;
  String get menuCustomers;
  String get menuOrders;
  String get menuAddCustomer;
  String get menuAddOrder;
  String get menuReports;
  String get menuBilling;
  String get menuExit;
  String get menuAppointments;
  String get menuInventory;
  String get menuNotifications;
  String get menuStaff;
  String get menuSettings;
  String get menuMore;
  String get menuMeasurements;

  // ── Dashboard ────────────────────────────────────────────────────────────
  String get dashboardTitle;
  String get dashboardBackToMain;
  String get dashboardTotalCustomers;
  String get dashboardTotalOrders;
  String get dashboardPendingOrders;
  String get dashboardCompletedOrders;
  String get dashboardTotalRevenue;
  String get dashboardBusinessOverview;
  String get dashboardOrdersByStatus;
  String get dashboardStatus;
  String get dashboardCount;
  String get dashboardOrders;
  String get dashboardRevenueSummary;
  String get dashboardTotalRevenueCompleted;
  String get dashboardManageCustomers;
  String get dashboardManageOrders;
  String get dashboardAddNewCustomer;
  String get dashboardAddNewOrder;
  String get dashboardDueToday;
  String get dashboardDelayed;
  String get dashboardReady;
  String get dashboardOpenOrders;
  String get dashboardCustomers;
  String get dashboardUnpaid;
  String get dashboardTodayPaid;
  String get dashboardMonthPaid;
  String get dashboardDueSoon;
  String get dashboardUnpaidBalances;
  String get dashboardNoRecords;

  // ── Customer Form ─────────────────────────────────────────────────────────
  String get customerFormTitle;
  String get customerFormBack;
  String get customerFormSaveCustomer;
  String get customerFormCancel;
  String get customerFormName;
  String get customerFormPhone;
  String get customerFormChest;
  String get customerFormWaist;
  String get customerFormLength;
  String get customerFormNameRequired;
  String get customerFormMeasurementsValid;
  String get customerFormSuccess;
  String get customerFormDelete;
  String get customerFormRefresh;

  // ── Customer List ─────────────────────────────────────────────────────────
  String get customerListTitle;
  String get customerListSearch;
  String get customerListBack;
  String get customerListAddCustomer;
  String get customerListEdit;
  String get customerListDelete;
  String get customerListRefresh;
  String get customerListNoSelection;
  String get customerListConfirmDelete;
  String get customerListDeleteMessage;
  String get customerListId;
  String get customerListPhone;
  String get customerListEmail;

  // ── Customers ─────────────────────────────────────────────────────────────
  String get customersNewCustomer;
  String get customersFullName;
  String get customersPhone;
  String get customersBusinessName;
  String get customersAddress;
  String get customersCategory;
  String get customersLanguage;
  String get customersNotes;
  String get customersRegular;
  String get customersVIP;
  String get customersOrganization;
  String get customersAmharic;
  String get customersEnglish;
  String get customersCancel;
  String get customersCreateCustomer;
  String get customersEditCustomer;
  String get customersSaveChanges;

  // ── Alerts ────────────────────────────────────────────────────────────────
  String get alertWarning;
  String get alertError;
  String get alertInformation;
  String get alertSuccess;

  // ── Order Form ────────────────────────────────────────────────────────────
  String get orderFormTitle;
  String get orderFormBack;
  String get orderFormSaveOrder;
  String get orderFormCancel;
  String get orderFormSelectCustomer;
  String get orderFormClothType;
  String get orderFormPrice;
  String get orderFormDeliveryDate;
  String get orderFormStatus;
  String get orderFormEditTitle;
  String get orderFormCustomerRequired;
  String get orderFormClothTypeRequired;
  String get orderFormPriceRequired;
  String get orderFormNotes;
  String get orderFormPaymentMethod;
  String get orderFormTransactionId;
  String get orderFormPaymentStatus;
  String get orderFormAddedMessage;
  String get orderFormUpdatedMessage;

  // ── Order List ────────────────────────────────────────────────────────────
  String get orderListTitle;
  String get orderListBack;
  String get orderListAddOrder;
  String get orderListEditStatus;
  String get orderListDelete;
  String get orderListRefresh;
  String get orderListFilterByStatus;
  String get orderListAll;
  String get orderListPending;
  String get orderListInProgress;
  String get orderListCompleted;
  String get orderListDelivered;
  String get orderListCustomer;
  String get orderListClothType;
  String get orderListPrice;
  String get orderListPaymentStatus;
  String get orderListPaymentMethod;
  String get orderListNoOrders;
  String get orderListStatus;
  String get orderListDate;
  String get orderListLoadError;
  String get orderListFilterError;
  String get orderListNoSelection;
  String get orderListEditStatusHeader;
  String get orderListNewStatus;
  String get orderListStatusUpdated;
  String get orderListConfirmDeleteHeader;
  String get orderListDeleteConfirmation;
  String get orderListOrderDeleted;

  // ── Orders (Create/Board) ─────────────────────────────────────────────────
  String get ordersTitle;
  String get ordersAdd;
  String get ordersRefresh;
  String get ordersSearch;
  String get ordersAll;
  String get ordersNoOrders;
  String get ordersNewOrder;
  String get ordersBasicInfo;
  String get ordersCustomerId;
  String get ordersClothType;
  String get ordersGender;
  String get ordersPrice;
  String get ordersMeasurements;
  String get ordersChest;
  String get ordersShoulder;
  String get ordersHip;
  String get ordersBreast;
  String get ordersWaist;
  String get ordersLength;
  String get ordersSleeve;
  String get ordersNeck;
  String get ordersUploadPhoto;
  String get ordersNoPhoto;
  String get ordersOrderDetails;
  String get ordersPriority;
  String get ordersUrgency;
  String get ordersDeliveryDate;
  String get ordersNotes;
  String get ordersCancel;
  String get ordersCreateOrder;
  String get ordersPleaseSelectCustomer;
  String get ordersErrorSaving;
  String get ordersRecordPayment;
  String get ordersPaymentAmount;
  String get ordersPaymentMethod;
  String get ordersPaymentReference;
  String get ordersSave;
  String get ordersBalance;
  String get ordersChangeStatus;
  String get ordersPaymentSection;
  String get ordersPaidAmount;
  String get ordersPaidAmountHint;
  String get ordersRemainingBalance;

  // ── Order Detail ──────────────────────────────────────────────────────────
  String get orderDetailSummary;
  String get orderDetailPayments;
  String get orderDetailTimeline;
  String get orderDetailAppointments;
  String get orderDetailMessages;
  String get orderDetailRefresh;
  String get orderDetailChangeStatus;
  String get orderDetailOrderNotFound;
  String get orderDetailRecordPayment;
  String get orderDetailAmount;
  String get orderDetailPaymentMethod;
  String get orderDetailReference;
  String get orderDetailCancel;
  String get orderDetailSave;
  String get orderDetailScheduleAppointment;
  String get orderDetailType;
  String get orderDetailNotes;
  String get orderDetailDate;
  String get orderDetailCustomer;
  String get orderDetailPhone;
  String get orderDetailStatus;
  String get orderDetailPriority;
  String get orderDetailUrgency;
  String get orderDetailDelivery;
  String get orderDetailTotal;
  String get orderDetailBalance;
  String get orderDetailItems;
  String get orderDetailNoPaymentsYet;
  String get orderDetailNoTimelineYet;
  String get orderDetailNoAppointments;
  String get orderDetailNoMessagesQueued;

  // ── Appointments ──────────────────────────────────────────────────────────
  String get appointmentScreenTitle;
  String get appointmentPickDayTooltip;
  String get appointmentNew;
  String get appointmentNoAppointments;
  String get appointmentDialogTitle;
  String get appointmentCustomerId;
  String get appointmentOrderIdOptional;
  String get appointmentType;
  String get appointmentScheduledTime;
  String get appointmentTitle;
  String get appointmentAdd;
  String get appointmentEdit;
  String get appointmentDate;
  String get appointmentTime;
  String get appointmentCustomer;
  String get appointmentNotes;
  String get appointmentSave;
  String get appointmentCancel;
  String get appointmentAddedMessage;
  String get appointmentUpdatedMessage;
  String get appointmentDetails;
  String get appointmentAdditionalNotes;

  // ── Inventory ─────────────────────────────────────────────────────────────
  String get inventoryTitle;
  String get inventoryAddItem;
  String get inventoryEditItem;
  String get inventoryName;
  String get inventoryQuantity;
  String get inventoryPrice;
  String get inventoryNotes;
  String get inventorySave;
  String get inventoryCancel;
  String get inventoryAddedMessage;
  String get inventoryUpdatedMessage;
  String get inventoryRefresh;
  String get inventoryNewItem;
  String get inventoryNoItems;
  String get inventoryDialogTitle;
  String get inventoryCategory;
  String get inventoryUnit;
  String get inventoryReorderLevel;

  // ── Measurements ──────────────────────────────────────────────────────────
  String get measurementsTitle;
  String get measurementsTemplates;
  String get measurementsCustomFields;
  String get measurementsClothTypes;
  String get measurementsSelectClothType;
  String get measurementsSelectTemplate;
  String get measurementsFields;
  String get measurementsAddCustomField;
  String get measurementsEditCustomField;
  String get measurementsFieldName;
  String get measurementsFieldNameHint;
  String get measurementsUnit;
  String get measurementsUnitHint;
  String get measurementsNoCustomFields;
  String get measurementsNoCustomFieldsHint;
  String get measurementsDeleteField;
  String get measurementsDeleteFieldConfirm;
  String get measurementsCustomFieldInfo;

  // ── Billing ───────────────────────────────────────────────────────────────
  String get billingTitle;
  String get billingBack;
  String get billingFrom;
  String get billingTo;
  String get billingFilter;
  String get billingTotalAmount;
  String get billingGenerateInvoice;
  String get billingMarkAsPaid;
  String get billingPrint;

  // ── Reports ───────────────────────────────────────────────────────────────
  String get reportsTitle;
  String get reportsBack;
  String get reportsRevenueReport;
  String get reportsCustomerAnalysis;
  String get reportsOrderTrends;

  // ── Financial Reports ─────────────────────────────────────────────────────
  String get financialReportsTitle;
  String get financialReportsNoData;
  String get financialReportsPaymentsByMethod;
  String get financialReportsPayments;
  String get financialReportsUnpaidBalances;

  // ── Notifications ─────────────────────────────────────────────────────────
  String get notificationsTitle;
  String get notificationsSendPending;
  String get notificationsRefresh;
  String get notificationsNoPending;

  // ── Staff ─────────────────────────────────────────────────────────────────
  String get staffTitle;
  String get staffAdd;
  String get staffRefresh;
  String get staffNoStaff;
  String get staffNewMember;
  String get staffFullName;
  String get staffRole;
  String get staffPhone;
  String get staffEmployeeCode;

  // ── Shop Settings ─────────────────────────────────────────────────────────
  String get shopSettingsTitle;
  String get shopSettingsSave;
  String get shopSettingsShopName;
  String get shopSettingsShopPhone;
  String get shopSettingsAddress;
  String get shopSettingsReceiptFooter;

  // ── Settings ──────────────────────────────────────────────────────────────
  String get settingsLanguage;
  String get settingsEnglish;
  String get settingsAmharic;
  String get settingsTheme;
  String get settingsAbout;
  String get settingsVersion;

  // ── License ───────────────────────────────────────────────────────────────
  String get licenseTitle;
  String get licenseTrial;
  String get licenseTrialDays;
  String get licenseTrialExpired;
  String get licenseActivate;
  String get licenseEnterKey;
  String get licenseActivateButton;
  String get licenseContinueTrial;
  String get licenseContact;
  String get licenseContactInfo;
  String get licenseInvalidKey;
  String get licenseActivationSuccess;
  String get licenseLicenseRequired;
  String get licenseYourDeviceId;
  String get licenseCopyDeviceId;
  String get licenseDeviceIdCopied;
  String get licenseShareDeviceId;
  String get licenseCompanyName;
  String get licenseCompanyNameHint;
  String get licenseFullLicense;
  String get licenseTrialVersion;
  String get licenseDaysRemaining;
  String get licenseStatus;
  String get licenseActive;
  String get licenseExpired;
  String get licenseDeviceMismatch;
  String get licenseType;
  String get licenseCompany;
  String get licenseDeviceId;

  // ── Common ────────────────────────────────────────────────────────────────
  String get commonSuccess;
  String get commonError;
  String get commonWarning;
  String get commonInfo;
  String get commonNoSelection;
  String get commonConfirmDelete;
  String get commonCancel;
  String get commonSave;
  String get commonDelete;
  String get commonEdit;
  String get commonAdd;
  String get commonClose;
  String get commonOk;
  String get commonYes;
  String get commonNo;
  String get commonBack;
  String get commonNext;
  String get commonPrevious;
  String get commonSubmit;
  String get commonRefresh;
  String get commonSearch;
  String get commonFilter;
  String get commonSort;
  String get commonExport;
  String get commonImport;
  String get commonPrint;
  String get commonDownload;
  String get commonUpload;
  String get commonSelectAll;
  String get commonDeselectAll;
  String get commonETB;

  // ── Form Validation ───────────────────────────────────────────────────────
  String get formRequired;
  String get formInvalidEmail;
  String get formInvalidPhone;
  String get formInvalidNumber;

  // ── Company ───────────────────────────────────────────────────────────────
  String get companyName;
  String get companyNameHint;

  // ── Business Contact ──────────────────────────────────────────────────────
  String get businessContactTitle;
  String get businessContactBody;
  String get businessPhone;
  String get businessEmail;
  String get businessTelegram;

  // ── New localized values ──────────────────────────────────────────────────
  String get genderMale;
  String get genderFemale;
  String get priorityLow;
  String get priorityNormal;
  String get priorityHigh;
  String get urgencyNormal;
  String get urgencyUrgent;
  String get urgencyExpress;
  String get paymentCash;
  String get paymentBank;
  String get paymentTelebirr;
  String get paymentCbeBirr;
  String get paymentChapa;
  String get paymentMobileMoney;
  String get recordPaymentTitle;
  String get paymentAmount;
  String get paymentMethod;
  String get paymentReference;
  String get orderCreatedSuccess;
  String get noCustomersFound;
  String get pleaseSelectCustomer;
  String get pleaseEnterValidCustomerId;

  // ── Monetization ─────────────────────────────────────────────────────────
  String get businessTelebirr;
  String get businessCbeBirr;
  String get pricingTitle;
  String get pricingBasic;
  String get pricingPro;
  String get pricingEnterprise;
  String get pricingBasicPrice;
  String get pricingProPrice;
  String get pricingEnterprisePrice;
  String get pricingBasicDesc;
  String get pricingProDesc;
  String get pricingEnterpriseDesc;
  String get pricingBuyNow;
  String get pricingPopular;
  String get paymentInstructionsTitle;
  String get paymentStep1;
  String get paymentStep2;
  String get paymentStep3;
  String get paymentStep4;
  String get paymentStep5;
  String get shareOnTelegram;
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
      <String>['am', 'en'].contains(locale.languageCode);

  @override
  bool shouldReload(_AppLocalizationsDelegate old) => false;
}

AppLocalizations lookupAppLocalizations(Locale locale) {
  switch (locale.languageCode) {
    case 'am':
      return AppLocalizationsAm();
    case 'en':
      return AppLocalizationsEn();
  }
  throw FlutterError(
      'AppLocalizations.delegate failed to load unsupported locale "$locale".');
}
