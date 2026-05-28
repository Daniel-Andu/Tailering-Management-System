import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/features/inventory/providers/inventory_provider.dart';

class InventoryScreen extends StatefulWidget {
  const InventoryScreen({super.key});

  @override
  State<InventoryScreen> createState() => _InventoryScreenState();
}

class _InventoryScreenState extends State<InventoryScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<InventoryProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<InventoryProvider>().refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateItemDialog,
        icon: const Icon(Icons.add),
        label: const Text('Item'),
      ),
      body: Consumer<InventoryProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.items.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }
          if (provider.items.isEmpty) {
            return const Center(child: Text('No inventory items'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.items.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = provider.items[index];
              final quantity =
                  ((item['quantity_on_hand'] as num?)?.toDouble() ?? 0)
                      .toStringAsFixed(2);
              final reorder =
                  ((item['reorder_level'] as num?)?.toDouble() ?? 0)
                      .toStringAsFixed(2);
              return ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text('${item['name']}'),
                subtitle: Text('${item['category']}  ${item['item_code'] ?? ''}'),
                trailing: Text('$quantity ${item['unit']}\nMin $reorder'),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _showCreateItemDialog() async {
    final nameController = TextEditingController();
    final categoryController = TextEditingController(text: 'fabric');
    final unitController = TextEditingController(text: 'meter');
    final quantityController = TextEditingController(text: '0');
    final reorderController = TextEditingController(text: '0');

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('New Inventory Item'),
        content: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: nameController,
                decoration: const InputDecoration(labelText: 'Name'),
              ),
              TextField(
                controller: categoryController,
                decoration: const InputDecoration(labelText: 'Category'),
              ),
              TextField(
                controller: unitController,
                decoration: const InputDecoration(labelText: 'Unit'),
              ),
              TextField(
                controller: quantityController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Quantity'),
              ),
              TextField(
                controller: reorderController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Reorder level'),
              ),
            ],
          ),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context, false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(context, true),
            child: const Text('Save'),
          ),
        ],
      ),
    );

    if (shouldSave != true || !mounted) return;
    await context.read<InventoryProvider>().createItem(
          name: nameController.text.trim(),
          category: categoryController.text.trim(),
          unit: unitController.text.trim(),
          quantityOnHand: double.tryParse(quantityController.text) ?? 0,
          reorderLevel: double.tryParse(reorderController.text) ?? 0,
        );
  }
}
