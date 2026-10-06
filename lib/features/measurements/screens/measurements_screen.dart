import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/features/measurements/providers/measurement_provider.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';

class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen>
    with SingleTickerProviderStateMixin {
  int? _selectedClothTypeId;
  int? _selectedTemplateId;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeasurementProvider>().loadClothTypes();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(l10n.measurementsTitle),
        bottom: TabBar(
          controller: _tabController,
          indicatorColor: Colors.white,
          labelColor: Colors.white,
          unselectedLabelColor: Colors.white70,
          tabs: [
            Tab(
                icon: const Icon(Icons.straighten),
                text: l10n.measurementsTemplates),
            Tab(
                icon: const Icon(Icons.add_chart),
                text: l10n.measurementsCustomFields),
          ],
        ),
        actions: [
          IconButton(
            tooltip: l10n.commonRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<MeasurementProvider>().loadClothTypes(),
          ),
        ],
      ),
      body: TabBarView(
        controller: _tabController,
        children: [
          _TemplatesTab(
            selectedClothTypeId: _selectedClothTypeId,
            selectedTemplateId: _selectedTemplateId,
            onClothTypeSelected: _selectClothType,
            onTemplateSelected: _selectTemplate,
          ),
          const _CustomFieldsTab(),
        ],
      ),
    );
  }

  Future<void> _selectClothType(int clothTypeId) async {
    setState(() {
      _selectedClothTypeId = clothTypeId;
      _selectedTemplateId = null;
    });
    await context
        .read<MeasurementProvider>()
        .loadTemplatesForClothType(clothTypeId);
  }

  Future<void> _selectTemplate(int templateId) async {
    setState(() => _selectedTemplateId = templateId);
    await context.read<MeasurementProvider>().loadFieldsForTemplate(templateId);
  }
}

// ── Templates Tab ─────────────────────────────────────────────────────────────

class _TemplatesTab extends StatelessWidget {
  const _TemplatesTab({
    required this.selectedClothTypeId,
    required this.selectedTemplateId,
    required this.onClothTypeSelected,
    required this.onTemplateSelected,
  });

  final int? selectedClothTypeId;
  final int? selectedTemplateId;
  final ValueChanged<int> onClothTypeSelected;
  final ValueChanged<int> onTemplateSelected;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Consumer<MeasurementProvider>(
      builder: (context, provider, _) {
        if (provider.isLoading && provider.clothTypes.isEmpty) {
          return const Center(child: CircularProgressIndicator());
        }
        if (provider.errorMessage != null) {
          return Center(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.error_outline, size: 48, color: Colors.red),
                const SizedBox(height: 12),
                Text(provider.errorMessage!,
                    style: const TextStyle(color: Colors.red)),
              ],
            ),
          );
        }

        return LayoutBuilder(
          builder: (context, constraints) {
            final wide = constraints.maxWidth >= 900;
            if (wide) {
              return Row(
                children: [
                  SizedBox(
                    width: 260,
                    child: _ClothTypePanel(
                      clothTypes: provider.clothTypes,
                      selectedId: selectedClothTypeId,
                      onSelected: onClothTypeSelected,
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  SizedBox(
                    width: 300,
                    child: _TemplatePanel(
                      templates: provider.templates,
                      selectedId: selectedTemplateId,
                      onSelected: onTemplateSelected,
                    ),
                  ),
                  const VerticalDivider(width: 1),
                  Expanded(child: _FieldPanel(fields: provider.fields)),
                ],
              );
            }

            // Mobile: stacked dropdowns
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                _StyledDropdown(
                  label: l10n.measurementsClothTypes,
                  icon: Icons.checkroom,
                  value: selectedClothTypeId,
                  items: provider.clothTypes,
                  textKey: 'default_name',
                  onChanged: (v) {
                    if (v != null) onClothTypeSelected(v);
                  },
                ),
                const SizedBox(height: 16),
                _StyledDropdown(
                  label: l10n.measurementsTemplates,
                  icon: Icons.list_alt,
                  value: selectedTemplateId,
                  items: provider.templates,
                  textKey: 'name',
                  onChanged: (v) {
                    if (v != null) onTemplateSelected(v);
                  },
                ),
                const SizedBox(height: 20),
                _FieldPanel(fields: provider.fields),
              ],
            );
          },
        );
      },
    );
  }
}

class _ClothTypePanel extends StatelessWidget {
  const _ClothTypePanel({
    required this.clothTypes,
    required this.selectedId,
    required this.onSelected,
  });
  final List<Map<String, Object?>> clothTypes;
  final int? selectedId;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: Colors.white,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(l10n.measurementsClothTypes,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.primary)),
          ),
          const Divider(height: 1),
          Expanded(
            child: ListView.builder(
              itemCount: clothTypes.length,
              itemBuilder: (context, index) {
                final item = clothTypes[index];
                final isSelected = item['id'] == selectedId;
                return ListTile(
                  selected: isSelected,
                  selectedTileColor: theme.colorScheme.primary.withOpacity(0.1),
                  leading: Container(
                    padding: const EdgeInsets.all(8),
                    decoration: BoxDecoration(
                      color: isSelected
                          ? theme.colorScheme.primary
                          : theme.colorScheme.surfaceContainerHighest,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Icon(Icons.checkroom,
                        size: 18,
                        color: isSelected
                            ? Colors.white
                            : theme.colorScheme.primary),
                  ),
                  title: Text('${item['default_name']}',
                      style: TextStyle(
                          fontWeight: isSelected
                              ? FontWeight.bold
                              : FontWeight.normal)),
                  onTap: () => onSelected(item['id'] as int),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

class _TemplatePanel extends StatelessWidget {
  const _TemplatePanel({
    required this.templates,
    required this.selectedId,
    required this.onSelected,
  });
  final List<Map<String, Object?>> templates;
  final int? selectedId;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      color: const Color(0xFFFAFAFA),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 16, 16, 8),
            child: Text(l10n.measurementsTemplates,
                style: theme.textTheme.titleMedium
                    ?.copyWith(color: theme.colorScheme.primary)),
          ),
          const Divider(height: 1),
          Expanded(
            child: templates.isEmpty
                ? Center(
                    child: Padding(
                      padding: const EdgeInsets.all(24),
                      child: Text(l10n.measurementsSelectClothType,
                          style: const TextStyle(color: Colors.grey)),
                    ),
                  )
                : ListView.builder(
                    itemCount: templates.length,
                    itemBuilder: (context, index) {
                      final item = templates[index];
                      final isSelected = item['id'] == selectedId;
                      return ListTile(
                        selected: isSelected,
                        selectedTileColor:
                            theme.colorScheme.primary.withOpacity(0.1),
                        title: Text('${item['name']}',
                            style: TextStyle(
                                fontWeight: isSelected
                                    ? FontWeight.bold
                                    : FontWeight.normal)),
                        trailing: item['is_default'] == 1
                            ? Icon(Icons.star,
                                size: 16, color: theme.colorScheme.primary)
                            : null,
                        onTap: () => onSelected(item['id'] as int),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

class _FieldPanel extends StatelessWidget {
  const _FieldPanel({required this.fields});
  final List<Map<String, Object?>> fields;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    if (fields.isEmpty) {
      return Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.straighten, size: 64, color: Colors.grey[300]),
            const SizedBox(height: 12),
            Text(l10n.measurementsSelectTemplate,
                style: TextStyle(color: Colors.grey[500])),
          ],
        ),
      );
    }

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 16, 16, 4),
          child: Text('${l10n.measurementsFields} (${fields.length})',
              style: theme.textTheme.titleMedium
                  ?.copyWith(color: theme.colorScheme.primary)),
        ),
        const Divider(height: 1),
        Expanded(
          child: ListView.separated(
            padding: const EdgeInsets.all(12),
            itemCount: fields.length,
            separatorBuilder: (_, __) => const SizedBox(height: 4),
            itemBuilder: (context, index) {
              final field = fields[index];
              return Card(
                margin: EdgeInsets.zero,
                child: ListTile(
                  leading: CircleAvatar(
                    backgroundColor:
                        theme.colorScheme.primary.withOpacity(0.12),
                    child: Text(
                      '${index + 1}',
                      style: TextStyle(
                          color: theme.colorScheme.primary,
                          fontWeight: FontWeight.bold),
                    ),
                  ),
                  title: Text('${field['field_key']}'.replaceAll('_', ' '),
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  subtitle: Text(
                      '${field['label_key']}'.replaceAll('measurement.', '')),
                  trailing: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.tertiaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Text(
                      '${field['unit']}',
                      style: TextStyle(
                          color: theme.colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                          fontSize: 12),
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}

class _StyledDropdown extends StatelessWidget {
  const _StyledDropdown({
    required this.label,
    required this.icon,
    required this.value,
    required this.items,
    required this.textKey,
    required this.onChanged,
  });
  final String label;
  final IconData icon;
  final int? value;
  final List<Map<String, Object?>> items;
  final String textKey;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      initialValue: value,
      decoration: InputDecoration(
        labelText: label,
        prefixIcon: Icon(icon),
      ),
      items: [
        for (final item in items)
          DropdownMenuItem<int>(
            value: item['id'] as int,
            child: Text('${item[textKey]}'),
          ),
      ],
      onChanged: onChanged,
    );
  }
}

// ── Custom Fields Tab ──────────────────────────────────────────────────────────

class _CustomFieldsTab extends StatelessWidget {
  const _CustomFieldsTab();

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Consumer<MeasurementProvider>(
      builder: (context, provider, _) {
        return Scaffold(
          backgroundColor: const Color(0xFFF8FAFC),
          floatingActionButton: FloatingActionButton.extended(
            onPressed: () => _showAddFieldDialog(context, provider),
            icon: const Icon(Icons.add),
            label: Text(l10n.measurementsAddCustomField),
          ),
          body: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                width: double.infinity,
                margin: const EdgeInsets.all(16),
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      theme.colorScheme.primary.withOpacity(0.08),
                      theme.colorScheme.tertiary.withOpacity(0.06),
                    ],
                  ),
                  borderRadius: BorderRadius.circular(16),
                  border: Border.all(
                      color: theme.colorScheme.primary.withOpacity(0.2)),
                ),
                child: Row(
                  children: [
                    Icon(Icons.info_outline,
                        color: theme.colorScheme.primary, size: 24),
                    const SizedBox(width: 12),
                    Expanded(
                      child: Text(
                        l10n.measurementsCustomFieldInfo,
                        style: TextStyle(
                            color: theme.colorScheme.primary,
                            fontSize: 13,
                            height: 1.5),
                      ),
                    ),
                  ],
                ),
              ),
              if (provider.isLoading && provider.customFields.isEmpty)
                const Expanded(
                    child: Center(child: CircularProgressIndicator()))
              else if (provider.customFields.isEmpty)
                Expanded(
                  child: Center(
                    child: Column(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.add_chart,
                            size: 72, color: Colors.grey[300]),
                        const SizedBox(height: 16),
                        Text(
                          l10n.measurementsNoCustomFields,
                          style: theme.textTheme.titleMedium
                              ?.copyWith(color: Colors.grey),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          l10n.measurementsNoCustomFieldsHint,
                          style: TextStyle(color: Colors.grey[400]),
                        ),
                        const SizedBox(height: 80),
                      ],
                    ),
                  ),
                )
              else
                Expanded(
                  child: ListView.separated(
                    padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                    itemCount: provider.customFields.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 8),
                    itemBuilder: (context, index) {
                      final field = provider.customFields[index];
                      return Card(
                        child: ListTile(
                          leading: CircleAvatar(
                            backgroundColor:
                                theme.colorScheme.secondaryContainer,
                            child: Icon(Icons.straighten,
                                size: 20,
                                color: theme.colorScheme.onSecondaryContainer),
                          ),
                          title: Text(
                            '${field['label']}',
                            style: const TextStyle(fontWeight: FontWeight.w600),
                          ),
                          trailing: Row(
                            mainAxisSize: MainAxisSize.min,
                            children: [
                              Container(
                                padding: const EdgeInsets.symmetric(
                                    horizontal: 10, vertical: 4),
                                decoration: BoxDecoration(
                                  color: theme.colorScheme.tertiaryContainer,
                                  borderRadius: BorderRadius.circular(20),
                                ),
                                child: Text(
                                  '${field['unit']}',
                                  style: TextStyle(
                                      color:
                                          theme.colorScheme.onTertiaryContainer,
                                      fontWeight: FontWeight.w600,
                                      fontSize: 12),
                                ),
                              ),
                              const SizedBox(width: 4),
                              IconButton(
                                icon: const Icon(Icons.edit_outlined, size: 20),
                                onPressed: () => _showEditFieldDialog(
                                    context, provider, field),
                              ),
                              IconButton(
                                icon: Icon(Icons.delete_outline,
                                    size: 20, color: theme.colorScheme.error),
                                onPressed: () => _confirmDelete(
                                    context, provider, field['id'] as int),
                              ),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
                ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _showAddFieldDialog(
      BuildContext context, MeasurementProvider provider) async {
    final l10n = AppLocalizations.of(context)!;
    final labelController = TextEditingController();
    final unitController = TextEditingController(text: 'cm');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.add_chart, color: Theme.of(ctx).colorScheme.primary),
            const SizedBox(width: 8),
            Text(l10n.measurementsAddCustomField),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: InputDecoration(
                labelText: l10n.measurementsFieldName,
                hintText: l10n.measurementsFieldNameHint,
                prefixIcon: const Icon(Icons.label_outline),
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: unitController,
              decoration: InputDecoration(
                labelText: l10n.measurementsUnit,
                hintText: l10n.measurementsUnitHint,
                prefixIcon: const Icon(Icons.straighten),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonAdd),
          ),
        ],
      ),
    );

    if (confirmed == true && labelController.text.trim().isNotEmpty) {
      await provider.addCustomField(
        label: labelController.text.trim(),
        unit: unitController.text.trim().isEmpty
            ? 'cm'
            : unitController.text.trim(),
      );
    }
  }

  Future<void> _showEditFieldDialog(BuildContext context,
      MeasurementProvider provider, Map<String, Object?> field) async {
    final l10n = AppLocalizations.of(context)!;
    final labelController =
        TextEditingController(text: field['label'] as String?);
    final unitController =
        TextEditingController(text: field['unit'] as String? ?? 'cm');

    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Row(
          children: [
            Icon(Icons.edit, color: Theme.of(ctx).colorScheme.primary),
            const SizedBox(width: 8),
            Text(l10n.measurementsEditCustomField),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            TextField(
              controller: labelController,
              decoration: InputDecoration(
                labelText: l10n.measurementsFieldName,
                prefixIcon: const Icon(Icons.label_outline),
              ),
              textCapitalization: TextCapitalization.words,
              autofocus: true,
            ),
            const SizedBox(height: 12),
            TextField(
              controller: unitController,
              decoration: InputDecoration(
                labelText: l10n.measurementsUnit,
                prefixIcon: const Icon(Icons.straighten),
              ),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonSave),
          ),
        ],
      ),
    );

    if (confirmed == true && labelController.text.trim().isNotEmpty) {
      await provider.updateCustomField(
        id: field['id'] as int,
        label: labelController.text.trim(),
        unit: unitController.text.trim().isEmpty
            ? 'cm'
            : unitController.text.trim(),
      );
    }
  }

  Future<void> _confirmDelete(
      BuildContext context, MeasurementProvider provider, int id) async {
    final l10n = AppLocalizations.of(context)!;
    final confirmed = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text(l10n.measurementsDeleteField),
        content: Text(l10n.measurementsDeleteFieldConfirm),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(ctx, false),
            child: Text(l10n.commonCancel),
          ),
          FilledButton(
            style: FilledButton.styleFrom(
                backgroundColor: Theme.of(ctx).colorScheme.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: Text(l10n.commonDelete),
          ),
        ],
      ),
    );
    if (confirmed == true) {
      await provider.deleteCustomField(id);
    }
  }
}
