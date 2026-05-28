import 'package:flutter/foundation.dart';
import 'package:path/path.dart';
import 'package:sqflite/sqflite.dart';
import 'package:tailoring_system/core/database/app_sequence_repository.dart';
import 'package:tailoring_system/core/database/database_schema.dart';
import 'package:tailoring_system/models/customer.dart';
import 'package:tailoring_system/models/order.dart';

class DatabaseHelper {
  static final DatabaseHelper instance = DatabaseHelper._init();
  static Database? _database;

  DatabaseHelper._init();

  Future<Database> get database async {
    if (_database != null) {
      print('Returning existing database instance');
      return _database!;
    }
    print('Initializing new database');
    _database = await _initDB('tailoring.db');
    return _database!;
  }

  Future<Database> _initDB(String filePath) async {
    if (kIsWeb) {
      // On web, use in-memory database
      return await openDatabase(
        filePath,
        version: DatabaseSchema.version,
        onCreate: _createDB,
        onUpgrade: _onUpgrade,
        onConfigure: _onConfigure,
      );
    } else {
      final dbPath = await getDatabasesPath();
      final path = join(dbPath, filePath);
      return await openDatabase(path,
          version: DatabaseSchema.version,
          onCreate: _createDB,
          onUpgrade: _onUpgrade,
          onConfigure: _onConfigure);
    }
  }

  Future _onConfigure(Database db) async {
    // Enable foreign keys
    await db.execute('PRAGMA foreign_keys = ON');
  }

  Future _createDB(Database db, int version) async {
    print('Creating new database with version $version');
    await DatabaseSchema.createAll(db);
  }

  Future _onUpgrade(Database db, int oldVersion, int newVersion) async {
    print('Upgrading database from version $oldVersion to $newVersion');
    await DatabaseSchema.migrate(db, oldVersion, newVersion);
  }

  // Customer operations
  Future<int> createCustomer(Customer customer) async {
    final db = await instance.database;
    final values = Map<String, Object?>.from(customer.toMap());
    final sequence = AppSequenceRepository(db);
    final customerCode =
        values['customerId']?.toString().trim().isNotEmpty == true
            ? values['customerId'].toString()
            : await sequence.nextCode(key: 'customer', prefix: 'CUS');
    final now = DateTime.now().toIso8601String();

    values['customerId'] = customerCode;
    values['customer_code'] = customerCode;
    values['full_name'] = values['name'];
    values['updated_at'] = now;
    values['is_active'] = 1;

    return await db.insert('customers', values);
  }

  Future<Customer> readCustomer(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'customers',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Customer.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Customer>> readAllCustomers() async {
    final db = await instance.database;
    const orderBy = 'date DESC';
    final result = await db.query(
      'customers',
      where: 'COALESCE(is_active, 1) = 1',
      orderBy: orderBy,
    );
    return result.map((json) => Customer.fromMap(json)).toList();
  }

  Future<int> updateCustomer(Customer customer) async {
    final db = await instance.database;
    final values = Map<String, Object?>.from(customer.toMap());
    values['customer_code'] = values['customerId'];
    values['full_name'] = values['name'];
    values['updated_at'] = DateTime.now().toIso8601String();
    return db.update(
      'customers',
      values,
      where: 'id = ?',
      whereArgs: [customer.id],
    );
  }

  Future<int> deleteCustomer(int id) async {
    final db = await instance.database;
    return await db.update(
      'customers',
      {
        'is_active': 0,
        'deleted_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future<List<Customer>> searchCustomers(String searchTerm) async {
    final db = await instance.database;
    final result = await db.query(
      'customers',
      where: '''
        is_active = 1 AND (
          customerId LIKE ?
          OR customer_code LIKE ?
          OR name LIKE ?
          OR full_name LIKE ?
          OR businessName LIKE ?
          OR phone LIKE ?
          OR secondary_phone LIKE ?
        )
      ''',
      whereArgs: [
        '%$searchTerm%',
        '%$searchTerm%',
        '%$searchTerm%',
        '%$searchTerm%',
        '%$searchTerm%',
        '%$searchTerm%',
        '%$searchTerm%',
      ],
      orderBy: 'date DESC',
    );
    return result.map((json) => Customer.fromMap(json)).toList();
  }

  // Order operations
  Future<int> createOrder(Order order) async {
    final db = await instance.database;
    final values = Map<String, Object?>.from(order.toMap());
    final sequence = AppSequenceRepository(db);
    final orderNumber = await sequence.nextCode(key: 'order', prefix: 'ORD');
    final price = ((values['price'] as num?)?.toDouble()) ?? 0;
    final deliveryDate = values['deliveryDate'];
    final now = DateTime.now().toIso8601String();

    values['order_number'] = orderNumber;
    values['priority'] = 'normal';
    values['urgency_level'] = 'normal';
    values['expected_delivery_date'] = deliveryDate;
    values['subtotal'] = price;
    values['total_amount'] = price;
    values['paid_amount'] = values['paymentStatus'] == 'paid' ? price : 0;
    values['balance_amount'] = values['paymentStatus'] == 'paid' ? 0 : price;
    values['updated_at'] = now;

    final orderId = await db.insert('orders', values);
    await db.insert('order_status_history', {
      'order_id': orderId,
      'old_status': null,
      'new_status': values['status'],
      'changed_at': now,
      'notes': 'Order created',
    });
    return orderId;
  }

  Future<Order> readOrder(int id) async {
    final db = await instance.database;
    final maps = await db.query(
      'orders',
      where: 'id = ?',
      whereArgs: [id],
    );

    if (maps.isNotEmpty) {
      return Order.fromMap(maps.first);
    } else {
      throw Exception('ID $id not found');
    }
  }

  Future<List<Order>> readAllOrders() async {
    final db = await instance.database;
    const orderBy = 'createdAt DESC';
    final result = await db.query(
      'orders',
      where: 'deleted_at IS NULL',
      orderBy: orderBy,
    );
    return result.map((json) => Order.fromMap(json)).toList();
  }

  Future<List<Order>> readOrdersByCustomer(int customerId) async {
    final db = await instance.database;
    final result = await db.query(
      'orders',
      where: 'customerId = ? AND deleted_at IS NULL',
      whereArgs: [customerId],
      orderBy: 'createdAt DESC',
    );
    return result.map((json) => Order.fromMap(json)).toList();
  }

  Future<int> updateOrder(Order order) async {
    final db = await instance.database;
    final values = Map<String, Object?>.from(order.toMap());
    final price = ((values['price'] as num?)?.toDouble()) ?? 0;
    final existingRows = await db.query(
      'orders',
      columns: ['status'],
      where: 'id = ?',
      whereArgs: [order.id],
      limit: 1,
    );
    final oldStatus =
        existingRows.isEmpty ? null : existingRows.first['status'] as String?;
    values['expected_delivery_date'] = values['deliveryDate'];
    values['subtotal'] = price;
    values['total_amount'] = price;
    values['balance_amount'] = values['paymentStatus'] == 'paid' ? 0 : price;
    values['updated_at'] = DateTime.now().toIso8601String();
    final count = await db.update(
      'orders',
      values,
      where: 'id = ?',
      whereArgs: [order.id],
    );
    final newStatus = values['status'] as String?;
    if (oldStatus != null && newStatus != null && oldStatus != newStatus) {
      await db.insert('order_status_history', {
        'order_id': order.id,
        'old_status': oldStatus,
        'new_status': newStatus,
        'changed_at': DateTime.now().toIso8601String(),
        'notes': 'Order updated',
      });
    }
    return count;
  }

  Future<int> deleteOrder(int id) async {
    final db = await instance.database;
    return await db.update(
      'orders',
      {
        'deleted_at': DateTime.now().toIso8601String(),
        'updated_at': DateTime.now().toIso8601String(),
      },
      where: 'id = ?',
      whereArgs: [id],
    );
  }

  Future close() async {
    final db = await instance.database;
    db.close();
  }
}
