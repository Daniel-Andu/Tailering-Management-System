import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/providers/order_provider.dart';
import 'package:tailoring_system/providers/customer_provider.dart';
import 'package:tailoring_system/models/order.dart';
import 'package:tailoring_system/models/customer.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';

class AddOrderScreen extends StatefulWidget {
  final Order? order;

  const AddOrderScreen({super.key, this.order});

  @override
  State<AddOrderScreen> createState() => _AddOrderScreenState();
}

class _AddOrderScreenState extends State<AddOrderScreen> {
  final _formKey = GlobalKey<FormState>();
  Customer? _selectedCustomer;
  final _clothTypeController = TextEditingController();
  final _priceController = TextEditingController();
  final _deliveryDateController = TextEditingController();
  final _notesController = TextEditingController();
  final _paymentMethodController = TextEditingController();
  final _transactionIdController = TextEditingController();
  String _status = 'Pending';
  String _paymentStatus = 'Pending';

  final List<String> _statusOptions = [
    'Pending',
    'In Progress',
    'Completed',
    'Delivered'
  ];
  final List<String> _paymentStatuses = ['Pending', 'Paid'];

  @override
  void initState() {
    super.initState();
    if (widget.order != null) {
      _clothTypeController.text = widget.order!.clothType;
      _priceController.text = widget.order!.price.toString();
      _deliveryDateController.text = widget.order!.deliveryDate ?? '';
      _status = widget.order!.status;
      _notesController.text = widget.order!.notes ?? '';
      _paymentMethodController.text = widget.order!.paymentMethod ?? '';
      _transactionIdController.text = widget.order!.transactionId ?? '';
      _paymentStatus = widget.order!.paymentStatus ?? 'Pending';
    }
  }

  @override
  void dispose() {
    _clothTypeController.dispose();
    _priceController.dispose();
    _deliveryDateController.dispose();
    _notesController.dispose();
    _paymentMethodController.dispose();
    _transactionIdController.dispose();
    super.dispose();
  }

  Future<void> _selectDeliveryDate() async {
    final DateTime? picked = await showDatePicker(
      context: context,
      initialDate: DateTime.now(),
      firstDate: DateTime.now(),
      lastDate: DateTime(2100),
    );
    if (picked != null) {
      setState(() {
        _deliveryDateController.text = picked.toIso8601String().split('T')[0];
      });
    }
  }

  void _saveOrder() async {
    final l10n = AppLocalizations.of(context)!;

    if (_formKey.currentState!.validate()) {
      if (_selectedCustomer == null) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(l10n.pleaseSelectCustomer),
            backgroundColor: Colors.red,
          ),
        );
        return;
      }

      final order = Order(
        id: widget.order?.id,
        customerId: _selectedCustomer!.id,
        clothType: _clothTypeController.text,
        price: double.tryParse(_priceController.text) ?? 0.0,
        deliveryDate: _deliveryDateController.text.isEmpty
            ? null
            : _deliveryDateController.text,
        status: _status,
        notes: _notesController.text.isEmpty ? null : _notesController.text,
        createdAt: widget.order?.createdAt ?? DateTime.now().toIso8601String(),
        paymentMethod: _paymentMethodController.text.isEmpty
            ? null
            : _paymentMethodController.text,
        transactionId: _transactionIdController.text.isEmpty
            ? null
            : _transactionIdController.text,
        paymentStatus: _paymentStatus,
      );

      final provider = Provider.of<OrderProvider>(context, listen: false);

      try {
        if (widget.order == null) {
          await provider.addOrder(order);
        } else {
          await provider.updateOrder(order);
        }

        if (mounted) {
          Navigator.pop(context);
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(widget.order == null
                  ? l10n.orderFormAddedMessage
                  : l10n.orderFormUpdatedMessage),
              backgroundColor: Colors.green,
            ),
          );
        }
      } catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error saving order: $e'),
              backgroundColor: Colors.red,
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.order == null ? l10n.orderFormTitle : l10n.orderFormEditTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Consumer<CustomerProvider>(
                  builder: (context, customerProvider, child) {
                    final customers = customerProvider.customers;
                    return DropdownButtonFormField<Customer>(
                      decoration: InputDecoration(
                        labelText: '${l10n.orderFormSelectCustomer} *',
                        border: const OutlineInputBorder(),
                      ),
                      initialValue: _selectedCustomer,
                      items: customers.map((customer) {
                        return DropdownMenuItem(
                          value: customer,
                          child: Text(customer.name),
                        );
                      }).toList(),
                      onChanged: (value) {
                        setState(() {
                          _selectedCustomer = value;
                        });
                      },
                      validator: (value) =>
                          value == null ? l10n.orderFormCustomerRequired : null,
                    );
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _clothTypeController,
                  decoration: InputDecoration(
                    labelText: '${l10n.orderFormClothType} *',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      value!.isEmpty ? l10n.orderFormClothTypeRequired : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _priceController,
                  decoration: InputDecoration(
                    labelText: '${l10n.orderFormPrice} *',
                    border: const OutlineInputBorder(),
                  ),
                  keyboardType: TextInputType.number,
                  validator: (value) =>
                      value!.isEmpty ? l10n.orderFormPriceRequired : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _deliveryDateController,
                  decoration: InputDecoration(
                    labelText: l10n.orderFormDeliveryDate,
                    border: const OutlineInputBorder(),
                    suffixIcon: const Icon(Icons.calendar_today),
                  ),
                  readOnly: true,
                  onTap: _selectDeliveryDate,
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: l10n.orderFormStatus,
                    border: const OutlineInputBorder(),
                  ),
                  initialValue: _status,
                  items: _statusOptions.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _status = value!;
                    });
                  },
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _notesController,
                  decoration: InputDecoration(
                    labelText: l10n.orderFormNotes,
                    border: const OutlineInputBorder(),
                  ),
                  maxLines: 3,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _paymentMethodController,
                  decoration: InputDecoration(
                    labelText: l10n.orderFormPaymentMethod,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _transactionIdController,
                  decoration: InputDecoration(
                    labelText: l10n.orderFormTransactionId,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                DropdownButtonFormField<String>(
                  decoration: InputDecoration(
                    labelText: l10n.orderFormPaymentStatus,
                    border: const OutlineInputBorder(),
                  ),
                  initialValue: _paymentStatus,
                  items: _paymentStatuses.map((status) {
                    return DropdownMenuItem(
                      value: status,
                      child: Text(status),
                    );
                  }).toList(),
                  onChanged: (value) {
                    setState(() {
                      _paymentStatus = value!;
                    });
                  },
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _saveOrder,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue[900],
                    ),
                    child: Text(
                      l10n.orderFormSaveOrder,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
