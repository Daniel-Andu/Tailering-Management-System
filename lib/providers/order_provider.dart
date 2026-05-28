import 'package:flutter/material.dart';
import 'package:tailoring_system/models/order.dart';
import 'package:tailoring_system/utils/database_helper.dart';

class OrderProvider extends ChangeNotifier {
  List<Order> _orders = [];
  bool _isLoading = false;

  List<Order> get orders => _orders;
  bool get isLoading => _isLoading;

  Future<void> loadOrders() async {
    _isLoading = true;
    notifyListeners();

    try {
      _orders = await DatabaseHelper.instance.readAllOrders();
    } catch (e) {
      print('Error loading orders: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addOrder(Order order) async {
    try {
      await DatabaseHelper.instance.createOrder(order);
      await loadOrders();
    } catch (e) {
      print('Error adding order: $e');
    }
  }

  Future<void> updateOrder(Order order) async {
    try {
      await DatabaseHelper.instance.updateOrder(order);
      await loadOrders();
    } catch (e) {
      print('Error updating order: $e');
    }
  }

  Future<void> deleteOrder(int id) async {
    try {
      await DatabaseHelper.instance.deleteOrder(id);
      await loadOrders();
    } catch (e) {
      print('Error deleting order: $e');
    }
  }

  List<Order> getOrdersByCustomer(int customerId) {
    return _orders.where((o) => o.customerId == customerId).toList();
  }

  double getTotalRevenue() {
    return _orders.fold(0.0, (sum, order) => sum + order.price);
  }
}
