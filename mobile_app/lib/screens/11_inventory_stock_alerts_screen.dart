import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../models/product_model.dart';
import '../providers/product_provider.dart';

class InventoryStockAlertsScreen extends StatefulWidget {
  const InventoryStockAlertsScreen({super.key});

  @override
  State<InventoryStockAlertsScreen> createState() => _InventoryStockAlertsScreenState();
}

class _InventoryStockAlertsScreenState extends State<InventoryStockAlertsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ProductProvider>(context, listen: false).fetchLowStockAlerts();
      Provider.of<ProductProvider>(context, listen: false).fetchProducts();
    });
  }

  void _showAdjustStockDialog(ProductModel product) {
    final qtyCtrl = TextEditingController();
    final reasonCtrl = TextEditingController(text: 'Restocked from supplier');
    String action = 'add';

    showDialog(
      context: context,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            return AlertDialog(
              title: Text('Replenish / Adjust Stock: ${product.name}'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Text('Current: ${product.currentStock} ${product.unit} (Min Alert: ${product.minStockThreshold})',
                      style: const TextStyle(fontWeight: FontWeight.bold, color: AppColors.warning)),
                  const SizedBox(height: 12),
                  DropdownButtonFormField<String>(
                    value: action,
                    decoration: const InputDecoration(labelText: 'Action'),
                    items: const [
                      DropdownMenuItem(value: 'add', child: Text('Add Stock (+) / இருப்பு சேர்க்க')),
                      DropdownMenuItem(value: 'subtract', child: Text('Damage / Waste (-) / சேதம்')),
                      DropdownMenuItem(value: 'set', child: Text('Set Exact (=) / சரியான அளவு')),
                    ],
                    onChanged: (val) => setModalState(() => action = val!),
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
                    decoration: const InputDecoration(labelText: 'Reason / காரணம்', prefixIcon: Icon(Icons.note_alt)),
                  ),
                ],
              ),
              actions: [
                TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
                ElevatedButton(
                  onPressed: () async {
                    final qty = double.tryParse(qtyCtrl.text) ?? 0.0;
                    if (qty <= 0) return;

                    final prov = Provider.of<ProductProvider>(context, listen: false);
                    final ok = await prov.adjustStock(product.id, action, qty, reasonCtrl.text.trim());

                    if (context.mounted) {
                      Navigator.pop(ctx);
                      await prov.fetchLowStockAlerts();
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text(ok ? 'Stock updated successfully!' : 'Failed to update stock.'),
                          backgroundColor: ok ? AppColors.success : AppColors.error,
                        ),
                      );
                    }
                  },
                  child: const Text('Update'),
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
    final prodProv = Provider.of<ProductProvider>(context);
    final lowStockItems = prodProv.lowStockProducts;

    // Calculate valuation
    double totalCostValuation = 0.0;
    double totalSellingValuation = 0.0;
    for (var p in prodProv.products) {
      totalCostValuation += p.currentStock * p.purchaseCost;
      totalSellingValuation += p.currentStock * p.sellingPrice;
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Inventory & Stock Alerts'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              prodProv.fetchLowStockAlerts();
              prodProv.fetchProducts();
            },
          ),
        ],
      ),
      body: Column(
        children: [
          // Stock Valuation Summary Card
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [AppColors.primary, AppColors.primaryLight],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: BorderRadius.circular(16),
            ),
            child: Column(
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total Stock Value (Cost)', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('₹${totalCostValuation.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Retail Value', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 4),
                        Text('₹${totalSellingValuation.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
                      ],
                    ),
                  ],
                ),
                const Divider(color: Colors.white38, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Total Products: ${prodProv.products.length}', style: const TextStyle(color: Colors.white, fontSize: 13)),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                      decoration: BoxDecoration(
                        color: lowStockItems.isNotEmpty ? Colors.redAccent : Colors.greenAccent.shade700,
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: Text(
                        '${lowStockItems.length} Low Stock Alert(s)',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),

          // Section Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              children: [
                const Icon(Icons.warning_amber_rounded, color: AppColors.warning),
                const SizedBox(width: 8),
                Text(
                  'Items Needing Reorder (${lowStockItems.length})',
                  style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                ),
              ],
            ),
          ),

          // Low stock alert items list
          Expanded(
            child: prodProv.isLoading
                ? const Center(child: CircularProgressIndicator())
                : lowStockItems.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.check_circle_outline, size: 64, color: Colors.green.shade400),
                            const SizedBox(height: 12),
                            const Text('Inventory levels are healthy!',
                                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.black800)),
                            const SizedBox(height: 4),
                            Text('All products have stock above minimum threshold.',
                                style: TextStyle(color: Colors.grey.shade600, fontSize: 13)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: lowStockItems.length,
                        itemBuilder: (context, index) {
                          final p = lowStockItems[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                              side: const BorderSide(color: Colors.orangeAccent),
                            ),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.red.shade50,
                                    child: const Icon(Icons.production_quantity_limits, color: Colors.redAccent),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(p.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                                        const SizedBox(height: 4),
                                        Row(
                                          children: [
                                            Text(
                                              'Current: ${p.currentStock} ${p.unit}',
                                              style: const TextStyle(color: Colors.redAccent, fontWeight: FontWeight.bold),
                                            ),
                                            const SizedBox(width: 8),
                                            Text(
                                              'Min Req: ${p.minStockThreshold} ${p.unit}',
                                              style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
                                            ),
                                          ],
                                        ),
                                      ],
                                    ),
                                  ),
                                  ElevatedButton.icon(
                                    onPressed: () => _showAdjustStockDialog(p),
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: AppColors.primary,
                                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
                                    ),
                                    icon: const Icon(Icons.add_shopping_cart, size: 16, color: Colors.white),
                                    label: const Text('Refill', style: TextStyle(color: Colors.white, fontSize: 12)),
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
