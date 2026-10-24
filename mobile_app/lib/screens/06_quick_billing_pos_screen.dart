import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/customer_model.dart';
import '../models/product_model.dart';
import '../providers/business_provider.dart';
import '../providers/customer_provider.dart';
import '../providers/pos_provider.dart';
import '../providers/product_provider.dart';
import '07_invoice_preview_screen.dart';

class QuickBillingPosScreen extends StatefulWidget {
  const QuickBillingPosScreen({super.key});

  @override
  State<QuickBillingPosScreen> createState() => _QuickBillingPosScreenState();
}

class _QuickBillingPosScreenState extends State<QuickBillingPosScreen> {
  final _searchController = TextEditingController();
  int? _selectedCategoryId;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final productProvider = Provider.of<ProductProvider>(context, listen: false);
      productProvider.fetchCategories();
      productProvider.fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onSearchChanged(String query) {
    Provider.of<ProductProvider>(context, listen: false).fetchProducts(
      search: query,
      categoryId: _selectedCategoryId,
    );
  }

  void _showCartSheet() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => const _CartBottomSheet(),
    );
  }

  void _showCustomerPicker() {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      builder: (ctx) => const _CustomerPickerSheet(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final pos = Provider.of<PosProvider>(context);
    final productProvider = Provider.of<ProductProvider>(context);
    final business = Provider.of<BusinessProvider>(context).currentBusiness;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Counter POS Billing'),
        actions: [
          // Selected Customer Quick Pill
          ActionChip(
            avatar: const Icon(Icons.person, size: 16, color: AppColors.primary),
            label: Text(
              pos.customerName,
              style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold),
              maxLines: 1,
              overflow: TextOverflow.ellipsis,
            ),
            backgroundColor: Colors.white,
            side: BorderSide.none,
            onPressed: _showCustomerPicker,
          ),
          const SizedBox(width: 8),
          // Clear cart icon
          if (pos.itemCount > 0)
            IconButton(
              icon: const Icon(Icons.delete_sweep),
              tooltip: 'Clear Cart',
              onPressed: () {
                pos.clearCart();
              },
            ),
        ],
      ),
      body: Column(
        children: [
          // Search & Barcode Row
          Padding(
            padding: const EdgeInsets.fromLTRB(12, 12, 12, 6),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onChanged: _onSearchChanged,
                    decoration: InputDecoration(
                      hintText: 'Search product name, SKU or barcode...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _onSearchChanged('');
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                IconButton.filled(
                  icon: const Icon(Icons.qr_code_scanner),
                  tooltip: 'Scan Barcode',
                  style: IconButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.all(12)),
                  onPressed: () {
                    // Quick simulated barcode scan prompt
                    _showBarcodeManualEntry();
                  },
                ),
              ],
            ),
          ),

          // Categories Horizontal Filter Bar
          if (productProvider.categories.isNotEmpty)
            SizedBox(
              height: 44,
              child: ListView(
                scrollDirection: Axis.horizontal,
                padding: const EdgeInsets.symmetric(horizontal: 12),
                children: [
                  ChoiceChip(
                    label: const Text('All Items'),
                    selected: _selectedCategoryId == null,
                    onSelected: (val) {
                      setState(() => _selectedCategoryId = null);
                      productProvider.fetchProducts(search: _searchController.text);
                    },
                  ),
                  const SizedBox(width: 6),
                  ...productProvider.categories.map((c) {
                    final isSel = _selectedCategoryId == c.id;
                    return Padding(
                      padding: const EdgeInsets.only(right: 6.0),
                      child: ChoiceChip(
                        label: Text(c.name),
                        selected: isSel,
                        onSelected: (val) {
                          setState(() => _selectedCategoryId = val ? c.id : null);
                          productProvider.fetchProducts(
                            search: _searchController.text,
                            categoryId: _selectedCategoryId,
                          );
                        },
                      ),
                    );
                  }),
                ],
              ),
            ),

          const Divider(height: 1),

          // Products Catalog Grid/List
          Expanded(
            child: productProvider.isLoading
                ? const Center(child: CircularProgressIndicator())
                : productProvider.products.isEmpty
                    ? const Center(
                        child: Text(
                          'No products found.\nTap Add Product to add items to catalog.',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : GridView.builder(
                        padding: const EdgeInsets.all(10),
                        gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                          crossAxisCount: 2,
                          childAspectRatio: 1.15,
                          crossAxisSpacing: 10,
                          mainAxisSpacing: 10,
                        ),
                        itemCount: productProvider.products.length,
                        itemBuilder: (context, index) {
                          final product = productProvider.products[index];
                          final inCartQty = pos.cartItems
                              .where((item) => item.product.id == product.id)
                              .fold(0.0, (sum, item) => sum + item.quantity);

                          return _buildProductCard(product, inCartQty, pos);
                        },
                      ),
          ),

          // Bottom Billing Cart Bar (Large Touch Action for Retailers)
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            decoration: BoxDecoration(
              color: Colors.white,
              boxShadow: [
                BoxShadow(color: Colors.black.withOpacity(0.08), blurRadius: 10, offset: const Offset(0, -3)),
              ],
            ),
            child: SafeArea(
              child: Row(
                children: [
                  // Cart Summary Chip
                  InkWell(
                    onTap: _showCartSheet,
                    child: Row(
                      children: [
                        Badge(
                          label: Text('${pos.itemCount}'),
                          isLabelVisible: pos.itemCount > 0,
                          backgroundColor: AppColors.error,
                          child: const Icon(Icons.shopping_cart, size: 28, color: AppColors.primary),
                        ),
                        const SizedBox(width: 12),
                        Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Text(
                              "₹${pos.grandTotal.toStringAsFixed(2)}",
                              style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, color: AppColors.primary),
                            ),
                            Text(
                              "${pos.totalQuantity.toStringAsFixed(pos.totalQuantity.truncateToDouble() == pos.totalQuantity ? 0 : 2)} items",
                              style: const TextStyle(fontSize: 11, color: AppColors.textSecondary),
                            ),
                          ],
                        ),
                      ],
                    ),
                  ),

                  const Spacer(),

                  // Checkout Button
                  ElevatedButton(
                    onPressed: pos.itemCount == 0
                        ? null
                        : () {
                            _showCheckoutSheet(business?.id ?? 1);
                          },
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primary,
                      padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
                    ),
                    child: const Row(
                      children: [
                        Text('CHECKOUT', style: TextStyle(fontWeight: FontWeight.bold)),
                        SizedBox(width: 6),
                        Icon(Icons.arrow_forward, size: 18),
                      ],
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProductCard(ProductModel product, double inCartQty, PosProvider pos) {
    return Card(
      margin: EdgeInsets.zero,
      elevation: inCartQty > 0 ? 3 : 1,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(10),
        side: BorderSide(
          color: inCartQty > 0 ? AppColors.primary : AppColors.border,
          width: inCartQty > 0 ? 1.5 : 1,
        ),
      ),
      child: InkWell(
        onTap: () {
          pos.addProduct(product);
        },
        borderRadius: BorderRadius.circular(10),
        child: Padding(
          padding: const EdgeInsets.all(10.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                    decoration: BoxDecoration(
                      color: AppColors.primary.withOpacity(0.08),
                      borderRadius: BorderRadius.circular(4),
                    ),
                    child: Text(
                      "${product.gstRate.toInt()}% GST",
                      style: const TextStyle(fontSize: 9, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                  ),
                  if (inCartQty > 0)
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                      decoration: BoxDecoration(
                        color: AppColors.primary,
                        borderRadius: BorderRadius.circular(4),
                      ),
                      child: Text(
                        "x${inCartQty.toInt()}",
                        style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: Colors.white),
                      ),
                    ),
                ],
              ),
              const SizedBox(height: 6),
              Expanded(
                child: Text(
                  product.name,
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13, color: AppColors.textPrimary),
                ),
              ),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(
                    "₹${product.sellingPrice.toStringAsFixed(2)}",
                    style: const TextStyle(fontSize: 15, fontWeight: FontWeight.bold, color: AppColors.textPrimary),
                  ),
                  Text(
                    "${product.currentStock.toInt()} ${product.unit}",
                    style: TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: product.isLowStock ? AppColors.error : AppColors.textSecondary,
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _showBarcodeManualEntry() {
    final controller = TextEditingController();
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Scan or Enter Barcode'),
        content: TextField(
          controller: controller,
          keyboardType: TextInputType.number,
          autofocus: true,
          decoration: const InputDecoration(hintText: 'Enter barcode or SKU number'),
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
          ElevatedButton(
            onPressed: () {
              Navigator.pop(ctx);
              final code = controller.text.trim();
              if (code.isNotEmpty) {
                Provider.of<ProductProvider>(context, listen: false).fetchProducts(barcode: code);
              }
            },
            child: const Text('Lookup Product'),
          ),
        ],
      ),
    );
  }

  void _showCheckoutSheet(int businessId) {
    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      backgroundColor: Colors.transparent,
      builder: (ctx) => _CheckoutModalSheet(businessId: businessId),
    );
  }
}

// --- Cart Bottom Sheet ---
class _CartBottomSheet extends StatelessWidget {
  const _CartBottomSheet();

  @override
  Widget build(BuildContext context) {
    final pos = Provider.of<PosProvider>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.75,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: const BoxDecoration(
              border: Border(bottom: BorderSide(color: AppColors.border)),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Text("Shopping Cart (${pos.itemCount} items)",
                    style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
              ],
            ),
          ),
          Expanded(
            child: pos.cartItems.isEmpty
                ? const Center(child: Text('Your cart is empty'))
                : ListView.separated(
                    padding: const EdgeInsets.all(12),
                    itemCount: pos.cartItems.length,
                    separatorBuilder: (_, __) => const Divider(),
                    itemBuilder: (context, index) {
                      final item = pos.cartItems[index];
                      return Row(
                        children: [
                          Expanded(
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.start,
                              children: [
                                Text(item.product.name,
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                Text(
                                  "₹${item.unitPrice.toStringAsFixed(2)} x ${item.quantity.toInt()} ${item.product.unit} • ${item.product.gstRate.toInt()}% GST",
                                  style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                ),
                              ],
                            ),
                          ),
                          // Decrement
                          IconButton(
                            icon: const Icon(Icons.remove_circle_outline, color: AppColors.error),
                            onPressed: () => pos.updateQuantity(index, item.quantity - 1),
                          ),
                          Text("${item.quantity.toInt()}", style: const TextStyle(fontWeight: FontWeight.bold)),
                          // Increment
                          IconButton(
                            icon: const Icon(Icons.add_circle_outline, color: AppColors.primary),
                            onPressed: () => pos.updateQuantity(index, item.quantity + 1),
                          ),
                          // Line Total
                          SizedBox(
                            width: 70,
                            child: Text(
                              "₹${item.lineTotal.toStringAsFixed(2)}",
                              textAlign: TextAlign.end,
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14),
                            ),
                          ),
                        ],
                      );
                    },
                  ),
          ),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.background,
              border: Border(top: BorderSide(color: AppColors.border)),
            ),
            child: Column(
              children: [
                Row(mainAxisAlignment: MainAxisAlignment.between, children: [
                  const Text('Subtotal:'),
                  Text("₹${pos.subtotal.toStringAsFixed(2)}"),
                ]),
                const SizedBox(height: 4),
                Row(mainAxisAlignment: MainAxisAlignment.between, children: [
                  const Text('GST Tax:'),
                  Text("₹${pos.totalTax.toStringAsFixed(2)}"),
                ]),
                const Divider(),
                Row(mainAxisAlignment: MainAxisAlignment.between, children: [
                  const Text('Grand Total:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
                  Text("₹${pos.grandTotal.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                ]),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

// --- Customer Picker Bottom Sheet ---
class _CustomerPickerSheet extends StatelessWidget {
  const _CustomerPickerSheet();

  @override
  Widget build(BuildContext context) {
    final customerProvider = Provider.of<CustomerProvider>(context);
    final pos = Provider.of<PosProvider>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.7,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              const Text('Select Customer / Khata', style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 8),
          ListTile(
            leading: const CircleAvatar(backgroundColor: AppColors.primary, child: Icon(Icons.people, color: Colors.white)),
            title: const Text('Walk-in Customer (General)'),
            subtitle: const Text('No credit khata tracking'),
            onTap: () {
              pos.setCustomer(null);
              Navigator.pop(context);
            },
          ),
          const Divider(),
          TextField(
            onChanged: (val) => customerProvider.fetchCustomers(search: val),
            decoration: const InputDecoration(
              hintText: 'Search customer name or phone...',
              prefixIcon: Icon(Icons.search),
            ),
          ),
          const SizedBox(height: 12),
          Expanded(
            child: ListView.builder(
              itemCount: customerProvider.customers.length,
              itemBuilder: (context, index) {
                final c = customerProvider.customers[index];
                return ListTile(
                  leading: const CircleAvatar(child: Icon(Icons.person)),
                  title: Text(c.name, style: const TextStyle(fontWeight: FontWeight.bold)),
                  subtitle: Text("${c.phone ?? 'No phone'} • Balance: ₹${c.currentBalance.toStringAsFixed(2)}"),
                  trailing: c.hasBalance
                      ? const Text('DUE', style: TextStyle(color: AppColors.error, fontWeight: FontWeight.bold))
                      : null,
                  onTap: () {
                    pos.setCustomer(c);
                    Navigator.pop(context);
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}

// --- Checkout Modal Sheet (Payment Selection & Complete Bill) ---
class _CheckoutModalSheet extends StatelessWidget {
  final int businessId;
  const _CheckoutModalSheet({required this.businessId});

  @override
  Widget build(BuildContext context) {
    final pos = Provider.of<PosProvider>(context);

    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      decoration: const BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      padding: const EdgeInsets.all(20),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.between,
            children: [
              const Text('Select Payment Method', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              IconButton(icon: const Icon(Icons.close), onPressed: () => Navigator.pop(context)),
            ],
          ),
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: AppColors.primary.withOpacity(0.06),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.between,
              children: [
                Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  const Text('Customer', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text(pos.customerName, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                ]),
                Column(crossAxisAlignment: CrossAxisAlignment.end, children: [
                  const Text('Bill Total', style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                  Text("₹${pos.grandTotal.toStringAsFixed(2)}",
                      style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18, color: AppColors.primary)),
                ]),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text('PAYMENT MODE', style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
          const SizedBox(height: 8),

          // Payment Mode Options: Cash, UPI, Bank Transfer, Khata Credit
          Row(
            children: [
              Expanded(
                child: _buildPayOption(
                  context,
                  title: 'Cash',
                  icon: Icons.payments,
                  selected: pos.paymentMethod == 'cash',
                  onTap: () => pos.setPaymentMethod('cash'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPayOption(
                  context,
                  title: 'UPI QR',
                  icon: Icons.qr_code_2,
                  selected: pos.paymentMethod == 'upi',
                  onTap: () => pos.setPaymentMethod('upi'),
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          Row(
            children: [
              Expanded(
                child: _buildPayOption(
                  context,
                  title: 'Khata (Credit)',
                  icon: Icons.account_balance_wallet,
                  selected: pos.paymentMethod == 'credit',
                  onTap: () => pos.setPaymentMethod('credit'),
                ),
              ),
              const SizedBox(width: 8),
              Expanded(
                child: _buildPayOption(
                  context,
                  title: 'Bank Transfer',
                  icon: Icons.account_balance,
                  selected: pos.paymentMethod == 'bank_transfer',
                  onTap: () => pos.setPaymentMethod('bank_transfer'),
                ),
              ),
            ],
          ),

          const SizedBox(height: 16),

          // Paid amount input
          TextField(
            keyboardType: const TextInputType.numberWithOptions(decimal: true),
            decoration: const InputDecoration(
              labelText: 'Paid Amount (₹)',
              prefixIcon: Icon(Icons.currency_rupee),
            ),
            controller: TextEditingController(text: pos.paidAmount.toStringAsFixed(2)),
            onChanged: (val) {
              final d = double.tryParse(val);
              if (d != null) pos.setPaidAmount(d);
            },
          ),

          const Spacer(),

          if (pos.lastError != null)
            Padding(
              padding: const EdgeInsets.only(bottom: 8.0),
              child: Text(pos.lastError!, style: const TextStyle(color: AppColors.error, fontSize: 13), textAlign: TextAlign.center),
            ),

          SizedBox(
            width: double.infinity,
            child: ElevatedButton.icon(
              onPressed: pos.isProcessing
                  ? null
                  : () async {
                      final success = await pos.checkout(businessId);
                      if (success && context.mounted) {
                        Navigator.pop(context); // close sheet
                        if (pos.lastCompletedInvoice != null) {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                              builder: (_) => InvoicePreviewScreen(
                                invoice: pos.lastCompletedInvoice!,
                                printData: pos.lastReceiptPrintData,
                              ),
                            ),
                          );
                        }
                        pos.clearCart();
                      }
                    },
              icon: pos.isProcessing
                  ? const SizedBox(height: 18, width: 18, child: CircularProgressIndicator(color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.check_circle),
              label: Text(pos.isProcessing ? 'PROCESSING BILL...' : 'COMPLETE & PRINT BILL'),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildPayOption(BuildContext context, {required String title, required IconData icon, required bool selected, required VoidCallback onTap}) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(10),
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 14),
        decoration: BoxDecoration(
          color: selected ? AppColors.primary.withOpacity(0.1) : Colors.white,
          border: Border.all(color: selected ? AppColors.primary : AppColors.border, width: selected ? 2 : 1),
          borderRadius: BorderRadius.circular(10),
        ),
        child: Column(
          children: [
            Icon(icon, color: selected ? AppColors.primary : AppColors.textSecondary, size: 26),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12, color: selected ? AppColors.primary : AppColors.textPrimary)),
          ],
        ),
      ),
    );
  }
}
