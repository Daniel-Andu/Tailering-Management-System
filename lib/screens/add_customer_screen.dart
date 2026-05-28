import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/providers/customer_provider.dart';
import 'package:tailoring_system/models/customer.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';

class AddCustomerScreen extends StatefulWidget {
  final Customer? customer;

  const AddCustomerScreen({super.key, this.customer});

  @override
  State<AddCustomerScreen> createState() => _AddCustomerScreenState();
}

class _AddCustomerScreenState extends State<AddCustomerScreen> {
  final _formKey = GlobalKey<FormState>();
  final _customerIdController = TextEditingController();
  final _nameController = TextEditingController();
  final _businessNameController = TextEditingController();
  final _phoneController = TextEditingController();
  final _emailController = TextEditingController();
  final _notesController = TextEditingController();

  @override
  void initState() {
    super.initState();
    if (widget.customer != null) {
      _customerIdController.text = widget.customer!.customerId;
      _nameController.text = widget.customer!.name;
      _businessNameController.text = widget.customer!.businessName ?? '';
      _phoneController.text = widget.customer!.phone ?? '';
      _emailController.text = widget.customer!.email ?? '';
      _notesController.text = widget.customer!.notes ?? '';
    } else {
      _customerIdController.text =
          'CUST${DateTime.now().millisecondsSinceEpoch}';
    }
  }

  @override
  void dispose() {
    _customerIdController.dispose();
    _nameController.dispose();
    _businessNameController.dispose();
    _phoneController.dispose();
    _emailController.dispose();
    _notesController.dispose();
    super.dispose();
  }

  void _saveCustomer() {
    if (_formKey.currentState!.validate()) {
      final customer = Customer(
        id: widget.customer?.id,
        customerId: _customerIdController.text,
        name: _nameController.text,
        businessName: _businessNameController.text.isEmpty
            ? null
            : _businessNameController.text,
        phone: _phoneController.text.isEmpty ? null : _phoneController.text,
        email: _emailController.text.isEmpty ? null : _emailController.text,
        date: widget.customer?.date ?? DateTime.now().toString().split(' ')[0],
        notes: _notesController.text.isEmpty ? null : _notesController.text,
      );

      final provider = Provider.of<CustomerProvider>(context, listen: false);

      if (widget.customer == null) {
        provider.addCustomer(customer);
      } else {
        provider.updateCustomer(customer);
      }

      Navigator.pop(context);
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(widget.customer == null
              ? 'Customer added successfully!'
              : 'Customer updated successfully!'),
          backgroundColor: Colors.green,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          widget.customer == null ? l10n.customerFormTitle : 'Edit Customer',
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: Form(
        key: _formKey,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            TextFormField(
              controller: _customerIdController,
              decoration: const InputDecoration(
                labelText: 'Customer ID *',
                border: OutlineInputBorder(),
              ),
              validator: (value) =>
                  value!.isEmpty ? 'Customer ID is required' : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _nameController,
              decoration: InputDecoration(
                labelText: '${l10n.customerFormName} *',
                border: const OutlineInputBorder(),
              ),
              validator: (value) =>
                  value!.isEmpty ? l10n.customerFormNameRequired : null,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _businessNameController,
              decoration: const InputDecoration(
                labelText: 'Business Name',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _phoneController,
              decoration: InputDecoration(
                labelText: l10n.customerFormPhone,
                border: const OutlineInputBorder(),
              ),
              keyboardType: TextInputType.phone,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _emailController,
              decoration: const InputDecoration(
                labelText: 'Email',
                border: OutlineInputBorder(),
              ),
              keyboardType: TextInputType.emailAddress,
            ),
            const SizedBox(height: 16),
            TextFormField(
              controller: _notesController,
              decoration: const InputDecoration(
                labelText: 'Notes',
                border: OutlineInputBorder(),
              ),
              maxLines: 3,
            ),
            const SizedBox(height: 24),
            SizedBox(
              width: double.infinity,
              height: 50,
              child: ElevatedButton(
                onPressed: _saveCustomer,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.blue[900],
                ),
                child: Text(
                  l10n.customerFormSaveCustomer,
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
    );
  }
}
