import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/providers/customer_provider.dart';
import 'package:tailoring_system/providers/order_provider.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';

class DashboardScreen extends StatelessWidget {
  const DashboardScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.dashboardTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900],
      ),
      body: Consumer2<CustomerProvider, OrderProvider>(
        builder: (context, customerProvider, orderProvider, child) {
          final customers = customerProvider.customers;
          final orders = orderProvider.orders;
          final pendingOrders =
              orders.where((o) => o.status == 'Pending').length;
          final completedOrders =
              orders.where((o) => o.status == 'Completed').length;
          final totalRevenue = orderProvider.getTotalRevenue();

          return SingleChildScrollView(
            padding: const EdgeInsets.all(16),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                _buildStatCard(
                  l10n.dashboardTotalCustomers,
                  customers.length.toString(),
                  Icons.people,
                  Colors.blue,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  l10n.dashboardTotalOrders,
                  orders.length.toString(),
                  Icons.shopping_bag,
                  Colors.green,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  l10n.dashboardPendingOrders,
                  pendingOrders.toString(),
                  Icons.pending,
                  Colors.orange,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  l10n.dashboardCompletedOrders,
                  completedOrders.toString(),
                  Icons.check_circle,
                  Colors.purple,
                ),
                const SizedBox(height: 16),
                _buildStatCard(
                  l10n.dashboardTotalRevenue,
                  '\$${totalRevenue.toStringAsFixed(2)}',
                  Icons.attach_money,
                  Colors.red,
                ),
              ],
            ),
          );
        },
      ),
    );
  }

  Widget _buildStatCard(
      String title, String value, IconData icon, Color color) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Row(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Icon(
                icon,
                size: 32,
                color: color,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: TextStyle(
                      fontSize: 14,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    value,
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: color,
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
