import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_colors.dart';
import '../core/database/app_database.dart';
import '../core/network/api_client.dart';
import '../models/business_model.dart';
import '../providers/auth_provider.dart';
import '../providers/business_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/product_provider.dart';
import 'main_navigation_screen.dart';

class AuthScreen extends StatefulWidget {
  const AuthScreen({super.key});

  @override
  State<AuthScreen> createState() => _AuthScreenState();
}

class _AuthScreenState extends State<AuthScreen> with SingleTickerProviderStateMixin {
  late TabController _tabController;

  // Login controllers
  final _loginEmailController = TextEditingController(text: 'shopowner@gmail.com');
  final _loginPasswordController = TextEditingController(text: 'password123');

  // Register controllers
  final _regNameController = TextEditingController();
  final _regStoreNameController = TextEditingController();
  final _regPhoneController = TextEditingController();
  final _regEmailController = TextEditingController();
  final _regPasswordController = TextEditingController();
  final _regGstinController = TextEditingController();

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
  }

  @override
  void dispose() {
    _tabController.dispose();
    _loginEmailController.dispose();
    _loginPasswordController.dispose();
    _regNameController.dispose();
    _regStoreNameController.dispose();
    _regPhoneController.dispose();
    _regEmailController.dispose();
    _regPasswordController.dispose();
    _regGstinController.dispose();
    super.dispose();
  }

  Future<void> _handleLogin() async {
    final email = _loginEmailController.text.trim();
    final password = _loginPasswordController.text;

    if (email.isEmpty || password.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please enter email and password')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    final success = await auth.login(email, password);

    if (success && mounted) {
      if (auth.businesses.isNotEmpty) {
        await businessProvider.init(auth.businesses);
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text(auth.errorMessage ?? 'Connection timeout. Check Server URL or use Offline Mode.'),
          action: SnackBarAction(
            label: 'Offline Mode',
            textColor: Colors.amber,
            onPressed: _handleOfflineMode,
          ),
        ),
      );
    }
  }

  Future<void> _handleRegister() async {
    final name = _regNameController.text.trim();
    final storeName = _regStoreNameController.text.trim();
    final phone = _regPhoneController.text.trim();
    final email = _regEmailController.text.trim();
    final password = _regPasswordController.text;

    if (name.isEmpty || email.isEmpty || password.isEmpty || phone.isEmpty) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Please fill all required fields')),
      );
      return;
    }

    final auth = Provider.of<AuthProvider>(context, listen: false);
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);

    final success = await auth.register(
      name: name,
      email: email,
      phone: phone,
      password: password,
      shopName: storeName.isNotEmpty ? storeName : null,
      gstin: _regGstinController.text.trim().isNotEmpty ? _regGstinController.text.trim() : null,
    );

    if (success && mounted) {
      if (auth.businesses.isNotEmpty) {
        await businessProvider.init(auth.businesses);
      }
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    } else if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(auth.errorMessage ?? 'Registration failed')),
      );
    }
  }

  void _handleOfflineMode() async {
    final businessProvider = Provider.of<BusinessProvider>(context, listen: false);
    final productProvider = Provider.of<ProductProvider>(context, listen: false);

    // Pre-populate demo grocery products in phone's SQLite DB if empty
    final db = AppDatabase();
    final cached = await db.getCachedProducts();
    if (cached.isEmpty) {
      await db.cacheProducts([
        {
          'id': 1,
          'business_id': 1,
          'category_id': 1,
          'name': 'Ponni Boiled Rice 25kg',
          'sku': 'RICE-PONNI-25',
          'barcode': '8901234001',
          'unit': 'BAG',
          'purchase_cost': 1200.0,
          'selling_price': 1350.0,
          'mrp': 1400.0,
          'tax_rate': 0.0,
          'hsn_code': '1006',
          'current_stock': 40.0,
          'min_stock_threshold': 5.0,
          'is_active': 1,
        },
        {
          'id': 2,
          'business_id': 1,
          'category_id': 1,
          'name': 'Toor Dal Premium 1kg',
          'sku': 'DAL-TOOR-1KG',
          'barcode': '8901234002',
          'unit': 'KG',
          'purchase_cost': 140.0,
          'selling_price': 165.0,
          'mrp': 175.0,
          'tax_rate': 0.0,
          'hsn_code': '0713',
          'current_stock': 85.0,
          'min_stock_threshold': 10.0,
          'is_active': 1,
        },
        {
          'id': 3,
          'business_id': 1,
          'category_id': 2,
          'name': 'Gold Winner Sunflower Oil 1L',
          'sku': 'OIL-GW-1L',
          'barcode': '8901234003',
          'unit': 'PKT',
          'purchase_cost': 110.0,
          'selling_price': 125.0,
          'mrp': 135.0,
          'tax_rate': 5.0,
          'hsn_code': '1512',
          'current_stock': 120.0,
          'min_stock_threshold': 15.0,
          'is_active': 1,
        },
        {
          'id': 4,
          'business_id': 1,
          'category_id': 3,
          'name': 'Tata Tea Gold 500g',
          'sku': 'TEA-TATA-500',
          'barcode': '8901234004',
          'unit': 'PKT',
          'purchase_cost': 210.0,
          'selling_price': 240.0,
          'mrp': 255.0,
          'tax_rate': 5.0,
          'hsn_code': '0902',
          'current_stock': 60.0,
          'min_stock_threshold': 8.0,
          'is_active': 1,
        },
        {
          'id': 5,
          'business_id': 1,
          'category_id': 4,
          'name': 'Refined White Sugar 1kg',
          'sku': 'SUGAR-1KG',
          'barcode': '8901234005',
          'unit': 'KG',
          'purchase_cost': 38.0,
          'selling_price': 44.0,
          'mrp': 46.0,
          'tax_rate': 5.0,
          'hsn_code': '1701',
          'current_stock': 200.0,
          'min_stock_threshold': 20.0,
          'is_active': 1,
        },
      ]);
    }

    final demoBiz = BusinessModel(
      id: 1,
      uuid: 'demo-shop-uuid',
      name: 'Sri Murugan Maligai Store',
      legalName: 'Sri Murugan Maligai Store',
      businessType: 'grocery',
      gstin: '33AAAAA0000A1Z5',
      phone: '9876543210',
      address: '12 Bazaar Street, Madurai',
      city: 'Madurai',
      state: 'Tamil Nadu',
      stateCode: '33',
      currency: 'INR',
      taxType: 'gst',
      invoicePrefix: 'INV-',
      nextInvoiceNumber: 101,
      receiptFooter: 'நன்றி! மீண்டும் வருக! / Thank You Visit Again!',
      upiVpa: 'shop@okaxis',
      upiName: 'Sri Murugan Maligai',
      enableThermalLogo: true,
      enableLowStockAlerts: true,
      isActive: true,
      userRole: 'owner',
    );

    await businessProvider.switchBusiness(demoBiz);
    await productProvider.fetchProducts();

    if (mounted) {
      Navigator.of(context).pushReplacement(
        MaterialPageRoute(builder: (_) => const MainNavigationScreen()),
      );
    }
  }

  void _showServerSettingsDialog() {
    final client = ApiClient();
    final urlCtrl = TextEditingController(text: client.baseUrl);

    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Server / API URL Settings'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Enter your PC IP address (if on same Wi-Fi) or Live Hosting URL:',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: urlCtrl,
              decoration: const InputDecoration(
                labelText: 'API Base URL',
                hintText: 'http://192.168.1.X/Shop/backend/public/api',
              ),
            ),
            const SizedBox(height: 10),
            const Text(
              'Local PC Wi-Fi URL:\nhttp://10.73.28.195/Shop/backend/public/api',
              style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.bold),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () async {
              client.setBaseUrl(urlCtrl.text.trim());
              final prefs = await SharedPreferences.getInstance();
              await prefs.setString('custom_api_url', urlCtrl.text.trim());
              if (mounted) Navigator.pop(ctx);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Server URL updated! Now try login.')),
              );
            },
            child: const Text('Save URL'),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final auth = Provider.of<AuthProvider>(context);

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.settings, color: AppColors.primary),
            tooltip: 'Server & Hosting Settings',
            onPressed: _showServerSettingsDialog,
          ),
        ],
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          child: Padding(
            padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 10.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Center(
                  child: Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.1),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(Icons.storefront_rounded, size: 48, color: AppColors.primary),
                  ),
                ),
                const SizedBox(height: 14),
                const Center(
                  child: Text(
                    'KadaiKhata',
                    style: TextStyle(fontSize: 26, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                ),
                const Center(
                  child: Text(
                    'Smart Shop Billing & Khata',
                    style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
                  ),
                ),
                const SizedBox(height: 20),

                Container(
                  decoration: BoxDecoration(
                    color: Colors.grey.shade100,
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    indicator: BoxDecoration(
                      color: AppColors.primary,
                      borderRadius: BorderRadius.circular(12),
                    ),
                    indicatorSize: TabBarIndicatorSize.tab,
                    labelColor: Colors.white,
                    unselectedLabelColor: AppColors.textSecondary,
                    labelStyle: const TextStyle(fontWeight: FontWeight.bold),
                    tabs: const [
                      Tab(text: 'Login'),
                      Tab(text: 'Register Shop'),
                    ],
                  ),
                ),

                const SizedBox(height: 20),

                SizedBox(
                  height: 520,
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      // --- LOGIN TAB ---
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _loginEmailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(
                                labelText: 'Email or Mobile Number',
                                prefixIcon: Icon(Icons.person_outline),
                              ),
                            ),
                            const SizedBox(height: 14),
                            TextField(
                              controller: _loginPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(
                                labelText: 'Password',
                                prefixIcon: Icon(Icons.lock_outline),
                              ),
                            ),
                            const SizedBox(height: 6),
                            Align(
                              alignment: Alignment.centerRight,
                              child: TextButton(
                                onPressed: () {
                                  ScaffoldMessenger.of(context).showSnackBar(
                                    const SnackBar(content: Text('Demo Password: password123')),
                                  );
                                },
                                child: const Text('Forgot Password?'),
                              ),
                            ),
                            const SizedBox(height: 12),
                            ElevatedButton(
                              onPressed: auth.isLoading ? null : _handleLogin,
                              child: auth.isLoading
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('Login to Store (Online)'),
                            ),
                            const SizedBox(height: 12),

                            // --- OFFLINE DEMO BUTTON ---
                            OutlinedButton.icon(
                              onPressed: _handleOfflineMode,
                              style: OutlinedButton.styleFrom(
                                foregroundColor: AppColors.primary,
                                side: const BorderSide(color: AppColors.primary, width: 1.5),
                                padding: const EdgeInsets.symmetric(vertical: 12),
                              ),
                              icon: const Icon(Icons.bolt, color: Colors.orange),
                              label: const Text('Try Offline Mode (No Server Needed)',
                                  style: TextStyle(fontWeight: FontWeight.bold)),
                            ),
                            const SizedBox(height: 16),

                            Container(
                              padding: const EdgeInsets.all(12),
                              decoration: BoxDecoration(
                                color: AppColors.primary.withOpacity(0.05),
                                borderRadius: BorderRadius.circular(8),
                                border: Border.all(color: AppColors.primary.withOpacity(0.2)),
                              ),
                              child: Column(
                                children: [
                                  const Text('Quick Demo Login:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12)),
                                  const SizedBox(height: 6),
                                  Row(
                                    mainAxisAlignment: MainAxisAlignment.center,
                                    children: [
                                      OutlinedButton(
                                        onPressed: () {
                                          _loginEmailController.text = 'shopowner@gmail.com';
                                          _loginPasswordController.text = 'password123';
                                          _handleLogin();
                                        },
                                        child: const Text('Owner Login', style: TextStyle(fontSize: 12)),
                                      ),
                                      const SizedBox(width: 8),
                                      OutlinedButton(
                                        onPressed: () {
                                          _loginEmailController.text = 'cashier@gmail.com';
                                          _loginPasswordController.text = 'password123';
                                          _handleLogin();
                                        },
                                        child: const Text('Cashier Login', style: TextStyle(fontSize: 12)),
                                      ),
                                    ],
                                  ),
                                  const SizedBox(height: 8),
                                  TextButton.icon(
                                    onPressed: _showServerSettingsDialog,
                                    icon: const Icon(Icons.settings_ethernet, size: 16),
                                    label: const Text('Change Server / Hosting URL', style: TextStyle(fontSize: 11)),
                                  ),
                                ],
                              ),
                            ),
                          ],
                        ),
                      ),

                      // --- REGISTER TAB ---
                      SingleChildScrollView(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.stretch,
                          children: [
                            TextField(
                              controller: _regNameController,
                              decoration: const InputDecoration(labelText: 'Owner Full Name *', prefixIcon: Icon(Icons.person)),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _regStoreNameController,
                              decoration: const InputDecoration(labelText: 'Shop / Store Name *', prefixIcon: Icon(Icons.store)),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _regPhoneController,
                              keyboardType: TextInputType.phone,
                              decoration: const InputDecoration(labelText: 'Mobile Number *', prefixIcon: Icon(Icons.phone)),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _regEmailController,
                              keyboardType: TextInputType.emailAddress,
                              decoration: const InputDecoration(labelText: 'Email Address *', prefixIcon: Icon(Icons.email)),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _regGstinController,
                              textCapitalization: TextCapitalization.characters,
                              decoration: const InputDecoration(labelText: 'GSTIN (Optional)', prefixIcon: Icon(Icons.badge)),
                            ),
                            const SizedBox(height: 12),
                            TextField(
                              controller: _regPasswordController,
                              obscureText: true,
                              decoration: const InputDecoration(labelText: 'Create Password *', prefixIcon: Icon(Icons.lock)),
                            ),
                            const SizedBox(height: 20),
                            ElevatedButton(
                              onPressed: auth.isLoading ? null : _handleRegister,
                              child: auth.isLoading
                                  ? const SizedBox(height: 20, width: 20, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                                  : const Text('Create Store & Start Free Trial'),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
