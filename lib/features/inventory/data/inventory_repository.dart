import 'package:tailoring_system/core/database/app_sequence_repository.dart';
import 'package:tailoring_system/utils/database_helper.dart';

class InventoryRepository {
  Future<List<Map<String, Object?>>> items() async {
    final db = await DatabaseHelper.instance.database;
    return db.query('inventory_items', orderBy: 'name ASC');
  }

  Future<int> createItem({
    required String name,
    required String category,
    required String unit,
    double quantityOnHand = 0,
    double reorderLevel = 0,
    double unitCost = 0,
  }) async {
    final db = await DatabaseHelper.instance.database;
    final code = await AppSequenceRepository(db).nextCode(
      key: 'inventory',
      prefix: 'INV',
      includeDate: false,
    );
    final now = DateTime.now().toIso8601String();
    return db.insert('inventory_items', {
      'item_code': code,
      'name': name,
      'category': category,
      'unit': unit,
      'quantity_on_hand': quantityOnHand,
      'reorder_level': reorderLevel,
      'unit_cost': unitCost,
      'created_at': now,
      'updated_at': now,
    });
  }

  Future<void> moveStock({
    required int inventoryItemId,
    required String movementType,
    required double quantity,
    double unitCost = 0,
    String? referenceType,
    int? referenceId,
    String? notes,
  }) async {
    final db = await DatabaseHelper.instance.database;
    await db.transaction((txn) async {
      final direction = movementType == 'out' ? -1 : 1;
      await txn.insert('inventory_movements', {
        'inventory_item_id': inventoryItemId,
        'movement_type': movementType,
        'quantity': quantity,
        'unit_cost': unitCost,
        'reference_type': referenceType,
        'reference_id': referenceId,
        'notes': notes,
        'moved_at': DateTime.now().toIso8601String(),
      });

      await txn.rawUpdate(
        '''
        UPDATE inventory_items
        SET quantity_on_hand = quantity_on_hand + ?,
            updated_at = ?
        WHERE id = ?
        ''',
        [quantity * direction, DateTime.now().toIso8601String(), inventoryItemId],
      );
    });
  }

  Future<List<Map<String, Object?>>> lowStockItems() async {
    final db = await DatabaseHelper.instance.database;
    return db.query(
      'inventory_items',
      where: 'quantity_on_hand <= reorder_level',
      orderBy: 'quantity_on_hand ASC',
    );
  }
}
