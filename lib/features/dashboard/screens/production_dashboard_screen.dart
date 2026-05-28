import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/features/dashboard/data/dashboard_repository.dart';
import 'package:tailoring_system/features/dashboard/providers/dashboard_provider.dart';

class ProductionDashboardScreen extends StatefulWidget {
  const ProductionDashboardScreen({super.key});

  @override
  State<ProductionDashboardScreen> createState() =>
      _ProductionDashboardScreenState();
}

class _ProductionDashboardScreenState extends State<ProductionDashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().refresh();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    // Refresh data when dependencies change (e.g., language change)
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<DashboardProvider>().refresh();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
        actions: [
          IconButton(
            tooltip: 'Refresh',
            icon: const Icon(Icons.refresh),
            onPressed: () => context.read<DashboardProvider>().refresh(),
          ),
        ],
      ),
      body: Consumer<DashboardProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.summary == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }

          final summary = provider.summary;
          if (summary == null) {
            return const Center(child: Text('No dashboard data'));
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              return RefreshIndicator(
                onRefresh: provider.refresh,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    _SummaryGrid(summary: summary, isWide: isWide),
                    const SizedBox(height: 16),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _OrderPanel(
                              title: 'Due Soon',
                              orders: provider.dueSoonOrders,
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _OrderPanel(
                              title: 'Unpaid Balances',
                              orders: provider.unpaidOrders,
                              showBalance: true,
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _OrderPanel(
                        title: 'Due Soon',
                        orders: provider.dueSoonOrders,
                      ),
                      const SizedBox(height: 16),
                      _OrderPanel(
                        title: 'Unpaid Balances',
                        orders: provider.unpaidOrders,
                        showBalance: true,
                      ),
                    ],
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({
    required this.summary,
    required this.isWide,
  });

  final DashboardSummary summary;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final cards = [
      _MetricCard('Due Today', summary.dueToday.toString(), Icons.today),
      _MetricCard('Delayed', summary.delayedOrders.toString(), Icons.warning),
      _MetricCard('Ready', summary.readyForPickup.toString(), Icons.checkroom),
      _MetricCard('Open Orders', summary.openOrders.toString(), Icons.list_alt),
      _MetricCard(
          'Customers', summary.activeCustomers.toString(), Icons.people),
      _MetricCard(
        'Unpaid',
        '${summary.unpaidBalance.toStringAsFixed(2)} ETB',
        Icons.account_balance_wallet,
      ),
      _MetricCard(
        'Today Paid',
        '${summary.todayPayments.toStringAsFixed(2)} ETB',
        Icons.payments,
      ),
      _MetricCard(
        'Month Paid',
        '${summary.monthPayments.toStringAsFixed(2)} ETB',
        Icons.bar_chart,
      ),
    ];

    return GridView.count(
      crossAxisCount: isWide ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: isWide ? 2.7 : 1.55,
      children: cards,
    );
  }
}

class _MetricCard extends StatelessWidget {
  const _MetricCard(this.title, this.value, this.icon);

  final String title;
  final String value;
  final IconData icon;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Icon(icon, size: 28),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.labelMedium,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _OrderPanel extends StatelessWidget {
  const _OrderPanel({
    required this.title,
    required this.orders,
    this.showBalance = false,
  });

  final String title;
  final List<Map<String, Object?>> orders;
  final bool showBalance;

  @override
  Widget build(BuildContext context) {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(title, style: Theme.of(context).textTheme.titleMedium),
            const SizedBox(height: 12),
            if (orders.isEmpty)
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 24),
                child: Center(child: Text('No records')),
              )
            else
              ...orders.map(
                (order) => ListTile(
                  dense: true,
                  contentPadding: EdgeInsets.zero,
                  title: Text(
                    (order['order_number'] as String?) ??
                        'Order #${order['id']}',
                  ),
                  subtitle: Text(
                    '${order['customer_name'] ?? '-'}  ${order['customer_phone'] ?? ''}',
                  ),
                  trailing: showBalance
                      ? Text(
                          '${((order['balance_amount'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)} ETB',
                        )
                      : Text((order['status'] as String?) ?? '-'),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
