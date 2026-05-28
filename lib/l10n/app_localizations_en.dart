// ignore: unused_import
import 'package:intl/intl.dart' as intl;
import 'app_localizations.dart';

// ignore_for_file: type=lint

/// The translations for English (`en`).
class AppLocalizationsEn extends AppLocalizations {
  AppLocalizationsEn([String locale = 'en']) : super(locale);

  @override
  String get appTitle => 'Tailoring Management System';

  @override
  String get appSubtitle => 'Professional Tailoring Business Management';

  @override
  String get menuDashboard => 'Dashboard';

  @override
  String get menuCustomers => 'Customers';

  @override
  String get menuOrders => 'Orders';

  @override
  String get menuAddCustomer => 'Add Customer';

  @override
  String get menuAddOrder => 'Add Order';

  @override
  String get menuReports => 'Reports';

  @override
  String get menuBilling => 'Billing';

  @override
  String get menuExit => 'Exit';

  @override
  String get menuAppointments => 'Appointments';

  @override
  String get menuInventory => 'Inventory';

  @override
  String get menuNotifications => 'Notifications';

  @override
  String get menuStaff => 'Staff';

  @override
  String get menuSettings => 'Settings';

  @override
  String get menuMore => 'More';

  @override
  String get dashboardTitle => 'Dashboard';

  @override
  String get dashboardBackToMain => 'Back to Main Menu';

  @override
  String get dashboardTotalCustomers => 'Total Customers';

  @override
  String get dashboardTotalOrders => 'Total Orders';

  @override
  String get dashboardPendingOrders => 'Pending Orders';

  @override
  String get dashboardCompletedOrders => 'Completed Orders';

  @override
  String get dashboardTotalRevenue => 'Total Revenue';

  @override
  String get dashboardBusinessOverview => 'Business Overview';

  @override
  String get dashboardOrdersByStatus => 'Orders by Status';

  @override
  String get dashboardStatus => 'Status';

  @override
  String get dashboardCount => 'Count';

  @override
  String get dashboardOrders => 'Orders';

  @override
  String get dashboardRevenueSummary => 'Revenue Summary';

  @override
  String get dashboardTotalRevenueCompleted => 'Total Revenue from Completed Orders';

  @override
  String get dashboardManageCustomers => 'Manage Customers';

  @override
  String get dashboardManageOrders => 'Manage Orders';

  @override
  String get dashboardAddNewCustomer => 'Add New Customer';

  @override
  String get dashboardAddNewOrder => 'Add New Order';

  @override
  String get customerFormTitle => 'Add New Customer';

  @override
  String get customerFormBack => 'Back';

  @override
  String get customerFormSaveCustomer => 'Save Customer';

  @override
  String get customerFormCancel => 'Cancel';

  @override
  String get customerFormName => 'Name';

  @override
  String get customerFormPhone => 'Phone';

  @override
  String get customerFormChest => 'Chest';

  @override
  String get customerFormWaist => 'Waist';

  @override
  String get customerFormLength => 'Length';

  @override
  String get customerFormNameRequired => 'Name is required';

  @override
  String get customerFormMeasurementsValid => 'Measurements must be valid numbers';

  @override
  String get customerFormSuccess => 'Customer saved successfully';

  @override
  String get customerFormDelete => 'Delete';

  @override
  String get customerFormRefresh => 'Refresh';

  @override
  String get customerListTitle => 'Customer List';

  @override
  String get customerListSearch => 'Search customers';

  @override
  String get customerListBack => 'Back';

  @override
  String get customerListAddCustomer => 'Add Customer';

  @override
  String get customerListEdit => 'Edit';

  @override
  String get customerListDelete => 'Delete';

  @override
  String get customerListRefresh => 'Refresh';

  @override
  String get customerListNoSelection => 'No customer selected';

  @override
  String get customerListConfirmDelete => 'Confirm Delete';

  @override
  String get customerListDeleteMessage => 'Are you sure you want to delete this customer';

  @override
  String get alertWarning => 'Warning';

  @override
  String get alertError => 'Error';

  @override
  String get alertInformation => 'Information';

  @override
  String get alertSuccess => 'Success';

  @override
  String get orderFormTitle => 'Add New Order';

  @override
  String get orderFormBack => 'Back';

  @override
  String get orderFormSaveOrder => 'Save Order';

  @override
  String get orderFormCancel => 'Cancel';

  @override
  String get orderFormSelectCustomer => 'Select Customer';

  @override
  String get orderFormClothType => 'Cloth Type';

  @override
  String get orderFormPrice => 'Price';

  @override
  String get orderFormDeliveryDate => 'Delivery Date';

  @override
  String get orderFormStatus => 'Status';

  @override
  String get orderListTitle => 'Order Management';

  @override
  String get orderListBack => 'Back';

  @override
  String get orderListAddOrder => 'Add Order';

  @override
  String get orderListEditStatus => 'Edit Status';

  @override
  String get orderListDelete => 'Delete';

  @override
  String get orderListRefresh => 'Refresh';

  @override
  String get orderListFilterByStatus => 'Filter by Status';

  @override
  String get orderListAll => 'All';

  @override
  String get orderListPending => 'Pending';

  @override
  String get orderListInProgress => 'In Progress';

  @override
  String get orderListCompleted => 'Completed';

  @override
  String get orderListDelivered => 'Delivered';

  @override
  String get orderListCustomer => 'Customer';

  @override
  String get orderListClothType => 'Cloth Type';

  @override
  String get orderListPrice => 'Price';

  @override
  String get orderListStatus => 'Status';

  @override
  String get orderListDate => 'Date';

  @override
  String get orderListLoadError => 'Failed to load orders';

  @override
  String get orderListFilterError => 'Filter error';

  @override
  String get orderListNoSelection => 'Please select an order';

  @override
  String get orderListEditStatusHeader => 'Edit Order Status';

  @override
  String get orderListNewStatus => 'New Status';

  @override
  String get orderListStatusUpdated => 'Status updated';

  @override
  String get orderListConfirmDeleteHeader => 'Delete Order Confirmation';

  @override
  String get orderListDeleteConfirmation => 'Are you sure you want to delete this order';

  @override
  String get orderListOrderDeleted => 'Order deleted';

  @override
  String get billingTitle => 'Billing & Invoicing';

  @override
  String get billingBack => 'Back';

  @override
  String get billingFrom => 'From';

  @override
  String get billingTo => 'To';

  @override
  String get billingFilter => 'Filter';

  @override
  String get billingTotalAmount => 'Total Amount';

  @override
  String get billingGenerateInvoice => 'Generate Invoice';

  @override
  String get billingMarkAsPaid => 'Mark as Paid';

  @override
  String get billingPrint => 'Print';

  @override
  String get reportsTitle => 'Business Reports';

  @override
  String get reportsBack => 'Back to Main Menu';

  @override
  String get reportsRevenueReport => 'Revenue Report';

  @override
  String get reportsCustomerAnalysis => 'Customer Analysis';

  @override
  String get reportsOrderTrends => 'Order Trends';

  @override
  String get commonSuccess => 'Success';

  @override
  String get commonError => 'Error';

  @override
  String get commonWarning => 'Warning';

  @override
  String get commonInfo => 'Information';

  @override
  String get commonNoSelection => 'Please select an item to proceed';

  @override
  String get commonConfirmDelete => 'Are you sure you want to delete this item';

  @override
  String get licenseTitle => 'License';

  @override
  String get licenseTrial => 'Trial Version';

  @override
  String get licenseTrialDays => 'Days Remaining';

  @override
  String get licenseTrialExpired => 'Trial Expired';

  @override
  String get licenseActivate => 'Activate License';

  @override
  String get licenseEnterKey => 'Enter License Key';

  @override
  String get licenseActivateButton => 'Activate';

  @override
  String get licenseContinueTrial => 'Continue Trial';

  @override
  String get licenseContact => 'Need a license? Contact us';

  @override
  String get licenseContactInfo => 'Email: your-email@example.com\nPhone: +XXX-XXX-XXX';

  @override
  String get licenseInvalidKey => 'Invalid license key';

  @override
  String get licenseActivationSuccess => 'License activated successfully';

  @override
  String get licenseLicenseRequired => 'License required to use this application';

  @override
  String get companyName => 'Company Name';

  @override
  String get companyNameHint => 'Enter your tailoring business name';

  @override
  String get staffTitle => 'Staff';

  @override
  String get staffAdd => 'Staff';

  @override
  String get staffRefresh => 'Refresh';

  @override
  String get staffNoStaff => 'No staff registered';

  @override
  String get staffNewMember => 'New Staff Member';

  @override
  String get staffFullName => 'Full Name';

  @override
  String get staffRole => 'Role';

  @override
  String get staffPhone => 'Phone';

  @override
  String get staffEmployeeCode => 'Employee Code';

  @override
  String get financialReportsTitle => 'Financial Reports';

  @override
  String get financialReportsNoData => 'No report data';

  @override
  String get financialReportsPaymentsByMethod => 'Payments By Method';

  @override
  String get financialReportsPayments => 'payments';

  @override
  String get financialReportsUnpaidBalances => 'Unpaid Balances';

  @override
  String get shopSettingsTitle => 'Shop Settings';

  @override
  String get shopSettingsSave => 'Save Settings';

  @override
  String get shopSettingsShopName => 'Shop name';

  @override
  String get shopSettingsShopPhone => 'Shop phone';

  @override
  String get shopSettingsAddress => 'Address';

  @override
  String get shopSettingsReceiptFooter => 'Receipt footer';

  @override
  String get ordersTitle => 'Orders';

  @override
  String get ordersAdd => 'Order';

  @override
  String get ordersRefresh => 'Refresh';

  @override
  String get ordersSearch => 'Search order, customer, phone, cloth';

  @override
  String get ordersAll => 'All';

  @override
  String get ordersNoOrders => 'No orders found';

  @override
  String get ordersNewOrder => 'New Order';

  @override
  String get ordersBasicInfo => 'Basic Information';

  @override
  String get ordersCustomerId => 'Customer ID';

  @override
  String get ordersClothType => 'Cloth type';

  @override
  String get ordersGender => 'Gender';

  @override
  String get ordersPrice => 'Price (ETB)';

  @override
  String get ordersMeasurements => 'Measurements (cm)';

  @override
  String get ordersChest => 'Chest';

  @override
  String get ordersShoulder => 'Shoulder';

  @override
  String get ordersHip => 'Hip';

  @override
  String get ordersBreast => 'Breast';

  @override
  String get ordersWaist => 'Waist';

  @override
  String get ordersLength => 'Length';

  @override
  String get ordersSleeve => 'Sleeve';

  @override
  String get ordersNeck => 'Neck';

  @override
  String get ordersUploadPhoto => 'Upload cloth photo';

  @override
  String get ordersNoPhoto => 'No photo selected';

  @override
  String get ordersOrderDetails => 'Order Details';

  @override
  String get ordersPriority => 'Priority';

  @override
  String get ordersUrgency => 'Urgency';

  @override
  String get ordersDeliveryDate => 'Delivery date';

  @override
  String get ordersNotes => 'Notes';

  @override
  String get ordersCancel => 'Cancel';

  @override
  String get ordersCreateOrder => 'Create Order';

  @override
  String get ordersPleaseSelectCustomer => 'Please select a customer';

  @override
  String get ordersErrorSaving => 'Error saving order';

  @override
  String get ordersRecordPayment => 'Record Payment';

  @override
  String get ordersPaymentAmount => 'Amount';

  @override
  String get ordersPaymentMethod => 'Payment method';

  @override
  String get ordersPaymentReference => 'Reference / transaction ID';

  @override
  String get ordersSave => 'Save';

  @override
  String get ordersBalance => 'Balance';

  @override
  String get ordersChangeStatus => 'Change status';

  @override
  String get customerListId => 'ID';

  @override
  String get customerListPhone => 'Phone';

  @override
  String get customerListEmail => 'Email';

  @override
  String get customersNewCustomer => 'New Customer';

  @override
  String get customersFullName => 'Full Name';

  @override
  String get customersPhone => 'Phone';

  @override
  String get customersBusinessName => 'Business name';

  @override
  String get customersAddress => 'Address';

  @override
  String get customersCategory => 'Category';

  @override
  String get customersLanguage => 'Language';

  @override
  String get customersNotes => 'Notes';

  @override
  String get customersRegular => 'Regular';

  @override
  String get customersVIP => 'VIP';

  @override
  String get customersOrganization => 'Organization';

  @override
  String get customersAmharic => 'Amharic';

  @override
  String get customersEnglish => 'English';

  @override
  String get customersCancel => 'Cancel';

  @override
  String get customersCreateCustomer => 'Create Customer';

  @override
  String get customersEditCustomer => 'Edit Customer';

  @override
  String get customersSaveChanges => 'Save Changes';

  @override
  String get notificationsTitle => 'Notifications';

  @override
  String get notificationsSendPending => 'Send Pending';

  @override
  String get notificationsRefresh => 'Refresh';

  @override
  String get notificationsNoPending => 'No pending notifications';

  @override
  String get ordersPaymentSection => 'Payment Information';

  @override
  String get ordersPaidAmount => 'Paid Amount';

  @override
  String get ordersPaidAmountHint => 'Enter amount paid upfront';

  @override
  String get ordersRemainingBalance => 'Remaining Balance';

  @override
  String get orderDetailSummary => 'Summary';

  @override
  String get orderDetailPayments => 'Payments';

  @override
  String get orderDetailTimeline => 'Timeline';

  @override
  String get orderDetailAppointments => 'Appointments';

  @override
  String get orderDetailMessages => 'Messages';

  @override
  String get orderDetailRefresh => 'Refresh';

  @override
  String get orderDetailChangeStatus => 'Change status';

  @override
  String get orderDetailOrderNotFound => 'Order not found';

  @override
  String get orderDetailRecordPayment => 'Record Payment';

  @override
  String get orderDetailAmount => 'Amount';

  @override
  String get orderDetailPaymentMethod => 'Payment method';

  @override
  String get orderDetailReference => 'Reference';

  @override
  String get orderDetailCancel => 'Cancel';

  @override
  String get orderDetailSave => 'Save';

  @override
  String get orderDetailScheduleAppointment => 'Schedule Appointment';

  @override
  String get orderDetailType => 'Type';

  @override
  String get orderDetailNotes => 'Notes';

  @override
  String get orderDetailDate => 'Date';

  @override
  String get orderDetailCustomer => 'Customer';

  @override
  String get orderDetailPhone => 'Phone';

  @override
  String get orderDetailStatus => 'Status';

  @override
  String get orderDetailPriority => 'Priority';

  @override
  String get orderDetailUrgency => 'Urgency';

  @override
  String get orderDetailDelivery => 'Delivery';

  @override
  String get orderDetailTotal => 'Total';

  @override
  String get orderDetailBalance => 'Balance';

  @override
  String get orderDetailItems => 'Items';

  @override
  String get orderDetailNoPaymentsYet => 'No payments yet';

  @override
  String get orderDetailNoTimelineYet => 'No timeline yet';

  @override
  String get orderDetailNoAppointments => 'No appointments';

  @override
  String get orderDetailNoMessagesQueued => 'No messages queued';
}
