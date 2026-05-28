import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'database/database_factory_initializer.dart';
import 'package:tailoring_system/app/production_shell_screen.dart';
import 'package:tailoring_system/providers/language_provider.dart';
import 'package:tailoring_system/providers/customer_provider.dart';
import 'package:tailoring_system/providers/order_provider.dart';
import 'package:tailoring_system/features/appointments/providers/appointment_provider.dart';
import 'package:tailoring_system/features/customers/providers/customer_directory_provider.dart';
import 'package:tailoring_system/features/customers/providers/customer_profile_provider.dart';
import 'package:tailoring_system/features/dashboard/providers/dashboard_provider.dart';
import 'package:tailoring_system/features/expenses/providers/expense_provider.dart';
import 'package:tailoring_system/features/inventory/providers/inventory_provider.dart';
import 'package:tailoring_system/features/measurements/providers/measurement_provider.dart';
import 'package:tailoring_system/features/notifications/providers/notification_provider.dart';
import 'package:tailoring_system/features/orders/providers/order_board_provider.dart';
import 'package:tailoring_system/features/orders/providers/order_detail_provider.dart';
import 'package:tailoring_system/features/orders/providers/order_workflow_provider.dart';
import 'package:tailoring_system/features/payments/providers/payment_provider.dart';
import 'package:tailoring_system/features/receipts/providers/receipt_provider.dart';
import 'package:tailoring_system/features/reports/providers/financial_report_provider.dart';
import 'package:tailoring_system/features/settings/providers/app_settings_provider.dart';
import 'package:tailoring_system/features/staff/providers/staff_provider.dart';
import 'package:tailoring_system/screens/splash_screen.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  initializeDatabaseFactory();
  runApp(const TailoringSystemApp());
}

class TailoringSystemApp extends StatelessWidget {
  const TailoringSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LanguageProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => CustomerDirectoryProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProfileProvider()),
        ChangeNotifierProvider(create: (_) => OrderProvider()),
        ChangeNotifierProvider(create: (_) => OrderBoardProvider()),
        ChangeNotifierProvider(create: (_) => OrderDetailProvider()),
        ChangeNotifierProvider(create: (_) => AppointmentProvider()),
        ChangeNotifierProvider(create: (_) => DashboardProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => InventoryProvider()),
        ChangeNotifierProvider(create: (_) => MeasurementProvider()),
        ChangeNotifierProvider(create: (_) => NotificationProvider()),
        ChangeNotifierProvider(create: (_) => OrderWorkflowProvider()),
        ChangeNotifierProvider(create: (_) => PaymentProvider()),
        ChangeNotifierProvider(create: (_) => ReceiptProvider()),
        ChangeNotifierProvider(create: (_) => FinancialReportProvider()),
        ChangeNotifierProvider(create: (_) => AppSettingsProvider()),
        ChangeNotifierProvider(create: (_) => StaffProvider()),
      ],
      child: Consumer<LanguageProvider>(
        builder: (context, languageProvider, child) {
          return MaterialApp(
            title: 'Tailoring System',
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: const Color(0xFF6366F1),
                brightness: Brightness.light,
                primary: const Color(0xFF6366F1),
                secondary: const Color(0xFFEC4899),
                tertiary: const Color(0xFF10B981),
              ),
              useMaterial3: true,
              scaffoldBackgroundColor: const Color(0xFFF8FAFC),
              cardTheme: const CardThemeData(
                elevation: 4,
                shadowColor: Color(0x1F000000),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.all(Radius.circular(16)),
                ),
                clipBehavior: Clip.antiAlias,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.26),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              filledButtonTheme: FilledButtonThemeData(
                style: FilledButton.styleFrom(
                  elevation: 2,
                  shadowColor: Colors.black.withOpacity(0.26),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  padding:
                      const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
                  textStyle: const TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFE2E8F0)),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFF6366F1), width: 2),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide: const BorderSide(color: Color(0xFFEF4444)),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(12),
                  borderSide:
                      const BorderSide(color: Color(0xFFEF4444), width: 2),
                ),
                contentPadding:
                    const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
              ),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: true,
                backgroundColor: Color(0xFF6366F1),
                foregroundColor: Colors.white,
                titleTextStyle: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
                iconTheme: IconThemeData(color: Colors.white),
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
              ),
              chipTheme: ChipThemeData(
                backgroundColor: const Color(0xFFF1F5F9),
                selectedColor: const Color(0xFF6366F1),
                labelStyle: const TextStyle(fontWeight: FontWeight.w500),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(8),
                ),
                side: BorderSide.none,
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                elevation: 8,
                backgroundColor: Colors.white,
                selectedItemColor: Color(0xFF6366F1),
                unselectedItemColor: Color(0xFF64748B),
                selectedLabelStyle: TextStyle(fontWeight: FontWeight.w600),
                type: BottomNavigationBarType.fixed,
              ),
              navigationRailTheme: NavigationRailThemeData(
                backgroundColor: Colors.white,
                elevation: 2,
                selectedIconTheme:
                    const IconThemeData(color: Color(0xFF6366F1)),
                unselectedIconTheme:
                    const IconThemeData(color: Color(0xFF64748B)),
                selectedLabelTextStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6366F1),
                ),
                unselectedLabelTextStyle: const TextStyle(
                  color: Color(0xFF64748B),
                ),
              ),
              dialogTheme: DialogThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
              ),
              snackBarTheme: SnackBarThemeData(
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 4,
              ),
            ),
            locale: languageProvider.locale,
            localizationsDelegates: const [
              AppLocalizations.delegate,
              GlobalMaterialLocalizations.delegate,
              GlobalWidgetsLocalizations.delegate,
              GlobalCupertinoLocalizations.delegate,
            ],
            supportedLocales: const [
              Locale('en'),
              Locale('am'),
            ],
            home: const AppInitializer(),
          );
        },
      ),
    );
  }
}

class AppInitializer extends StatefulWidget {
  const AppInitializer({super.key});

  @override
  State<AppInitializer> createState() => _AppInitializerState();
}

class _AppInitializerState extends State<AppInitializer> {
  @override
  void initState() {
    super.initState();
    _initializeApp();
  }

  Future<void> _initializeApp() async {
    await Future.delayed(const Duration(seconds: 1));

    if (!mounted) return;

    // Bypass license check temporarily to get app loading
    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const ProductionShellScreen(),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
