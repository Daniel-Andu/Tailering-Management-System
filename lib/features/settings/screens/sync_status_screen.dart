import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/providers/auth_provider.dart';
import 'package:tailoring_system/services/customer_sync_service.dart';

class SyncStatusScreen extends StatefulWidget {
  const SyncStatusScreen({super.key});

  @override
  State<SyncStatusScreen> createState() => _SyncStatusScreenState();
}

class _SyncStatusScreenState extends State<SyncStatusScreen> {
  final CustomerSyncService _syncService = CustomerSyncService();
  bool _isSyncing = false;
  Map<String, int>? _syncStats;
  String? _lastSyncResult;

  @override
  void initState() {
    super.initState();
    _loadSyncStats();
  }

  Future<void> _loadSyncStats() async {
    final stats = await _syncService.getSyncStats();
    if (mounted) {
      setState(() {
        _syncStats = stats;
      });
    }
  }

  Future<void> _performFullSync() async {
    if (_isSyncing) return;

    setState(() {
      _isSyncing = true;
      _lastSyncResult = null;
    });

    try {
      final result = await _syncService.fullSync();
      await _loadSyncStats(); // Refresh stats

      if (mounted) {
        setState(() {
          _lastSyncResult =
              'Synced ${result['pushed']} to cloud, pulled ${result['pulled']} from cloud';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(_lastSyncResult!),
            backgroundColor: Colors.green,
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _lastSyncResult = 'Sync failed: $e';
        });

        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Sync failed: $e'),
            backgroundColor: Colors.red,
            duration: const Duration(seconds: 4),
          ),
        );
      }
    } finally {
      if (mounted) {
        setState(() {
          _isSyncing = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final authProvider = context.watch<AuthProvider>();
    final isAuthenticated = authProvider.isAuthenticated;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Cloud Sync Status'),
      ),
      body: RefreshIndicator(
        onRefresh: _loadSyncStats,
        child: ListView(
          padding: const EdgeInsets.all(16),
          children: [
            // ── Authentication Status ───────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(
                          isAuthenticated
                              ? Icons.cloud_done
                              : Icons.cloud_off,
                          color: isAuthenticated
                              ? Colors.green
                              : Colors.orange,
                          size: 32,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                isAuthenticated
                                    ? 'Connected to Cloud'
                                    : 'Offline Mode',
                                style: theme.textTheme.titleLarge?.copyWith(
                                  fontWeight: FontWeight.bold,
                                  color: isAuthenticated
                                      ? Colors.green
                                      : Colors.orange,
                                ),
                              ),
                              const SizedBox(height: 4),
                              Text(
                                isAuthenticated
                                    ? authProvider.currentUser?.email ??
                                        'Logged in'
                                    : 'Login to enable cloud sync',
                                style: TextStyle(
                                  color: Colors.grey.shade600,
                                  fontSize: 13,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── Sync Statistics ─────────────────────────────────────────
            if (_syncStats != null) ...[
              Card(
                child: Padding(
                  padding: const EdgeInsets.all(20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.analytics_outlined,
                              color: theme.colorScheme.primary, size: 24),
                          const SizedBox(width: 12),
                          Text(
                            'Customer Sync Statistics',
                            style: theme.textTheme.titleMedium?.copyWith(
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: 20),
                      _StatRow(
                        icon: Icons.people,
                        label: 'Total Customers',
                        value: '${_syncStats!['total']}',
                        color: theme.colorScheme.primary,
                      ),
                      const SizedBox(height: 12),
                      _StatRow(
                        icon: Icons.check_circle,
                        label: 'Synced',
                        value: '${_syncStats!['synced']}',
                        color: Colors.green,
                      ),
                      const SizedBox(height: 12),
                      _StatRow(
                        icon: Icons.pending,
                        label: 'Pending Sync',
                        value: '${_syncStats!['pending']}',
                        color: Colors.orange,
                      ),
                      const SizedBox(height: 12),
                      _StatRow(
                        icon: Icons.error,
                        label: 'Sync Errors',
                        value: '${_syncStats!['error']}',
                        color: Colors.red,
                      ),
                    ],
                  ),
                ),
              ),
            ],

            const SizedBox(height: 16),

            // ── Sync Actions ────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.sync,
                            color: theme.colorScheme.primary, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'Sync Actions',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: FilledButton.icon(
                        onPressed:
                            (isAuthenticated && !_isSyncing)
                                ? _performFullSync
                                : null,
                        icon: _isSyncing
                            ? const SizedBox(
                                width: 20,
                                height: 20,
                                child: CircularProgressIndicator(
                                  strokeWidth: 2,
                                  color: Colors.white,
                                ),
                              )
                            : const Icon(Icons.sync),
                        label: Text(_isSyncing ? 'Syncing...' : 'Sync Now'),
                      ),
                    ),
                    if (_lastSyncResult != null) ...[
                      const SizedBox(height: 12),
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: theme.colorScheme.surfaceContainerHighest,
                          borderRadius: BorderRadius.circular(10),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              Icons.info_outline,
                              size: 18,
                              color: theme.colorScheme.primary,
                            ),
                            const SizedBox(width: 8),
                            Expanded(
                              child: Text(
                                _lastSyncResult!,
                                style: const TextStyle(fontSize: 13),
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ],
                ),
              ),
            ),

            const SizedBox(height: 16),

            // ── How It Works ────────────────────────────────────────────
            Card(
              child: Padding(
                padding: const EdgeInsets.all(20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Icon(Icons.help_outline,
                            color: theme.colorScheme.primary, size: 24),
                        const SizedBox(width: 12),
                        Text(
                          'How Cloud Sync Works',
                          style: theme.textTheme.titleMedium?.copyWith(
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    _InfoTile(
                      icon: Icons.offline_bolt,
                      title: 'Offline-First',
                      description:
                          'Work anytime, even without internet. All data is saved locally.',
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      icon: Icons.cloud_upload,
                      title: 'Auto Background Sync',
                      description:
                          'Changes sync automatically when connected to internet.',
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      icon: Icons.devices,
                      title: 'Multi-Device',
                      description:
                          'Access your data from multiple devices seamlessly.',
                    ),
                    const SizedBox(height: 12),
                    _InfoTile(
                      icon: Icons.security,
                      title: 'Secure & Private',
                      description:
                          'Your data is encrypted and only you can access it.',
                    ),
                  ],
                ),
              ),
            ),

            const SizedBox(height: 32),
          ],
        ),
      ),
    );
  }
}

class _StatRow extends StatelessWidget {
  const _StatRow({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  final IconData icon;
  final String label;
  final String value;
  final Color color;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Icon(icon, color: color, size: 20),
        const SizedBox(width: 12),
        Expanded(
          child: Text(
            label,
            style: const TextStyle(fontSize: 15),
          ),
        ),
        Text(
          value,
          style: TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
            color: color,
          ),
        ),
      ],
    );
  }
}

class _InfoTile extends StatelessWidget {
  const _InfoTile({
    required this.icon,
    required this.title,
    required this.description,
  });

  final IconData icon;
  final String title;
  final String description;

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Icon(icon, size: 20, color: Colors.grey.shade600),
        const SizedBox(width: 12),
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: const TextStyle(
                  fontWeight: FontWeight.w600,
                  fontSize: 14,
                ),
              ),
              const SizedBox(height: 2),
              Text(
                description,
                style: TextStyle(
                  fontSize: 13,
                  color: Colors.grey.shade600,
                ),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
