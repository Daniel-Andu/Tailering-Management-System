import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/features/dashboard/data/dashboard_repository.dart';
import 'package:tailoring_system/features/dashboard/providers/dashboard_provider.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';

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
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final theme = Theme.of(context);

    return Scaffold(
      backgroundColor: const Color(0xFFF8FAFC),
      appBar: AppBar(
        title: Text(l10n.dashboardTitle),
        actions: [
          IconButton(
            tooltip: l10n.commonRefresh,
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
            return Center(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Icon(Icons.error_outline, size: 56, color: theme.colorScheme.error),
                  const SizedBox(height: 16),
                  Text(provider.errorMessage!,
                      style: TextStyle(color: theme.colorScheme.error)),
                  const SizedBox(height: 16),
                  FilledButton.icon(
                    onPressed: provider.refresh,
                    icon: const Icon(Icons.refresh),
                    label: Text(l10n.commonRefresh),
                  ),
                ],
              ),
            );
          }

          final summary = provider.summary;
          if (summary == null) {
            return Center(
              child: Text(l10n.dashboardNoRecords,
                  style: TextStyle(color: Colors.grey.shade500)),
            );
          }

          return LayoutBuilder(
            builder: (context, constraints) {
              final isWide = constraints.maxWidth >= 900;
              return RefreshIndicator(
                onRefresh: provider.refresh,
                child: ListView(
                  padding: const EdgeInsets.all(16),
                  children: [
                    // Hero header
                    _DashboardHeader(summary: summary),
                    const SizedBox(height: 16),
                    _SummaryGrid(summary: summary, isWide: isWide),
                    const SizedBox(height: 20),
                    if (isWide)
                      Row(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Expanded(
                            child: _OrderPanel(
                              title: l10n.dashboardDueSoon,
                              icon: Icons.access_time,
                              orders: provider.dueSoonOrders,
                              accentColor: const Color(0xFFFF9800),
                            ),
                          ),
                          const SizedBox(width: 16),
                          Expanded(
                            child: _OrderPanel(
                              title: l10n.dashboardUnpaidBalances,
                              icon: Icons.account_balance_wallet,
                              orders: provider.unpaidOrders,
                              showBalance: true,
                              accentColor: const Color(0xFFEF4444),
                            ),
                          ),
                        ],
                      )
                    else ...[
                      _OrderPanel(
                        title: l10n.dashboardDueSoon,
                        icon: Icons.access_time,
                        orders: provider.dueSoonOrders,
                        accentColor: const Color(0xFFFF9800),
                      ),
                      const SizedBox(height: 16),
                      _OrderPanel(
                        title: l10n.dashboardUnpaidBalances,
                        icon: Icons.account_balance_wallet,
                        orders: provider.unpaidOrders,
                        showBalance: true,
                        accentColor: const Color(0xFFEF4444),
                      ),
                    ],
                    const SizedBox(height: 32),
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

class _DashboardHeader extends StatelessWidget {
  const _DashboardHeader({required this.summary});
  final DashboardSummary summary;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            theme.colorScheme.primary,
            theme.colorScheme.secondary,
          ],
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: theme.colorScheme.primary.withOpacity(0.4),
            blurRadius: 20,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  l10n.dashboardBusinessOverview,
                  style: const TextStyle(
                    color: Colors.white70,
                    fontSize: 14,
                    fontWeight: FontWeight.w500,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  '${summary.monthPayments.toStringAsFixed(0)} ${l10n.commonETB}',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 28,
                    fontWeight: FontWeight.w800,
                    letterSpacing: -0.5,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  l10n.dashboardMonthPaid,
                  style: const TextStyle(
                    color: Colors.white60,
                    fontSize: 12,
                  ),
                ),
              ],
            ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(0.15),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.checkroom, color: Colors.white, size: 32),
          ),
        ],
      ),
    );
  }
}

class _SummaryGrid extends StatelessWidget {
  const _SummaryGrid({required this.summary, required this.isWide});

  final DashboardSummary summary;
  final bool isWide;

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    final cards = [
      _MetricCardData(l10n.dashboardDueToday, summary.dueToday.toString(),
          Icons.today, const Color(0xFF8B5CF6), const Color(0xFFF3E8FF)),
      _MetricCardData(l10n.dashboardDelayed, summary.delayedOrders.toString(),
          Icons.warning_amber_rounded, const Color(0xFFEF4444), const Color(0xFFFEE2E2)),
      _MetricCardData(l10n.dashboardReady, summary.readyForPickup.toString(),
          Icons.checkroom, const Color(0xFF10B981), const Color(0xFFD1FAE5)),
      _MetricCardData(l10n.dashboardOpenOrders, summary.openOrders.toString(),
          Icons.list_alt, const Color(0xFF3B82F6), const Color(0xFFDBEAFE)),
      _MetricCardData(l10n.dashboardCustomers, summary.activeCustomers.toString(),
          Icons.people_alt, const Color(0xFFF59E0B), const Color(0xFFFEF3C7)),
      _MetricCardData(
        l10n.dashboardUnpaid,
        '${summary.unpaidBalance.toStringAsFixed(0)} ${l10n.commonETB}',
        Icons.account_balance_wallet,
        const Color(0xFFEF4444),
        const Color(0xFFFEE2E2),
      ),
      _MetricCardData(
        l10n.dashboardTodayPaid,
        '${summary.todayPayments.toStringAsFixed(0)} ${l10n.commonETB}',
        Icons.payments,
        const Color(0xFF10B981),
        const Color(0xFFD1FAE5),
      ),
      _MetricCardData(
        l10n.dashboardMonthPaid,
        '${summary.monthPayments.toStringAsFixed(0)} ${l10n.commonETB}',
        Icons.bar_chart,
        const Color(0xFF8B5CF6),
        const Color(0xFFF3E8FF),
      ),
    ];

    return GridView.count(
      crossAxisCount: isWide ? 4 : 2,
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: isWide ? 2.5 : 1.5,
      children: cards.map((data) => _MetricCard(data: data)).toList(),
    );
  }
}

class _MetricCardData {
  const _MetricCardData(
      this.title, this.value, this.icon, this.iconColor, this.bgColor);
  final String title;
  final String value;
  final IconData icon;
  final Color iconColor;
  final Color bgColor;
}

class _MetricCard extends StatelessWidget {
  const _MetricCard({required this.data});
  final _MetricCardData data;

  @override
  Widget build(BuildContext context) {
    return Card(
      elevation: 2,
      child: Padding(
        padding: const EdgeInsets.all(14),
        child: Row(
          children: [
            Container(
              width: 44,
              height: 44,
              decoration: BoxDecoration(
                color: data.bgColor,
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(data.icon, size: 24, color: data.iconColor),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    data.title,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: Colors.grey.shade600,
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    data.value,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.w800,
                      color: data.iconColor,
                    ),
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
    required this.icon,
    required this.orders,
    required this.accentColor,
    this.showBalance = false,
  });

  final String title;
  final IconData icon;
  final List<Map<String, Object?>> orders;
  final bool showBalance;
  final Color accentColor;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final l10n = AppLocalizations.of(context)!;
    return Card(
      elevation: 2,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: accentColor.withOpacity(0.08),
              borderRadius:
                  const BorderRadius.vertical(top: Radius.circular(16)),
              border: Border(
                  bottom:
                      BorderSide(color: accentColor.withOpacity(0.15))),
            ),
            child: Row(
              children: [
                Icon(icon, size: 20, color: accentColor),
                const SizedBox(width: 8),
                Text(title,
                    style: theme.textTheme.titleSmall?.copyWith(
                        color: accentColor, fontWeight: FontWeight.w700)),
                const Spacer(),
                Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(20),
                  ),
                  child: Text(
                    '${orders.length}',
                    style: TextStyle(
                        color: accentColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13),
                  ),
                ),
              ],
            ),
          ),
          if (orders.isEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 28),
              child: Center(
                child: Column(
                  children: [
                    Icon(Icons.check_circle_outline,
                        size: 36, color: Colors.grey.shade300),
                    const SizedBox(height: 8),
                    Text(l10n.dashboardNoRecords,
                        style: TextStyle(color: Colors.grey.shade400,
                            fontSize: 13)),
                  ],
                ),
              ),
            )
          else
            ...orders.map(
              (order) => ListTile(
                dense: true,
                leading: Container(
                  width: 36,
                  height: 36,
                  decoration: BoxDecoration(
                    color: accentColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Icon(Icons.receipt_long,
                      size: 18, color: accentColor),
                ),
                title: Text(
                  (order['order_number'] as String?) ??
                      'Order #${order['id']}',
                  style: const TextStyle(
                      fontWeight: FontWeight.w600, fontSize: 13),
                ),
                subtitle: Text(
                  '${order['customer_name'] ?? '-'}  ${order['customer_phone'] ?? ''}',
                  style: TextStyle(fontSize: 12, color: Colors.grey.shade500),
                ),
                trailing: showBalance
                    ? Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          '${((order['balance_amount'] as num?)?.toDouble() ?? 0).toStringAsFixed(0)} ETB',
                          style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.w700,
                              fontSize: 12),
                        ),
                      )
                    : Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 4),
                        decoration: BoxDecoration(
                          color: accentColor.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: Text(
                          (order['status'] as String?) ?? '-',
                          style: TextStyle(
                              color: accentColor,
                              fontWeight: FontWeight.w600,
                              fontSize: 11),
                        ),
                      ),
              ),
            ),
          const SizedBox(height: 8),
        ],
      ),
    );
  }
}
