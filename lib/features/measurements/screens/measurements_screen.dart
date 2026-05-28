import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/features/measurements/providers/measurement_provider.dart';

class MeasurementsScreen extends StatefulWidget {
  const MeasurementsScreen({super.key});

  @override
  State<MeasurementsScreen> createState() => _MeasurementsScreenState();
}

class _MeasurementsScreenState extends State<MeasurementsScreen> {
  int? _selectedClothTypeId;
  int? _selectedTemplateId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<MeasurementProvider>().loadClothTypes();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Measurements'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<MeasurementProvider>().loadClothTypes(),
          ),
        ],
      ),
      body: Consumer<MeasurementProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.clothTypes.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final wide = constraints.maxWidth >= 900;
              if (wide) {
                return Row(
                  children: [
                    SizedBox(
                      width: 280,
                      child: _ClothTypeList(
                        clothTypes: provider.clothTypes,
                        selectedId: _selectedClothTypeId,
                        onSelected: _selectClothType,
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    SizedBox(
                      width: 320,
                      child: _TemplateList(
                        templates: provider.templates,
                        selectedId: _selectedTemplateId,
                        onSelected: _selectTemplate,
                      ),
                    ),
                    const VerticalDivider(width: 1),
                    Expanded(child: _FieldList(fields: provider.fields)),
                  ],
                );
              }

              return ListView(
                padding: const EdgeInsets.all(16),
                children: [
                  _DropdownSection(
                    label: 'Cloth type',
                    value: _selectedClothTypeId,
                    items: provider.clothTypes,
                    textKey: 'default_name',
                    onChanged: (value) {
                      if (value != null) _selectClothType(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  _DropdownSection(
                    label: 'Template',
                    value: _selectedTemplateId,
                    items: provider.templates,
                    textKey: 'name',
                    onChanged: (value) {
                      if (value != null) _selectTemplate(value);
                    },
                  ),
                  const SizedBox(height: 16),
                  _FieldList(fields: provider.fields),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _selectClothType(int clothTypeId) async {
    setState(() {
      _selectedClothTypeId = clothTypeId;
      _selectedTemplateId = null;
    });
    await context.read<MeasurementProvider>().loadTemplatesForClothType(clothTypeId);
  }

  Future<void> _selectTemplate(int templateId) async {
    setState(() => _selectedTemplateId = templateId);
    await context.read<MeasurementProvider>().loadFieldsForTemplate(templateId);
  }
}

class _ClothTypeList extends StatelessWidget {
  const _ClothTypeList({
    required this.clothTypes,
    required this.selectedId,
    required this.onSelected,
  });

  final List<Map<String, Object?>> clothTypes;
  final int? selectedId;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text('Cloth Types', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final item in clothTypes)
          ListTile(
            selected: item['id'] == selectedId,
            title: Text('${item['default_name']}'),
            onTap: () => onSelected(item['id'] as int),
          ),
      ],
    );
  }
}

class _TemplateList extends StatelessWidget {
  const _TemplateList({
    required this.templates,
    required this.selectedId,
    required this.onSelected,
  });

  final List<Map<String, Object?>> templates;
  final int? selectedId;
  final ValueChanged<int> onSelected;

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Text('Templates', style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        if (templates.isEmpty)
          const Padding(
            padding: EdgeInsets.all(16),
            child: Text('Select a cloth type'),
          )
        else
          for (final item in templates)
            ListTile(
              selected: item['id'] == selectedId,
              title: Text('${item['name']}'),
              trailing:
                  item['is_default'] == 1 ? const Icon(Icons.star, size: 18) : null,
              onTap: () => onSelected(item['id'] as int),
            ),
      ],
    );
  }
}

class _FieldList extends StatelessWidget {
  const _FieldList({required this.fields});

  final List<Map<String, Object?>> fields;

  @override
  Widget build(BuildContext context) {
    if (fields.isEmpty) {
      return const Center(child: Text('Select a template'));
    }

    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: fields.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final field = fields[index];
        return ListTile(
          leading: const Icon(Icons.straighten),
          title: Text('${field['field_key']}'),
          subtitle: Text('${field['label_key']}'),
          trailing: Text('${field['unit']}'),
        );
      },
    );
  }
}

class _DropdownSection extends StatelessWidget {
  const _DropdownSection({
    required this.label,
    required this.value,
    required this.items,
    required this.textKey,
    required this.onChanged,
  });

  final String label;
  final int? value;
  final List<Map<String, Object?>> items;
  final String textKey;
  final ValueChanged<int?> onChanged;

  @override
  Widget build(BuildContext context) {
    return DropdownButtonFormField<int>(
      value: value,
      decoration: InputDecoration(labelText: label),
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
