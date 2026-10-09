import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:tailoring_system/features/appointments/screens/appointments_screen.dart';
import 'package:tailoring_system/features/customers/screens/customer_directory_screen.dart';
import 'package:tailoring_system/features/dashboard/screens/production_dashboard_screen.dart';
import 'package:tailoring_system/features/inventory/screens/inventory_screen.dart';
import 'package:tailoring_system/features/measurements/screens/measurements_screen.dart';
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

  static const _pages = [
    ProductionDashboardScreen(),
    CustomerDirectoryScreen(),
    OrderBoardScreen(),
    AppointmentsScreen(),
    InventoryScreen(),
    MeasurementsScreen(),
    FinancialReportsScreen(),
    NotificationsScreen(),
    StaffScreen(),
    ShopSettingsScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    final languageProvider = Provider.of<LanguageProvider>(context);
    final l10n = AppLocalizations.of(context)!;

    return LayoutBuilder(
      builder: (context, constraints) {
        final wide = constraints.maxWidth >= 900;
        final extended = constraints.maxWidth >= 1200;

        if (wide) {
          return Scaffold(
            appBar: _buildAppBar(context, l10n, languageProvider),
            body: Row(
              children: [
                NavigationRail(
                  selectedIndex: _selectedIndex,
                  extended: extended,
                  onDestinationSelected: (index) {
                    setState(() => _selectedIndex = index);
                  },
                  leading: extended
                      ? Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              Container(
                                padding: const EdgeInsets.all(8),
                                decoration: BoxDecoration(
                                  color: Theme.of(context)
                                      .colorScheme
                                      .primaryContainer,
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Icon(Icons.checkroom,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                              const SizedBox(width: 8),
                              Text(
                                l10n.appTitle,
                                style: TextStyle(
                                    fontWeight: FontWeight.bold,
                                    fontSize: 13,
                                    color:
                                        Theme.of(context).colorScheme.primary),
                              ),
                            ],
                          ),
                        )
                      : null,
                  destinations: _buildRailDestinations(l10n),
                ),
                const VerticalDivider(width: 1),
                Expanded(child: _pages[_selectedIndex]),
              ],
            ),
          );
        }

        return Scaffold(
          appBar: _buildAppBar(context, l10n, languageProvider),
          body: _pages[_selectedIndex],
          bottomNavigationBar: _buildBottomNav(l10n),
        );
      },
    );
  }

  AppBar _buildAppBar(BuildContext context, AppLocalizations l10n,
      LanguageProvider languageProvider) {
    return AppBar(
      title: Row(
        children: [
          const Icon(Icons.checkroom, size: 22),
          const SizedBox(width: 8),
          Text(_getPageTitle(_selectedIndex, l10n)),
        ],
      ),
      actions: [
        Padding(
          padding: const EdgeInsets.only(right: 8),
          child: Material(
            color: Colors.white.withOpacity(0.15),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              borderRadius: BorderRadius.circular(12),
              onTap: () => languageProvider.toggleLanguage(),
              child: Padding(
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                child: Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    const Icon(Icons.language, size: 18, color: Colors.white),
                    const SizedBox(width: 6),
                    Text(
                      languageProvider.isAmharic ? 'EN' : 'አማ',
                      style: const TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                          fontSize: 13),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ),
      ],
    );
  }

  List<NavigationRailDestination> _buildRailDestinations(
      AppLocalizations l10n) {
    return [
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
        icon: const Icon(Icons.straighten_outlined),
        selectedIcon: const Icon(Icons.straighten),
        label: Text(l10n.menuMeasurements),
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
    ];
  }

  NavigationBar _buildBottomNav(AppLocalizations l10n) {
    return NavigationBar(
      selectedIndex: _mobileSelectedIndex,
      onDestinationSelected: (index) {
        if (index == 4) {
          _showMoreMenu(l10n);
        } else {
          setState(() => _selectedIndex = _pageIndexForMobileTab(index));
        }
      },
      destinations: [
        NavigationDestination(
          icon: const Icon(Icons.dashboard_outlined),
          selectedIcon: const Icon(Icons.dashboard),
          label: l10n.menuDashboard,
        ),
        NavigationDestination(
          icon: const Icon(Icons.people_outline),
          selectedIcon: const Icon(Icons.people),
          label: l10n.menuCustomers,
        ),
        NavigationDestination(
          icon: const Icon(Icons.assignment_outlined),
          selectedIcon: const Icon(Icons.assignment),
          label: l10n.menuOrders,
        ),
        NavigationDestination(
          icon: const Icon(Icons.straighten_outlined),
          selectedIcon: const Icon(Icons.straighten),
          label: l10n.menuMeasurements,
        ),
        NavigationDestination(
          icon: const Icon(Icons.more_horiz),
          label: l10n.menuMore,
        ),
      ],
    );
  }

  void _showMoreMenu(AppLocalizations l10n) {
    final items = [
      _MoreMenuItem(Icons.event_outlined, l10n.menuAppointments, 3),
      _MoreMenuItem(Icons.inventory_2_outlined, l10n.menuInventory, 4),
      _MoreMenuItem(Icons.bar_chart_outlined, l10n.menuReports, 6),
      _MoreMenuItem(Icons.sms_outlined, l10n.menuNotifications, 7),
      _MoreMenuItem(Icons.badge_outlined, l10n.menuStaff, 8),
      _MoreMenuItem(Icons.settings_outlined, l10n.menuSettings, 9),
    ];

    showModalBottomSheet<void>(
      context: context,
      showDragHandle: true,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) {
        return SafeArea(
          child: Padding(
            padding: const EdgeInsets.fromLTRB(16, 0, 16, 16),
            child: Column(
              mainAxisSize: MainAxisSize.min,
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Text(
                    l10n.menuMore,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                        ),
                  ),
                ),
                GridView.count(
                  crossAxisCount: 3,
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  mainAxisSpacing: 8,
                  crossAxisSpacing: 8,
                  childAspectRatio: 1.1,
                  children: items.map((item) {
                    final selected = _selectedIndex == item.pageIndex;
                    final colors = Theme.of(context).colorScheme;
                    return Material(
                      color: selected
                          ? colors.secondaryContainer
                          : colors.surfaceContainerLow,
                      borderRadius: BorderRadius.circular(16),
                      child: InkWell(
                        borderRadius: BorderRadius.circular(16),
                        onTap: () {
                          Navigator.pop(context);
                          setState(() => _selectedIndex = item.pageIndex);
                        },
                        child: Padding(
                          padding: const EdgeInsets.all(8),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(
                                item.icon,
                                color: selected
                                    ? colors.onSecondaryContainer
                                    : colors.onSurfaceVariant,
                              ),
                              const SizedBox(height: 6),
                              Text(
                                item.label,
                                textAlign: TextAlign.center,
                                maxLines: 2,
                                overflow: TextOverflow.ellipsis,
                                style: Theme.of(context).textTheme.labelMedium,
                              ),
                            ],
                          ),
                        ),
                      ),
                    );
                  }).toList(),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  String _getPageTitle(int index, AppLocalizations l10n) {
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
        return l10n.menuMeasurements;
      case 6:
        return l10n.menuReports;
      case 7:
        return l10n.menuNotifications;
      case 8:
        return l10n.menuStaff;
      case 9:
        return l10n.menuSettings;
      default:
        return l10n.appTitle;
    }
  }

  int get _mobileSelectedIndex {
    switch (_selectedIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 2;
      case 5:
        return 3; // Measurements
      default:
        return 4;
    }
  }

  int _pageIndexForMobileTab(int tabIndex) {
    switch (tabIndex) {
      case 0:
        return 0;
      case 1:
        return 1;
      case 2:
        return 2;
      case 3:
        return 5; // Measurements
      default:
        return 4; // Inventory (more)
    }
  }
}

class _MoreMenuItem {
  const _MoreMenuItem(this.icon, this.label, this.pageIndex);

  final IconData icon;
  final String label;
  final int pageIndex;
}
