import 'package:sqflite/sqflite.dart';

class DatabaseSchema {
  static const int version = 8;

  static Future<void> createAll(Database db) async {
    await _createCustomers(db);
    await _createOrders(db);
    await _createProductionTables(db);
    await _createIndexes(db);
    await _seedDefaults(db);
  }

  static Future<void> migrate(
      Database db, int oldVersion, int newVersion) async {
    // Always ensure production tables exist (safe - uses IF NOT EXISTS)
    await _createProductionTables(db);
    await _createIndexes(db);

    if (oldVersion < 5) {
      // Only create tables if they don't exist (safe migration)
      await _createCustomers(db);
      await _createOrders(db);
      await _addColumnIfMissing(db, 'customers', 'customer_code', 'TEXT');
      await _addColumnIfMissing(db, 'customers', 'full_name', 'TEXT');
      await _addColumnIfMissing(db, 'customers', 'gender', 'TEXT');
      await _addColumnIfMissing(db, 'customers', 'secondary_phone', 'TEXT');
      await _addColumnIfMissing(db, 'customers', 'address', 'TEXT');
      await _addColumnIfMissing(db, 'customers', 'city', 'TEXT');
      await _addColumnIfMissing(db, 'customers', 'area', 'TEXT');
      await _addColumnIfMissing(db, 'customers', 'landmark', 'TEXT');
      await _addColumnIfMissing(db, 'customers', 'profile_photo_path', 'TEXT');
      await _addColumnIfMissing(
          db, 'customers', 'category', "TEXT NOT NULL DEFAULT 'regular'");
      await _addColumnIfMissing(
          db, 'customers', 'preferred_language', "TEXT NOT NULL DEFAULT 'am'");
      await _addColumnIfMissing(
          db, 'customers', 'loyalty_points', 'INTEGER NOT NULL DEFAULT 0');
      await _addColumnIfMissing(
          db, 'customers', 'credit_limit', 'REAL NOT NULL DEFAULT 0');
      await _addColumnIfMissing(db, 'customers', 'updated_at', 'TEXT');
      await _addColumnIfMissing(db, 'customers', 'deleted_at', 'TEXT');
      await _addColumnIfMissing(
          db, 'customers', 'is_active', 'INTEGER NOT NULL DEFAULT 1');

      await _addColumnIfMissing(db, 'orders', 'order_number', 'TEXT');
      await _addColumnIfMissing(
          db, 'orders', 'priority', "TEXT NOT NULL DEFAULT 'normal'");
      await _addColumnIfMissing(
          db, 'orders', 'urgency_level', "TEXT NOT NULL DEFAULT 'normal'");
      await _addColumnIfMissing(db, 'orders', 'expected_delivery_date', 'TEXT');
      await _addColumnIfMissing(db, 'orders', 'actual_delivery_date', 'TEXT');
      await _addColumnIfMissing(db, 'orders', 'fitting_date', 'TEXT');
      await _addColumnIfMissing(db, 'orders', 'assigned_staff_id', 'INTEGER');
      await _addColumnIfMissing(
          db, 'orders', 'subtotal', 'REAL NOT NULL DEFAULT 0');
      await _addColumnIfMissing(
          db, 'orders', 'discount_amount', 'REAL NOT NULL DEFAULT 0');
      await _addColumnIfMissing(
          db, 'orders', 'tax_amount', 'REAL NOT NULL DEFAULT 0');
      await _addColumnIfMissing(
          db, 'orders', 'total_amount', 'REAL NOT NULL DEFAULT 0');
      await _addColumnIfMissing(
          db, 'orders', 'paid_amount', 'REAL NOT NULL DEFAULT 0');
      await _addColumnIfMissing(
          db, 'orders', 'balance_amount', 'REAL NOT NULL DEFAULT 0');
      await _addColumnIfMissing(db, 'orders', 'internal_notes', 'TEXT');
      await _addColumnIfMissing(db, 'orders', 'updated_at', 'TEXT');
      await _addColumnIfMissing(db, 'orders', 'deleted_at', 'TEXT');

      await _backfillProductionColumns(db);
      await _seedDefaults(db);
    }
    if (oldVersion < 6) {
      // Add measurement fields and cloth photo to orders table (safe)
      await _addColumnIfMissing(db, 'orders', 'gender', 'TEXT');
      await _addColumnIfMissing(db, 'orders', 'chest', 'REAL');
      await _addColumnIfMissing(db, 'orders', 'shoulder', 'REAL');
      await _addColumnIfMissing(db, 'orders', 'hip', 'REAL');
      await _addColumnIfMissing(db, 'orders', 'breast', 'REAL');
      await _addColumnIfMissing(db, 'orders', 'waist', 'REAL');
      await _addColumnIfMissing(db, 'orders', 'length', 'REAL');
      await _addColumnIfMissing(db, 'orders', 'sleeve', 'REAL');
      await _addColumnIfMissing(db, 'orders', 'neck', 'REAL');
      await _addColumnIfMissing(db, 'orders', 'cloth_photo', 'TEXT');
    }
    if (oldVersion < 8) {
      // Ensure all measurement columns exist in orders table (safe migration)
      await _addColumnIfMissing(db, 'orders', 'gender', 'TEXT');
      await _addColumnIfMissing(db, 'orders', 'chest', 'REAL');
      await _addColumnIfMissing(db, 'orders', 'shoulder', 'REAL');
      await _addColumnIfMissing(db, 'orders', 'hip', 'REAL');
      await _addColumnIfMissing(db, 'orders', 'breast', 'REAL');
      await _addColumnIfMissing(db, 'orders', 'waist', 'REAL');
      await _addColumnIfMissing(db, 'orders', 'length', 'REAL');
      await _addColumnIfMissing(db, 'orders', 'sleeve', 'REAL');
      await _addColumnIfMissing(db, 'orders', 'neck', 'REAL');
      await _addColumnIfMissing(db, 'orders', 'cloth_photo', 'TEXT');
    }
  }

  static Future<void> _createCustomers(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS customers (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customerId TEXT NOT NULL,
        customer_code TEXT,
        name TEXT NOT NULL,
        full_name TEXT,
        businessName TEXT,
        gender TEXT,
        phone TEXT,
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
        date TEXT NOT NULL,
        updated_at TEXT,
        deleted_at TEXT,
        is_active INTEGER NOT NULL DEFAULT 1,
        notes TEXT
      )
    ''');
  }

  static Future<void> _createOrders(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS orders (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_number TEXT,
        customerId INTEGER,
        clothType TEXT NOT NULL,
        price REAL NOT NULL,
        deliveryDate TEXT,
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
        createdAt TEXT NOT NULL,
        updated_at TEXT,
        deleted_at TEXT,
        paymentMethod TEXT,
        transactionId TEXT,
        paymentStatus TEXT,
        gender TEXT,
        chest REAL,
        shoulder REAL,
        hip REAL,
        breast REAL,
        waist REAL,
        length REAL,
        sleeve REAL,
        neck REAL,
        cloth_photo TEXT,
        FOREIGN KEY (customerId) REFERENCES customers (id)
      )
    ''');
  }

  static Future<void> _createProductionTables(Database db) async {
    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_sequences (
        key TEXT PRIMARY KEY,
        current_value INTEGER NOT NULL DEFAULT 0,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS employees (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        employee_code TEXT UNIQUE,
        full_name TEXT NOT NULL,
        phone TEXT,
        role TEXT NOT NULL DEFAULT 'tailor',
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS cloth_types (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        name_key TEXT NOT NULL UNIQUE,
        default_name TEXT NOT NULL,
        is_active INTEGER NOT NULL DEFAULT 1,
        sort_order INTEGER NOT NULL DEFAULT 0
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS measurement_templates (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        cloth_type_id INTEGER NOT NULL,
        name TEXT NOT NULL,
        is_default INTEGER NOT NULL DEFAULT 0,
        is_active INTEGER NOT NULL DEFAULT 1,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL,
        FOREIGN KEY (cloth_type_id) REFERENCES cloth_types(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS measurement_fields (
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
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS customer_measurements (
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
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS customer_measurement_values (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        measurement_id INTEGER NOT NULL,
        field_id INTEGER NOT NULL,
        value REAL,
        text_value TEXT,
        FOREIGN KEY (measurement_id) REFERENCES customer_measurements(id),
        FOREIGN KEY (field_id) REFERENCES measurement_fields(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS order_items (
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
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS order_status_history (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        order_id INTEGER NOT NULL,
        old_status TEXT,
        new_status TEXT NOT NULL,
        changed_by_employee_id INTEGER,
        changed_at TEXT NOT NULL,
        notes TEXT,
        FOREIGN KEY (order_id) REFERENCES orders(id),
        FOREIGN KEY (changed_by_employee_id) REFERENCES employees(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS payments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        payment_number TEXT NOT NULL UNIQUE,
        order_id INTEGER NOT NULL,
        customer_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        payment_method TEXT NOT NULL,
        payment_type TEXT NOT NULL DEFAULT 'partial',
        transaction_reference TEXT,
        receipt_number TEXT,
        notes TEXT,
        paid_at TEXT NOT NULL,
        created_by_employee_id INTEGER,
        FOREIGN KEY (order_id) REFERENCES orders(id),
        FOREIGN KEY (customer_id) REFERENCES customers(id),
        FOREIGN KEY (created_by_employee_id) REFERENCES employees(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS refunds (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        payment_id INTEGER NOT NULL,
        amount REAL NOT NULL,
        reason TEXT,
        refunded_at TEXT NOT NULL,
        FOREIGN KEY (payment_id) REFERENCES payments(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS appointments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER NOT NULL,
        order_id INTEGER,
        appointment_type TEXT NOT NULL,
        scheduled_at TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'scheduled',
        notes TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers(id),
        FOREIGN KEY (order_id) REFERENCES orders(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS attachments (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        owner_type TEXT NOT NULL,
        owner_id INTEGER NOT NULL,
        file_path TEXT NOT NULL,
        file_type TEXT,
        caption TEXT,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS notifications (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        customer_id INTEGER,
        order_id INTEGER,
        channel TEXT NOT NULL,
        recipient TEXT NOT NULL,
        language_code TEXT NOT NULL DEFAULT 'am',
        template_key TEXT NOT NULL,
        message TEXT NOT NULL,
        status TEXT NOT NULL DEFAULT 'pending',
        provider_message_id TEXT,
        error_message TEXT,
        scheduled_at TEXT,
        sent_at TEXT,
        created_at TEXT NOT NULL,
        FOREIGN KEY (customer_id) REFERENCES customers(id),
        FOREIGN KEY (order_id) REFERENCES orders(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS inventory_items (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        item_code TEXT UNIQUE,
        name TEXT NOT NULL,
        category TEXT NOT NULL DEFAULT 'fabric',
        unit TEXT NOT NULL DEFAULT 'meter',
        quantity_on_hand REAL NOT NULL DEFAULT 0,
        reorder_level REAL NOT NULL DEFAULT 0,
        unit_cost REAL NOT NULL DEFAULT 0,
        created_at TEXT NOT NULL,
        updated_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS inventory_movements (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        inventory_item_id INTEGER NOT NULL,
        movement_type TEXT NOT NULL,
        quantity REAL NOT NULL,
        unit_cost REAL NOT NULL DEFAULT 0,
        reference_type TEXT,
        reference_id INTEGER,
        notes TEXT,
        moved_at TEXT NOT NULL,
        FOREIGN KEY (inventory_item_id) REFERENCES inventory_items(id)
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS expenses (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        expense_number TEXT UNIQUE,
        category TEXT NOT NULL,
        amount REAL NOT NULL,
        payment_method TEXT,
        description TEXT,
        expense_date TEXT NOT NULL,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS audit_logs (
        id INTEGER PRIMARY KEY AUTOINCREMENT,
        entity_type TEXT NOT NULL,
        entity_id INTEGER,
        action TEXT NOT NULL,
        old_value TEXT,
        new_value TEXT,
        created_by_employee_id INTEGER,
        created_at TEXT NOT NULL
      )
    ''');

    await db.execute('''
      CREATE TABLE IF NOT EXISTS app_settings (
        key TEXT PRIMARY KEY,
        value TEXT,
        updated_at TEXT NOT NULL
      )
    ''');
  }

  static Future<void> _seedDefaults(Database db) async {
    final now = DateTime.now().toIso8601String();
    final clothTypes = <Map<String, Object?>>[
      {'name_key': 'cloth.suit', 'default_name': 'Suit', 'sort_order': 1},
      {'name_key': 'cloth.dress', 'default_name': 'Dress', 'sort_order': 2},
      {'name_key': 'cloth.shirt', 'default_name': 'Shirt', 'sort_order': 3},
      {'name_key': 'cloth.trouser', 'default_name': 'Trouser', 'sort_order': 4},
      {
        'name_key': 'cloth.traditional',
        'default_name': 'Traditional Clothes',
        'sort_order': 5
      },
      {
        'name_key': 'cloth.custom',
        'default_name': 'Custom Clothes',
        'sort_order': 6
      },
    ];

    for (final clothType in clothTypes) {
      await db.insert('cloth_types', clothType,
          conflictAlgorithm: ConflictAlgorithm.ignore);
    }

    await _seedMeasurementTemplate(
        db,
        'cloth.shirt',
        'Shirt Measurements',
        [
          'neck',
          'shoulder',
          'chest',
          'waist',
          'sleeve',
          'wrist',
          'shirt_length',
        ],
        now);
    await _seedMeasurementTemplate(
        db,
        'cloth.trouser',
        'Trouser Measurements',
        [
          'waist',
          'hip',
          'thigh',
          'knee',
          'inseam',
          'outseam',
          'ankle',
          'rise',
        ],
        now);
    await _seedMeasurementTemplate(
        db,
        'cloth.suit',
        'Suit Measurements',
        [
          'height',
          'shoulder',
          'chest',
          'waist',
          'jacket_length',
          'sleeve',
          'neck',
          'trouser_waist',
          'trouser_length',
          'inseam',
        ],
        now);
    await _seedMeasurementTemplate(
        db,
        'cloth.dress',
        'Dress Measurements',
        [
          'height',
          'shoulder',
          'chest',
          'waist',
          'hip',
          'dress_length',
          'sleeve',
          'arm_round',
        ],
        now);
    await _seedMeasurementTemplate(
        db,
        'cloth.traditional',
        'Traditional Measurements',
        [
          'height',
          'shoulder',
          'chest',
          'waist',
          'hip',
          'sleeve',
          'cloth_length',
        ],
        now);

    await db.insert(
      'app_settings',
      {'key': 'shop.default_language', 'value': 'am', 'updated_at': now},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
    await db.insert(
      'app_settings',
      {'key': 'shop.currency', 'value': 'ETB', 'updated_at': now},
      conflictAlgorithm: ConflictAlgorithm.ignore,
    );
  }

  static Future<void> _createIndexes(Database db) async {
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_customers_search ON customers(customer_code, name, phone, businessName)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_customers_active ON customers(is_active, deleted_at)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_orders_customer ON orders(customerId)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_orders_delivery ON orders(expected_delivery_date, deliveryDate)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_payments_order ON payments(order_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_payments_customer ON payments(customer_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_notifications_status ON notifications(status, channel)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_measurements_customer ON customer_measurements(customer_id)',
    );
    await db.execute(
      'CREATE INDEX IF NOT EXISTS idx_appointments_day ON appointments(scheduled_at)',
    );
  }

  static Future<void> _seedMeasurementTemplate(
    Database db,
    String clothTypeKey,
    String templateName,
    List<String> fieldKeys,
    String now,
  ) async {
    final clothTypes = await db.query(
      'cloth_types',
      columns: ['id'],
      where: 'name_key = ?',
      whereArgs: [clothTypeKey],
      limit: 1,
    );
    if (clothTypes.isEmpty) return;

    final clothTypeId = clothTypes.first['id'] as int;
    final existing = await db.query(
      'measurement_templates',
      columns: ['id'],
      where: 'cloth_type_id = ? AND is_default = 1',
      whereArgs: [clothTypeId],
      limit: 1,
    );
    if (existing.isNotEmpty) return;

    final templateId = await db.insert('measurement_templates', {
      'cloth_type_id': clothTypeId,
      'name': templateName,
      'is_default': 1,
      'is_active': 1,
      'created_at': now,
      'updated_at': now,
    });

    for (var index = 0; index < fieldKeys.length; index++) {
      final fieldKey = fieldKeys[index];
      await db.insert('measurement_fields', {
        'template_id': templateId,
        'field_key': fieldKey,
        'label_key': 'measurement.$fieldKey',
        'input_type': 'number',
        'unit': 'cm',
        'is_required': 0,
        'sort_order': index,
      });
    }
  }

  static Future<void> _backfillProductionColumns(Database db) async {
    final now = DateTime.now().toIso8601String();
    await db.execute(
        "UPDATE customers SET customer_code = customerId WHERE customer_code IS NULL");
    await db.execute(
        "UPDATE customers SET full_name = name WHERE full_name IS NULL");
    await db.execute(
        "UPDATE customers SET updated_at = date WHERE updated_at IS NULL");
    await db.execute(
        "UPDATE orders SET expected_delivery_date = deliveryDate WHERE expected_delivery_date IS NULL");
    await db.execute("UPDATE orders SET subtotal = price WHERE subtotal = 0");
    await db.execute(
        "UPDATE orders SET total_amount = price WHERE total_amount = 0");
    await db.execute(
        "UPDATE orders SET balance_amount = price WHERE balance_amount = 0");
    await db.execute(
        "UPDATE orders SET updated_at = createdAt WHERE updated_at IS NULL");
    await db.execute(
        "UPDATE app_sequences SET updated_at = '$now' WHERE updated_at IS NULL");
  }

  static Future<void> _addColumnIfMissing(
    Database db,
    String table,
    String column,
    String definition,
  ) async {
    final columns = await db.rawQuery('PRAGMA table_info($table)');
    final exists = columns.any((row) => row['name'] == column);
    if (!exists) {
      await db.execute('ALTER TABLE $table ADD COLUMN $column $definition');
    }
  }
}
