import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/features/customers/providers/customer_directory_provider.dart';
import 'package:tailoring_system/features/customers/providers/customer_profile_provider.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';

class CustomerDirectoryScreen extends StatefulWidget {
  const CustomerDirectoryScreen({super.key});

  @override
  State<CustomerDirectoryScreen> createState() =>
      _CustomerDirectoryScreenState();
}

class _CustomerDirectoryScreenState extends State<CustomerDirectoryScreen> {
  final _searchController = TextEditingController();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<CustomerDirectoryProvider>().search('');
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(title: Text(l10n.menuCustomers)),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateCustomerDialog,
        icon: const Icon(Icons.person_add_alt),
        label: Text(l10n.menuAddCustomer),
      ),
      body: Consumer<CustomerDirectoryProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SearchBar(
                  controller: _searchController,
                  hintText: l10n.customerListSearch,
                  leading: const Icon(Icons.search),
                  onChanged: provider.search,
                  trailing: [
                    if (_searchController.text.isNotEmpty)
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () {
                          _searchController.clear();
                          provider.search('');
                        },
                      ),
                  ],
                ),
              ),
              if (provider.errorMessage != null)
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(
                    provider.errorMessage!,
                    style:
                        TextStyle(color: Theme.of(context).colorScheme.error),
                  ),
                ),
              Expanded(
                child: provider.isLoading && provider.customers.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : provider.customers.isEmpty
                        ? const Center(child: Text('No customers found'))
                        : ListView.separated(
                            padding: const EdgeInsets.fromLTRB(16, 0, 16, 96),
                            itemCount: provider.customers.length,
                            separatorBuilder: (_, __) =>
                                const Divider(height: 1),
                            itemBuilder: (context, index) {
                              final customer = provider.customers[index];
                              return ListTile(
                                leading: CircleAvatar(
                                  child: Text(
                                    _initials('${customer['name'] ?? ''}'),
                                  ),
                                ),
                                title: Text('${customer['name'] ?? '-'}'),
                                subtitle: Text(
                                  '${customer['phone'] ?? ''}  ${customer['customer_code'] ?? customer['customerId'] ?? ''}\n'
                                  '${customer['businessName'] ?? ''}',
                                ),
                                isThreeLine: true,
                                trailing: Chip(
                                  label: Text(
                                      '${customer['category'] ?? 'regular'}'),
                                ),
                                onTap: () => _showCustomerProfile(customer),
                              );
                            },
                          ),
              ),
            ],
          );
        },
      ),
    );
  }

  Future<void> _showCustomerProfile(Map<String, Object?> customer) async {
    final customerId = customer['id'] as int?;
    if (customerId == null) return;
    await context.read<CustomerProfileProvider>().load(customerId);
    if (!mounted) return;

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      isScrollControlled: true,
      builder: (context) => Consumer<CustomerProfileProvider>(
        builder: (context, provider, _) {
          final stats = provider.stats;
          return DraggableScrollableSheet(
            expand: false,
            initialChildSize: 0.75,
            minChildSize: 0.4,
            maxChildSize: 0.95,
            builder: (context, scrollController) => ListView(
              controller: scrollController,
              padding: const EdgeInsets.all(16),
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(
                      '${customer['name'] ?? '-'}',
                      style: Theme.of(context).textTheme.headlineSmall,
                    ),
                    IconButton(
                      icon: const Icon(Icons.edit),
                      onPressed: () => _showEditCustomerDialog(customer),
                      tooltip: 'Edit Customer',
                    ),
                  ],
                ),
                const SizedBox(height: 4),
                Text('${customer['phone'] ?? ''}'),
                const SizedBox(height: 16),
                if (stats != null)
                  Wrap(
                    spacing: 12,
                    runSpacing: 12,
                    children: [
                      _ProfileMetric('Orders', stats.totalOrders.toString()),
                      _ProfileMetric(
                          'Completed', stats.completedOrders.toString()),
                      _ProfileMetric(
                        'Balance',
                        '${stats.totalBalance.toStringAsFixed(2)} ETB',
                      ),
                    ],
                  ),
                const SizedBox(height: 20),
                Text('Timeline',
                    style: Theme.of(context).textTheme.titleMedium),
                const SizedBox(height: 8),
                for (final event in provider.timeline)
                  ListTile(
                    contentPadding: EdgeInsets.zero,
                    leading: const Icon(Icons.timeline),
                    title: Text('${event['type']}  ${event['title'] ?? ''}'),
                    subtitle: Text('${event['occurred_at'] ?? ''}'),
                  ),
              ],
            ),
          );
        },
      ),
    );
  }

  Future<void> _showEditCustomerDialog(Map<String, Object?> customer) async {
    final l10n = AppLocalizations.of(context)!;
    final name = TextEditingController(text: customer['name']?.toString());
    final phone = TextEditingController(text: customer['phone']?.toString());
    final business =
        TextEditingController(text: customer['businessName']?.toString());
    final address =
        TextEditingController(text: customer['address']?.toString());
    final notes = TextEditingController(text: customer['notes']?.toString());
    var category = customer['category']?.toString() ?? 'regular';
    var language = customer['preferred_language']?.toString() ?? 'am';

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.edit,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(l10n.customersEditCustomer,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                TextField(
                                  controller: name,
                                  decoration: InputDecoration(
                                    labelText: l10n.customersFullName,
                                    prefixIcon: const Icon(Icons.person),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: phone,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: l10n.customersPhone,
                                    prefixIcon: const Icon(Icons.phone),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: business,
                                  decoration: InputDecoration(
                                    labelText: l10n.customersBusinessName,
                                    prefixIcon: const Icon(Icons.business),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: address,
                                  decoration: InputDecoration(
                                    labelText: l10n.customersAddress,
                                    prefixIcon: const Icon(Icons.location_on),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                DropdownButtonFormField<String>(
                                  value: category,
                                  decoration: InputDecoration(
                                    labelText: l10n.customersCategory,
                                    prefixIcon: const Icon(Icons.category),
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                        value: 'regular',
                                        child: Text(l10n.customersRegular)),
                                    DropdownMenuItem(
                                        value: 'vip',
                                        child: Text(l10n.customersVIP)),
                                    DropdownMenuItem(
                                      value: 'organization',
                                      child: Text(l10n.customersOrganization),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null)
                                      setDialogState(() => category = value);
                                  },
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: language,
                                  decoration: InputDecoration(
                                    labelText: l10n.customersLanguage,
                                    prefixIcon: const Icon(Icons.language),
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                        value: 'am',
                                        child: Text(l10n.customersAmharic)),
                                    DropdownMenuItem(
                                        value: 'en',
                                        child: Text(l10n.customersEnglish)),
                                  ],
                                  onChanged: (value) {
                                    if (value != null)
                                      setDialogState(() => language = value);
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: notes,
                                  decoration: InputDecoration(
                                    labelText: l10n.customersNotes,
                                    prefixIcon: const Icon(Icons.note),
                                  ),
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.customersCancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(l10n.customersSaveChanges),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (shouldSave != true || !mounted) return;
    final customerId = customer['id'] as int?;
    if (customerId == null) return;

    await context.read<CustomerDirectoryProvider>().updateCustomer(
          customerId: customerId,
          fullName: name.text.trim(),
          phone: phone.text.trim(),
          businessName: business.text.trim(),
          address: address.text.trim(),
          category: category,
          preferredLanguage: language,
          notes: notes.text.trim(),
        );
  }

  Future<void> _showCreateCustomerDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final name = TextEditingController();
    final phone = TextEditingController();
    final business = TextEditingController();
    final address = TextEditingController();
    final notes = TextEditingController();
    var category = 'regular';
    var language = 'am';

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 500, maxHeight: 600),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                // Header
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.primaryContainer,
                    borderRadius: const BorderRadius.only(
                      topLeft: Radius.circular(20),
                      topRight: Radius.circular(20),
                    ),
                  ),
                  child: Row(
                    children: [
                      Icon(Icons.person_add_alt,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(l10n.customersNewCustomer,
                          style: const TextStyle(
                              fontSize: 20, fontWeight: FontWeight.bold)),
                      const Spacer(),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(context, false),
                      ),
                    ],
                  ),
                ),
                // Content
                Expanded(
                  child: SingleChildScrollView(
                    padding: const EdgeInsets.all(20),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                TextField(
                                  controller: name,
                                  decoration: InputDecoration(
                                    labelText: l10n.customersFullName,
                                    prefixIcon: const Icon(Icons.person),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: phone,
                                  keyboardType: TextInputType.phone,
                                  decoration: InputDecoration(
                                    labelText: l10n.customersPhone,
                                    prefixIcon: const Icon(Icons.phone),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: business,
                                  decoration: InputDecoration(
                                    labelText: l10n.customersBusinessName,
                                    prefixIcon: const Icon(Icons.business),
                                  ),
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: address,
                                  decoration: InputDecoration(
                                    labelText: l10n.customersAddress,
                                    prefixIcon: const Icon(Icons.location_on),
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                DropdownButtonFormField<String>(
                                  value: category,
                                  decoration: InputDecoration(
                                    labelText: l10n.customersCategory,
                                    prefixIcon: const Icon(Icons.category),
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                        value: 'regular',
                                        child: Text(l10n.customersRegular)),
                                    DropdownMenuItem(
                                        value: 'vip',
                                        child: Text(l10n.customersVIP)),
                                    DropdownMenuItem(
                                      value: 'organization',
                                      child: Text(l10n.customersOrganization),
                                    ),
                                  ],
                                  onChanged: (value) {
                                    if (value != null)
                                      setDialogState(() => category = value);
                                  },
                                ),
                                const SizedBox(height: 12),
                                DropdownButtonFormField<String>(
                                  value: language,
                                  decoration: InputDecoration(
                                    labelText: l10n.customersLanguage,
                                    prefixIcon: const Icon(Icons.language),
                                  ),
                                  items: [
                                    DropdownMenuItem(
                                        value: 'am',
                                        child: Text(l10n.customersAmharic)),
                                    DropdownMenuItem(
                                        value: 'en',
                                        child: Text(l10n.customersEnglish)),
                                  ],
                                  onChanged: (value) {
                                    if (value != null)
                                      setDialogState(() => language = value);
                                  },
                                ),
                                const SizedBox(height: 12),
                                TextField(
                                  controller: notes,
                                  decoration: InputDecoration(
                                    labelText: l10n.customersNotes,
                                    prefixIcon: const Icon(Icons.note),
                                  ),
                                  maxLines: 3,
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                // Footer
                Container(
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      top: BorderSide(
                        color: Theme.of(context).dividerColor,
                        width: 1,
                      ),
                    ),
                  ),
                  child: Row(
                    children: [
                      Expanded(
                        child: OutlinedButton(
                          onPressed: () => Navigator.pop(context, false),
                          child: Text(l10n.customersCancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(l10n.customersCreateCustomer),
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );

    if (shouldSave != true || !mounted) return;
    await context.read<CustomerDirectoryProvider>().createCustomer(
          fullName: name.text.trim(),
          phone: phone.text.trim(),
          businessName: business.text.trim(),
          address: address.text.trim(),
          category: category,
          preferredLanguage: language,
          notes: notes.text.trim(),
        );
  }

  String _initials(String value) {
    final parts = value.trim().split(RegExp(r'\s+'));
    if (parts.isEmpty || parts.first.isEmpty) return '?';
    if (parts.length == 1) return parts.first.characters.first.toUpperCase();
    return '${parts.first.characters.first}${parts.last.characters.first}'
        .toUpperCase();
  }
}

class _ProfileMetric extends StatelessWidget {
  const _ProfileMetric(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 150,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(value, style: Theme.of(context).textTheme.titleMedium),
            ],
          ),
        ),
      ),
    );
  }
}
