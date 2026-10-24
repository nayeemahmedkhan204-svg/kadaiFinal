import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/product_model.dart';
import '../models/purchase_model.dart';
import '../models/supplier_model.dart';
import '../providers/product_provider.dart';

class PurchaseManagementScreen extends StatefulWidget {
  const PurchaseManagementScreen({super.key});

  @override
  State<PurchaseManagementScreen> createState() => _PurchaseManagementScreenState();
}

class _PurchaseManagementScreenState extends State<PurchaseManagementScreen> {
  final ApiClient _api = ApiClient();
  List<PurchaseModel> _purchases = [];
  List<SupplierModel> _suppliers = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchData();
  }

  Future<void> _fetchData() async {
    setState(() => _isLoading = true);
    // Fetch purchases
    final pRes = await _api.get(ApiEndpoints.purchases);
    if (pRes.success && pRes.data != null) {
      final raw = pRes.data['purchases']['data'] as List<dynamic>? ?? [];
      _purchases = raw.map((p) => PurchaseModel.fromJson(p)).toList();
    }
    // Fetch suppliers
    final sRes = await _api.get(ApiEndpoints.suppliers);
    if (sRes.success && sRes.data != null) {
      final raw = sRes.data['suppliers']['data'] as List<dynamic>? ?? [];
      _suppliers = raw.map((s) => SupplierModel.fromJson(s)).toList();
    }
    setState(() => _isLoading = false);
  }

  void _showNewPurchaseModal() {
    int? selectedSupplierId = _suppliers.isNotEmpty ? _suppliers.first.id : null;
    final invNumCtrl = TextEditingController();
    final paidAmountCtrl = TextEditingController(text: '0');
    String paymentMode = 'cash';
    List<Map<String, dynamic>> items = [];

    final products = Provider.of<ProductProvider>(context, listen: false).products;

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setModalState) {
            double totalBillAmount = 0.0;
            for (var it in items) {
              totalBillAmount += (it['quantity'] as double) * (it['unit_cost'] as double);
            }

            return Padding(
              padding: EdgeInsets.only(
                left: 16,
                right: 16,
                top: 20,
                bottom: MediaQuery.of(ctx).viewInsets.bottom + 20,
              ),
              child: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.stretch,
                  children: [
                    const Text('New Purchase Entry / புதிய கொள்முதல்',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                    const SizedBox(height: 12),
                    DropdownButtonFormField<int>(
                      value: selectedSupplierId,
                      decoration: const InputDecoration(labelText: 'Supplier / விற்பனையாளர்', prefixIcon: Icon(Icons.storefront)),
                      items: _suppliers
                          .map((s) => DropdownMenuItem(value: s.id, child: Text('${s.name} (${s.phone})')))
                          .toList(),
                      onChanged: (val) => setModalState(() => selectedSupplierId = val),
                    ),
                    const SizedBox(height: 10),
                    TextField(
                      controller: invNumCtrl,
                      decoration: const InputDecoration(
                          labelText: 'Supplier Invoice / Bill No.', prefixIcon: Icon(Icons.receipt)),
                    ),
                    const SizedBox(height: 14),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Items in Purchase', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                        TextButton.icon(
                          onPressed: () {
                            if (products.isEmpty) {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(content: Text('No products found to add.')),
                              );
                              return;
                            }
                            final firstP = products.first;
                            setModalState(() {
                              items.add({
                                'product_id': firstP.id,
                                'product_name': firstP.name,
                                'unit': firstP.unit,
                                'quantity': 10.0,
                                'unit_cost': firstP.purchaseCost,
                                'tax_rate': firstP.taxRate,
                              });
                            });
                          },
                          icon: const Icon(Icons.add, size: 18),
                          label: const Text('Add Product'),
                        ),
                      ],
                    ),
                    ...items.asMap().entries.map((entry) {
                      final idx = entry.key;
                      final it = entry.value;
                      return Card(
                        margin: const EdgeInsets.only(bottom: 8),
                        child: Padding(
                          padding: const EdgeInsets.all(8.0),
                          child: Column(
                            children: [
                              Row(
                                children: [
                                  Expanded(
                                    child: DropdownButton<int>(
                                      value: it['product_id'],
                                      isExpanded: true,
                                      items: products.map((p) => DropdownMenuItem(value: p.id, child: Text(p.name))).toList(),
                                      onChanged: (val) {
                                        if (val != null) {
                                          final p = products.firstWhere((element) => element.id == val);
                                          setModalState(() {
                                            it['product_id'] = p.id;
                                            it['product_name'] = p.name;
                                            it['unit'] = p.unit;
                                            it['unit_cost'] = p.purchaseCost;
                                            it['tax_rate'] = p.taxRate;
                                          });
                                        }
                                      },
                                    ),
                                  ),
                                  IconButton(
                                    icon: const Icon(Icons.delete, color: Colors.red, size: 20),
                                    onPressed: () {
                                      setModalState(() => items.removeAt(idx));
                                    },
                                  ),
                                ],
                              ),
                              Row(
                                children: [
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: it['quantity'].toString(),
                                      keyboardType: TextInputType.number,
                                      decoration: InputDecoration(labelText: 'Qty (${it['unit']})'),
                                      onChanged: (val) {
                                        setModalState(() {
                                          it['quantity'] = double.tryParse(val) ?? 1.0;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Expanded(
                                    child: TextFormField(
                                      initialValue: it['unit_cost'].toString(),
                                      keyboardType: TextInputType.number,
                                      decoration: const InputDecoration(labelText: 'Cost ₹'),
                                      onChanged: (val) {
                                        setModalState(() {
                                          it['unit_cost'] = double.tryParse(val) ?? 0.0;
                                        });
                                      },
                                    ),
                                  ),
                                  const SizedBox(width: 8),
                                  Text(
                                    '₹${((it['quantity'] as double) * (it['unit_cost'] as double)).toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold),
                                  ),
                                ],
                              ),
                            ],
                          ),
                        ),
                      );
                    }),
                    const Divider(),
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        const Text('Total Purchase Amount:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                        Text('₹${totalBillAmount.toStringAsFixed(2)}',
                            style: const TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold, fontSize: 18)),
                      ],
                    ),
                    const SizedBox(height: 10),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: paidAmountCtrl,
                            keyboardType: TextInputType.number,
                            decoration: const InputDecoration(labelText: 'Amount Paid Now ₹'),
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: DropdownButtonFormField<String>(
                            value: paymentMode,
                            decoration: const InputDecoration(labelText: 'Payment Mode'),
                            items: const [
                              DropdownMenuItem(value: 'cash', child: Text('Cash')),
                              DropdownMenuItem(value: 'upi', child: Text('UPI')),
                              DropdownMenuItem(value: 'bank_transfer', child: Text('Bank')),
                            ],
                            onChanged: (val) => setModalState(() => paymentMode = val!),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 16),
                    ElevatedButton(
                      onPressed: () async {
                        if (selectedSupplierId == null || items.isEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Please select supplier and add at least one item.')),
                          );
                          return;
                        }

                        final payload = {
                          'supplier_id': selectedSupplierId,
                          'purchase_number': invNumCtrl.text.trim().isNotEmpty ? invNumCtrl.text.trim() : null,
                          'purchase_date': DateTime.now().toIso8601String().substring(0, 10),
                          'paid_amount': double.tryParse(paidAmountCtrl.text) ?? 0.0,
                          'payment_method': paymentMode,
                          'items': items.map((it) => {
                            'product_id': it['product_id'],
                            'quantity': it['quantity'],
                            'purchase_cost': it['unit_cost'],
                            'tax_rate': it['tax_rate'],
                          }).toList(),
                        };

                        final res = await _api.post(ApiEndpoints.purchases, payload);
                        if (context.mounted) {
                          Navigator.pop(ctx);
                          if (res.success) {
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(content: Text('Purchase recorded & stock updated!'), backgroundColor: AppColors.success),
                            );
                            _fetchData();
                            Provider.of<ProductProvider>(context, listen: false).fetchProducts();
                          } else {
                            ScaffoldMessenger.of(context).showSnackBar(
                              SnackBar(content: Text(res.message ?? 'Failed to record purchase.'), backgroundColor: AppColors.error),
                            );
                          }
                        }
                      },
                      style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                      child: const Text('Save & Update Stock',
                          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Purchase Management / கொள்முதல்'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchData),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showNewPurchaseModal,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Purchase', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: _isLoading
          ? const Center(child: CircularProgressIndicator())
          : _purchases.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.shopping_cart_checkout, size: 64, color: Colors.grey.shade400),
                      const SizedBox(height: 12),
                      const Text('No purchase records found', style: TextStyle(fontSize: 16, color: Colors.grey)),
                      const SizedBox(height: 8),
                      ElevatedButton(
                        onPressed: _showNewPurchaseModal,
                        child: const Text('Record First Purchase'),
                      ),
                    ],
                  ),
                )
              : ListView.builder(
                  padding: const EdgeInsets.all(12),
                  itemCount: _purchases.length,
                  itemBuilder: (context, index) {
                    final pur = _purchases[index];
                    return Card(
                      margin: const EdgeInsets.only(bottom: 10),
                      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                      child: Padding(
                        padding: const EdgeInsets.all(14),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text(
                                  pur.purchaseNumber,
                                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: AppColors.primary),
                                ),
                                Container(
                                  padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                  decoration: BoxDecoration(
                                    color: pur.paymentStatus == 'paid'
                                        ? Colors.green.shade50
                                        : (pur.paymentStatus == 'partial' ? Colors.orange.shade50 : Colors.red.shade50),
                                    borderRadius: BorderRadius.circular(6),
                                  ),
                                  child: Text(
                                    pur.paymentStatus.toUpperCase(),
                                    style: TextStyle(
                                      fontSize: 11,
                                      fontWeight: FontWeight.bold,
                                      color: pur.paymentStatus == 'paid'
                                          ? Colors.green.shade700
                                          : (pur.paymentStatus == 'partial' ? Colors.orange.shade800 : Colors.red.shade700),
                                    ),
                                  ),
                                ),
                              ],
                            ),
                            const SizedBox(height: 6),
                            Text('Supplier: ${pur.supplierName ?? 'Direct Purchase'}',
                                style: const TextStyle(fontWeight: FontWeight.w500)),
                            const SizedBox(height: 4),
                            Text('Date: ${pur.purchaseDate}', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                            const Divider(height: 16),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.spaceBetween,
                              children: [
                                Text('${pur.items.length} item(s)', style: TextStyle(color: Colors.grey.shade700)),
                                Text('Total: ₹${pur.totalAmount.toStringAsFixed(2)}',
                                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                              ],
                            ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
    );
  }
}
