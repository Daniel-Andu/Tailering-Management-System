import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/core/domain/order_status.dart';
import 'package:tailoring_system/core/domain/payment_method.dart';
import 'package:tailoring_system/features/orders/providers/order_board_provider.dart';
import 'package:tailoring_system/features/orders/screens/order_detail_screen.dart';
import 'package:tailoring_system/features/payments/providers/payment_provider.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';

class OrderBoardScreen extends StatefulWidget {
  const OrderBoardScreen({super.key});

  @override
  State<OrderBoardScreen> createState() => _OrderBoardScreenState();
}

class _OrderBoardScreenState extends State<OrderBoardScreen> {
  final _searchController = TextEditingController();
  String? _status;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<OrderBoardProvider>().load();
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
      appBar: AppBar(
        title: Text(l10n.ordersTitle),
        actions: [
          IconButton(
            tooltip: l10n.ordersRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<OrderBoardProvider>().load(
                  status: _status,
                  query: _searchController.text,
                ),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateOrderDialog,
        icon: const Icon(Icons.add),
        label: Text(l10n.ordersAdd),
      ),
      body: Consumer<OrderBoardProvider>(
        builder: (context, provider, _) {
          return Column(
            children: [
              Padding(
                padding: const EdgeInsets.all(16),
                child: SearchBar(
                  controller: _searchController,
                  hintText: l10n.ordersSearch,
                  leading: const Icon(Icons.search),
                  onChanged: (value) {
                    provider.load(status: _status, query: value);
                  },
                ),
              ),
              SizedBox(
                height: 48,
                child: ListView(
                  scrollDirection: Axis.horizontal,
                  padding: const EdgeInsets.symmetric(horizontal: 16),
                  children: [
                    Padding(
                      padding: const EdgeInsets.only(right: 8),
                      child: ChoiceChip(
                        label: Text(l10n.ordersAll),
                        selected: _status == null,
                        onSelected: (_) => _setStatus(null),
                      ),
                    ),
                    for (final status in OrderStatuses.values)
                      Padding(
                        padding: const EdgeInsets.only(right: 8),
                        child: ChoiceChip(
                          label: Text(status.replaceAll('_', ' ')),
                          selected: _status == status,
                          onSelected: (_) => _setStatus(status),
                        ),
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
                child: provider.isLoading && provider.orders.isEmpty
                    ? const Center(child: CircularProgressIndicator())
                    : provider.orders.isEmpty
                        ? Center(child: Text(l10n.ordersNoOrders))
                        : LayoutBuilder(
                            builder: (context, constraints) {
                              final wide = constraints.maxWidth >= 900;
                              if (wide) {
                                return GridView.builder(
                                  padding:
                                      const EdgeInsets.fromLTRB(16, 8, 16, 96),
                                  gridDelegate:
                                      const SliverGridDelegateWithMaxCrossAxisExtent(
                                    maxCrossAxisExtent: 420,
                                    mainAxisExtent: 214,
                                    crossAxisSpacing: 12,
                                    mainAxisSpacing: 12,
                                  ),
                                  itemCount: provider.orders.length,
                                  itemBuilder: (context, index) => _OrderCard(
                                    order: provider.orders[index],
                                    onStatusChanged: provider.changeStatus,
                                    onPaymentRecorded: () => provider.load(
                                      status: _status,
                                      query: _searchController.text,
                                    ),
                                  ),
                                );
                              }
                              return ListView.builder(
                                padding:
                                    const EdgeInsets.fromLTRB(16, 8, 16, 96),
                                itemCount: provider.orders.length,
                                itemBuilder: (context, index) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: _OrderCard(
                                    order: provider.orders[index],
                                    onStatusChanged: provider.changeStatus,
                                    onPaymentRecorded: () => provider.load(
                                      status: _status,
                                      query: _searchController.text,
                                    ),
                                  ),
                                ),
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

  void _setStatus(String? status) {
    setState(() => _status = status);
    context.read<OrderBoardProvider>().load(
          status: status,
          query: _searchController.text,
        );
  }

  Future<void> _showCreateOrderDialog() async {
    final l10n = AppLocalizations.of(context)!;
    final customerIdController = TextEditingController();
    final clothTypeController = TextEditingController(text: 'Shirt');
    final priceController = TextEditingController();
    final paidAmountController = TextEditingController();
    final notesController = TextEditingController();
    var gender = 'male';
    var priority = OrderPriorities.normal;
    var urgency = OrderUrgencyLevels.normal;
    var deliveryDate = DateTime.now().add(const Duration(days: 7));

    // Measurement controllers
    final chestController = TextEditingController();
    final shoulderController = TextEditingController();
    final hipController = TextEditingController();
    final breastController = TextEditingController();
    final waistController = TextEditingController();
    final lengthController = TextEditingController();
    final sleeveController = TextEditingController();
    final neckController = TextEditingController();
    String? clothPhotoPath;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => Dialog(
          child: Container(
            constraints: const BoxConstraints(maxWidth: 600, maxHeight: 700),
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
                      Icon(Icons.add_circle_outline,
                          color: Theme.of(context).colorScheme.primary),
                      const SizedBox(width: 12),
                      Text(l10n.ordersNewOrder,
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
                        // Basic Info Section
                        _buildSectionHeader(l10n.ordersBasicInfo),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: TextField(
                                controller: customerIdController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: l10n.ordersCustomerId,
                                  prefixIcon: const Icon(Icons.person),
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: clothTypeController,
                                decoration: InputDecoration(
                                  labelText: l10n.ordersClothType,
                                  prefixIcon: const Icon(Icons.checkroom),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: gender,
                                decoration: InputDecoration(
                                  labelText: l10n.ordersGender,
                                  prefixIcon: const Icon(Icons.wc),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'male', child: Text('Male')),
                                  DropdownMenuItem(
                                      value: 'female', child: Text('Female')),
                                ],
                                onChanged: (value) {
                                  if (value != null)
                                    setDialogState(() => gender = value);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: TextField(
                                controller: priceController,
                                keyboardType: TextInputType.number,
                                decoration: InputDecoration(
                                  labelText: l10n.ordersPrice,
                                  prefixIcon: const Icon(Icons.attach_money),
                                ),
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 20),

                        // Measurements Section
                        _buildSectionHeader(l10n.ordersMeasurements),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildMeasurementField(
                                          chestController, l10n.ordersChest),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildMeasurementField(
                                          shoulderController,
                                          l10n.ordersShoulder),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildMeasurementField(
                                          hipController, l10n.ordersHip),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildMeasurementField(
                                          breastController, l10n.ordersBreast),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildMeasurementField(
                                          waistController, l10n.ordersWaist),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildMeasurementField(
                                          lengthController, l10n.ordersLength),
                                    ),
                                  ],
                                ),
                                const SizedBox(height: 12),
                                Row(
                                  children: [
                                    Expanded(
                                      child: _buildMeasurementField(
                                          sleeveController, l10n.ordersSleeve),
                                    ),
                                    const SizedBox(width: 12),
                                    Expanded(
                                      child: _buildMeasurementField(
                                          neckController, l10n.ordersNeck),
                                    ),
                                  ],
                                ),
                              ],
                            ),
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Photo Upload
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.camera_alt),
                            title: Text(l10n.ordersUploadPhoto),
                            subtitle:
                                Text(clothPhotoPath ?? l10n.ordersNoPhoto),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () async {
                              final picker = ImagePicker();
                              final pickedFile = await picker.pickImage(
                                source: ImageSource.gallery,
                                imageQuality: 80,
                              );
                              if (pickedFile != null) {
                                setDialogState(
                                    () => clothPhotoPath = pickedFile.path);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 20),

                        // Order Details Section
                        _buildSectionHeader(l10n.ordersOrderDetails),
                        const SizedBox(height: 12),
                        Row(
                          children: [
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: priority,
                                decoration: InputDecoration(
                                  labelText: l10n.ordersPriority,
                                  prefixIcon: const Icon(Icons.flag),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'low', child: Text('Low')),
                                  DropdownMenuItem(
                                      value: 'normal', child: Text('Normal')),
                                  DropdownMenuItem(
                                      value: 'high', child: Text('High')),
                                ],
                                onChanged: (value) {
                                  if (value != null)
                                    setDialogState(() => priority = value);
                                },
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: DropdownButtonFormField<String>(
                                value: urgency,
                                decoration: InputDecoration(
                                  labelText: l10n.ordersUrgency,
                                  prefixIcon: const Icon(Icons.speed),
                                ),
                                items: const [
                                  DropdownMenuItem(
                                      value: 'normal', child: Text('Normal')),
                                  DropdownMenuItem(
                                      value: 'urgent', child: Text('Urgent')),
                                  DropdownMenuItem(
                                      value: 'express', child: Text('Express')),
                                ],
                                onChanged: (value) {
                                  if (value != null)
                                    setDialogState(() => urgency = value);
                                },
                              ),
                            ),
                          ],
                        ),
                        const SizedBox(height: 12),
                        Card(
                          child: ListTile(
                            leading: const Icon(Icons.calendar_month),
                            title: Text(l10n.ordersDeliveryDate),
                            subtitle: Text(
                                '${deliveryDate.day}/${deliveryDate.month}/${deliveryDate.year}'),
                            trailing:
                                const Icon(Icons.arrow_forward_ios, size: 16),
                            onTap: () async {
                              final picked = await showDatePicker(
                                context: context,
                                initialDate: deliveryDate,
                                firstDate: DateTime.now(),
                                lastDate: DateTime(2100),
                              );
                              if (picked != null) {
                                setDialogState(() => deliveryDate = picked);
                              }
                            },
                          ),
                        ),
                        const SizedBox(height: 12),
                        TextField(
                          controller: notesController,
                          decoration: InputDecoration(
                            labelText: l10n.ordersNotes,
                            prefixIcon: const Icon(Icons.note),
                          ),
                          maxLines: 3,
                        ),
                        const SizedBox(height: 20),
                        // Payment Section
                        _buildSectionHeader(l10n.ordersPaymentSection),
                        const SizedBox(height: 12),
                        Card(
                          child: Padding(
                            padding: const EdgeInsets.all(16),
                            child: Column(
                              children: [
                                TextField(
                                  controller: paidAmountController,
                                  keyboardType: TextInputType.number,
                                  decoration: InputDecoration(
                                    labelText: l10n.ordersPaidAmount,
                                    hintText: l10n.ordersPaidAmountHint,
                                    prefixIcon: const Icon(Icons.payments),
                                  ),
                                  onChanged: (value) => setDialogState(() {}),
                                ),
                                const SizedBox(height: 12),
                                Builder(
                                  builder: (context) {
                                    final price =
                                        double.tryParse(priceController.text) ??
                                            0;
                                    final paid = double.tryParse(
                                            paidAmountController.text) ??
                                        0;
                                    final balance = price - paid;
                                    return Container(
                                      padding: const EdgeInsets.all(12),
                                      decoration: BoxDecoration(
                                        color: balance > 0
                                            ? Theme.of(context)
                                                .colorScheme
                                                .errorContainer
                                            : Theme.of(context)
                                                .colorScheme
                                                .tertiaryContainer,
                                        borderRadius: BorderRadius.circular(8),
                                      ),
                                      child: Row(
                                        mainAxisAlignment:
                                            MainAxisAlignment.spaceBetween,
                                        children: [
                                          Text(
                                            l10n.ordersRemainingBalance,
                                            style: TextStyle(
                                              fontWeight: FontWeight.w600,
                                              color: balance > 0
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onErrorContainer
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onTertiaryContainer,
                                            ),
                                          ),
                                          Text(
                                            '${balance.toStringAsFixed(2)} ETB',
                                            style: TextStyle(
                                              fontWeight: FontWeight.bold,
                                              fontSize: 18,
                                              color: balance > 0
                                                  ? Theme.of(context)
                                                      .colorScheme
                                                      .onErrorContainer
                                                  : Theme.of(context)
                                                      .colorScheme
                                                      .onTertiaryContainer,
                                            ),
                                          ),
                                        ],
                                      ),
                                    );
                                  },
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
                          child: Text(l10n.ordersCancel),
                        ),
                      ),
                      const SizedBox(width: 12),
                      Expanded(
                        child: FilledButton(
                          onPressed: () => Navigator.pop(context, true),
                          child: Text(l10n.ordersCreateOrder),
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
    final customerId = int.tryParse(customerIdController.text);
    final price = double.tryParse(priceController.text);
    if (customerId == null || price == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
            content: Text('Please enter valid Customer ID and Price')),
      );
      return;
    }

    try {
      await context.read<OrderBoardProvider>().createOrder(
            customerId: customerId,
            clothType: clothTypeController.text.trim(),
            price: price,
            deliveryDate: deliveryDate,
            priority: priority,
            urgencyLevel: urgency,
            notes: notesController.text.trim(),
            gender: gender,
            chest: double.tryParse(chestController.text),
            shoulder: double.tryParse(shoulderController.text),
            hip: double.tryParse(hipController.text),
            breast: double.tryParse(breastController.text),
            waist: double.tryParse(waistController.text),
            length: double.tryParse(lengthController.text),
            sleeve: double.tryParse(sleeveController.text),
            neck: double.tryParse(neckController.text),
            clothPhoto: clothPhotoPath,
          );
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Order created successfully')),
        );
      }
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error creating order: $e')),
        );
      }
    }
  }

  Widget _buildSectionHeader(String title) {
    return Text(
      title,
      style: const TextStyle(
        fontSize: 16,
        fontWeight: FontWeight.bold,
        color: Color(0xFF6366F1),
      ),
    );
  }

  Widget _buildMeasurementField(
      TextEditingController controller, String label) {
    return TextField(
      controller: controller,
      keyboardType: TextInputType.number,
      decoration: InputDecoration(
        labelText: label,
        filled: true,
        fillColor: Colors.grey[50],
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(8),
          borderSide: BorderSide.none,
        ),
      ),
    );
  }
}

class _OrderCard extends StatelessWidget {
  const _OrderCard({
    required this.order,
    required this.onStatusChanged,
    required this.onPaymentRecorded,
  });

  final Map<String, Object?> order;
  final Future<void> Function(int orderId, String status) onStatusChanged;
  final Future<void> Function() onPaymentRecorded;

  @override
  Widget build(BuildContext context) {
    final orderId = order['id'] as int;
    final status = order['status'] as String? ?? OrderStatuses.confirmed;
    final balance =
        ((order['balance_amount'] as num?)?.toDouble() ?? 0).toStringAsFixed(2);

    return Card(
      child: InkWell(
        onTap: () {
          Navigator.of(context).push(
            MaterialPageRoute(
              builder: (_) => OrderDetailScreen(orderId: orderId),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(14),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Expanded(
                    child: Text(
                      '${order['order_number'] ?? 'Order #$orderId'}',
                      style: Theme.of(context).textTheme.titleMedium,
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  Chip(label: Text(status.replaceAll('_', ' '))),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                '${order['customer_name'] ?? '-'}  ${order['customer_phone'] ?? ''}',
              ),
              const SizedBox(height: 4),
              Text('${order['clothType']}  ${order['price']} ETB'),
              const SizedBox(height: 4),
              Text(
                'Due: ${order['expected_delivery_date'] ?? order['deliveryDate'] ?? '-'}',
              ),
              const Spacer(),
              Row(
                children: [
                  Text('Balance: $balance ETB'),
                  const Spacer(),
                  IconButton(
                    tooltip: 'Record payment',
                    icon: const Icon(Icons.payments_outlined),
                    onPressed: () => _showPaymentDialog(context, balance),
                  ),
                  PopupMenuButton<String>(
                    tooltip: 'Change status',
                    onSelected: (value) => onStatusChanged(orderId, value),
                    itemBuilder: (context) => [
                      for (final value in OrderStatuses.values)
                        PopupMenuItem(
                          value: value,
                          child: Text(value.replaceAll('_', ' ')),
                        ),
                    ],
                    child: const Icon(Icons.more_vert),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Future<void> _showPaymentDialog(BuildContext context, String balance) async {
    final amountController = TextEditingController(text: balance);
    final referenceController = TextEditingController();
    var method = PaymentMethods.cash;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('Record Payment'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount'),
              ),
              DropdownButtonFormField<String>(
                value: method,
                decoration: const InputDecoration(labelText: 'Payment method'),
                items: const [
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'bank_transfer', child: Text('Bank')),
                  DropdownMenuItem(value: 'telebirr', child: Text('Telebirr')),
                  DropdownMenuItem(value: 'cbe_birr', child: Text('CBE Birr')),
                  DropdownMenuItem(value: 'chapa', child: Text('Chapa')),
                  DropdownMenuItem(
                    value: 'mobile_money',
                    child: Text('Mobile Money'),
                  ),
                ],
                onChanged: (value) {
                  if (value != null) setDialogState(() => method = value);
                },
              ),
              TextField(
                controller: referenceController,
                decoration: const InputDecoration(
                  labelText: 'Reference / transaction ID',
                ),
              ),
            ],
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
      ),
    );

    if (shouldSave != true || !context.mounted) return;
    final amount = double.tryParse(amountController.text);
    final customerId = order['customerId'] as int?;
    if (amount == null || customerId == null) return;

    await context.read<PaymentProvider>().recordPayment(
          orderId: order['id'] as int,
          customerId: customerId,
          amount: amount,
          paymentMethod: method,
          transactionReference: referenceController.text.trim(),
        );
    await onPaymentRecorded();
  }
}
