import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/core/domain/order_status.dart';
import 'package:tailoring_system/core/domain/payment_method.dart';
import 'package:tailoring_system/features/appointments/providers/appointment_provider.dart';
import 'package:tailoring_system/features/orders/providers/order_detail_provider.dart';
import 'package:tailoring_system/features/orders/providers/order_workflow_provider.dart';
import 'package:tailoring_system/features/payments/providers/payment_provider.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';

class OrderDetailScreen extends StatefulWidget {
  const OrderDetailScreen({super.key, required this.orderId});

  final int orderId;

  @override
  State<OrderDetailScreen> createState() => _OrderDetailScreenState();
}

class _OrderDetailScreenState extends State<OrderDetailScreen>
    with SingleTickerProviderStateMixin {
  late final TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 5, vsync: this);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  Future<void> _load() {
    return context.read<OrderDetailProvider>().load(widget.orderId);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Consumer<OrderDetailProvider>(
          builder: (context, provider, _) {
            final order = provider.order;
            return Text('${order?['order_number'] ?? 'Order'}');
          },
        ),
        actions: [
          IconButton(
            tooltip: l10n.orderDetailRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
          PopupMenuButton<String>(
            tooltip: l10n.orderDetailChangeStatus,
            onSelected: _changeStatus,
            itemBuilder: (context) => [
              for (final status in OrderStatuses.values)
                PopupMenuItem(
                  value: status,
                  child: Text(status.replaceAll('_', ' ')),
                ),
            ],
          ),
        ],
        bottom: TabBar(
          controller: _tabController,
          isScrollable: true,
          tabs: [
            Tab(text: l10n.orderDetailSummary),
            Tab(text: l10n.orderDetailPayments),
            Tab(text: l10n.orderDetailTimeline),
            Tab(text: l10n.orderDetailAppointments),
            Tab(text: l10n.orderDetailMessages),
          ],
        ),
      ),
      body: Consumer<OrderDetailProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.order == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }
          final order = provider.order;
          if (order == null) {
            return Center(child: Text(l10n.orderDetailOrderNotFound));
          }

          return TabBarView(
            controller: _tabController,
            children: [
              _SummaryTab(order: order, items: provider.items),
              _PaymentsTab(
                order: order,
                payments: provider.payments,
                onRecordPayment: _recordPayment,
              ),
              _TimelineTab(history: provider.history),
              _AppointmentsTab(
                appointments: provider.appointments,
                onCreateAppointment: _createAppointment,
              ),
              _MessagesTab(notifications: provider.notifications),
            ],
          );
        },
      ),
    );
  }

  Future<void> _changeStatus(String status) async {
    await context.read<OrderWorkflowProvider>().changeStatus(
          orderId: widget.orderId,
          newStatus: status,
        );
    await _load();
  }

  Future<void> _recordPayment(Map<String, Object?> order) async {
    final l10n = AppLocalizations.of(context)!;
    final amountController = TextEditingController(
      text: (((order['balance_amount'] as num?)?.toDouble() ?? 0)
          .toStringAsFixed(2)),
    );
    final referenceController = TextEditingController();
    var method = PaymentMethods.cash;

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.orderDetailRecordPayment),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: amountController,
                keyboardType: TextInputType.number,
                decoration: InputDecoration(labelText: l10n.orderDetailAmount),
              ),
              DropdownButtonFormField<String>(
                value: method,
                decoration:
                    InputDecoration(labelText: l10n.orderDetailPaymentMethod),
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
                decoration:
                    InputDecoration(labelText: l10n.orderDetailReference),
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.orderDetailCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.orderDetailSave),
            ),
          ],
        ),
      ),
    );

    if (shouldSave != true || !mounted) return;
    final amount = double.tryParse(amountController.text);
    final customerId = order['customerId'] as int?;
    if (amount == null || customerId == null) return;

    await context.read<PaymentProvider>().recordPayment(
          orderId: widget.orderId,
          customerId: customerId,
          amount: amount,
          paymentMethod: method,
          transactionReference: referenceController.text.trim(),
        );
    await _load();
  }

  Future<void> _createAppointment() async {
    final l10n = AppLocalizations.of(context)!;
    final provider = context.read<OrderDetailProvider>();
    final order = provider.order;
    if (order == null) return;

    final typeController = TextEditingController(text: 'fitting');
    final notesController = TextEditingController();
    var scheduledAt = DateTime.now().add(const Duration(days: 1));

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: Text(l10n.orderDetailScheduleAppointment),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              TextField(
                controller: typeController,
                decoration: InputDecoration(labelText: l10n.orderDetailType),
              ),
              TextField(
                controller: notesController,
                decoration: InputDecoration(labelText: l10n.orderDetailNotes),
              ),
              ListTile(
                contentPadding: EdgeInsets.zero,
                title: Text(l10n.orderDetailDate),
                subtitle: Text(scheduledAt.toString()),
                trailing: const Icon(Icons.calendar_month),
                onTap: () async {
                  final picked = await showDatePicker(
                    context: context,
                    initialDate: scheduledAt,
                    firstDate: DateTime.now(),
                    lastDate: DateTime(2100),
                  );
                  if (picked != null) {
                    setDialogState(() => scheduledAt = picked);
                  }
                },
              ),
            ],
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: Text(l10n.orderDetailCancel),
            ),
            FilledButton(
              onPressed: () => Navigator.pop(context, true),
              child: Text(l10n.orderDetailSave),
            ),
          ],
        ),
      ),
    );

    if (shouldSave != true || !mounted) return;
    await context.read<AppointmentProvider>().createAppointment(
          customerId: order['customerId'] as int,
          orderId: widget.orderId,
          appointmentType: typeController.text.trim(),
          scheduledAt: scheduledAt,
          notes: notesController.text.trim(),
        );
    await _load();
  }
}

class _SummaryTab extends StatelessWidget {
  const _SummaryTab({required this.order, required this.items});

  final Map<String, Object?> order;
  final List<Map<String, Object?>> items;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Wrap(
          spacing: 12,
          runSpacing: 12,
          children: [
            _InfoCard(
                l10n.orderDetailCustomer, '${order['customer_name'] ?? '-'}'),
            _InfoCard(
                l10n.orderDetailPhone, '${order['customer_phone'] ?? '-'}'),
            _InfoCard(l10n.orderDetailStatus, '${order['status'] ?? '-'}'),
            _InfoCard(l10n.orderDetailPriority, '${order['priority'] ?? '-'}'),
            _InfoCard(
                l10n.orderDetailUrgency, '${order['urgency_level'] ?? '-'}'),
            _InfoCard(l10n.orderDetailDelivery,
                '${order['expected_delivery_date'] ?? '-'}'),
            _InfoCard(
              l10n.orderDetailTotal,
              '${((order['total_amount'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)} ETB',
            ),
            _InfoCard(
              l10n.orderDetailBalance,
              '${((order['balance_amount'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)} ETB',
            ),
          ],
        ),
        const SizedBox(height: 24),
        Text(l10n.orderDetailItems,
            style: Theme.of(context).textTheme.titleMedium),
        const SizedBox(height: 8),
        for (final item in items)
          ListTile(
            leading: const Icon(Icons.checkroom),
            title: Text('${item['item_name']}'),
            subtitle: Text('${item['style_name'] ?? ''}'),
            trailing: Text('${item['total_price']} ETB'),
          ),
        if ((order['notes'] as String?)?.isNotEmpty == true) ...[
          const SizedBox(height: 16),
          Text(l10n.orderDetailNotes,
              style: Theme.of(context).textTheme.titleMedium),
          const SizedBox(height: 8),
          Text('${order['notes']}'),
        ],
      ],
    );
  }
}

class _PaymentsTab extends StatelessWidget {
  const _PaymentsTab({
    required this.order,
    required this.payments,
    required this.onRecordPayment,
  });

  final Map<String, Object?> order;
  final List<Map<String, Object?>> payments;
  final Future<void> Function(Map<String, Object?> order) onRecordPayment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FilledButton.icon(
          onPressed: () => onRecordPayment(order),
          icon: const Icon(Icons.payments_outlined),
          label: Text(l10n.orderDetailRecordPayment),
        ),
        const SizedBox(height: 16),
        if (payments.isEmpty)
          Center(child: Text(l10n.orderDetailNoPaymentsYet))
        else
          for (final payment in payments)
            ListTile(
              leading: const Icon(Icons.receipt_long),
              title: Text('${payment['amount']} ETB'),
              subtitle: Text(
                '${payment['payment_method']}  ${payment['paid_at']}',
              ),
              trailing: Text('${payment['receipt_number'] ?? ''}'),
            ),
      ],
    );
  }
}

class _TimelineTab extends StatelessWidget {
  const _TimelineTab({required this.history});

  final List<Map<String, Object?>> history;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (history.isEmpty)
      return Center(child: Text(l10n.orderDetailNoTimelineYet));
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: history.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = history[index];
        return ListTile(
          leading: const Icon(Icons.timeline),
          title: Text('${item['new_status']}'.replaceAll('_', ' ')),
          subtitle: Text('${item['changed_at']}\n${item['notes'] ?? ''}'),
          isThreeLine: true,
        );
      },
    );
  }
}

class _AppointmentsTab extends StatelessWidget {
  const _AppointmentsTab({
    required this.appointments,
    required this.onCreateAppointment,
  });

  final List<Map<String, Object?>> appointments;
  final VoidCallback onCreateAppointment;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        FilledButton.icon(
          onPressed: onCreateAppointment,
          icon: const Icon(Icons.event_outlined),
          label: Text(l10n.orderDetailScheduleAppointment),
        ),
        const SizedBox(height: 16),
        if (appointments.isEmpty)
          Center(child: Text(l10n.orderDetailNoAppointments))
        else
          for (final appointment in appointments)
            ListTile(
              leading: const Icon(Icons.event_available),
              title: Text('${appointment['appointment_type']}'),
              subtitle: Text('${appointment['scheduled_at']}'),
              trailing: Text('${appointment['status']}'),
            ),
      ],
    );
  }
}

class _MessagesTab extends StatelessWidget {
  const _MessagesTab({required this.notifications});

  final List<Map<String, Object?>> notifications;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    if (notifications.isEmpty) {
      return Center(child: Text(l10n.orderDetailNoMessagesQueued));
    }
    return ListView.separated(
      padding: const EdgeInsets.all(16),
      itemCount: notifications.length,
      separatorBuilder: (_, __) => const Divider(height: 1),
      itemBuilder: (context, index) {
        final item = notifications[index];
        return ListTile(
          leading: const Icon(Icons.sms_outlined),
          title: Text('${item['recipient']}  ${item['status']}'),
          subtitle: Text('${item['message']}'),
        );
      },
    );
  }
}

class _InfoCard extends StatelessWidget {
  const _InfoCard(this.label, this.value);

  final String label;
  final String value;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(label, style: Theme.of(context).textTheme.labelMedium),
              const SizedBox(height: 4),
              Text(
                value,
                maxLines: 2,
                overflow: TextOverflow.ellipsis,
                style: Theme.of(context).textTheme.titleSmall,
              ),
            ],
          ),
        ),
      ),
    );
  }
}
