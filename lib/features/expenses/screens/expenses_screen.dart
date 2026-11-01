import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/features/expenses/providers/expense_provider.dart';

class ExpensesScreen extends StatefulWidget {
  const ExpensesScreen({super.key});

  @override
  State<ExpensesScreen> createState() => _ExpensesScreenState();
}

class _ExpensesScreenState extends State<ExpensesScreen> {
  late DateTime _start;
  late DateTime _end;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _start = DateTime(now.year, now.month, 1);
    _end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() async {
    await context.read<ExpenseProvider>().loadRange(start: _start, end: _end);
  }

  Future<void> _addExpense() async {
    final draft = await showDialog<_ExpenseDraft>(
      context: context,
      builder: (context) => const _ExpenseDialog(),
    );
    if (draft == null || !mounted) return;

    final provider = context.read<ExpenseProvider>();
    await provider.createExpense(
      category: draft.category,
      amount: draft.amount,
      expenseDate: draft.date,
      paymentMethod: draft.paymentMethod,
      description: draft.description,
    );
    if (!mounted) return;
    if (provider.errorMessage != null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
            content: Text('Could not save expense: ${provider.errorMessage}')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Expenses'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            onPressed: _load,
            icon: const Icon(Icons.refresh),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _addExpense,
        icon: const Icon(Icons.add),
        label: const Text('Add expense'),
      ),
      body: Consumer<ExpenseProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.expenses.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null && provider.expenses.isEmpty) {
            return Center(child: Text(provider.errorMessage!));
          }
          if (provider.expenses.isEmpty) {
            return const Center(
                child: Text('No expenses recorded this month.'));
          }

          final total = provider.expenses.fold<double>(
            0,
            (sum, expense) =>
                sum + ((expense['amount'] as num?)?.toDouble() ?? 0),
          );
          return ListView(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 96),
            children: [
              Card(
                child: ListTile(
                  leading: const CircleAvatar(
                    child: Icon(Icons.account_balance_wallet_outlined),
                  ),
                  title: const Text('This month'),
                  subtitle: Text('${provider.expenses.length} expenses'),
                  trailing: Text(
                    '${total.toStringAsFixed(2)} ETB',
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ),
              ),
              const SizedBox(height: 8),
              for (final expense in provider.expenses)
                Card(
                  child: ListTile(
                    leading: const Icon(Icons.receipt_long_outlined),
                    title: Text('${expense['category']}'),
                    subtitle: Text(
                      [
                        '${expense['expense_date']}',
                        if ((expense['description'] as String?)?.isNotEmpty ==
                            true)
                          expense['description'] as String,
                        if ((expense['payment_method'] as String?)
                                ?.isNotEmpty ==
                            true)
                          expense['payment_method'] as String,
                      ].join(' • '),
                    ),
                    isThreeLine: true,
                    trailing: Text(
                      '${((expense['amount'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)} ETB',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ExpenseDraft {
  const _ExpenseDraft({
    required this.category,
    required this.amount,
    required this.date,
    required this.paymentMethod,
    required this.description,
  });

  final String category;
  final double amount;
  final DateTime date;
  final String? paymentMethod;
  final String? description;
}

class _ExpenseDialog extends StatefulWidget {
  const _ExpenseDialog();

  @override
  State<_ExpenseDialog> createState() => _ExpenseDialogState();
}

class _ExpenseDialogState extends State<_ExpenseDialog> {
  final _formKey = GlobalKey<FormState>();
  final _categoryController = TextEditingController();
  final _amountController = TextEditingController();
  final _descriptionController = TextEditingController();
  DateTime _date = DateTime.now();
  String _method = 'cash';

  @override
  void dispose() {
    _categoryController.dispose();
    _amountController.dispose();
    _descriptionController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      title: const Text('Add expense'),
      content: Form(
        key: _formKey,
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextFormField(
                controller: _categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
                validator: (value) =>
                    value == null || value.trim().isEmpty ? 'Required' : null,
              ),
              const SizedBox(height: 12),
              TextFormField(
                controller: _amountController,
                keyboardType:
                    const TextInputType.numberWithOptions(decimal: true),
                decoration: const InputDecoration(labelText: 'Amount (ETB)'),
                validator: (value) {
                  final amount = double.tryParse(value ?? '');
                  return amount == null || amount <= 0
                      ? 'Enter an amount greater than zero'
                      : null;
                },
              ),
              const SizedBox(height: 12),
              DropdownButtonFormField<String>(
                value: _method,
                decoration: const InputDecoration(labelText: 'Payment method'),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(
                      value: 'bank_transfer', child: Text('Bank transfer')),
                  DropdownMenuItem(
                      value: 'mobile_money', child: Text('Mobile money')),
                ],
                onChanged: (value) {
                  if (value != null) setState(() => _method = value);
                },
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: const Text('Expense date'),
                subtitle: Text(
                    MaterialLocalizations.of(context).formatMediumDate(_date)),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final date = await showDatePicker(
                    context: context,
                    initialDate: _date,
                    firstDate: DateTime(2000),
                    lastDate: DateTime.now(),
                  );
                  if (date != null) setState(() => _date = date);
                },
              ),
              TextFormField(
                controller: _descriptionController,
                decoration: const InputDecoration(labelText: 'Description'),
                maxLines: 2,
              ),
            ],
          ),
        ),
      ),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('Cancel'),
        ),
        FilledButton(
          onPressed: () {
            if (!_formKey.currentState!.validate()) return;
            Navigator.pop(
              context,
              _ExpenseDraft(
                category: _categoryController.text.trim(),
                amount: double.parse(_amountController.text),
                date: _date,
                paymentMethod: _method,
                description: _descriptionController.text.trim(),
              ),
            );
          },
          child: const Text('Save'),
        ),
      ],
    );
  }
}
