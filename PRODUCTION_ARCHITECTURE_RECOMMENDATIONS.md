# Production Architecture Recommendations

## Goal

Build the Tailoring Management System as a production-ready Flutter app for real tailoring shops in Ethiopia, supporting Web, Windows Desktop, Android, and iOS with offline-first SQLite storage, Provider state management, English/Amharic localization, printable receipts, order tracking, payments, and customer measurement history.

## 1. Customer Management

### Recommended Customer Fields

Required fields:

- `id`: local database primary key.
- `customer_code`: human-readable unique code, for example `CUS-2026-0001`.
- `full_name`: customer name.
- `phone`: main Ethiopian phone number, required for SMS.
- `created_at`: registration date.
- `updated_at`: last profile update.

Optional fields:

- `business_name`: useful for organizations, boutiques, schools, or uniform clients.
- `gender`: male, female, other, unknown.
- `email`: optional because many walk-in tailoring customers may not use email.
- `secondary_phone`: backup contact.
- `address`: city, sub-city, woreda, area, landmark.
- `profile_photo_path`: local image path or synced URL later.
- `category`: VIP, regular, wholesale, organization, inactive.
- `notes`: free-form tailoring notes.
- `preferred_language`: `en` or `am`.
- `favorite_styles`: free text or linked style records.
- `loyalty_points`: numeric points.
- `credit_limit`: optional limit for trusted customers.
- `is_active`: soft disable instead of deleting.

Remove or rename:

- Rename `customerId` to `customer_code` for clarity.
- Rename `date` or `registrationDate` to `created_at`.
- Avoid storing calculated values like total orders directly unless cached; compute from orders/payments or keep a summary table refreshed by app logic.

### Customer Features

- Customer profile with photo, contact, balance, open orders, completed orders, last visit, and total spend.
- Measurement history by cloth type and date.
- Visit history from orders, fittings, payments, and notes.
- Customer debt/balance from invoices and payments.
- VIP/regular categorization.
- Loyalty points from completed paid orders.
- Favorite styles and fabric preferences.
- Search by name, phone, customer code, business name, and notes.
- Fast duplicate detection by phone number.
- Customer timeline showing profile changes, orders, payments, fittings, and SMS messages.

### Customer UI

Desktop/tablet:

- Left side: searchable customer list with filters.
- Main area: selected customer profile, statistics, orders, measurements, payments, timeline.
- Top actions: new order, add measurement, record payment, send SMS, edit customer.

Mobile:

- Customer list screen with search and quick filters.
- Customer detail screen using tabs: Overview, Orders, Measurements, Payments, Timeline.
- Floating action button for primary action.

Recommended customer cards:

- Name, phone, customer code, category badge, balance status, active order count.

## 2. Order Management

### Recommended Order Fields

Required fields:

- `id`
- `order_number`: human-readable code, for example `ORD-20260525-0001`.
- `customer_id`
- `status`
- `priority`
- `created_at`
- `expected_delivery_date`
- `total_amount`
- `paid_amount`
- `balance_amount`

Optional fields:

- `cloth_type_id`
- `cloth_category_id`
- `style_name`
- `description`
- `fabric_id`
- `assigned_staff_id`
- `fitting_date`
- `actual_delivery_date`
- `urgency_level`
- `discount_amount`
- `tax_amount`
- `notes`
- `internal_notes`
- `delivery_method`
- `pickup_confirmed_at`
- `customer_signature_path`

### Professional Tailoring Workflow

Recommended order stages:

1. Draft
2. Confirmed
3. Measurement Taken
4. Cutting
5. Sewing
6. First Fitting
7. Adjustment
8. Final Pressing
9. Ready for Pickup
10. Delivered
11. Completed
12. Cancelled
13. Delayed

Keep `orders.status` as the current status, and store every status change in `order_status_history`.

### Order Number Generation

Use a deterministic local format:

```text
ORD-YYYYMMDD-#####
```

Example:

```text
ORD-20260525-00001
```

For multi-branch support later:

```text
AA-BR01-20260525-00001
```

Store the sequence in `app_sequences` to avoid duplicate numbers.

### Order Features

- Order timeline/history.
- Staff assignment by stage.
- Fitting appointments.
- Delivery tracking.
- Urgency levels: normal, urgent, express.
- Priority: low, normal, high.
- Attachments: customer reference images, style photos, fabric photos, sketches.
- Multiple garments under one order using `order_items`.
- Per-garment measurement snapshot so historical orders do not change when customer measurements are updated later.
- Automatic delay detection when expected delivery date passes.
- Ready/completed SMS notification.

### Order UI

Desktop/tablet:

- Kanban board by order stage.
- Order list with filters: status, due date, staff, unpaid, delayed, urgent.
- Order detail layout: summary, customer, garments, measurements, payments, timeline, attachments.

Mobile:

- Order list with status chips.
- Order detail tabs: Summary, Items, Measurements, Payments, Timeline.
- Quick actions: change status, add payment, call customer, send SMS.

## 3. Measurement System

### Architecture

Use templates instead of hard-coded measurement fields. Each cloth type can define its own measurement template.

Core idea:

- `measurement_templates`: Suit, Dress, Shirt, Trouser, Traditional Clothes, Custom.
- `measurement_fields`: fields inside a template, such as chest, waist, shoulder.
- `customer_measurements`: one measurement session for one customer and template.
- `customer_measurement_values`: actual values for each field.
- `order_measurement_snapshots`: copy used in a specific order.

This makes the system flexible when a tailor adds custom cloth types or measurements.

### Measurement Field Examples

Common fields:

- Height
- Weight
- Chest
- Waist
- Hip
- Shoulder
- Sleeve length
- Neck
- Arm round
- Wrist

Trouser fields:

- Waist
- Hip
- Thigh
- Knee
- Inseam
- Outseam
- Ankle
- Rise

Shirt fields:

- Neck
- Shoulder
- Chest
- Sleeve
- Wrist
- Shirt length

Suit fields:

- Jacket length
- Chest
- Waist
- Shoulder
- Sleeve
- Trouser waist
- Trouser length
- Inseam

Traditional clothes:

- Cloth-specific templates should be editable because Ethiopian traditional garments vary by region and shop practice.

### Measurement UI

- Template selector at top.
- Dynamic form generated from `measurement_fields`.
- Units: cm, inch, or shop default.
- Required fields marked clearly.
- Previous measurement comparison.
- Save as new measurement version.
- Print measurement sheet.
- Attach body/reference photos if needed.

Flutter implementation:

- `MeasurementTemplateProvider`
- `MeasurementFormProvider`
- Dynamic `Form` generated from field metadata.
- Use `TextEditingController` map keyed by `field_key`.
- Validate numeric fields using localized validation messages.

## 4. Scalable SQLite Database Design

Use normalized tables, soft deletes for important business records, timestamps on all tables, and status history tables for auditability.

### Core Tables

```sql
CREATE TABLE customers (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_code TEXT NOT NULL UNIQUE,
  full_name TEXT NOT NULL,
  business_name TEXT,
  gender TEXT,
  phone TEXT NOT NULL,
  secondary_phone TEXT,
  email TEXT,
  address TEXT,
  city TEXT,
  area TEXT,
  landmark TEXT,
  profile_photo_path TEXT,
  category TEXT NOT NULL DEFAULT 'regular',
  preferred_language TEXT NOT NULL DEFAULT 'am',
  loyalty_points INTEGER NOT NULL DEFAULT 0,
  credit_limit REAL NOT NULL DEFAULT 0,
  notes TEXT,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  deleted_at TEXT
);
```

```sql
CREATE TABLE orders (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_number TEXT NOT NULL UNIQUE,
  customer_id INTEGER NOT NULL,
  status TEXT NOT NULL,
  priority TEXT NOT NULL DEFAULT 'normal',
  urgency_level TEXT NOT NULL DEFAULT 'normal',
  expected_delivery_date TEXT,
  actual_delivery_date TEXT,
  fitting_date TEXT,
  assigned_staff_id INTEGER,
  subtotal REAL NOT NULL DEFAULT 0,
  discount_amount REAL NOT NULL DEFAULT 0,
  tax_amount REAL NOT NULL DEFAULT 0,
  total_amount REAL NOT NULL DEFAULT 0,
  paid_amount REAL NOT NULL DEFAULT 0,
  balance_amount REAL NOT NULL DEFAULT 0,
  notes TEXT,
  internal_notes TEXT,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  deleted_at TEXT,
  FOREIGN KEY (customer_id) REFERENCES customers(id),
  FOREIGN KEY (assigned_staff_id) REFERENCES employees(id)
);
```

```sql
CREATE TABLE order_items (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  order_id INTEGER NOT NULL,
  cloth_type_id INTEGER,
  item_name TEXT NOT NULL,
  style_name TEXT,
  quantity INTEGER NOT NULL DEFAULT 1,
  unit_price REAL NOT NULL DEFAULT 0,
  total_price REAL NOT NULL DEFAULT 0,
  notes TEXT,
  created_at TEXT NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (cloth_type_id) REFERENCES cloth_types(id)
);
```

### Measurement Tables

```sql
CREATE TABLE cloth_types (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  name_key TEXT NOT NULL,
  default_name TEXT NOT NULL,
  is_active INTEGER NOT NULL DEFAULT 1
);
```

```sql
CREATE TABLE measurement_templates (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  cloth_type_id INTEGER NOT NULL,
  name TEXT NOT NULL,
  is_default INTEGER NOT NULL DEFAULT 0,
  is_active INTEGER NOT NULL DEFAULT 1,
  created_at TEXT NOT NULL,
  updated_at TEXT NOT NULL,
  FOREIGN KEY (cloth_type_id) REFERENCES cloth_types(id)
);
```

```sql
CREATE TABLE measurement_fields (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  template_id INTEGER NOT NULL,
  field_key TEXT NOT NULL,
  label_key TEXT NOT NULL,
  input_type TEXT NOT NULL DEFAULT 'number',
  unit TEXT NOT NULL DEFAULT 'cm',
  is_required INTEGER NOT NULL DEFAULT 0,
  sort_order INTEGER NOT NULL DEFAULT 0,
  min_value REAL,
  max_value REAL,
  FOREIGN KEY (template_id) REFERENCES measurement_templates(id)
);
```

```sql
CREATE TABLE customer_measurements (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  customer_id INTEGER NOT NULL,
  template_id INTEGER NOT NULL,
  title TEXT,
  measured_by_staff_id INTEGER,
  measured_at TEXT NOT NULL,
  notes TEXT,
  FOREIGN KEY (customer_id) REFERENCES customers(id),
  FOREIGN KEY (template_id) REFERENCES measurement_templates(id),
  FOREIGN KEY (measured_by_staff_id) REFERENCES employees(id)
);
```

```sql
CREATE TABLE customer_measurement_values (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  measurement_id INTEGER NOT NULL,
  field_id INTEGER NOT NULL,
  value REAL,
  text_value TEXT,
  FOREIGN KEY (measurement_id) REFERENCES customer_measurements(id),
  FOREIGN KEY (field_id) REFERENCES measurement_fields(id)
);
```

### Payment And Finance Tables

```sql
CREATE TABLE payments (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  payment_number TEXT NOT NULL UNIQUE,
  order_id INTEGER NOT NULL,
  customer_id INTEGER NOT NULL,
  amount REAL NOT NULL,
  payment_method TEXT NOT NULL,
  payment_type TEXT NOT NULL,
  transaction_reference TEXT,
  receipt_number TEXT,
  notes TEXT,
  paid_at TEXT NOT NULL,
  created_by_employee_id INTEGER,
  FOREIGN KEY (order_id) REFERENCES orders(id),
  FOREIGN KEY (customer_id) REFERENCES customers(id),
  FOREIGN KEY (created_by_employee_id) REFERENCES employees(id)
);
```

```sql
CREATE TABLE refunds (
  id INTEGER PRIMARY KEY AUTOINCREMENT,
  payment_id INTEGER NOT NULL,
  amount REAL NOT NULL,
  reason TEXT,
  refunded_at TEXT NOT NULL,
  FOREIGN KEY (payment_id) REFERENCES payments(id)
);
```

### Operational Tables

- `employees`: shop users and staff.
- `roles`: admin, cashier, tailor, cutter, manager.
- `order_status_history`: status changes with timestamp and staff.
- `appointments`: fitting and pickup appointments.
- `attachments`: image/file references for customers, orders, and measurements.
- `inventory_items`: fabric, buttons, zippers, thread.
- `inventory_movements`: stock in/out/adjustment.
- `expenses`: rent, salary, utility, transport, materials.
- `notifications`: queued/sent SMS, WhatsApp, email.
- `audit_logs`: important data changes.
- `app_settings`: shop name, address, phone, receipt footer, default language.
- `app_sequences`: order/customer/payment number counters.
- `subscriptions`: only if the app will be licensed or sold as SaaS.

## 5. Transaction And Payment System

### Payment Features

- Partial payment.
- Advance payment.
- Full payment.
- Refund.
- Payment correction with audit log.
- Balance tracking per order and customer.
- Receipt generation.
- PDF invoice.
- Daily/monthly financial dashboard.
- Cashier report.

### Payment Methods

Recommended enum values:

- `cash`
- `bank_transfer`
- `telebirr`
- `cbe_birr`
- `chapa`
- `mobile_money`
- `card`
- `other`

### Invoice Logic

For each order:

```text
subtotal - discount + tax = total_amount
total_amount - sum(payments) + sum(refunds) = balance_amount
```

Do not trust manually entered `paid_amount`; recalculate after each payment. You may cache `paid_amount` and `balance_amount` in `orders` for fast UI, but update them through one repository method only.

### Payment Gateway Recommendation

Keep online payment integration behind an interface:

```dart
abstract class PaymentGateway {
  Future<PaymentInitResult> initializePayment(PaymentRequest request);
  Future<PaymentVerificationResult> verifyPayment(String transactionId);
}
```

Recommended Ethiopia-focused payment options to evaluate:

- Chapa: Ethiopian payment gateway with developer APIs and support for local payment methods.
- ArifPay: Ethiopian payment provider/payment gateway option.
- Bank transfer/manual reference entry for shops that do not need online checkout.

Current public sources show Chapa provides developer APIs and Ethiopian payment gateway services, while third-party payment listings describe Chapa as supporting Telebirr, CBE Birr, Amole, and local banks. ArifPay also presents itself as an Ethiopian payment provider/payment gateway. Verify contract terms, settlement time, fees, and production API access before implementation.

## 6. SMS And Notifications

### Notification Triggers

Send notifications when:

- Order is confirmed.
- Fitting appointment is scheduled.
- Order is delayed.
- Order is ready for pickup.
- Order is delivered.
- Payment is received.
- Balance remains unpaid.

### SMS Architecture

Do not send SMS directly from UI widgets.

Use:

- `NotificationService`
- `SmsGateway`
- `NotificationRepository`
- `notifications` table
- Retry queue with delivery status

Flow:

```text
Order status changes
  -> create notification record
  -> NotificationService sends through SmsGateway
  -> save provider response and delivery status
```

Recommended SMS status values:

- pending
- sent
- delivered
- failed
- cancelled

### Ethiopia SMS Providers To Evaluate

Current public options include:

- SMSEthiopia: Ethiopia-focused REST API for SMS, OTP, 2FA, and bulk messages.
- send.et: Ethiopia-focused SMS API, OTP, sender names, webhooks, and delivery reporting.
- AfroMessage: Ethiopia SMS provider with REST API.
- Africala: SMS, Voice, and WhatsApp APIs for Ethiopia.
- Beem Africa: broader African SMS, OTP, USSD, WhatsApp, and payment APIs.

Selection criteria:

- Ethiopian number delivery reliability.
- Sender name support.
- Amharic SMS support.
- Delivery reports and webhooks.
- OTP support.
- Cost per SMS.
- Local compliance/KYB requirements.
- API documentation quality.

### SMS Templates

English:

```text
Hello {customer_name}, your order {order_number} is ready for pickup. Balance: {balance} ETB. {shop_name}
```

Amharic:

```text
ሰላም {customer_name}, ትዕዛዝዎ {order_number} ለመውሰድ ዝግጁ ሆኗል። ቀሪ ክፍያ፦ {balance} ብር። {shop_name}
```

Use customer preferred language. Keep SMS short because Amharic Unicode messages reduce SMS segment length.

### Background Strategy

Flutter apps are not reliable as always-running background servers, especially on mobile and web. For production SMS automation:

- Local-only app: queue notifications and send when app is open.
- Better production option: add a small backend service later for SMS/payment webhooks.
- For Windows shop desktop use: a background sync worker can run while the app is open.

## 7. Amharic Localization

### Localization Architecture

Use Flutter ARB files:

- `app_en.arb`
- `app_am.arb`

Localize:

- UI labels.
- Validation messages.
- Status names.
- Measurement labels.
- Receipt text.
- SMS templates.
- Report labels.
- Error messages.

Do not store translated labels as only one language in the database. Store stable keys:

```text
measurement.chest
order.status.ready
payment.method.telebirr
```

Then translate keys in ARB files.

### RTL/LTR

Amharic is written left-to-right, so the app does not need RTL layout for Amharic. Still keep layout direction dynamic in case Arabic or another RTL language is added later.

### Translation Management

- Centralize enums and translation keys.
- Avoid hard-coded strings in widgets.
- Add a localization review checklist before release.
- Store customer preferred language for notifications and receipts.

## 8. Modern UI/UX Improvements

### Design Direction

The app should feel like a professional shop operations tool, not a landing page.

Use:

- Clear dashboard.
- Dense but readable tables.
- Status chips.
- Search-first layouts.
- Fast actions.
- Responsive master-detail layouts on desktop.
- Bottom navigation or navigation rail on mobile/tablet.

### Main Navigation

Recommended modules:

- Dashboard
- Customers
- Orders
- Measurements
- Payments
- Appointments
- Inventory
- Expenses
- Reports
- Settings

### Dashboard

Show:

- Today’s due orders.
- Delayed orders.
- Ready for pickup.
- Unpaid balances.
- Today’s payments.
- Monthly revenue.
- Top customers.
- Staff workload.

### Order Board

Use a stage board:

- Confirmed
- Cutting
- Sewing
- Fitting
- Ready
- Delivered

Desktop can use Kanban. Mobile should use filter chips and a list.

### Forms

Use step-based forms:

New order:

1. Select or create customer.
2. Add garments/items.
3. Add measurements.
4. Set fitting/delivery dates.
5. Add payment.
6. Confirm and print receipt.

### Responsive Layout

Breakpoints:

- Phone: single-column screens.
- Tablet: navigation rail plus content.
- Desktop/web: sidebar plus master-detail.

## 9. Flutter Architecture

### Recommended Folder Structure

```text
lib/
  app/
    app.dart
    routes.dart
    theme.dart
  core/
    constants/
    database/
    errors/
    localization/
    utils/
  features/
    customers/
      data/
      models/
      providers/
      screens/
      widgets/
    orders/
    measurements/
    payments/
    notifications/
    inventory/
    reports/
    settings/
```

### Layering

Use:

- Model: plain data objects.
- Repository: database operations.
- Provider: screen/business state.
- Service: cross-cutting workflows like SMS, PDF, payment gateway.
- UI: widgets only.

Avoid:

- Calling `DatabaseHelper` directly from widgets.
- Business logic inside screens.
- Hard-coded strings.
- Large single database helper with every query forever.

### Provider Strategy

Keep Provider, but organize by feature:

- `CustomerProvider`
- `OrderProvider`
- `MeasurementProvider`
- `PaymentProvider`
- `DashboardProvider`
- `SettingsProvider`

Each provider calls repositories, not raw SQLite.

### Database Migration

Add a migration system:

- Keep database version in one file.
- Add migration functions per version.
- Never drop business tables in production upgrades unless intentionally resetting demo data.

## 10. Reports

Recommended reports:

- Daily sales.
- Monthly sales.
- Unpaid balances.
- Completed orders.
- Delayed orders.
- Customer order history.
- Staff productivity.
- Expense report.
- Profit estimate.
- Inventory usage.

Export formats:

- PDF
- CSV
- Printable receipt/invoice

## 11. Implementation Roadmap

### Phase 1: Stabilize Core

- Refactor database initialization.
- Add repositories.
- Improve customer/order models.
- Add safe migrations.
- Add customer and order search.
- Add payment table and partial payment logic.

### Phase 2: Tailoring Workflow

- Add cloth types.
- Add measurement templates.
- Add dynamic measurement forms.
- Add order items.
- Add order status history.
- Add fitting appointments.

### Phase 3: Production UI

- Redesign dashboard.
- Redesign customer profile.
- Add order board.
- Add responsive desktop layouts.
- Add printable receipts.

### Phase 4: Notifications And Finance

- Add SMS notification queue.
- Integrate selected SMS provider.
- Add payment reports.
- Add PDF invoices.
- Add expenses.

### Phase 5: Advanced Shop Operations

- Inventory/fabric management.
- Staff assignment and performance.
- Loyalty system.
- Multi-branch support.
- Backup/export/import.
- Optional backend sync.

## 12. Sources Checked For Ethiopia Integrations

- SMSEthiopia: https://smsethiopia.com/
- send.et: https://send.et/
- AfroMessage: https://afromessage.com/
- Africala: https://africala.net/et/
- Beem Africa APIs: https://beem.africa/beem-api/
- Chapa developer documentation: https://developer.chapa.co/guide
- Chapa website: https://chapa.co/
- ArifPay website: https://arifpay.net/

