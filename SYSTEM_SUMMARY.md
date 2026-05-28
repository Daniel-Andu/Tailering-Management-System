# Tailoring System Summary

## Overview

Tailoring System is a Flutter application for managing a tailoring business. It is designed to run across platforms, including web, Windows desktop, and mobile targets. The app starts with a splash screen, initializes app services, then opens the main home screen.

## How The System Works

1. The app starts from `lib/main.dart`.
2. Flutter bindings are initialized before the UI loads.
3. The database factory is initialized based on the platform:
   - Web uses SQLite through `sqflite_common_ffi_web`.
   - Windows, Linux, and macOS use `sqflite_common_ffi`.
   - Android and iOS use the normal `sqflite` backend.
4. Providers are registered with `MultiProvider`:
   - `LanguageProvider`
   - `CustomerProvider`
   - `OrderProvider`
5. The app shows `SplashScreen` first.
6. `AppInitializer` waits briefly, then opens `HomeScreen`.
7. Customer and order data is stored in a local SQLite database named `tailoring.db`.

## Main Functionalities

### Customer Management

The system supports customer records with:

- Customer ID
- Customer name
- Business name
- Phone number
- Email
- Registration date
- Notes

Supported customer operations:

- Add new customer
- View all customers
- Search customers by customer ID or name
- View one customer by ID
- Update customer details
- Delete customer records

### Order Management

The system supports tailoring order records with:

- Linked customer ID
- Cloth type
- Price
- Delivery date
- Order status
- Notes
- Created date
- Payment method
- Transaction ID
- Payment status

Supported order operations:

- Add new order
- View all orders
- View one order by ID
- View orders for a specific customer
- Update order details
- Delete order records

### Local Database

The app uses SQLite tables:

- `customers`
- `orders`

The `orders` table links to customers using `customerId`.

Database access is handled by:

- `lib/utils/database_helper.dart`

Platform database initialization is handled by:

- `lib/database/database_factory_initializer.dart`
- `lib/database/database_factory_initializer_io.dart`
- `lib/database/database_factory_initializer_web.dart`
- `lib/database/database_factory_initializer_stub.dart`

### Language Support

The app includes localization support for:

- English (`en`)
- Amharic (`am`)

Localization is configured with Flutter localization delegates and app-generated localization files.

### State Management

The app uses the `provider` package for state management.

Main providers:

- `LanguageProvider`: controls selected app language.
- `CustomerProvider`: manages customer loading and customer state.
- `OrderProvider`: manages order loading and order state.

### Web Support

For Chrome and other web targets, the app uses SQLite through WebAssembly.

Required web database file:

- `web/sqlite3.wasm`

The app is configured to use no-worker mode on web, so it does not require `sqflite_sw.js`.

## Current Startup Flow

```text
main()
  -> initializeDatabaseFactory()
  -> runApp(TailoringSystemApp)
  -> register providers
  -> show SplashScreen
  -> navigate to HomeScreen
```

## Notes

- The previous web error `databaseFactory not initialized` was fixed by initializing the database factory before the app starts.
- The previous web error about missing `sqflite_sw.js` was avoided by switching web SQLite to no-worker mode.
- The Flutter web lifecycle channel warning is a debug warning and is not the main database issue.

