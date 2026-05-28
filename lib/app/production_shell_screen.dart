import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/features/appointments/screens/appointments_screen.dart';
import 'package:tailoring_system/features/customers/screens/customer_directory_screen.dart';
import 'package:tailoring_system/features/dashboard/screens/production_dashboard_screen.dart';
import 'package:tailoring_system/features/inventory/screens/inventory_screen.dart';
import 'package:tailoring_system/features/notifications/screens/notifications_screen.dart';
import 'package:tailoring_system/features/orders/screens/order_board_screen.dart';
import 'package:tailoring_system/features/reports/screens/financial_reports_screen.dart';
import 'package:tailoring_system/features/settings/screens/shop_settings_screen.dart';
import 'package:tailoring_system/features/staff/screens/staff_screen.dart';
import 'package:tailoring_system/providers/language_provider.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';

class ProductionShellScreen extends StatefulWidget {
  const ProductionShellScreen({super.key});

  @override
  State<ProductionShellScreen> createState() => _ProductionShellScreenState();
}

class _ProductionShellScreenState extends State<ProductionShellScreen> {
  int _selectedIndex = 0;

  final _pages = const [
    ProductionDashboardScreen(),
    CustomerDirectoryScreen(),
    OrderBoardScreen(),
    AppointmentsScreen(),
    InventoryScreen(),
    FinancialReportsScreen(),
    NotificationsScreen(),
    StaffScreen(),
    ShopSettingsScreen(),
  ];

  final _destinations = const [
    _Destination('Dashboard', Icons.dashboard_outlined),
    _Destination('Customers', Icons.people_outline),
    _Destination('Orders', Icons.assignment_outlined),
    _Destination('Appointments', Icons.event_outlined),
    _Destination('Inventory', Icons.inventory_2_outlined),
    _Destination('Reports', Icons.bar_chart_outlined),
    _Destination('Notifications', Icons.sms_outlined),
    _Destination('Staff', Icons.badge_outlined),
    _Destination('Settings', Icons.settings_outlined),
  ];

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        if (wide) {
          return Scaffold(
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  extended: constraints.maxWidth >= 1180,
                  onDestinationSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                  destinations: [
                    NavigationRailDestination(
                      icon: const Icon(Icons.dashboard_outlined),
                      selectedIcon: const Icon(Icons.dashboard),
                      label: Text(l10n.menuDashboard),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.people_outline),
                      selectedIcon: const Icon(Icons.people),
                      label: Text(l10n.menuCustomers),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.assignment_outlined),
                      selectedIcon: const Icon(Icons.assignment),
                      label: Text(l10n.menuOrders),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.event_outlined),
                      selectedIcon: const Icon(Icons.event),
                      label: Text(l10n.menuAppointments),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.inventory_2_outlined),
                      selectedIcon: const Icon(Icons.inventory_2),
                      label: Text(l10n.menuInventory),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.bar_chart_outlined),
                      selectedIcon: const Icon(Icons.bar_chart),
                      label: Text(l10n.menuReports),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.sms_outlined),
                      selectedIcon: const Icon(Icons.sms),
                      label: Text(l10n.menuNotifications),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.badge_outlined),
                      selectedIcon: const Icon(Icons.badge),
                      label: Text(l10n.menuStaff),
                    ),
                    NavigationRailDestination(
                      icon: const Icon(Icons.settings_outlined),
                      selectedIcon: const Icon(Icons.settings),
                      label: Text(l10n.menuSettings),
                    ),
                  ],
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _pages[_selectedIndex]),
              ],
            ),
            appBar: AppBar(
              title: Text(_getDestinationLabel(_selectedIndex, l10n)),
              actions: [
                Container(
                  margin: const EdgeInsets.symmetric(horizontal: 8),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: IconButton(
                    icon: const Icon(Icons.language),
                    onPressed: () {
                      languageProvider.toggleLanguage();
                    },
                    tooltip: languageProvider.isAmharic ? 'English' : 'አማርኛ',
                  ),
                ),
              ],
            ),
          );
        }

        return Scaffold(
          body: _pages[_selectedIndex],
          appBar: AppBar(
            title: Text(_getDestinationLabel(_selectedIndex, l10n)),
            actions: [
              Container(
                margin: const EdgeInsets.symmetric(horizontal: 8),
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: IconButton(
                  icon: const Icon(Icons.language),
                  onPressed: () {
                    languageProvider.toggleLanguage();
                  },
                  tooltip: languageProvider.isAmharic ? 'English' : 'አማርኛ',
                ),
              ),
            ],
          ),
          bottomNavigationBar: NavigationBar(
            selectedIndex: _mobileSelectedIndex,
            onDestinationSelected: (index) {
              setState(() => _selectedIndex = _pageIndexForMobileTab(index));
            },
            destinations: [
              NavigationDestination(
                icon: const Icon(Icons.dashboard_outlined),
                label: l10n.menuDashboard,
              ),
              NavigationDestination(
                icon: const Icon(Icons.people_outline),
                label: l10n.menuCustomers,
              ),
              NavigationDestination(
                icon: const Icon(Icons.assignment_outlined),
                label: l10n.menuOrders,
              ),
              NavigationDestination(
                icon: const Icon(Icons.inventory_2_outlined),
                label: l10n.menuInventory,
              ),
              NavigationDestination(
                icon: const Icon(Icons.more_horiz),
                label: l10n.menuMore,
              ),
            ],
          ),
        );
      },
    );
  }

  String _getDestinationLabel(int index, AppLocalizations l10n) {
    switch (index) {
      case 0:
        return l10n.menuDashboard;
      case 1:
        return l10n.menuCustomers;
      case 2:
        return l10n.menuOrders;
      case 3:
        return l10n.menuAppointments;
      case 4:
        return l10n.menuInventory;
      case 5:
        return l10n.menuReports;
      case 6:
        return l10n.menuNotifications;
      case 7:
        return l10n.menuStaff;
      case 8:
        return l10n.menuSettings;
      default:
        return '';
    }
  }

  int get _mobileSelectedIndex {
    if (_selectedIndex == 0) return 0;
    if (_selectedIndex == 1) return 1;
    if (_selectedIndex == 2) return 2;
    if (_selectedIndex == 3) return 3;
    return 4;
  }

  int _pageIndexForMobileTab(int tabIndex) {
    return switch (tabIndex) {
      0 => 0,
      1 => 1,
      2 => 2,
      3 => 3,
      _ => 4,
    };
  }
}

class _Destination {
  const _Destination(this.label, this.icon);

  final String label;
  final IconData icon;
}
