import 'package:flutter/material.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:provider/provider.dart';

import 'core/constants/app_constants.dart';
import 'core/l10n/app_localizations.dart';
import 'core/theme/app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/business_provider.dart';
import 'providers/customer_provider.dart';
import 'providers/expense_provider.dart';
import 'providers/pos_provider.dart';
import 'providers/printer_provider.dart';
import 'providers/product_provider.dart';
import 'providers/report_provider.dart';
import 'providers/sync_provider.dart';
import 'screens/01_splash_screen.dart';
import 'screens/02_onboarding_screen.dart';
import 'screens/03_auth_screen.dart';
import 'screens/04_business_setup_screen.dart';
import 'screens/05_dashboard_screen.dart';
import 'screens/06_quick_billing_pos_screen.dart';
import 'screens/08_sales_history_screen.dart';
import 'screens/09_product_management_screen.dart';
import 'screens/10_product_categories_screen.dart';
import 'screens/11_inventory_stock_alerts_screen.dart';
import 'screens/12_purchase_management_screen.dart';
import 'screens/13_customer_management_screen.dart';
import 'screens/15_supplier_management_screen.dart';
import 'screens/16_expenses_screen.dart';
import 'screens/17_payments_collections_screen.dart';
import 'screens/18_gst_reports_screen.dart';
import 'screens/19_profit_loss_screen.dart';
import 'screens/20_reports_screen.dart';
import 'screens/21_bluetooth_printer_screen.dart';
import 'screens/22_business_settings_screen.dart';
import 'screens/23_staff_management_screen.dart';
import 'screens/24_subscription_screen.dart';
import 'screens/25_backup_restore_screen.dart';
import 'screens/26_help_support_screen.dart';
import 'screens/main_navigation_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const KadaiKhataApp());
}

class KadaiKhataApp extends StatefulWidget {
  const KadaiKhataApp({super.key});

  @override
  State<KadaiKhataApp> createState() => _KadaiKhataAppState();
}

class _KadaiKhataAppState extends State<KadaiKhataApp> {
  Locale _locale = const Locale('en');

  void setLocale(Locale newLocale) {
    setState(() {
      _locale = newLocale;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => BusinessProvider()),
        ChangeNotifierProvider(create: (_) => PosProvider()),
        ChangeNotifierProvider(create: (_) => ProductProvider()),
        ChangeNotifierProvider(create: (_) => CustomerProvider()),
        ChangeNotifierProvider(create: (_) => ExpenseProvider()),
        ChangeNotifierProvider(create: (_) => ReportProvider()),
        ChangeNotifierProvider(create: (_) => PrinterProvider()),
        ChangeNotifierProvider(create: (_) => SyncProvider()),
      ],
      child: MaterialApp(
        title: AppConstants.appName,
        debugShowCheckedModeBanner: false,
        theme: AppTheme.lightTheme,
        locale: _locale,
        supportedLocales: const [
          Locale('en', 'US'),
          Locale('ta', 'IN'),
        ],
        localizationsDelegates: const [
          AppLocalizationsDelegate(),
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        home: const SplashScreen(),
        routes: {
          '/splash': (_) => const SplashScreen(),
          '/onboarding': (_) => const OnboardingScreen(),
          '/auth': (_) => const AuthScreen(),
          '/business_setup': (_) => const BusinessSetupScreen(),
          '/main': (_) => const MainNavigationScreen(),
          '/dashboard': (_) => const DashboardScreen(),
          '/pos': (_) => const QuickBillingPosScreen(),
          '/sales_history': (_) => const SalesHistoryScreen(),
          '/products': (_) => const ProductManagementScreen(),
          '/categories': (_) => const ProductCategoriesScreen(),
          '/inventory': (_) => const InventoryStockAlertsScreen(),
          '/purchases': (_) => const PurchaseManagementScreen(),
          '/customers': (_) => const CustomerManagementScreen(),
          '/suppliers': (_) => const SupplierManagementScreen(),
          '/expenses': (_) => const ExpensesScreen(),
          '/payments': (_) => const PaymentsCollectionsScreen(),
          '/gst_reports': (_) => const GstReportsScreen(),
          '/profit_loss': (_) => const ProfitLossScreen(),
          '/reports': (_) => const ReportsScreen(),
          '/printer': (_) => const BluetoothPrinterScreen(),
          '/settings': (_) => const BusinessSettingsScreen(),
          '/staff': (_) => const StaffManagementScreen(),
          '/subscription': (_) => const SubscriptionScreen(),
          '/sync': (_) => const BackupRestoreScreen(),
          '/help': (_) => const HelpSupportScreen(),
        },
      ),
    );
  }
}
