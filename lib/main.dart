import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';
import 'database/database_factory_initializer.dart';
import 'package:tailoring_system/core/database/sync_migration.dart';
import 'package:tailoring_system/providers/auth_provider.dart';
import 'package:tailoring_system/providers/theme_provider.dart';
import 'package:tailoring_system/config/app_theme.dart';
import 'package:tailoring_system/screens/auth/auth_router.dart';
import 'package:tailoring_system/app/production_shell_screen.dart';
import 'package:tailoring_system/providers/language_provider.dart';
import 'package:tailoring_system/providers/customer_provider.dart';
import 'package:tailoring_system/providers/order_provider.dart';
import 'package:tailoring_system/utils/database_helper.dart';
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
import 'package:tailoring_system/screens/license_screen.dart';
import 'package:tailoring_system/utils/license_manager.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  
  // Initialize Firebase
  await Firebase.initializeApp();
  
  // Initialize local database
  initializeDatabaseFactory();
  
  runApp(const TailoringSystemApp());
}

class TailoringSystemApp extends StatelessWidget {
  const TailoringSystemApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => ThemeProvider()),
        ChangeNotifierProvider(create: (_) => AuthProvider()),
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
      child: Consumer2<LanguageProvider, ThemeProvider>(
        builder: (context, languageProvider, themeProvider, child) {
          return MaterialApp(
            title: 'Tailoring System',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: themeProvider.themeMode,
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
    // Initialize database first with better error handling
    try {
      final db = await DatabaseHelper.instance.database;
      print('✅ Database initialized successfully');
      
      // Run sync migrations
      await SyncMigration.runAllMigrations(db);
    } catch (e) {
      print('❌ Database initialization error: $e');
      // Continue even if database fails - show error screen later
    }

    // Small delay for splash screen
    await Future.delayed(const Duration(milliseconds: 800));

    if (!mounted) return;

    // Check authentication status first
    try {
      final authProvider = Provider.of<AuthProvider>(context, listen: false);
      print('🔍 Checking auth status...');
      await authProvider.checkAuthStatus();
      print('✅ Auth status checked');
      
      if (!mounted) return;

      // If not authenticated, go to auth flow
      if (!authProvider.isAuthenticated) {
        print('❌ Not authenticated - showing login');
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthRouter()),
        );
        return;
      }

      print('✅ User authenticated - proceeding to app');
    } catch (e) {
      print('❌ Auth check error: $e');
      // If auth check fails, go to login
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const AuthRouter()),
        );
      }
      return;
    }

    // If authenticated, proceed with license check
    try {
      await LicenseManager.initializeTrial();
    } catch (e) {
      print('⚠️ License initialization error: $e');
      // Continue even if license check fails - default to license screen
    }

    bool isLicensed = false;
    try {
      isLicensed = await LicenseManager.isLicensed();
    } catch (e) {
      print('⚠️ License check error: $e');
      // Default to license screen if check fails
      isLicensed = false;
    }

    if (!mounted) return;

    try {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => isLicensed
              ? const ProductionShellScreen()
              : const LicenseScreen(),
        ),
      );
    } catch (e) {
      print('❌ Navigation error: $e');
      // If navigation fails, try to show license screen directly
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => const LicenseScreen()),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
