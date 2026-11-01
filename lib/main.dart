import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';
import 'package:firebase_core/firebase_core.dart';

import 'firebase_options.dart';
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
import 'package:tailoring_system/features/subscriptions/data/subscription_service.dart';
import 'package:tailoring_system/screens/splash_screen.dart';
import 'package:tailoring_system/screens/license_screen.dart';
import 'package:tailoring_system/utils/license_manager.dart';
import 'package:tailoring_system/l10n/app_localizations.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final firebaseInitializationError = await _initializeFirebase();

  if (firebaseInitializationError != null) {
    runApp(
      FirebaseConfigurationRequiredApp(
        errorMessage: firebaseInitializationError,
      ),
    );
    return;
  }

  // Initialize local database factory.
  initializeDatabaseFactory();

  runApp(const TailoringSystemApp());
}

// ============================================================
// FIREBASE INITIALIZATION
// ============================================================

Future<String?> _initializeFirebase() async {
  try {
    await Firebase.initializeApp(
      options: DefaultFirebaseOptions.currentPlatform,
    );

    debugPrint('Firebase initialized successfully!');

    return null;
  } catch (error, stackTrace) {
    debugPrint('Firebase initialization failed: $error');
    debugPrintStack(stackTrace: stackTrace);

    return 'Firebase could not be initialized: $error';
  }
}

// ============================================================
// FIREBASE CONFIGURATION ERROR SCREEN
// ============================================================

class FirebaseConfigurationRequiredApp extends StatelessWidget {
  const FirebaseConfigurationRequiredApp({
    required this.errorMessage,
    super.key,
  });

  final String errorMessage;

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Firebase setup required',
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Center(
          child: ConstrainedBox(
            constraints: const BoxConstraints(maxWidth: 680),
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Card(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Column(
                    mainAxisSize: MainAxisSize.min,
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Icon(Icons.cloud_off, size: 40),
                      const SizedBox(height: 16),
                      Text(
                        'Firebase initialization failed',
                        style: Theme.of(context).textTheme.headlineSmall,
                      ),
                      const SizedBox(height: 12),
                      Text(errorMessage),
                      const SizedBox(height: 20),
                      const Text(
                        'Check your Firebase project configuration '
                        'and try again.',
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}

// ============================================================
// MAIN APPLICATION
// ============================================================

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

            // =================================================
            // LIGHT THEME
            // =================================================

            theme: ThemeData(
              colorScheme: ColorScheme.fromSeed(
                seedColor: AppTheme.primaryColor,
                brightness: Brightness.light,
                primary: AppTheme.primaryColor,
                secondary: AppTheme.secondaryColor,
                tertiary: const Color(0xFF06B6D4),
                surfaceContainer: const Color(0xFFF8FAFC),
              ),
              useMaterial3: true,
              fontFamily: 'sans-serif',
              scaffoldBackgroundColor: const Color(0xFFF8FAFC),
              cardTheme: CardThemeData(
                elevation: 3,
                shadowColor: Colors.black.withOpacity(0.15),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                clipBehavior: Clip.antiAlias,
                color: Colors.white,
              ),
              elevatedButtonTheme: ElevatedButtonThemeData(
                style: ElevatedButton.styleFrom(
                  elevation: 4,
                  shadowColor: const Color(0xFF8B5CF6).withOpacity(0.4),
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              filledButtonTheme: FilledButtonThemeData(
                style: FilledButton.styleFrom(
                  elevation: 3,
                  shadowColor: Colors.black.withOpacity(0.2),
                  backgroundColor: const Color(0xFF8B5CF6),
                  foregroundColor: Colors.white,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                    letterSpacing: 0.5,
                  ),
                ),
              ),
              outlinedButtonTheme: OutlinedButtonThemeData(
                style: OutlinedButton.styleFrom(
                  foregroundColor: const Color(0xFF8B5CF6),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(14),
                  ),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 28,
                    vertical: 16,
                  ),
                  side: const BorderSide(
                    color: Color(0xFF8B5CF6),
                    width: 2,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              textButtonTheme: TextButtonThemeData(
                style: TextButton.styleFrom(
                  foregroundColor: const Color(0xFF8B5CF6),
                  padding: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 12,
                  ),
                  textStyle: const TextStyle(
                    fontSize: 15,
                    fontWeight: FontWeight.w600,
                  ),
                ),
              ),
              inputDecorationTheme: InputDecorationTheme(
                filled: true,
                fillColor: Colors.white,
                contentPadding: const EdgeInsets.symmetric(
                  horizontal: 18,
                  vertical: 16,
                ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                enabledBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFE2E8F0),
                    width: 1.5,
                  ),
                ),
                focusedBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFF8B5CF6),
                    width: 2.5,
                  ),
                ),
                errorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFEF4444),
                    width: 1.5,
                  ),
                ),
                focusedErrorBorder: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(14),
                  borderSide: const BorderSide(
                    color: Color(0xFFEF4444),
                    width: 2.5,
                  ),
                ),
                labelStyle: const TextStyle(
                  color: Color(0xFF64748B),
                  fontWeight: FontWeight.w500,
                ),
                floatingLabelStyle: const TextStyle(
                  color: Color(0xFF8B5CF6),
                  fontWeight: FontWeight.w600,
                ),
                hintStyle: TextStyle(
                  color: Colors.grey[400],
                  fontSize: 14,
                ),
                errorStyle: const TextStyle(
                  color: Color(0xFFEF4444),
                  fontSize: 13,
                  fontWeight: FontWeight.w500,
                ),
              ),
              appBarTheme: const AppBarTheme(
                elevation: 0,
                centerTitle: false,
                backgroundColor: Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                titleTextStyle: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Colors.white,
                  letterSpacing: 0.3,
                ),
                iconTheme: IconThemeData(
                  color: Colors.white,
                  size: 24,
                ),
                toolbarHeight: 64,
              ),
              floatingActionButtonTheme: FloatingActionButtonThemeData(
                elevation: 6,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(16),
                ),
                backgroundColor: const Color(0xFF8B5CF6),
                foregroundColor: Colors.white,
                sizeConstraints: const BoxConstraints(
                  minHeight: 60,
                  minWidth: 60,
                ),
              ),
              chipTheme: ChipThemeData(
                backgroundColor: const Color(0xFFF3E8FF),
                selectedColor: const Color(0xFF8B5CF6),
                labelStyle: const TextStyle(
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF1F2937),
                ),
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                side: BorderSide.none,
                padding: const EdgeInsets.symmetric(
                  horizontal: 12,
                  vertical: 8,
                ),
              ),
              bottomNavigationBarTheme: const BottomNavigationBarThemeData(
                elevation: 12,
                backgroundColor: Colors.white,
                selectedItemColor: Color(0xFF8B5CF6),
                unselectedItemColor: Color(0xFF94A3B8),
                selectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  fontSize: 12,
                ),
                unselectedLabelStyle: TextStyle(
                  fontWeight: FontWeight.w500,
                  fontSize: 11,
                ),
                type: BottomNavigationBarType.fixed,
              ),
              navigationRailTheme: const NavigationRailThemeData(
                backgroundColor: Colors.white,
                elevation: 2,
                selectedIconTheme: IconThemeData(
                  color: Color(0xFF8B5CF6),
                  size: 28,
                ),
                unselectedIconTheme: IconThemeData(
                  color: Color(0xFF94A3B8),
                  size: 24,
                ),
                selectedLabelTextStyle: TextStyle(
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF8B5CF6),
                  fontSize: 13,
                ),
                unselectedLabelTextStyle: TextStyle(
                  color: Color(0xFF64748B),
                  fontSize: 12,
                ),
              ),
              dialogTheme: DialogThemeData(
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 8,
                backgroundColor: Colors.white,
                titleTextStyle: const TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
              ),
              snackBarTheme: SnackBarThemeData(
                behavior: SnackBarBehavior.floating,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                ),
                elevation: 6,
                backgroundColor: const Color(0xFF1F2937),
                contentTextStyle: const TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Colors.white,
                ),
              ),
              textTheme: const TextTheme(
                displayLarge: TextStyle(
                  fontSize: 32,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.5,
                ),
                displayMedium: TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                  letterSpacing: -0.3,
                ),
                displaySmall: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
                headlineLarge: TextStyle(
                  fontSize: 22,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
                headlineMedium: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF1F2937),
                ),
                headlineSmall: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w700,
                  color: Color(0xFF374151),
                ),
                titleLarge: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
                titleMedium: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
                titleSmall: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                ),
                bodyLarge: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF374151),
                ),
                bodyMedium: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF4B5563),
                  height: 1.5,
                ),
                bodySmall: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w500,
                  color: Color(0xFF6B7280),
                ),
                labelLarge: TextStyle(
                  fontSize: 14,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF374151),
                ),
                labelMedium: TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF4B5563),
                ),
                labelSmall: TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w600,
                  color: Color(0xFF6B7280),
                  letterSpacing: 0.5,
                ),
              ),
            ),

            // =================================================
            // DARK THEME
            // =================================================

            darkTheme: _buildDarkTheme(),

            themeMode: themeProvider.themeMode,

            locale: languageProvider.locale,

            // =================================================
            // LOCALIZATION
            // =================================================

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

  // ==========================================================
  // DARK THEME BUILDER
  // ==========================================================

  ThemeData _buildDarkTheme() {
    final scheme = ColorScheme.fromSeed(
      seedColor: const Color(0xFFA78BFA),
      brightness: Brightness.dark,
      surface: const Color(0xFF171923),
    );

    final border = OutlineInputBorder(
      borderRadius: BorderRadius.circular(14),
      borderSide: BorderSide(color: scheme.outlineVariant),
    );

    return ThemeData(
      useMaterial3: true,
      colorScheme: scheme,
      brightness: Brightness.dark,
      fontFamily: 'sans-serif',
      scaffoldBackgroundColor: const Color(0xFF10121A),
      cardTheme: CardThemeData(
        color: const Color(0xFF191C27),
        elevation: 1,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        clipBehavior: Clip.antiAlias,
      ),
      appBarTheme: AppBarTheme(
        backgroundColor: const Color(0xFF171923),
        foregroundColor: scheme.onSurface,
        elevation: 0,
        centerTitle: false,
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: const Color(0xFF202330),
        contentPadding: const EdgeInsets.symmetric(
          horizontal: 16,
          vertical: 15,
        ),
        border: border,
        enabledBorder: border,
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: scheme.primary,
            width: 2,
          ),
        ),
        errorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(color: scheme.error),
        ),
        focusedErrorBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(14),
          borderSide: BorderSide(
            color: scheme.error,
            width: 2,
          ),
        ),
        labelStyle: TextStyle(color: scheme.onSurfaceVariant),
        hintStyle: TextStyle(
          color: scheme.onSurfaceVariant.withOpacity(0.8),
        ),
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 15,
          ),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          backgroundColor: scheme.primary,
          foregroundColor: scheme.onPrimary,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(14),
          ),
          padding: const EdgeInsets.symmetric(
            horizontal: 22,
            vertical: 15,
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        backgroundColor: const Color(0xFF171923),
        indicatorColor: scheme.primaryContainer,
        labelTextStyle: WidgetStatePropertyAll(
          TextStyle(color: scheme.onSurfaceVariant),
        ),
      ),
      navigationRailTheme: NavigationRailThemeData(
        backgroundColor: const Color(0xFF171923),
        indicatorColor: scheme.primaryContainer,
      ),
      dialogTheme: DialogThemeData(
        backgroundColor: const Color(0xFF1B1E29),
        titleTextStyle: TextStyle(
          color: scheme.onSurface,
          fontSize: 20,
          fontWeight: FontWeight.w700,
        ),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
      snackBarTheme: SnackBarThemeData(
        behavior: SnackBarBehavior.floating,
        backgroundColor: scheme.inverseSurface,
        contentTextStyle: TextStyle(color: scheme.onInverseSurface),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
      dividerTheme: DividerThemeData(
        color: scheme.outlineVariant,
      ),
    );
  }
}

// ============================================================
// APPLICATION INITIALIZER
// ============================================================

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
    // Load application settings.
    try {
      await context.read<AppSettingsProvider>().load();
    } catch (e) {
      debugPrint('App settings initialization error: $e');
    }

    // Initialize local database.
    try {
      initializeDatabaseFactory();

      final db = await DatabaseHelper.instance.database;

      debugPrint('Database initialized successfully');

      // Run database synchronization migrations.
      await SyncMigration.runAllMigrations(db);
    } catch (e) {
      debugPrint('Database initialization error: $e');
    }

    if (!mounted) return;

    final authProvider = Provider.of<AuthProvider>(
      context,
      listen: false,
    );
    await authProvider.checkAuthStatus();
    if (!mounted) return;

    if (!authProvider.isAuthenticated || authProvider.shouldShowOnboarding) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => const AuthRouter(),
        ),
      );
      return;
    }

    // Initialize license trial.
    try {
      await LicenseManager.initializeTrial();
    } catch (e) {
      debugPrint('License initialization error: $e');
    }

    // Check license status.
    bool isLicensed = false;

    try {
      isLicensed = await LicenseManager.isLicensed();
    } catch (e) {
      debugPrint('License check error: $e');
      isLicensed = false;
    }

    // Check subscription status.
    try {
      final subscription = await SubscriptionService().loadStatus();

      isLicensed = isLicensed || (subscription?.isActive ?? false);
    } catch (e) {
      debugPrint('Subscription status check error: $e');
    }

    if (!mounted) return;

    // Navigate to the appropriate screen.
    try {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(
          builder: (_) => isLicensed
              ? const ProductionShellScreen()
              : const LicenseScreen(),
        ),
      );
    } catch (e) {
      debugPrint('Navigation error: $e');

      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(
            builder: (_) => const LicenseScreen(),
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return const SplashScreen();
  }
}
