# Tailoring System - Complete Documentation

## Table of Contents
1. [System Overview](#system-overview)
2. [Architecture](#architecture)
3. [Database Schema](#database-schema)
4. [How the System Works](#how-the-system-works)
5. [Features](#features)
6. [Technologies Used](#technologies-used)
7. [File Structure](#file-structure)
8. [State Management](#state-management)
9. [Localization](#localization)
10. [Platform Support](#platform-support)

---

## System Overview

Tailoring System is a comprehensive Flutter-based business management application designed for tailoring businesses. It provides tools to manage customers, orders, measurements, payments, inventory, appointments, and more. The application runs on multiple platforms including Android, iOS, Windows, Web, and Linux.

**Key Capabilities:**
- Customer management with profiles and contact information
- Order tracking with status workflow
- Measurement templates and custom measurements
- Payment tracking and receipts
- Inventory management
- Appointment scheduling
- Staff management
- Financial reporting
- Multi-language support (English & Amharic)

---

## Architecture

### Application Flow

```
main.dart
  ↓
Initialize Flutter bindings
  ↓
Initialize database factory (platform-specific)
  ↓
Register Providers (State Management)
  ↓
Show SplashScreen
  ↓
AppInitializer (Initialize database, check license)
  ↓
Navigate to LicenseScreen OR ProductionShellScreen
  ↓
Main Application Interface
```

### Platform-Specific Database Initialization

The app uses different SQLite implementations based on the platform:

- **Web**: `sqflite_common_ffi_web` - SQLite through WebAssembly
- **Windows/Linux/macOS**: `sqflite_common_ffi` - SQLite via FFI
- **Android/iOS**: `sqflite` - Native SQLite

**Database Factory Initializers:**
- `lib/database/database_factory_initializer.dart` - Main entry point
- `lib/database/database_factory_initializer_io.dart` - Desktop platforms
- `lib/database/database_factory_initializer_web.dart` - Web platform
- `lib/database/database_factory_initializer_stub.dart` - Fallback

---

## Database Schema

### Database Version: 10
**Database File:** `tailoring.db`

### Core Tables

#### 1. customers
Stores customer information with soft-delete support.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key (auto-increment) |
| customerId | TEXT | Unique customer ID (e.g., CUS001) |
| customer_code | TEXT | Customer code for reference |
| name | TEXT | Customer name |
| full_name | TEXT | Full name (backfilled from name) |
| businessName | TEXT | Business name (if applicable) |
| gender | TEXT | Gender (male/female/other) |
| phone | TEXT | Primary phone number |
| secondary_phone | TEXT | Secondary phone number |
| email | TEXT | Email address |
| address | TEXT | Street address |
| city | TEXT | City |
| area | TEXT | Area/neighborhood |
| landmark | TEXT | Landmark for location |
| profile_photo_path | TEXT | Path to profile photo |
| category | TEXT | Customer category (regular/vip/wholesale) |
| preferred_language | TEXT | Language preference (en/am) |
| loyalty_points | INTEGER | Loyalty points balance |
| credit_limit | REAL | Credit limit amount |
| date | TEXT | Registration date |
| updated_at | TEXT | Last update timestamp |
| deleted_at | TEXT | Soft delete timestamp |
| is_active | INTEGER | Active status (1=active, 0=inactive) |
| notes | TEXT | Additional notes |

**Indexes:**
- `idx_customers_search` - For searching by code, name, phone, business
- `idx_customers_active` - For filtering active customers

---

#### 2. orders
Stores tailoring orders with payment and delivery tracking.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key (auto-increment) |
| order_number | TEXT | Unique order number (e.g., ORD001) |
| customerId | INTEGER | Foreign key to customers table |
| clothType | TEXT | Type of cloth (suit/dress/shirt/etc.) |
| price | REAL | Base price |
| deliveryDate | TEXT | Original delivery date |
| status | TEXT | Order status (pending/in_progress/ready/delivered) |
| priority | TEXT | Priority level (normal/high/urgent) |
| urgency_level | TEXT | Urgency level |
| expected_delivery_date | TEXT | Expected delivery date |
| actual_delivery_date | TEXT | Actual delivery date |
| fitting_date | TEXT | Fitting appointment date |
| assigned_staff_id | INTEGER | Assigned staff member ID |
| subtotal | REAL | Subtotal amount |
| discount_amount | REAL | Discount applied |
| tax_amount | REAL | Tax amount |
| total_amount | REAL | Total amount |
| paid_amount | REAL | Amount paid |
| balance_amount | REAL | Remaining balance |
| notes | TEXT | Customer notes |
| internal_notes | TEXT | Internal staff notes |
| createdAt | TEXT | Creation timestamp |
| updated_at | TEXT | Last update timestamp |
| deleted_at | TEXT | Soft delete timestamp |
| paymentMethod | TEXT | Payment method (cash/card/bank/etc.) |
| transactionId | TEXT | Transaction ID |
| paymentStatus | TEXT | Payment status (pending/partial/paid) |
| gender | TEXT | Customer gender |
| chest | REAL | Chest measurement |
| shoulder | REAL | Shoulder measurement |
| hip | REAL | Hip measurement |
| breast | REAL | Breast measurement |
| waist | REAL | Waist measurement |
| length | REAL | Length measurement |
| sleeve | REAL | Sleeve measurement |
| neck | REAL | Neck measurement |
| cloth_photo | TEXT | Path to cloth photo |

**Foreign Keys:**
- `customerId` → `customers(id)`

**Indexes:**
- `idx_orders_customer` - For filtering by customer
- `idx_orders_status` - For filtering by status
- `idx_orders_delivery` - For delivery date queries

---

#### 3. app_sequences
Manages auto-incrementing sequences for codes.

| Column | Type | Description |
|--------|------|-------------|
| key | TEXT | Sequence key (e.g., 'customer', 'order') |
| current_value | INTEGER | Current sequence value |
| updated_at | TEXT | Last update timestamp |

**Usage:** Generates sequential codes like CUS001, ORD001, etc.

---

#### 4. employees
Manages staff/employee information.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key (auto-increment) |
| employee_code | TEXT | Unique employee code |
| full_name | TEXT | Employee full name |
| phone | TEXT | Phone number |
| role | TEXT | Role (tailor/manager/admin) |
| is_active | INTEGER | Active status |
| created_at | TEXT | Creation timestamp |
| updated_at | TEXT | Last update timestamp |

---

#### 5. cloth_types
Defines available cloth types.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key (auto-increment) |
| name_key | TEXT | Localization key for name |
| default_name | TEXT | Default English name |
| is_active | INTEGER | Active status |
| sort_order | INTEGER | Display order |

**Pre-seeded Types:**
- Suit
- Dress
- Shirt
- Trouser
- Traditional Clothes
- Custom Clothes

---

#### 6. measurement_templates
Defines measurement templates for each cloth type.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key (auto-increment) |
| cloth_type_id | INTEGER | Foreign key to cloth_types |
| name | TEXT | Template name |
| is_default | INTEGER | Default template flag |
| is_active | INTEGER | Active status |
| created_at | TEXT | Creation timestamp |
| updated_at | TEXT | Last update timestamp |

**Foreign Keys:**
- `cloth_type_id` → `cloth_types(id)`

---

#### 7. measurement_fields
Defines individual measurement fields within templates.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key (auto-increment) |
| template_id | INTEGER | Foreign key to measurement_templates |
| field_key | TEXT | Field identifier |
| label_key | TEXT | Localization key for label |
| input_type | TEXT | Input type (number/text/select) |
| unit | TEXT | Unit of measurement (cm/inch) |
| is_required | INTEGER | Required field flag |
| sort_order | INTEGER | Display order |
| min_value | REAL | Minimum value |
| max_value | REAL | Maximum value |

**Foreign Keys:**
- `template_id` → `measurement_templates(id)`

---

#### 8. customer_measurements
Stores customer measurement records.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key (auto-increment) |
| customer_id | INTEGER | Foreign key to customers |
| template_id | INTEGER | Foreign key to measurement_templates |
| title | TEXT | Measurement title |
| measured_by_staff_id | INTEGER | Staff who took measurements |
| measured_at | TEXT | Measurement timestamp |
| notes | TEXT | Additional notes |

**Foreign Keys:**
- `customer_id` → `customers(id)`
- `template_id` → `measurement_templates(id)`
- `measured_by_staff_id` → `employees(id)`

---

#### 9. customer_measurement_values
Stores actual measurement values.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key (auto-increment) |
| measurement_id | INTEGER | Foreign key to customer_measurements |
| field_id | INTEGER | Foreign key to measurement_fields |
| value | REAL | Numeric measurement value |
| text_value | TEXT | Text measurement value |

**Foreign Keys:**
- `measurement_id` → `customer_measurements(id)`
- `field_id` → `measurement_fields(id)`

---

#### 10. order_items
Stores individual items within an order.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key (auto-increment) |
| order_id | INTEGER | Foreign key to orders |
| cloth_type_id | INTEGER | Foreign key to cloth_types |
| item_name | TEXT | Item name |
| style_name | TEXT | Style name |
| quantity | INTEGER | Quantity |
| unit_price | REAL | Unit price |
| total_price | REAL | Total price |
| notes | TEXT | Notes |
| created_at | TEXT | Creation timestamp |

**Foreign Keys:**
- `order_id` → `orders(id)`
- `cloth_type_id` → `cloth_types(id)`

---

#### 11. order_status_history
Tracks order status changes.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key (auto-increment) |
| order_id | INTEGER | Foreign key to orders |
| old_status | TEXT | Previous status |
| new_status | TEXT | New status |
| changed_by_employee_id | INTEGER | Staff who changed status |
| changed_at | TEXT | Change timestamp |
| notes | TEXT | Change notes |

**Foreign Keys:**
- `order_id` → `orders(id)`
- `changed_by_employee_id` → `employees(id)`

---

#### 12. payments
Stores payment records.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key (auto-increment) |
| payment_number | TEXT | Unique payment number |
| order_id | INTEGER | Foreign key to orders |
| customer_id | INTEGER | Foreign key to customers |
| amount | REAL | Payment amount |
| payment_method | TEXT | Payment method |
| payment_type | TEXT | Payment type (partial/full) |
| transaction_reference | TEXT | Transaction reference |
| receipt_number | TEXT | Receipt number |
| notes | TEXT | Notes |
| paid_at | TEXT | Payment timestamp |
| created_by_employee_id | INTEGER | Staff who recorded payment |

**Foreign Keys:**
- `order_id` → `orders(id)`
- `customer_id` → `customers(id)`
- `created_by_employee_id` → `employees(id)`

**Indexes:**
- `idx_payments_order` - For filtering by order
- `idx_payments_customer` - For filtering by customer

---

#### 13. refunds
Stores refund records.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key (auto-increment) |
| payment_id | INTEGER | Foreign key to payments |
| amount | REAL | Refund amount |
| reason | TEXT | Refund reason |
| refunded_at | TEXT | Refund timestamp |

**Foreign Keys:**
- `payment_id` → `payments(id)`

---

#### 14. appointments
Stores appointment records.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key (auto-increment) |
| customer_id | INTEGER | Foreign key to customers |
| order_id | INTEGER | Foreign key to orders |
| appointment_type | TEXT | Type (fitting/measurement/delivery) |
| scheduled_at | TEXT | Scheduled datetime |
| status | TEXT | Status (scheduled/completed/cancelled) |
| notes | TEXT | Notes |
| created_at | TEXT | Creation timestamp |

**Foreign Keys:**
- `customer_id` → `customers(id)`
- `order_id` → `orders(id)`

**Indexes:**
- `idx_appointments_day` - For daily appointment queries

---

#### 15. attachments
Stores file attachments (photos, documents).

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key (auto-increment) |
| owner_type | TEXT | Entity type (customer/order/measurement) |
| owner_id | INTEGER | Entity ID |
| file_path | TEXT | File path |
| file_type | TEXT | File type (image/document) |
| caption | TEXT | File caption |
| created_at | TEXT | Creation timestamp |

---

#### 16. notifications
Stores notification records for SMS/email.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key (auto-increment) |
| customer_id | INTEGER | Foreign key to customers |
| order_id | INTEGER | Foreign key to orders |
| channel | TEXT | Channel (sms/email/whatsapp) |
| recipient | TEXT | Recipient address |
| language_code | TEXT | Language code |
| template_key | TEXT | Message template key |
| message | TEXT | Message content |
| status | TEXT | Status (pending/sent/failed) |
| provider_message_id | TEXT | Provider message ID |
| error_message | TEXT | Error message if failed |
| scheduled_at | TEXT | Scheduled datetime |
| sent_at | TEXT | Sent datetime |
| created_at | TEXT | Creation timestamp |

**Foreign Keys:**
- `customer_id` → `customers(id)`
- `order_id` → `orders(id)`

**Indexes:**
- `idx_notifications_status` - For filtering by status

---

#### 17. inventory_items
Stores inventory items.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key (auto-increment) |
| item_code | TEXT | Unique item code |
| name | TEXT | Item name |
| category | TEXT | Category (fabric/thread/buttons/etc.) |
| unit | TEXT | Unit of measure (meter/piece) |
| quantity_on_hand | REAL | Current quantity |
| reorder_level | REAL | Reorder level |
| unit_cost | REAL | Unit cost |
| created_at | TEXT | Creation timestamp |
| updated_at | TEXT | Last update timestamp |

---

#### 18. inventory_movements
Tracks inventory movements (in/out).

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key (auto-increment) |
| inventory_item_id | INTEGER | Foreign key to inventory_items |
| movement_type | TEXT | Type (in/out/adjustment) |
| quantity | REAL | Quantity moved |
| unit_cost | REAL | Unit cost |
| reference_type | TEXT | Reference type (order/purchase) |
| reference_id | INTEGER | Reference ID |
| notes | TEXT | Notes |
| moved_at | TEXT | Movement timestamp |

**Foreign Keys:**
- `inventory_item_id` → `inventory_items(id)`

---

#### 19. expenses
Stores expense records.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key (auto-increment) |
| expense_number | TEXT | Unique expense number |
| category | TEXT | Expense category |
| amount | REAL | Expense amount |
| payment_method | TEXT | Payment method |
| description | TEXT | Description |
| expense_date | TEXT | Expense date |
| created_at | TEXT | Creation timestamp |

---

#### 20. audit_logs
Stores audit trail for all changes.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key (auto-increment) |
| entity_type | TEXT | Entity type (customer/order/etc.) |
| entity_id | INTEGER | Entity ID |
| action | TEXT | Action (create/update/delete) |
| old_value | TEXT | Old value (JSON) |
| new_value | TEXT | New value (JSON) |
| created_by_employee_id | INTEGER | Staff who made change |
| created_at | TEXT | Creation timestamp |

**Foreign Keys:**
- `created_by_employee_id` → `employees(id)`

---

#### 21. app_settings
Stores application settings.

| Column | Type | Description |
|--------|------|-------------|
| key | TEXT | Setting key (primary key) |
| value | TEXT | Setting value |
| updated_at | TEXT | Last update timestamp |

**Pre-seeded Settings:**
- `shop.default_language` = 'am'
- `shop.currency` = 'ETB'

---

#### 22. custom_measurement_fields
Stores tailor-defined custom measurement fields.

| Column | Type | Description |
|--------|------|-------------|
| id | INTEGER | Primary key (auto-increment) |
| label | TEXT | Field label |
| unit | TEXT | Unit of measurement |
| sort_order | INTEGER | Display order |
| created_at | TEXT | Creation timestamp |

---

## How the System Works

### 1. Application Startup

**Step 1: Initialization**
```dart
void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDatabaseFactory();  // Platform-specific DB init
  runApp(const TailoringSystemApp());
}
```

**Step 2: Provider Registration**
The app registers multiple providers using `MultiProvider`:
- `LanguageProvider` - Manages app language
- `CustomerProvider` - Manages customer state
- `OrderProvider` - Manages order state
- `DashboardProvider` - Dashboard statistics
- `AppointmentProvider` - Appointment management
- `ExpenseProvider` - Expense tracking
- `InventoryProvider` - Inventory management
- `MeasurementProvider` - Measurement records
- `NotificationProvider` - Notification handling
- `OrderBoardProvider` - Order board view
- `OrderDetailProvider` - Order details
- `OrderWorkflowProvider` - Order workflow
- `PaymentProvider` - Payment processing
- `ReceiptProvider` - Receipt generation
- `FinancialReportProvider` - Financial reports
- `AppSettingsProvider` - App settings
- `StaffProvider` - Staff management

**Step 3: Splash Screen**
Shows loading screen while initializing services.

**Step 4: App Initialization**
- Initializes database connection
- Checks license status
- Navigates to appropriate screen (License or Main App)

### 2. Customer Management Flow

**Creating a Customer:**
1. User enters customer details
2. `CustomerProvider.createCustomer()` called
3. `DatabaseHelper.createCustomer()` generates unique customer code (CUS001, CUS002, etc.)
4. Data inserted into `customers` table
5. Customer list refreshes automatically

**Searching Customers:**
- Searches across: customer code, name, business name, phone
- Uses SQL LIKE queries with wildcards
- Returns only active customers (is_active = 1)

**Soft Delete:**
- Customers are not actually deleted
- `is_active` set to 0
- `deleted_at` timestamp recorded
- Can be restored if needed

### 3. Order Management Flow

**Creating an Order:**
1. Select customer from list
2. Choose cloth type
3. Enter measurements (based on cloth type template)
4. Set price and delivery date
5. `OrderProvider.createOrder()` called
6. `DatabaseHelper.createOrder()` generates unique order number (ORD001, ORD002, etc.)
7. Order status history record created
8. Order added to `orders` table

**Order Status Workflow:**
- `pending` → `in_progress` → `ready` → `delivered`
- Each status change recorded in `order_status_history`
- Staff member who changed status is tracked

**Payment Tracking:**
- `paid_amount` tracks total payments
- `balance_amount` = `total_amount` - `paid_amount`
- `paymentStatus` = 'paid' when balance = 0

### 4. Measurement System

**Templates:**
- Each cloth type has default measurement template
- Templates define which measurements are required
- Example: Shirt template includes neck, shoulder, chest, waist, sleeve, wrist

**Recording Measurements:**
1. Select customer
2. Select measurement template based on cloth type
3. Enter measurement values
4. Values stored in `customer_measurements` and `customer_measurement_values`
5. Can be reused for future orders

**Custom Fields:**
- Tailors can add custom measurement fields
- Stored in `custom_measurement_fields` table
- Can be added to any template

### 5. Payment Processing

**Recording a Payment:**
1. Select order
2. Enter payment amount
3. Choose payment method (cash/card/bank/etc.)
4. Generate unique payment number
5. Update order's `paid_amount`
6. Create payment record in `payments` table
7. Generate receipt

**Refunds:**
- Linked to original payment
- Recorded in `refunds` table
- Updates order balance

### 6. Inventory Management

**Adding Items:**
1. Enter item details (name, category, unit)
2. Set initial quantity and cost
3. Item added to `inventory_items` table

**Tracking Movements:**
- Every quantity change recorded in `inventory_movements`
- Types: 'in' (purchase), 'out' (used in order), 'adjustment'
- Reference links to order or purchase

**Reorder Alerts:**
- When quantity_on_hand < reorder_level
- System can alert for reordering

### 7. Appointment System

**Scheduling:**
1. Select customer
2. Choose appointment type (fitting/measurement/delivery)
3. Set date and time
4. Appointment saved to `appointments` table

**Status Tracking:**
- `scheduled` → `completed` → `cancelled`
- Can link to specific order

### 8. Notifications

**Sending Notifications:**
1. Create notification record in `notifications` table
2. Set channel (SMS/email/WhatsApp)
3. Use template for message content
4. Status tracked: `pending` → `sent` or `failed`
5. Provider message ID stored for tracking

**Templates:**
- Pre-defined message templates
- Support for multiple languages
- Personalized with customer/order details

---

## Features

### Core Features

1. **Customer Management**
   - Add, edit, delete customers
   - Customer profiles with photos
   - Customer categories (regular, VIP, wholesale)
   - Loyalty points tracking
   - Credit limit management
   - Search and filter customers

2. **Order Management**
   - Create orders linked to customers
   - Order status tracking
   - Priority and urgency levels
   - Order history and status changes
   - Order notes (customer and internal)

3. **Measurement Management**
   - Pre-defined measurement templates
   - Custom measurement fields
   - Customer measurement history
   - Reuse measurements for new orders

4. **Payment Processing**
   - Record payments (partial/full)
   - Multiple payment methods
   - Payment history
   - Balance tracking
   - Refund processing
   - Receipt generation

5. **Inventory Management**
   - Track fabric and supplies
   - Inventory movements (in/out)
   - Reorder level alerts
   - Cost tracking

6. **Appointment Scheduling**
   - Schedule fittings and measurements
   - Delivery appointments
   - Appointment status tracking

7. **Staff Management**
   - Employee profiles
   - Role-based access
   - Staff assignment to orders

8. **Financial Reporting**
   - Revenue reports
   - Expense tracking
   - Profit/loss analysis
   - Payment summaries

9. **Notifications**
   - SMS notifications
   - Email notifications
   - WhatsApp integration (configurable)
   - Multi-language messages

10. **Settings**
    - Currency configuration
    - Language preferences
    - Shop information
    - Custom measurement fields

---

## Technologies Used

### Framework & Language
- **Flutter** - UI framework
- **Dart** - Programming language
- **SDK Version**: >=3.0.0 <4.0.0

### Database
- **SQLite** - Local database
- **sqflite** - SQLite plugin for Android/iOS
- **sqflite_common_ffi** - SQLite for desktop platforms
- **sqflite_common_ffi_web** - SQLite for web (WebAssembly)

### State Management
- **provider** - State management solution

### Storage
- **path_provider** - File system paths
- **shared_preferences** - Simple key-value storage
- **flutter_secure_storage** - Secure storage for sensitive data

### Localization
- **flutter_localizations** - Flutter localization
- **intl** - Internationalization utilities
- **flutter_intl** - Code generation for localization

### Image Handling
- **image_picker** - Camera and gallery image selection

### UI Components
- **Material Design 3** - Modern Material Design
- **cupertino_icons** - iOS-style icons

---

## File Structure

```
lib/
├── main.dart                          # App entry point
├── app/
│   └── production_shell_screen.dart   # Main app shell
├── core/
│   ├── database/
│   │   ├── app_sequence_repository.dart  # Sequence code generation
│   │   └── database_schema.dart         # Database schema definitions
│   └── ...
├── database/
│   ├── database_factory_initializer.dart      # Main DB factory init
│   ├── database_factory_initializer_io.dart   # Desktop DB init
│   ├── database_factory_initializer_web.dart  # Web DB init
│   └── database_factory_initializer_stub.dart # Fallback
├── l10n/
│   ├── app_localizations.dart          # Localization class
│   ├── app_en.arb                      # English translations
│   └── app_am.arb                      # Amharic translations
├── models/
│   ├── customer.dart                   # Customer model
│   └── order.dart                      # Order model
├── providers/
│   ├── language_provider.dart          # Language state
│   ├── customer_provider.dart          # Customer state
│   └── order_provider.dart             # Order state
├── screens/
│   ├── splash_screen.dart              # Loading screen
│   ├── license_screen.dart             # License activation
│   └── ...
├── utils/
│   └── database_helper.dart            # Database operations
└── features/
    ├── appointments/                   # Appointment feature
    ├── customers/                      # Customer feature
    ├── dashboard/                      # Dashboard feature
    ├── expenses/                       # Expense tracking
    ├── inventory/                      # Inventory management
    ├── measurements/                   # Measurement system
    ├── notifications/                  # Notification system
    ├── orders/                         # Order management
    ├── payments/                       # Payment processing
    ├── receipts/                       # Receipt generation
    ├── reports/                        # Financial reports
    ├── settings/                       # App settings
    └── staff/                          # Staff management
```

---

## State Management

The app uses the **Provider** package for state management. Each feature has its own provider that manages the state for that specific domain.

### Provider Hierarchy

```
MultiProvider
├── LanguageProvider
├── CustomerProvider
├── CustomerDirectoryProvider
├── CustomerProfileProvider
├── OrderProvider
├── OrderBoardProvider
├── OrderDetailProvider
├── AppointmentProvider
├── DashboardProvider
├── ExpenseProvider
├── InventoryProvider
├── MeasurementProvider
├── NotificationProvider
├── OrderWorkflowProvider
├── PaymentProvider
├── ReceiptProvider
├── FinancialReportProvider
├── AppSettingsProvider
└── StaffProvider
```

### State Flow

1. **UI Widget** calls provider method
2. **Provider** updates internal state
3. **Provider** notifies listeners
4. **UI Widget** rebuilds with new state
5. **Database** operations happen in provider

---

## Localization

The app supports multiple languages through Flutter's localization system.

### Supported Languages
- **English (en)** - Default
- **Amharic (am)** - Ethiopian language

### Localization Files
- `lib/l10n/app_en.arb` - English translations
- `lib/l10n/app_am.arb` - Amharic translations
- `lib/l10n/app_localizations.dart` - Generated localization class

### Usage in Code
```dart
// Get localized string
final localizations = AppLocalizations.of(context);
final text = localizations.customerName; // Returns name in current language
```

### Language Switching
- User can switch language in settings
- `LanguageProvider` manages current language
- All UI updates automatically when language changes

---

## Platform Support

### Android
- **Minimum SDK**: 23 (Android 6.0)
- **Target SDK**: Latest
- **Permissions**: Camera, Storage, Internet
- **Database**: Native SQLite via sqflite

### iOS
- **Minimum iOS**: iOS 12.0
- **Database**: Native SQLite via sqflite

### Windows
- **Database**: SQLite via sqflite_common_ffi
- **Storage**: Windows file system

### Web
- **Database**: SQLite via WebAssembly (sqlite3.wasm)
- **Renderer**: HTML (for offline support)
- **Storage**: Browser storage

### Linux
- **Database**: SQLite via sqflite_common_ffi
- **Storage**: Linux file system

### macOS
- **Database**: SQLite via sqflite_common_ffi
- **Storage**: macOS file system

---

## Database Operations

### Database Helper Methods

**Customer Operations:**
- `createCustomer(Customer)` - Create new customer
- `readCustomer(int id)` - Get customer by ID
- `readAllCustomers()` - Get all active customers
- `updateCustomer(Customer)` - Update customer
- `deleteCustomer(int id)` - Soft delete customer
- `searchCustomers(String term)` - Search customers

**Order Operations:**
- `createOrder(Order)` - Create new order
- `readOrder(int id)` - Get order by ID
- `readAllOrders()` - Get all orders
- `readOrdersByCustomer(int customerId)` - Get customer's orders
- `updateOrder(Order)` - Update order
- `deleteOrder(int id)` - Soft delete order

### Sequence Generation

The `AppSequenceRepository` generates sequential codes:

```dart
final sequence = AppSequenceRepository(db);
final customerCode = await sequence.nextCode(key: 'customer', prefix: 'CUS');
// Returns: CUS001, CUS002, CUS003, etc.
```

### Database Migration

When database version changes, migration runs automatically:

```dart
Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
  await DatabaseSchema.migrate(db, oldVersion, newVersion);
}
```

Migration safely adds columns using `addColumnIfMissing` to prevent errors.

---

## Security Features

### Data Protection
- **Soft Delete**: Records marked as deleted, not removed
- **Audit Trail**: All changes logged in `audit_logs` table
- **Foreign Keys**: Referential integrity enforced
- **Secure Storage**: Sensitive data in `flutter_secure_storage`

### License System
- Trial period support
- License activation required
- License validation on startup
- License status checked before app access

---

## Performance Optimizations

### Database Indexes
- Search fields indexed for fast queries
- Foreign key columns indexed
- Date fields indexed for range queries

### Lazy Loading
- Providers load data on demand
- Pagination for large lists
- Caching of frequently accessed data

### Efficient Queries
- Use of WHERE clauses to filter data
- LIMIT clauses for pagination
- JOIN queries optimized with indexes

---

## Error Handling

### Database Errors
- Try-catch blocks around all DB operations
- Graceful degradation if DB fails
- Error logging for debugging

### Initialization Errors
- Database initialization wrapped in try-catch
- License check errors handled
- App continues even if some services fail

### UI Errors
- Input validation before saving
- User-friendly error messages
- Recovery options for common errors

---

## Deployment

### Android APK
- **Release Build**: `flutter build apk --release`
- **Output**: `build/app/outputs/flutter-apk/app-release.apk`
- **Signing**: Debug keystore (for testing)
- **Production**: Requires release keystore for Play Store

### Web Build
- **Release Build**: `flutter build web --release`
- **Output**: `build/web/`
- **Hosting**: Can be hosted on any web server
- **Offline**: HTML renderer for offline support

### Windows Build
- **Release Build**: `flutter build windows --release`
- **Output**: `build/windows/runner/Release/`
- **Installer**: Can create MSI installer

---

## Troubleshooting

### Common Issues

**Database Not Initialized:**
- Ensure `initializeDatabaseFactory()` called before `runApp()`
- Check platform-specific initializer is correct

**Web CanvasKit Errors:**
- Use `--web-renderer html` flag for offline support
- HTML renderer works without CDN

**App Not Opening After Install:**
- Check `AndroidManifest.xml` permissions
- Ensure `usesCleartextTraffic="true"` for some operations
- Check for initialization errors in logs

**Build Time Too Long:**
- Enable Gradle daemon in `gradle.properties`
- Use `--no-tree-shake-icons` if icon tree-shaking causes issues
- Clear cache: `flutter clean`

---

## Future Enhancements

Potential improvements for the system:

1. **Cloud Sync** - Sync data across devices
2. **Online Payments** - Integrate payment gateways
3. **Barcode Scanning** - Scan fabric barcodes
4. **Advanced Reporting** - More detailed analytics
5. **Multi-Shop Support** - Manage multiple locations
6. **API Integration** - Connect to accounting software
7. **Mobile Printing** - Print receipts directly
8. **Voice Commands** - Voice input for measurements
9. **AI Recommendations** - Suggest cloth types based on measurements
10. **Customer Portal** - Web portal for customers to track orders

---

## Support & Maintenance

### Regular Maintenance Tasks
- Database backups
- Log file cleanup
- Performance monitoring
- Security updates
- Dependency updates

### Backup Strategy
- Export database regularly
- Backup customer photos
- Save configuration settings
- Keep version history

---

## License & Distribution

### Current Distribution
- Direct APK distribution
- Debug keystore signing
- "Unknown source" warning expected

### Production Distribution
- Google Play Store ($25 one-time fee)
- Requires release keystore
- App review process
- Automatic payment collection

### Business Model
- One-time purchase
- Subscription model (optional)
- Per-shop licensing
- Custom development available

---

## Conclusion

The Tailoring System is a comprehensive, cross-platform business management solution designed specifically for tailoring businesses. It provides all the essential tools needed to manage customers, orders, measurements, payments, inventory, and more. The system is built with modern Flutter technologies, uses a robust SQLite database, and supports multiple platforms and languages.

The modular architecture allows for easy expansion and customization, while the comprehensive database schema ensures data integrity and supports complex business operations. The system is production-ready and can be deployed immediately for business use.
