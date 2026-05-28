import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/features/notifications/providers/notification_provider.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';

class NotificationsScreen extends StatefulWidget {
  const NotificationsScreen({super.key});

  @override
  State<NotificationsScreen> createState() => _NotificationsScreenState();
}

class _NotificationsScreenState extends State<NotificationsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<NotificationProvider>().loadPending();
    });
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.notificationsTitle),
        actions: [
          TextButton.icon(
            onPressed: () =>
                context.read<NotificationProvider>().processPendingSms(),
            icon: const Icon(Icons.send),
            label: Text(l10n.notificationsSendPending),
          ),
          IconButton(
            tooltip: l10n.notificationsRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<NotificationProvider>().loadPending(),
          ),
        ],
      ),
      body: Consumer<NotificationProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.pending.isEmpty) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }
          if (provider.pending.isEmpty) {
            return Center(child: Text(l10n.notificationsNoPending));
          }

          return ListView.separated(
            padding: const EdgeInsets.all(16),
            itemCount: provider.pending.length,
            separatorBuilder: (_, __) => const Divider(height: 1),
            itemBuilder: (context, index) {
              final item = provider.pending[index];
              return ListTile(
                leading: const Icon(Icons.sms_outlined),
                title: Text('${item['recipient']}'),
                subtitle: Text('${item['message']}'),
                trailing: Text('${item['language_code']}'),
              );
            },
          );
        },
      ),
    );
  }
}
