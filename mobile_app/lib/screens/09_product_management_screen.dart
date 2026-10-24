import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/l10n/app_localizations.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';

class ProductManagementScreen extends StatefulWidget {
  const ProductManagementScreen({super.key});

  @override
  State<ProductManagementScreen> createState() => _ProductManagementScreenState();
}

class _ProductManagementScreenState extends State<ProductManagementScreen> {
  final TextEditingController _searchController = TextEditingController();
  int? _selectedCategoryId;
  bool _showOnlyLowStock = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      final provider = Provider.of<ProductProvider>(context, listen: false);
      provider.fetchCategories();
      provider.fetchProducts();
    });
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  void _onFilterChanged() {
    Provider.of<ProductProvider>(context, listen: false).fetchProducts(
      search: _searchController.text.trim(),
      categoryId: _selectedCategoryId,
      lowStock: _showOnlyLowStock,
    );
  }

  void _showAddEditProductModal([ProductModel? product]) {
    final nameCtrl = TextEditingController(text: product?.name ?? '');
    final skuCtrl = TextEditingController(text: product?.sku ?? '');
    final barcodeCtrl = TextEditingController(text: product?.barcode ?? '');
    final costCtrl = TextEditingController(text: product != null ? product.purchaseCost.toString() : '');
    final priceCtrl = TextEditingController(text: product != null ? product.sellingPrice.toString() : '');
    final mrpCtrl = TextEditingController(text: product?.mrp != null ? product!.mrp.toString() : '');
    final gstCtrl = TextEditingController(text: product?.taxRate.toString() ?? '5.0');
    final hsnCtrl = TextEditingController(text: product?.hsnCode ?? '');
    final stockCtrl = TextEditingController(text: product != null ? product.currentStock.toString() : '0');
    final minStockCtrl = TextEditingController(text: product != null ? product.minStockThreshold.toString() : '5');
    String selectedUnit = product?.unit ?? 'PCS';
    int? catId = product?.categoryId;

    final categories = Provider.of<ProductProvider>(context, listen: false).categories;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return Padding(
              padding: EdgeInsets.only(
                left: 20,
                right: 20,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    Text(
                      product == null ? 'Add New Product / பொருள் சேர்க்க' : 'Edit Product / பொருள் திருத்து',
                      style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                    ),
                    const SizedBox(height: 14),
                    TextField(
                      controller: nameCtrl,
                      decoration: const InputDecoration(labelText: 'Product Name * / பெயர்', prefixIcon: Icon(Icons.inventory_2)),
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: barcodeCtrl,
                            decoration: const InputDecoration(labelText: 'Barcode / பட்டைக்குறி', prefixIcon: Icon(Icons.qr_code_scanner)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: skuCtrl,
                            decoration: const InputDecoration(labelText: 'SKU Code', prefixIcon: Icon(Icons.tag)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: DropdownButtonFormField<int>(
                            value: catId,
                            decoration: const InputDecoration(labelText: 'Category / வகை'),
                            items: categories.map((c) => DropdownMenuItem(value: c.id, child: Text(c.name))).toList(),
                            onChanged: (val) => setModalState(() => catId = val),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: selectedUnit,
                            decoration: const InputDecoration(labelText: 'Unit / அலகு'),
                            items: ['PCS', 'KG', 'LTR', 'GM', 'ML', 'PKT', 'BOX', 'BAG']
                                .map((u) => DropdownMenuItem(value: u, child: Text(u)))
                                .toList(),
                            onChanged: (val) => setModalState(() => selectedUnit = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: costCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Purchase Cost ₹', prefixIcon: Icon(Icons.currency_rupee)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: priceCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Selling Price ₹ *', prefixIcon: Icon(Icons.sell)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: mrpCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'MRP ₹', prefixIcon: Icon(Icons.price_check)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: gstCtrl.text,
                            decoration: const InputDecoration(labelText: 'GST % / வரி'),
                            items: ['0.0', '5.0', '12.0', '18.0', '28.0']
                                .map((r) => DropdownMenuItem(value: r, child: Text('$r%')))
                                .toList(),
                            onChanged: (val) => setModalState(() => gstCtrl.text = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: hsnCtrl,
                            decoration: const InputDecoration(labelText: 'HSN Code', prefixIcon: Icon(Icons.numbers)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: stockCtrl,
                            keyboardType: TextInputType.number,
                            enabled: product == null, // Opening stock only editable at creation
                            decoration: const InputDecoration(labelText: 'Current Stock / இருப்பு', prefixIcon: Icon(Icons.storage)),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: minStockCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Min Alert / குறைந்தபட்சம்', prefixIcon: Icon(Icons.warning_amber)),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 20),
                    ElevatedButton(
                      onPressed: () async {
                        final name = nameCtrl.text.trim();
                        final price = double.tryParse(priceCtrl.text) ?? 0.0;
                        if (name.isEmpty || price <= 0) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please enter valid product name and selling price.')),
                          );
                          return;
                        }

                        final data = {
                          'name': name,
                          'sku': skuCtrl.text.trim().isNotEmpty ? skuCtrl.text.trim() : null,
                          'barcode': barcodeCtrl.text.trim().isNotEmpty ? barcodeCtrl.text.trim() : null,
                          'category_id': catId,
                          'unit': selectedUnit,
                          'purchase_cost': double.tryParse(costCtrl.text) ?? 0.0,
                          'selling_price': price,
                          'mrp': double.tryParse(mrpCtrl.text),
                          'tax_rate': double.tryParse(gstCtrl.text) ?? 0.0,
                          'hsn_code': hsnCtrl.text.trim().isNotEmpty ? hsnCtrl.text.trim() : null,
                          'current_stock': double.tryParse(stockCtrl.text) ?? 0.0,
                          'min_stock_threshold': double.tryParse(minStockCtrl.text) ?? 5.0,
                          'is_active': true,
                        };

                        final prodProv = Provider.of<ProductProvider>(context, listen: false);
                        bool ok = false;
                        if (product == null) {
                          ok = await prodProv.addProduct(data);
                        } else {
                          ok = await prodProv.updateProduct(product.id, data);
                        }

                        if (context.mounted) {
                          Navigator.pop(ctx);
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text(ok ? 'Product saved successfully!' : 'Failed to save product.'),
                              backgroundColor: ok ? AppColors.success : AppColors.error,
                            ),
                          );
                        }
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      child: Text(product == null ? 'Save Product / சேமி' : 'Update Product / புதுப்பி',
                          style: const TextStyle(fontSize: 16, color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                ),
              ),
            );
          },
        );
      },
    );
  }

  void _showStockAdjustModal(ProductModel product) {
    final qtyCtrl = TextEditingController();
    final reasonCtrl = TextEditingController(text: 'Physical stock verification');
    String adjustType = 'add'; // 'add', 'subtract', 'set'

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            return AlertDialog(
              title: Text('Adjust Stock: ${product.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Current Stock: ${product.currentStock} ${product.unit}',
                      style: const TextStyle(fontWeight: FontWeight.bold)),
                  const SizedBox(height: 14),
                  DropdownButtonFormField<String>(
                    value: adjustType,
                    decoration: const InputDecoration(labelText: 'Action / நடவடிக்கை'),
                    items: const [
                      DropdownMenuItem(value: 'add', child: Text('Add Stock (+)')),
                      DropdownMenuItem(value: 'subtract', child: Text('Deduct / Damage (-)')),
                      DropdownMenuItem(value: 'set', child: Text('Set Exact Stock (=)')),
                    ],
                    onChanged: (val) => setDialogState(() => adjustType = val!),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: qtyCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Quantity / அளவு', prefixIcon: Icon(Icons.numbers)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: reasonCtrl,
                    decoration: const InputDecoration(labelText: 'Reason / காரணம்', prefixIcon: Icon(Icons.notes)),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    final qty = double.tryParse(qtyCtrl.text) ?? 0.0;
                    if (qty <= 0) return;

                    final ok = await Provider.of<ProductProvider>(context, listen: false).adjustStock(
                      product.id,
                      adjustType,
                      qty,
                      reasonCtrl.text.trim(),
                    );

                    if (context.mounted) {
                      Navigator.pop(ctx);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok ? 'Stock adjusted successfully!' : 'Failed to adjust stock.'),
                          backgroundColor: ok ? AppColors.success : AppColors.error,
                        ),
                      );
                    }
                  },
                  child: const Text('Confirm Adjustment'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final l10n = AppLocalizations.of(context);
    final prodProv = Provider.of<ProductProvider>(context);

    return Scaffold(
      appBar: AppBar(
        title: Text(l10n.products),
        actions: [
          IconButton(
            icon: Icon(_showOnlyLowStock ? Icons.warning : Icons.warning_amber_outlined),
            tooltip: 'Low Stock Filter',
            color: _showOnlyLowStock ? Colors.orangeAccent : Colors.white,
            onPressed: () {
              setState(() {
                _showOnlyLowStock = !_showOnlyLowStock;
              });
              _onFilterChanged();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => prodProv.fetchProducts(),
          ),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: () => _showAddEditProductModal(),
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Product', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Search & Filter Header
          Container(
            padding: const EdgeInsets.all(12),
            color: Colors.white,
            child: Column(
              children: [
                TextField(
                  controller: _searchController,
                  decoration: InputDecoration(
                    hintText: 'Search products by name or barcode...',
                    prefixIcon: const Icon(Icons.search),
                    suffixIcon: _searchController.text.isNotEmpty
                        ? IconButton(
                            icon: const Icon(Icons.clear),
                            onPressed: () {
                              _searchController.clear();
                              _onFilterChanged();
                            },
                          )
                        : null,
                    isDense: true,
                  ),
                  onChanged: (val) => _onFilterChanged(),
                ),
                const SizedBox(height: 8),
                // Category Pills horizontal scroll
                SingleChildScrollView(
                  scrollDirection: Axis.horizontal,
                  child: Row(
                    children: [
                      ChoiceChip(
                        label: const Text('All Categories'),
                        selected: _selectedCategoryId == null,
                        onSelected: (sel) {
                          if (sel) {
                            setState(() => _selectedCategoryId = null);
                            _onFilterChanged();
                          }
                        },
                      ),
                      const SizedBox(width: 6),
                      ...prodProv.categories.map((cat) {
                        return Padding(
                          padding: const EdgeInsets.only(right: 6),
                          child: ChoiceChip(
                            label: Text(cat.name),
                            selected: _selectedCategoryId == cat.id,
                            onSelected: (sel) {
                              setState(() {
                                _selectedCategoryId = sel ? cat.id : null;
                              });
                              _onFilterChanged();
                            },
                          ),
                        );
                      }),
                    ],
                  ),
                ),
              ],
            ),
          ),

          // Product List
          Expanded(
            child: prodProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : prodProv.products.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.inventory_2_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text('No products found', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            const SizedBox(height: 8),
                            ElevatedButton.icon(
                              onPressed: () => _showAddEditProductModal(),
                              icon: const Icon(Icons.add),
                              label: const Text('Add First Product'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: prodProv.products.length,
                        itemBuilder: (context, index) {
                          final p = prodProv.products[index];
                          final isLowStock = p.currentStock <= p.minStockThreshold;

                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: BorderSide(
                                color: isLowStock ? AppColors.warning.withOpacity(0.5) : Colors.transparent,
                              ),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Product Avatar / Stock Badge
                                  Container(
                                    width: 50,
                                    height: 50,
                                    decoration: BoxDecoration(
                                      color: isLowStock ? AppColors.warning.withOpacity(0.15) : AppColors.primaryLight.withOpacity(0.15),
                                      borderRadius: BorderRadius.circular(10),
                                    ),
                                    child: Center(
                                      child: Icon(
                                        isLowStock ? Icons.warning_amber_rounded : Icons.shopping_bag_outlined,
                                        color: isLowStock ? AppColors.warning : AppColors.primary,
                                        size: 28,
                                      ),
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  // Product Info
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          p.name,
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                                        ),
                                        const SizedBox(height: 3),
                                        Row(
                                          children: [
                                            Text('₹${p.sellingPrice.toStringAsFixed(2)}',
                                                style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 15)),
                                            if (p.mrp != null && p.mrp! > p.sellingPrice) ...[
                                              const SizedBox(width: 6),
                                              Text('₹${p.mrp!.toStringAsFixed(2)}',
                                                  style: const TextStyle(
                                                    decoration: TextDecoration.lineThrough,
                                                    color: Colors.grey,
                                                    fontSize: 12,
                                                  )),
                                            ],
                                            const SizedBox(width: 8),
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text('GST ${p.taxRate}%',
                                                  style: TextStyle(fontSize: 10, color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                                            ),
                                          ],
                                        ),
                                        const SizedBox(height: 4),
                                        Text(
                                          'Stock: ${p.currentStock.toStringAsFixed(1)} ${p.unit} ${isLowStock ? '(Low Stock!)' : ''}',
                                          style: TextStyle(
                                            color: isLowStock ? AppColors.warning : Colors.grey.shade700,
                                            fontWeight: isLowStock ? FontWeight.bold : FontWeight.normal,
                                            fontSize: 13,
                                          ),
                                        ),
                                        if (p.barcode != null && p.barcode!.isNotEmpty)
                                          Text('Barcode: ${p.barcode}', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  // Action Buttons
                                  Column(
                                    children: [
                                      IconButton(
                                        icon: const Icon(Icons.edit, color: AppColors.primary, size: 20),
                                        onPressed: () => _showAddEditProductModal(p),
                                        tooltip: 'Edit Product',
                                      ),
                                      IconButton(
                                        icon: const Icon(Icons.tune, color: Colors.orange, size: 20),
                                        onPressed: () => _showStockAdjustModal(p),
                                        tooltip: 'Adjust Stock',
                                      ),
                                    ],
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
          ),
        ],
      ),
    );
  }
}
