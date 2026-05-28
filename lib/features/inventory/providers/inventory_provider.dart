import 'package:flutter/foundation.dart';
import 'package:tailoring_system/features/inventory/data/inventory_repository.dart';

class InventoryProvider extends ChangeNotifier {
  InventoryProvider({InventoryRepository? repository})
      : _repository = repository ?? InventoryRepository();

  final InventoryRepository _repository;

  bool _isLoading = false;
  String? _errorMessage;
  List<Map<String, Object?>> _items = [];
  List<Map<String, Object?>> _lowStockItems = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<Map<String, Object?>> get items => List.unmodifiable(_items);
  List<Map<String, Object?>> get lowStockItems => List.unmodifiable(_lowStockItems);

  Future<void> refresh() async {
    await _run(() async {
      _items = await _repository.items();
      _lowStockItems = await _repository.lowStockItems();
    });
  }

  Future<void> createItem({
    required String name,
    required String category,
    required String unit,
    double quantityOnHand = 0,
    double reorderLevel = 0,
    double unitCost = 0,
  }) async {
    await _run(() async {
      await _repository.createItem(
        name: name,
        category: category,
        unit: unit,
        quantityOnHand: quantityOnHand,
        reorderLevel: reorderLevel,
        unitCost: unitCost,
      );
      _items = await _repository.items();
      _lowStockItems = await _repository.lowStockItems();
    });
  }

  Future<void> _run(Future<void> Function() action) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();
    try {
      await action();
    } catch (error) {
      _errorMessage = error.toString();
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
