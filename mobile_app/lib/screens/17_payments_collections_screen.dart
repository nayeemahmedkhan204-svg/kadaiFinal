import 'package:flutter/material.dart';
import '../core/constants/app_colors.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';

class PaymentsCollectionsScreen extends StatefulWidget {
  const PaymentsCollectionsScreen({super.key});

  @override
  State<PaymentsCollectionsScreen> createState() => _PaymentsCollectionsScreenState();
}

class _PaymentsCollectionsScreenState extends State<PaymentsCollectionsScreen> {
  final ApiClient _api = ApiClient();
  List<dynamic> _payments = [];
  bool _isLoading = false;
  String _selectedFilter = 'all'; // 'all', 'inward', 'outward'

  @override
  void initState() {
    super.initState();
    _fetchPayments();
  }

  Future<void> _fetchPayments() async {
    setState(() => _isLoading = true);
    // Fetch payments list
    final res = await _api.get(ApiEndpoints.payments);
    if (res.success && res.data != null) {
      _payments = res.data['payments']['data'] as List<dynamic>? ?? [];
    }
    setState(() => _isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final filteredPayments = _payments.where((p) {
      final type = p['type'] ?? 'inward';
      if (_selectedFilter == 'inward') return type == 'inward';
      if (_selectedFilter == 'outward') return type == 'outward';
      return true;
    }).toList();

    double totalInward = 0.0;
    double totalOutward = 0.0;
    for (var p in _payments) {
      final amt = (p['amount'] as num?)?.toDouble() ?? 0.0;
      if (p['type'] == 'outward') {
        totalOutward += amt;
      } else {
        totalInward += amt;
      }
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Payments & Collections / வரவு செலவு'),
        actions: [
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchPayments),
        ],
      ),
      body: Column(
        children: [
          // Inward vs Outward Summary
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(16),
              boxShadow: [
                BoxShadow(color: Colors.grey.withOpacity(0.1), spreadRadius: 2, blurRadius: 8),
              ],
            ),
            child: Row(
              children: [
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        children: [
                          Icon(Icons.arrow_downward, color: Colors.green, size: 16),
                          SizedBox(width: 4),
                          Text('Collections (In)', style: TextStyle(color: Colors.green, fontWeight: FontWeight.bold, fontSize: 13)),
                        ],
                      ),
                      const SizedBox(height: 4),
                      Text('₹${totalInward.toStringAsFixed(2)}',
                          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.green)),
                    ],
                  ),
                ),
                Container(height: 40, width: 1, color: Colors.grey.shade300),
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.only(left: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Row(
                          children: [
                            Icon(Icons.arrow_upward, color: Colors.orange, size: 16),
                            SizedBox(width: 4),
                            Text('Payments (Out)', style: TextStyle(color: Colors.orange, fontWeight: FontWeight.bold, fontSize: 13)),
                          ],
                        ),
                        const SizedBox(height: 4),
                        Text('₹${totalOutward.toStringAsFixed(2)}',
                            style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: Colors.orange)),
                      ],
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Filters
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 12),
            child: Row(
              children: [
                ChoiceChip(
                  label: const Text('All Transactions'),
                  selected: _selectedFilter == 'all',
                  onSelected: (sel) => setState(() => _selectedFilter = 'all'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Collections Only'),
                  selected: _selectedFilter == 'inward',
                  selectedColor: Colors.green.shade100,
                  onSelected: (sel) => setState(() => _selectedFilter = 'inward'),
                ),
                const SizedBox(width: 8),
                ChoiceChip(
                  label: const Text('Supplier Payments'),
                  selected: _selectedFilter == 'outward',
                  selectedColor: Colors.orange.shade100,
                  onSelected: (sel) => setState(() => _selectedFilter = 'outward'),
                ),
              ],
            ),
          ),
          const SizedBox(height: 8),

          // Payment list
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : filteredPayments.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(Icons.receipt_outlined, size: 64, color: Colors.grey.shade400),
                            const SizedBox(height: 12),
                            const Text('No payment records found', style: TextStyle(fontSize: 16, color: Colors.grey)),
                          ],
                        ),
                      )
                    : ListView.builder(
                        padding: const EdgeInsets.all(12),
                        itemCount: filteredPayments.length,
                        itemBuilder: (context, index) {
                          final item = filteredPayments[index];
                          final isOutward = item['type'] == 'outward';
                          final amt = (item['amount'] as num?)?.toDouble() ?? 0.0;
                          final date = item['payment_date'] ?? item['created_at'] ?? '';
                          final party = item['party_name'] ?? (isOutward ? 'Supplier Payment' : 'Customer Collection');
                          final mode = (item['payment_method'] ?? 'cash').toString().toUpperCase();
                          final ref = item['transaction_reference'];

                          return Card(
                            margin: const EdgeInsets.only(bottom: 8),
                            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(10)),
                            child: Padding(
                              padding: const EdgeInsets.all(12),
                              child: Row(
                                children: [
                                  CircleAvatar(
                                    backgroundColor: isOutward ? Colors.orange.shade50 : Colors.green.shade50,
                                    child: Icon(
                                      isOutward ? Icons.arrow_outward : Icons.arrow_downward,
                                      color: isOutward ? Colors.orange : Colors.green,
                                    ),
                                  ),
                                  const SizedBox(width: 12),
                                  Expanded(
                                    child: Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(party, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                                        const SizedBox(height: 2),
                                        Row(
                                          children: [
                                            Container(
                                              padding: const EdgeInsets.symmetric(horizontal: 5, vertical: 1),
                                              decoration: BoxDecoration(
                                                color: Colors.blue.shade50,
                                                borderRadius: BorderRadius.circular(4),
                                              ),
                                              child: Text(mode, style: TextStyle(fontSize: 10, color: Colors.blue.shade800, fontWeight: FontWeight.bold)),
                                            ),
                                            const SizedBox(width: 6),
                                            Text(date.toString().substring(0, 10), style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
                                          ],
                                        ),
                                        if (ref != null && ref.toString().isNotEmpty)
                                          Text('Ref: $ref', style: TextStyle(color: Colors.grey.shade500, fontSize: 10)),
                                      ],
                                    ),
                                  ),
                                  Text(
                                    '${isOutward ? '-' : '+'} ₹${amt.toStringAsFixed(2)}',
                                    style: TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                      color: isOutward ? Colors.orange.shade800 : Colors.green.shade700,
                                    ),
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
