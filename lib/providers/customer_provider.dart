import 'package:flutter/material.dart';
import 'package:tailoring_system/models/customer.dart';
import 'package:tailoring_system/utils/database_helper.dart';

class CustomerProvider extends ChangeNotifier {
  List<Customer> _customers = [];
  bool _isLoading = false;

  List<Customer> get customers => _customers;
  bool get isLoading => _isLoading;

  Future<void> loadCustomers() async {
    _isLoading = true;
    notifyListeners();

    try {
      _customers = await DatabaseHelper.instance.readAllCustomers();
    } catch (e) {
      print('Error loading customers: $e');
    }

    _isLoading = false;
    notifyListeners();
  }

  Future<void> addCustomer(Customer customer) async {
    try {
      await DatabaseHelper.instance.createCustomer(customer);
      await loadCustomers();
    } catch (e) {
      print('Error adding customer: $e');
    }
  }

  Future<void> updateCustomer(Customer customer) async {
    try {
      await DatabaseHelper.instance.updateCustomer(customer);
      await loadCustomers();
    } catch (e) {
      print('Error updating customer: $e');
    }
  }

  Future<void> deleteCustomer(int id) async {
    try {
      await DatabaseHelper.instance.deleteCustomer(id);
      await loadCustomers();
    } catch (e) {
      print('Error deleting customer: $e');
    }
  }

  Customer? getCustomerById(int id) {
    try {
      return _customers.firstWhere((c) => c.id == id);
    } catch (e) {
      return null;
    }
  }

  Future<List<Customer>> searchCustomers(String searchTerm) async {
    try {
      return await DatabaseHelper.instance.searchCustomers(searchTerm);
    } catch (e) {
      print('Error searching customers: $e');
      return [];
    }
  }
}
