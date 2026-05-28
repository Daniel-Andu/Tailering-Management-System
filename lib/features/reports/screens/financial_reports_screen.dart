import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/features/reports/providers/financial_report_provider.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';

class FinancialReportsScreen extends StatefulWidget {
  const FinancialReportsScreen({super.key});

  @override
  State<FinancialReportsScreen> createState() => _FinancialReportsScreenState();
}

class _FinancialReportsScreenState extends State<FinancialReportsScreen> {
  late DateTime _start;
  late DateTime _end;

  @override
  void initState() {
    super.initState();
    final now = DateTime.now();
    _start = DateTime(now.year, now.month, 1);
    _end = DateTime(now.year, now.month + 1, 0, 23, 59, 59);
    WidgetsBinding.instance.addPostFrameCallback((_) => _load());
  }

  Future<void> _load() {
    return context
        .read<FinancialReportProvider>()
        .loadRange(start: _start, end: _end);
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;
    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.financialReportsTitle),
        actions: [
          IconButton(
            tooltip: l10n.staffRefresh,
            icon: const Icon(Icons.refresh),
            onPressed: _load,
          ),
        ],
      ),
      body: Consumer<FinancialReportProvider>(
        builder: (context, provider, _) {
          if (provider.isLoading && provider.summary == null) {
            return const Center(child: CircularProgressIndicator());
          }
          if (provider.errorMessage != null) {
            return Center(child: Text(provider.errorMessage!));
          }

          final summary = provider.summary;
          if (summary == null) {
            return Center(child: Text(l10n.financialReportsNoData));
          }

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Wrap(
                spacing: 12,
                runSpacing: 12,
                children: [
                  _ReportCard(
                      'Payments', summary.grossPayments, Icons.payments),
                  _ReportCard(
                      'Refunds', summary.refunds, Icons.assignment_return),
                  _ReportCard('Expenses', summary.expenses, Icons.receipt_long),
                  _ReportCard('Net Cash', summary.netCash,
                      Icons.account_balance_wallet),
                  _ReportCard(
                      'Order Value', summary.orderValue, Icons.shopping_bag),
                ],
              ),
              const SizedBox(height: 24),
              Text(l10n.financialReportsPaymentsByMethod,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final row in provider.paymentsByMethod)
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.primaryContainer,
                      child: Icon(Icons.payments_outlined,
                          color: Theme.of(context).colorScheme.primary),
                    ),
                    title: Text(
                      '${row['payment_method']}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle: Text(
                        '${row['count']} ${l10n.financialReportsPayments}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.tertiaryContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${((row['total'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)} ETB',
                        style: TextStyle(
                          color:
                              Theme.of(context).colorScheme.onTertiaryContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
              const SizedBox(height: 16),
              Text(l10n.financialReportsUnpaidBalances,
                  style: Theme.of(context).textTheme.titleMedium),
              const SizedBox(height: 8),
              for (final row in provider.unpaidBalances.take(20))
                Card(
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor:
                          Theme.of(context).colorScheme.errorContainer,
                      child: Icon(Icons.account_balance_wallet_outlined,
                          color:
                              Theme.of(context).colorScheme.onErrorContainer),
                    ),
                    title: Text(
                      '${row['customer_name'] ?? '-'}',
                      style: const TextStyle(fontWeight: FontWeight.w600),
                    ),
                    subtitle:
                        Text('${row['order_number'] ?? 'Order #${row['id']}'}'),
                    trailing: Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 12, vertical: 6),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.errorContainer,
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                        '${((row['balance_amount'] as num?)?.toDouble() ?? 0).toStringAsFixed(2)} ETB',
                        style: TextStyle(
                          color: Theme.of(context).colorScheme.onErrorContainer,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                ),
            ],
          );
        },
      ),
    );
  }
}

class _ReportCard extends StatelessWidget {
  const _ReportCard(this.label, this.amount, [this.icon]);

  final String label;
  final double amount;
  final IconData? icon;

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: 180,
      child: Card(
        elevation: 4,
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              if (icon != null)
                Icon(
                  icon,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              if (icon != null) const SizedBox(height: 8),
              Text(
                label,
                style: Theme.of(context).textTheme.labelLarge,
              ),
              const SizedBox(height: 8),
              Text(
                '${amount.toStringAsFixed(2)} ETB',
                style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                    ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
