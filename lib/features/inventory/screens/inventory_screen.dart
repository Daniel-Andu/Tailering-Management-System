import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/features/inventory/providers/inventory_provider.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';

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
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.inventoryTitle),
        actions: [
          IconButton(
            tooltip: l10n.inventoryRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<InventoryProvider>().refresh(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _openCreateItemForm,
        icon: const Icon(Icons.add),
        label: Text(l10n.inventoryNewItem),
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
            return Center(child: Text(l10n.inventoryNoItems));
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
              final reorder = ((item['reorder_level'] as num?)?.toDouble() ?? 0)
                  .toStringAsFixed(2);
              return ListTile(
                leading: const Icon(Icons.inventory_2_outlined),
                title: Text('${item['name']}'),
                subtitle:
                    Text('${item['category']}  ${item['item_code'] ?? ''}'),
                trailing: Text('$quantity ${item['unit']}\nMin $reorder'),
                isThreeLine: true,
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _openCreateItemForm() async {
    await Navigator.of(context).push<void>(
      MaterialPageRoute(builder: (_) => const _CreateInventoryItemScreen()),
    );
    if (!mounted) return;
    await context.read<InventoryProvider>().refresh();
  }
}

class _CreateInventoryItemScreen extends StatefulWidget {
  const _CreateInventoryItemScreen();

  @override
  State<_CreateInventoryItemScreen> createState() =>
      _CreateInventoryItemScreenState();
}

class _CreateInventoryItemScreenState
    extends State<_CreateInventoryItemScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _categoryController = TextEditingController(text: 'fabric');
  final _unitController = TextEditingController(text: 'meter');
  final _quantityController = TextEditingController(text: '0');
  final _reorderController = TextEditingController(text: '0');
  bool _isSaving = false;

  @override
  void dispose() {
    _nameController.dispose();
    _categoryController.dispose();
    _unitController.dispose();
    _quantityController.dispose();
    _reorderController.dispose();
    super.dispose();
  }

  Future<void> _saveItem() async {
    if (!_formKey.currentState!.validate()) return;

    setState(() => _isSaving = true);
    try {
      await context.read<InventoryProvider>().createItem(
            name: _nameController.text.trim(),
            category: _categoryController.text.trim(),
            unit: _unitController.text.trim(),
            quantityOnHand: double.tryParse(_quantityController.text) ?? 0,
            reorderLevel: double.tryParse(_reorderController.text) ?? 0,
          );
      if (!mounted) return;
      Navigator.pop(context);
    } finally {
      if (mounted) setState(() => _isSaving = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.inventoryDialogTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Center(
        child: ConstrainedBox(
          constraints: const BoxConstraints(maxWidth: 720),
          child: Form(
            key: _formKey,
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                TextFormField(
                  controller: _nameController,
                  decoration: InputDecoration(
                    labelText: '${l10n.inventoryName} *',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _categoryController,
                  decoration: InputDecoration(
                    labelText: '${l10n.inventoryCategory} *',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _unitController,
                  decoration: InputDecoration(
                    labelText: '${l10n.inventoryUnit} *',
                    border: const OutlineInputBorder(),
                  ),
                  validator: (value) =>
                      (value ?? '').trim().isEmpty ? 'Required' : null,
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _quantityController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.inventoryQuantity,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 16),
                TextFormField(
                  controller: _reorderController,
                  keyboardType: TextInputType.number,
                  decoration: InputDecoration(
                    labelText: l10n.inventoryReorderLevel,
                    border: const OutlineInputBorder(),
                  ),
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  height: 50,
                  child: ElevatedButton(
                    onPressed: _isSaving ? null : _saveItem,
                    child: _isSaving
                        ? const CircularProgressIndicator(color: Colors.white)
                        : Text(l10n.inventorySave),
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
