import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/features/appointments/providers/appointment_provider.dart';

class AppointmentsScreen extends StatefulWidget {
  const AppointmentsScreen({super.key});

  @override
  State<AppointmentsScreen> createState() => _AppointmentsScreenState();
}

class _AppointmentsScreenState extends State<AppointmentsScreen> {
  DateTime _selectedDay = DateTime.now();

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppointmentProvider>().loadDay(_selectedDay);
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Appointments'),
        actions: [
          IconButton(
            tooltip: 'Pick day',
            icon: const Icon(Icons.calendar_month),
            onPressed: _pickDay,
          ),
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () =>
                context.read<AppointmentProvider>().loadDay(_selectedDay),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showCreateAppointmentDialog,
        icon: const Icon(Icons.add),
        label: const Text('Appointment'),
      ),
      body: Consumer<AppointmentProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.appointments.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }
          if (provider.appointments.isEmpty) {
            return const Center(child: Text('No appointments for this day'));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.appointments.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = provider.appointments[index];
              return ListTile(
                leading: const Icon(Icons.event_available),
                title: Text('${item['customer_name'] ?? '-'}'),
                subtitle: Text(
                  '${item['appointment_type']}  ${item['scheduled_at']}\n'
                  '${item['customer_phone'] ?? ''} ${item['order_number'] ?? ''}',
                ),
                isThreeLine: true,
                trailing: Text('${item['status']}'),
              );
            },
          );
        },
      ),
    );
  }

  Future<void> _pickDay() async {
    final picked = await showDatePicker(
      context: context,
      initialDate: _selectedDay,
      firstDate: DateTime(2020),
      lastDate: DateTime(2100),
    );
    if (picked == null || !mounted) return;
    setState(() => _selectedDay = picked);
    await context.read<AppointmentProvider>().loadDay(picked);
  }

  Future<void> _showCreateAppointmentDialog() async {
    final customerIdController = TextEditingController();
    final orderIdController = TextEditingController();
    final typeController = TextEditingController(text: 'fitting');
    final notesController = TextEditingController();
    var scheduledAt = DateTime.now().add(const Duration(hours: 1));

    final shouldSave = await showDialog<bool>(
      context: context,
      builder: (context) => StatefulBuilder(
        builder: (context, setDialogState) => AlertDialog(
          title: const Text('New Appointment'),
          content: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                TextField(
                  controller: customerIdController,
                  keyboardType: TextInputType.number,
                  decoration: const InputDecoration(labelText: 'Customer ID'),
                ),
                TextField(
                  controller: orderIdController,
                  keyboardType: TextInputType.number,
                  decoration:
                      const InputDecoration(labelText: 'Order ID (optional)'),
                ),
                TextField(
                  controller: typeController,
                  decoration:
                      const InputDecoration(labelText: 'Type, e.g. fitting'),
                ),
                TextField(
                  controller: notesController,
                  decoration: const InputDecoration(labelText: 'Notes'),
                ),
                const SizedBox(height: 12),
                ListTile(
                  contentPadding: EdgeInsets.zero,
                  title: const Text('Scheduled time'),
                  subtitle: Text(scheduledAt.toString()),
                  trailing: const Icon(Icons.schedule),
                  onTap: () async {
                    final date = await showDatePicker(
                      context: context,
                      initialDate: scheduledAt,
                      firstDate: DateTime.now().subtract(const Duration(days: 1)),
                      lastDate: DateTime(2100),
                    );
                    if (date == null || !context.mounted) return;
                    final time = await showTimePicker(
                      context: context,
                      initialTime: TimeOfDay.fromDateTime(scheduledAt),
                    );
                    if (time == null) return;
                    setDialogState(() {
                      scheduledAt = DateTime(
                        date.year,
                        date.month,
                        date.day,
                        time.hour,
                        time.minute,
                      );
                    });
                  },
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
      ),
    );

    if (shouldSave != true || !mounted) return;
    final customerId = int.tryParse(customerIdController.text);
    if (customerId == null) return;

    await context.read<AppointmentProvider>().createAppointment(
          customerId: customerId,
          scheduledAt: scheduledAt,
          appointmentType: typeController.text.trim(),
          orderId: int.tryParse(orderIdController.text),
          notes: notesController.text.trim(),
        );
    if (!mounted) return;
    setState(() => _selectedDay = scheduledAt);
  }
}
