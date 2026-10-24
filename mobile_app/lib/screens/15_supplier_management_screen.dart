import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/supplier_model.dart';

class SupplierManagementScreen extends StatefulWidget {
  const SupplierManagementScreen({super.key});

  @override
  State<SupplierManagementScreen> createState() => _SupplierManagementScreenState();
}

class _SupplierManagementScreenState extends State<SupplierManagementScreen> {
  final ApiClient _api = ApiClient();
  List<SupplierModel> _suppliers = [];
  double _totalPayable = 0.0;
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _fetchSuppliers();
  }

  Future<void> _fetchSuppliers() async {
    setState(() => _isLoading = true);
    final res = await _api.get(ApiEndpoints.suppliers);
    if (res.success && res.data != null) {
      _totalPayable = (res.data['total_payable'] as num?)?.toDouble() ?? 0.0;
      final raw = res.data['suppliers']['data'] as List<dynamic>? ?? [];
      _suppliers = raw.map((s) => SupplierModel.fromJson(s)).toList();
    }
    setState(() => _isLoading = false);
  }

  void _showAddSupplierModal() {
    final nameCtrl = TextEditingController();
    final contactCtrl = TextEditingController();
    final phoneCtrl = TextEditingController();
    final emailCtrl = TextEditingController();
    final addressCtrl = TextEditingController();
    final gstinCtrl = TextEditingController();
    final openingBalCtrl = TextEditingController(text: '0');

    showModalBottomSheet(
      context: context,
      isScrollControlled: true,
      shape: const RoundedRectangleBorder(borderRadius: BorderRadius.vertical(top: Radius.circular(20))),
      builder: (ctx) {
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
                const Text('Add Supplier / விற்பனையாளர் சேர்க்க',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary)),
                const SizedBox(height: 14),
                TextField(
                  controller: nameCtrl,
                  decoration: const InputDecoration(labelText: 'Supplier / Business Name *', prefixIcon: Icon(Icons.store)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: contactCtrl,
                  decoration: const InputDecoration(labelText: 'Contact Person Name', prefixIcon: Icon(Icons.person)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: phoneCtrl,
                  keyboardType: TextInputType.phone,
                  decoration: const InputDecoration(labelText: 'Phone Number *', prefixIcon: Icon(Icons.phone)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: emailCtrl,
                  keyboardType: TextInputType.emailAddress,
                  decoration: const InputDecoration(labelText: 'Email Address (Optional)', prefixIcon: Icon(Icons.email)),
                ),
                const SizedBox(height: 10),
                TextField(
                  controller: addressCtrl,
                  decoration: const InputDecoration(labelText: 'Address', prefixIcon: Icon(Icons.location_on)),
                ),
                const SizedBox(height: 10),
                Row(
                  children: [
                    Expanded(
                      child: TextField(
                        controller: gstinCtrl,
                        decoration: const InputDecoration(labelText: 'GSTIN (Optional)', prefixIcon: Icon(Icons.badge)),
                      ),
                    ),
                    const SizedBox(width: 10),
                    Expanded(
                      child: TextField(
                        controller: openingBalCtrl,
                        keyboardType: TextInputType.number,
                        decoration: const InputDecoration(labelText: 'Opening Payable ₹', prefixIcon: Icon(Icons.currency_rupee)),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 20),
                ElevatedButton(
                  onPressed: () async {
                    final name = nameCtrl.text.trim();
                    final phone = phoneCtrl.text.trim();
                    if (name.isEmpty || phone.isEmpty) return;

                    final res = await _api.post(ApiEndpoints.suppliers, {
                      'name': name,
                      'contact_person': contactCtrl.text.trim().isNotEmpty ? contactCtrl.text.trim() : null,
                      'phone': phone,
                      'email': emailCtrl.text.trim().isNotEmpty ? emailCtrl.text.trim() : null,
                      'address': addressCtrl.text.trim().isNotEmpty ? addressCtrl.text.trim() : null,
                      'gstin': gstinCtrl.text.trim().isNotEmpty ? gstinCtrl.text.trim() : null,
                      'opening_balance': double.tryParse(openingBalCtrl.text) ?? 0.0,
                    });

                    if (context.mounted) {
                      Navigator.pop(ctx);
                      if (res.success) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Supplier added successfully!'), backgroundColor: AppColors.success),
                        );
                        _fetchSuppliers();
                      } else {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(content: Text(res.message ?? 'Failed to add supplier.'), backgroundColor: AppColors.error),
                        );
                      }
                    }
                  },
                  style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                  child: const Text('Save Supplier', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                ),
              ],
            ),
          ),
        );
      },
    );
  }

  void _showRecordSupplierPaymentDialog(SupplierModel supplier) {
    final amtCtrl = TextEditingController();
    final refCtrl = TextEditingController();
    String mode = 'bank_transfer';

    showDialog(
      context: context,
      builder: (ctx) {
        return AlertDialog(
          title: Text('Pay Supplier: ${supplier.name}'),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text('Payable Balance: ₹${supplier.outstandingBalance.toStringAsFixed(2)}',
                  style: const TextStyle(fontWeight: FontWeight.bold, color: Colors.red)),
              const SizedBox(height: 12),
              TextField(
                controller: amtCtrl,
                keyboardType: TextInputType.number,
                decoration: const InputDecoration(labelText: 'Amount to Pay ₹', prefixIcon: Icon(Icons.currency_rupee)),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: mode,
                decoration: const InputDecoration(labelText: 'Payment Mode'),
                items: const [
                  DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer / NEFT')),
                  DropdownMenuItem(value: 'upi', child: Text('UPI / QR')),
                  DropdownMenuItem(value: 'cash', child: Text('Cash')),
                  DropdownMenuItem(value: 'cheque', child: Text('Cheque')),
                ],
                onChanged: (val) => mode = val!,
              ),
              const SizedBox(height: 10),
              TextField(
                controller: refCtrl,
                decoration: const InputDecoration(labelText: 'Ref / Cheque No.', prefixIcon: Icon(Icons.tag)),
              ),
            ],
          ),
          actions: [
            TextButton(onPressed: () => Navigator.pop(ctx), child: const Text('Cancel')),
            ElevatedButton(
              onPressed: () async {
                final amt = double.tryParse(amtCtrl.text) ?? 0.0;
                if (amt <= 0) return;

                final res = await _api.post(ApiEndpoints.supplierPayment(supplier.id), {
                  'amount': amt,
                  'payment_mode': mode,
                  'transaction_reference': refCtrl.text.trim(),
                });

                if (context.mounted) {
                  Navigator.pop(ctx);
                  if (res.success) {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Supplier payment recorded!'), backgroundColor: AppColors.success),
                    );
                    _fetchSuppliers();
                  }
                }
              },
              child: const Text('Confirm Payment'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Suppliers / கொள்முதல் வழங்குநர்'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchSuppliers),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showAddSupplierModal,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.add, color: Colors.white),
        label: const Text('New Supplier', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Total Payables Card
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.orange.shade50,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: Colors.orange.shade200),
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text('Total Supplier Payables / நாம் கொடுக்க வேண்டியது',
                        style: TextStyle(color: Colors.orange, fontSize: 13, fontWeight: FontWeight.bold)),
                    const SizedBox(height: 4),
                    Text(
                      '₹${_totalPayable.toStringAsFixed(2)}',
                      style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange.shade900),
                    ),
                  ],
                ),
                Icon(Icons.inventory, color: Colors.orange.shade700, size: 36),
              ],
            ),
          ),

          // Supplier List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _suppliers.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.storefront_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text('No suppliers added yet', style: TextStyle(fontSize: 16, color: Colors.grey)),
                            const SizedBox(height: 8),
                            ElevatedButton(
                              onPressed: _showAddSupplierModal,
                              child: const Text('Add First Supplier'),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _suppliers.length,
                        itemBuilder: (context, index) {
                          final sup = _suppliers[index];
                          return Card(
                            margin: const EdgeInsets.only(bottom: 10),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                            child: Padding(
                              padding: const EdgeInsets.all(14),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: Colors.blue.shade50,
                                    child: const Icon(Icons.business, color: AppColors.primary),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(sup.name, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                                        if (sup.contactPerson != null && sup.contactPerson!.isNotEmpty)
                                          Text('Contact: ${sup.contactPerson}', style: TextStyle(color: Colors.grey.shade700, fontSize: 12)),
                                        Text(sup.phone, style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                        if (sup.gstin != null && sup.gstin!.isNotEmpty)
                                          Text('GSTIN: ${sup.gstin}', style: TextStyle(color: Colors.grey.shade500, fontSize: 11)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text('₹${sup.outstandingBalance.toStringAsFixed(2)}',
                                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 15, color: Colors.orange)),
                                      const SizedBox(height: 4),
                                      ElevatedButton(
                                        onPressed: () => _showRecordSupplierPaymentDialog(sup),
                                        style: ElevatedButton.styleFrom(
                                          backgroundColor: AppColors.primary,
                                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                                          minimumSize: const Size(60, 30),
                                        ),
                                        child: const Text('Pay', style: TextStyle(color: Colors.white, fontSize: 12)),
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
