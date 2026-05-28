import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/providers/order_provider.dart';
import 'package:tailoring_system/providers/customer_provider.dart';
import 'package:tailoring_system/models/order.dart';
import 'package:tailoring_system/screens/add_order_screen.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';

class OrderListScreen extends StatelessWidget {
  const OrderListScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context)!;

    return Scaffold(
      appBar: AppBar(
        title: Text(
          l10n.orderListTitle,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        backgroundColor: Colors.blue[900],
        actions: [
          Container(
            margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 8),
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [Color(0xFFF59E0B), Color(0xFFD97706)],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: Colors.orange.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 4),
                ),
              ],
            ),
            child: IconButton(
              icon: const Icon(Icons.add, color: Colors.white),
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (_) => const AddOrderScreen()),
                );
              },
              tooltip: 'Add Order',
            ),
          ),
        ],
      ),
      body: Consumer2<OrderProvider, CustomerProvider>(
        builder: (context, orderProvider, customerProvider, child) {
          if (orderProvider.isLoading) {
            return const Center(child: CircularProgressIndicator());
          }

          final orders = orderProvider.orders;

          if (orders.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.shopping_bag_outlined,
                    size: 64,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No orders found',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  ElevatedButton(
                    onPressed: () {
                      orderProvider.loadOrders();
                    },
                    child: const Text('Refresh'),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final customer =
                  customerProvider.getCustomerById(order.customerId ?? 0);
              return _buildOrderCard(
                  context, order, customer, orderProvider, l10n);
            },
          );
        },
      ),
    );
  }

  Widget _buildOrderCard(BuildContext context, Order order, customer,
      OrderProvider provider, AppLocalizations l10n) {
    Color statusColor;
    switch (order.status) {
      case 'Pending':
        statusColor = Colors.orange;
        break;
      case 'In Progress':
        statusColor = Colors.blue;
        break;
      case 'Completed':
        statusColor = Colors.green;
        break;
      case 'Delivered':
        statusColor = Colors.purple;
        break;
      default:
        statusColor = Colors.grey;
    }

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: ListTile(
        leading: CircleAvatar(
          backgroundColor: statusColor,
          child: const Icon(
            Icons.shopping_bag,
            color: Colors.white,
          ),
        ),
        title: Text(
          order.clothType,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
        subtitle: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              '${l10n.orderListCustomer}: ${customer?.name ?? 'Unknown'}',
              style: const TextStyle(),
            ),
            Text(
              '${l10n.orderListPrice}: \$${order.price.toStringAsFixed(2)}',
              style: const TextStyle(),
            ),
            if (order.paymentStatus != null)
              Text(
                'Payment Status: ${order.paymentStatus}',
                style: TextStyle(
                  color: order.paymentStatus == 'Paid'
                      ? Colors.green
                      : Colors.orange,
                  fontWeight: FontWeight.bold,
                ),
              ),
            if (order.paymentMethod != null)
              Text(
                'Payment Method: ${order.paymentMethod}',
                style: const TextStyle(),
              ),
          ],
        ),
        trailing: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.end,
          children: [
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: statusColor.withOpacity(0.1),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                order.status,
                style: TextStyle(
                  fontSize: 12,
                  color: statusColor,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
            IconButton(
              icon: const Icon(Icons.delete),
              onPressed: () {
                _showDeleteDialog(context, order, provider, l10n);
              },
            ),
          ],
        ),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddOrderScreen(order: order),
            ),
          );
        },
      ),
    );
  }

  void _showDeleteDialog(BuildContext context, Order order,
      OrderProvider provider, AppLocalizations l10n) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(l10n.orderListConfirmDeleteHeader),
        content:
            Text('${l10n.orderListDeleteConfirmation} ${order.clothType}?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: Text(l10n.customerFormCancel),
          ),
          TextButton(
            onPressed: () {
              provider.deleteOrder(order.id!);
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text(l10n.orderListOrderDeleted)),
              );
            },
            child: Text(l10n.orderListDelete),
          ),
        ],
      ),
    );
  }
}
