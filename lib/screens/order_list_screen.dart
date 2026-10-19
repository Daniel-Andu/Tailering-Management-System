import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/providers/order_provider.dart';
import 'package:tailoring_system/providers/customer_provider.dart';
import 'package:tailoring_system/models/order.dart';
import 'package:tailoring_system/screens/add_order_screen.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';

class OrderListScreen extends StatefulWidget {
  const OrderListScreen({super.key});

  @override
  State<OrderListScreen> createState() => _OrderListScreenState();
}

class _OrderListScreenState extends State<OrderListScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final orderProvider = Provider.of<OrderProvider>(context, listen: false);
      final customerProvider =
          Provider.of<CustomerProvider>(context, listen: false);
      orderProvider.loadOrders();
      customerProvider.loadCustomers();
    });
  }

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
              tooltip: l10n.orderListAddOrder,
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
                    l10n.orderListNoOrders,
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
                    child: Text(l10n.orderListRefresh),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: orders.length,
            itemBuilder: (context, index) {
              final order = orders[index];
              final customer = order.customerId != null && order.customerId! > 0
                  ? customerProvider.getCustomerById(order.customerId!)
                  : null;
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
      child: InkWell(
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (_) => AddOrderScreen(order: order),
            ),
          );
        },
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundColor: statusColor,
                    child: const Icon(
                      Icons.shopping_bag,
                      color: Colors.white,
                      size: 20,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: Text(
                      order.clothType,
                      style: const TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                  Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
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
                ],
              ),
              const SizedBox(height: 8),
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
                  '${l10n.orderListPaymentStatus}: ${order.paymentStatus}',
                  style: TextStyle(
                    color: order.paymentStatus == 'Paid'
                        ? Colors.green
                        : Colors.orange,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              if (order.paymentMethod != null)
                Text(
                  '${l10n.orderListPaymentMethod}: ${order.paymentMethod}',
                  style: const TextStyle(),
                ),
              const SizedBox(height: 8),
              Row(
                mainAxisAlignment: MainAxisAlignment.end,
                children: [
                  IconButton(
                    icon: const Icon(Icons.delete),
                    onPressed: () {
                      _showDeleteDialog(context, order, provider, l10n);
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
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
