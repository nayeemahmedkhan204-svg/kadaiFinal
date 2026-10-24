import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/customer_model.dart';
import '../providers/customer_provider.dart';

class CustomerKhataScreen extends StatefulWidget {
  final CustomerModel customer;

  const CustomerKhataScreen({super.key, required this.customer});

  @override
  State<CustomerKhataScreen> createState() => _CustomerKhataScreenState();
}

class _CustomerKhataScreenState extends State<CustomerKhataScreen> {
  final ApiClient _api = ApiClient();
  late CustomerModel _customer;
  List<dynamic> _transactions = [];
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _customer = widget.customer;
    _fetchStatement();
  }

  Future<void> _fetchStatement() async {
    setState(() => _isLoading = true);
    final res = await _api.get(ApiEndpoints.customerLedger(_customer.id));
    if (res.success && res.data != null) {
      if (res.data['customer'] != null) {
        _customer = CustomerModel.fromJson(res.data['customer']);
      }
      _transactions = res.data['transactions'] as List<dynamic>? ?? [];
    }
    setState(() => _isLoading = false);
  }

  void _showRecordPaymentModal() {
    final amountCtrl = TextEditingController(text: _customer.outstandingBalance > 0 ? _customer.outstandingBalance.toString() : '');
    final refCtrl = TextEditingController();
    final noteCtrl = TextEditingController();
    String mode = 'cash';

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
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  const Text(
                    'Record Payment Collection / பணம் வரவு',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: AppColors.primary),
                  ),
                  const SizedBox(height: 14),
                  TextField(
                    controller: amountCtrl,
                    keyboardType: TextInputType.number,
                    decoration: const InputDecoration(labelText: 'Amount Received ₹ *', prefixIcon: Icon(Icons.currency_rupee)),
                  ),
                  const SizedBox(height: 10),
                  DropdownButtonFormField<String>(
                    value: mode,
                    decoration: const InputDecoration(labelText: 'Payment Mode / கட்டணம் வகை'),
                    items: const [
                      DropdownMenuItem(value: 'cash', child: Text('Cash / ரொக்கம்')),
                      DropdownMenuItem(value: 'upi', child: Text('UPI (GPay / PhonePe / Paytm)')),
                      DropdownMenuItem(value: 'bank_transfer', child: Text('Bank Transfer / NEFT')),
                    ],
                    onChanged: (val) => setModalState(() => mode = val!),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: refCtrl,
                    decoration: const InputDecoration(labelText: 'Transaction Ref / UTR (Optional)', prefixIcon: Icon(Icons.tag)),
                  ),
                  const SizedBox(height: 10),
                  TextField(
                    controller: noteCtrl,
                    decoration: const InputDecoration(labelText: 'Notes / குறிப்பு', prefixIcon: Icon(Icons.notes)),
                  ),
                  const SizedBox(height: 20),
                  ElevatedButton(
                    onPressed: () async {
                      final amount = double.tryParse(amountCtrl.text) ?? 0.0;
                      if (amount <= 0) return;

                      final ok = await Provider.of<CustomerProvider>(context, listen: false).recordPayment(
                        _customer.id,
                        amount,
                        mode,
                        reference: refCtrl.text.trim().isNotEmpty ? refCtrl.text.trim() : null,
                        notes: noteCtrl.text.trim().isNotEmpty ? noteCtrl.text.trim() : null,
                      );

                      if (context.mounted) {
                        Navigator.pop(ctx);
                        if (ok) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Payment recorded successfully!'), backgroundColor: AppColors.success),
                          );
                          _fetchStatement();
                        } else {
                          ScaffoldMessenger.of(context).showSnackBar(
                            const SnackBar(content: Text('Failed to record payment.'), backgroundColor: AppColors.error),
                          );
                        }
                      }
                    },
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primary, padding: const EdgeInsets.symmetric(vertical: 14)),
                    child: const Text('Confirm Payment / பதிவு செய்',
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 16)),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    final hasDue = _customer.outstandingBalance > 0;

    return Scaffold(
      appBar: AppBar(
        title: Text('${_customer.name} - Khata'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchStatement),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        onPressed: _showRecordPaymentModal,
        backgroundColor: AppColors.primary,
        icon: const Icon(Icons.payment, color: Colors.white),
        label: const Text('Record Payment', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
      ),
      body: Column(
        children: [
          // Customer Balance Banner
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: hasDue ? [Colors.red.shade700, Colors.red.shade900] : [Colors.green.shade700, Colors.green.shade900],
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
                        Text(_customer.name, style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold)),
                        const SizedBox(height: 2),
                        Text(_customer.phone ?? '', style: const TextStyle(color: Colors.white70, fontSize: 13)),
                      ],
                    ),
                    Column(
                      crossAxisAlignment: CrossAxisAlignment.end,
                      children: [
                        const Text('Outstanding Due', style: TextStyle(color: Colors.white70, fontSize: 12)),
                        const SizedBox(height: 2),
                        Text(
                          '₹${_customer.outstandingBalance.toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.bold),
                        ),
                      ],
                    ),
                  ],
                ),
                const Divider(color: Colors.white30, height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Credit Limit: ₹${_customer.creditLimit.toStringAsFixed(0)}',
                        style: const TextStyle(color: Colors.white70, fontSize: 12)),
                    Text(hasDue ? 'Payment Pending' : 'Account Settled',
                        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12)),
                  ],
                ),
              ],
            ),
          ),

          // Ledger Title
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                const Text('Transaction History / கணக்கு அறிக்கை', style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                Text('${_transactions.length} entries', style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
              ],
            ),
          ),

          // Ledger List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _transactions.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.history, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text('No transactions found in this ledger',
                                style: TextStyle(fontSize: 15, color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: _transactions.length,
                        itemBuilder: (context, index) {
                          final tx = _transactions[index];
                          final isDebit = (tx['type'] == 'debit' || tx['entry_type'] == 'debit');
                          final amount = (tx['amount'] as num?)?.toDouble() ?? 0.0;
                          final date = tx['entry_date'] ?? tx['created_at'] ?? '';
                          final desc = tx['description'] ?? (isDebit ? 'Credit Sale Bill' : 'Payment Received');

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isDebit ? Colors.red.shade50 : Colors.green.shade50,
                                    child: Icon(
                                      isDebit ? Icons.arrow_outward : Icons.arrow_downward,
                                      color: isDebit ? Colors.red : Colors.green,
                                      size: 20,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(desc, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        const SizedBox(height: 3),
                                        Text(date.toString().substring(0, 10),
                                            style: TextStyle(color: Colors.grey.shade600, fontSize: 12)),
                                      ],
                                    ),
                                  ),
                                  Column(
                                    crossAxisAlignment: CrossAxisAlignment.end,
                                    children: [
                                      Text(
                                        '${isDebit ? '+' : '-'} ₹${amount.toStringAsFixed(2)}',
                                        style: TextStyle(
                                          fontWeight: FontWeight.bold,
                                          fontSize: 15,
                                          color: isDebit ? Colors.red : Colors.green,
                                        ),
                                      ),
                                      Text(
                                        isDebit ? 'Credit Given' : 'Payment Recd',
                                        style: TextStyle(fontSize: 11, color: isDebit ? Colors.red : Colors.green),
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
