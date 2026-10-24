import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/constants/app_constants.dart';
import '../providers/auth_provider.dart';
import '../providers/business_provider.dart';
import '03_auth_screen.dart';
import '04_business_setup_screen.dart';
import '05_dashboard_screen.dart';
import '06_quick_billing_pos_screen.dart';
import '08_sales_history_screen.dart';
import '09_product_management_screen.dart';
import '10_product_categories_screen.dart';
import '11_inventory_stock_alerts_screen.dart';
import '12_purchase_management_screen.dart';
import '13_customer_management_screen.dart';
import '15_supplier_management_screen.dart';
import '16_expenses_screen.dart';
import '17_payments_collections_screen.dart';
import '18_gst_reports_screen.dart';
import '19_profit_loss_screen.dart';
import '20_reports_screen.dart';
import '21_bluetooth_printer_screen.dart';
import '22_business_settings_screen.dart';
import '23_staff_management_screen.dart';
import '24_subscription_screen.dart';
import '25_backup_restore_screen.dart';
import '26_help_support_screen.dart';

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;

  final List<Widget> _primaryScreens = const [
    QuickBillingPosScreen(),
    DashboardScreen(),
    ProductManagementScreen(),
    CustomerManagementScreen(),
  ];

  void _onTabSelected(int index) {
    setState(() => _currentIndex = index);
  }

  void _navigateToScreen(Widget screen) {
    Navigator.pop(context); // Close drawer
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  void _showSwitchBusinessModal() {
    Navigator.pop(context); // Close drawer
    final authProv = Provider.of<AuthProvider>(context, listen: false);
    final bizProv = Provider.of<BusinessProvider>(context, listen: false);
    final userBusinesses = authProv.businesses;

    showModalBottomSheet(
      context: context,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Text('Switch Shop / கடை மாற்று',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                  IconButton(
                    icon: const Icon(Icons.add_business),
                    tooltip: 'Add New Shop',
                    onPressed: () {
                      Navigator.pop(ctx);
                      Navigator.push(context, MaterialPageRoute(builder: (_) => const BusinessSetupScreen()));
                    },
                  ),
                ],
              ),
              const SizedBox(height: 12),
              ...userBusinesses.map((biz) {
                final isSelected = bizProv.currentBusiness?.id == biz.id;
                return Card(
                  margin: const EdgeInsets.only(bottom: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                    side: BorderSide(color: isSelected ? AppColors.primary : Colors.transparent),
                  ),
                  child: ListTile(
                    leading: CircleAvatar(
                      backgroundColor: isSelected ? AppColors.primary : Colors.grey.shade200,
                      child: Text(
                        biz.name.isNotEmpty ? biz.name[0].toUpperCase() : 'S',
                        style: TextStyle(color: isSelected ? Colors.white : Colors.black87, fontWeight: FontWeight.bold),
                      ),
                    ),
                    title: Text(biz.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                    subtitle: Text('${biz.city ?? 'Tamil Nadu'} • Role: ${biz.userRole ?? 'Owner'}'),
                    trailing: isSelected ? const Icon(Icons.check_circle, color: AppColors.primary) : null,
                    onTap: () async {
                      await bizProv.switchBusiness(biz);
                      if (context.mounted) Navigator.pop(ctx);
                    },
                  ),
                );
              }),
            ],
          ),
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final authProv = Provider.of<AuthProvider>(context);
    final bizProv = Provider.of<BusinessProvider>(context);
    final currentBiz = bizProv.currentBusiness;
    final currentUser = authProv.user;

    return Scaffold(
      drawer: Drawer(
        child: ListView(
          padding: EdgeInsets.zero,
          children: [
            // Drawer Header with Business and User Details
            UserAccountsDrawerHeader(
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryLight],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              accountName: Row(
                children: [
                  Expanded(
                    child: Text(
                      currentBiz?.name ?? 'KadaiKhata Store',
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                      maxLines: 1,
                      overflow: TextOverflow.ellipsis,
                    ),
                  ),
                  InkWell(
                    onTap: _showSwitchBusinessModal,
                    child: Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(color: Colors.white24, borderRadius: BorderRadius.circular(8)),
                      child: const Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          Icon(Icons.swap_horiz, color: Colors.white, size: 14),
                          SizedBox(width: 2),
                          Text('Switch', style: TextStyle(color: Colors.white, fontSize: 10, fontWeight: FontWeight.bold)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
              accountEmail: Text(
                '${currentUser?.name ?? 'Owner'} (${currentUser?.role ?? 'Admin'}) • ${currentUser?.phone ?? currentUser?.email ?? ''}',
                style: const TextStyle(fontSize: 12, color: Colors.white70),
              ),
              currentAccountPicture: CircleAvatar(
                backgroundColor: Colors.white,
                child: Text(
                  currentBiz?.name.isNotEmpty == true ? currentBiz!.name[0].toUpperCase() : 'K',
                  style: const TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.primary),
                ),
              ),
            ),

            // Billing & Sales Section
            _DrawerSectionTitle(title: 'Billing & POS / விற்பனை'),
            _DrawerItem(
              icon: Icons.point_of_sale,
              title: 'Quick POS Counter Billing',
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 0);
              },
            ),
            _DrawerItem(
              icon: Icons.receipt_long,
              title: 'Sales History & Invoices',
              onTap: () => _navigateToScreen(const SalesHistoryScreen()),
            ),

            const Divider(),

            // Products & Stock Section
            _DrawerSectionTitle(title: 'Catalog & Inventory / இருப்பு'),
            _DrawerItem(
              icon: Icons.inventory_2,
              title: 'Product Catalog',
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 2);
              },
            ),
            _DrawerItem(
              icon: Icons.category,
              title: 'Product Categories',
              onTap: () => _navigateToScreen(const ProductCategoriesScreen()),
            ),
            _DrawerItem(
              icon: Icons.warning_amber_rounded,
              title: 'Inventory & Stock Alerts',
              onTap: () => _navigateToScreen(const InventoryStockAlertsScreen()),
            ),

            const Divider(),

            // Khata & Parties Section
            _DrawerSectionTitle(title: 'Customers & Suppliers / கணக்குகள்'),
            _DrawerItem(
              icon: Icons.people,
              title: 'Customer Khata (Credit Ledgers)',
              onTap: () {
                Navigator.pop(context);
                setState(() => _currentIndex = 3);
              },
            ),
            _DrawerItem(
              icon: Icons.shopping_cart_checkout,
              title: 'Purchase Management',
              onTap: () => _navigateToScreen(const PurchaseManagementScreen()),
            ),
            _DrawerItem(
              icon: Icons.storefront,
              title: 'Suppliers Directory',
              onTap: () => _navigateToScreen(const SupplierManagementScreen()),
            ),

            const Divider(),

            // Accounting & Reports Section
            _DrawerSectionTitle(title: 'Accounts & Reports / அறிக்கைகள்'),
            _DrawerItem(
              icon: Icons.money_off,
              title: 'Daily Expenses',
              onTap: () => _navigateToScreen(const ExpensesScreen()),
            ),
            _DrawerItem(
              icon: Icons.payments,
              title: 'Payments & Collections Feed',
              onTap: () => _navigateToScreen(const PaymentsCollectionsScreen()),
            ),
            _DrawerItem(
              icon: Icons.trending_up,
              title: 'Profit & Loss Statement',
              onTap: () => _navigateToScreen(const ProfitLossScreen()),
            ),
            _DrawerItem(
              icon: Icons.account_balance,
              title: 'GST Summary (GSTR-1)',
              onTap: () => _navigateToScreen(const GstReportsScreen()),
            ),
            _DrawerItem(
              icon: Icons.analytics,
              title: 'Reports Hub (PDF / Excel)',
              onTap: () => _navigateToScreen(const ReportsScreen()),
            ),

            const Divider(),

            // Hardware & Settings Section
            _DrawerSectionTitle(title: 'Settings & Hardware / அமைப்புகள்'),
            _DrawerItem(
              icon: Icons.bluetooth,
              title: 'Bluetooth Thermal Printer Setup',
              onTap: () => _navigateToScreen(const BluetoothPrinterScreen()),
            ),
            _DrawerItem(
              icon: Icons.settings,
              title: 'Shop & Billing Settings',
              onTap: () => _navigateToScreen(const BusinessSettingsScreen()),
            ),
            _DrawerItem(
              icon: Icons.group,
              title: 'Staff & Cashier Roles',
              onTap: () => _navigateToScreen(const StaffManagementScreen()),
            ),
            _DrawerItem(
              icon: Icons.card_membership,
              title: 'Subscription & Plans',
              onTap: () => _navigateToScreen(const SubscriptionScreen()),
            ),
            _DrawerItem(
              icon: Icons.cloud_sync,
              title: 'Backup, Restore & Sync',
              onTap: () => _navigateToScreen(const BackupRestoreScreen()),
            ),
            _DrawerItem(
              icon: Icons.help_outline,
              title: 'Help, Support & FAQs',
              onTap: () => _navigateToScreen(const HelpSupportScreen()),
            ),

            const Divider(),

            // Logout
            ListTile(
              leading: const Icon(Icons.logout, color: Colors.red),
              title: const Text('Logout / வெளியேறு', style: TextStyle(color: Colors.red, fontWeight: FontWeight.bold)),
              onTap: () async {
                Navigator.pop(context);
                await authProv.logout();
                if (context.mounted) {
                  Navigator.pushAndRemoveUntil(
                    context,
                    MaterialPageRoute(builder: (_) => const AuthScreen()),
                    (route) => false,
                  );
                }
              },
            ),
            const SizedBox(height: 20),
          ],
        ),
      ),
      body: IndexedStack(
        index: _currentIndex,
        children: _primaryScreens,
      ),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _currentIndex,
        onDestinationSelected: _onTabSelected,
        destinations: const [
          NavigationDestination(
            icon: Icon(Icons.point_of_sale_outlined),
            selectedIcon: Icon(Icons.point_of_sale, color: AppColors.primary),
            label: 'Quick POS',
          ),
          NavigationDestination(
            icon: Icon(Icons.dashboard_outlined),
            selectedIcon: Icon(Icons.dashboard, color: AppColors.primary),
            label: 'Dashboard',
          ),
          NavigationDestination(
            icon: Icon(Icons.inventory_2_outlined),
            selectedIcon: Icon(Icons.inventory_2, color: AppColors.primary),
            label: 'Products',
          ),
          NavigationDestination(
            icon: Icon(Icons.account_balance_wallet_outlined),
            selectedIcon: Icon(Icons.account_balance_wallet, color: AppColors.primary),
            label: 'Khata',
          ),
        ],
      ),
    );
  }
}

class _DrawerSectionTitle extends StatelessWidget {
  final String title;

  const _DrawerSectionTitle({required this.title});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(left: 16, top: 8, bottom: 4),
      child: Text(
        title,
        style: TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey.shade600, letterSpacing: 0.5),
      ),
    );
  }
}

class _DrawerItem extends StatelessWidget {
  final IconData icon;
  final String title;
  final VoidCallback onTap;

  const _DrawerItem({required this.icon, required this.title, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(title, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w500)),
      dense: true,
      onTap: onTap,
    );
  }
}
