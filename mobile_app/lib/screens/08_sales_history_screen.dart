import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/invoice_model.dart';
import '07_invoice_preview_screen.dart';

class SalesHistoryScreen extends StatefulWidget {
  const SalesHistoryScreen({super.key});

  @override
  State<SalesHistoryScreen> createState() => _SalesHistoryScreenState();
}

class _SalesHistoryScreenState extends State<SalesHistoryScreen> {
  final ApiClient _api = ApiClient();
  final _searchController = TextEditingController();

  List<InvoiceModel> _invoices = [];
  bool _isLoading = false;
  String? _selectedPaymentStatus;

  @override
  void initState() {
    super.initState();
    _fetchInvoices();
  }

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _fetchInvoices() async {
    setState(() => _isLoading = true);

    final queryParams = <String, String>{};
    if (_searchController.text.isNotEmpty) {
      queryParams['search'] = _searchController.text.trim();
    }
    if (_selectedPaymentStatus != null) {
      queryParams['payment_status'] = _selectedPaymentStatus!;
    }

    final response = await _api.get(ApiEndpoints.invoices, queryParams: queryParams);
    setState(() => _isLoading = false);

    if (response.success && response.data != null) {
      final raw = response.data['invoices']['data'] as List<dynamic>? ?? [];
      setState(() {
        _invoices = raw.map((e) => InvoiceModel.fromJson(e)).toList();
      });
    }
  }

  Future<void> _cancelInvoice(InvoiceModel invoice) async {
    final reasonController = TextEditingController();

    final confirm = await showDialog<bool>(
      context: context,
      builder: (ctx) => AlertDialog(
        title: Text("Cancel Invoice #${invoice.invoiceNumber}?"),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              "Cancelling will automatically restore product stock and reverse customer credit dues.",
              style: TextStyle(fontSize: 13, color: AppColors.textSecondary),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: reasonController,
              decoration: const InputDecoration(labelText: 'Cancellation Reason *'),
            ),
          ],
        ),
        actions: [
          TextButton(onPressed: () => Navigator.pop(ctx, false), child: const Text('Back')),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            onPressed: () => Navigator.pop(ctx, true),
            child: const Text('Confirm Cancel'),
          ),
        ],
      ),
    );

    if (confirm == true && mounted) {
      final reason = reasonController.text.trim().isNotEmpty ? reasonController.text.trim() : 'Customer cancellation';
      final response = await _api.post(ApiEndpoints.cancelInvoice(invoice.id), {'reason': reason});

      if (response.success && mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Invoice cancelled and stock reversed.')),
        );
        _fetchInvoices();
      } else if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(response.message ?? 'Failed to cancel invoice')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Sales & Invoices History'),
      ),
      body: Column(
        children: [
          // Search & Filter Bar
          Padding(
            padding: const EdgeInsets.all(12),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _searchController,
                    onSubmitted: (_) => _fetchInvoices(),
                    decoration: InputDecoration(
                      hintText: 'Search bill number, customer name or phone...',
                      prefixIcon: const Icon(Icons.search),
                      suffixIcon: _searchController.text.isNotEmpty
                          ? IconButton(
                              icon: const Icon(Icons.clear),
                              onPressed: () {
                                _searchController.clear();
                                _fetchInvoices();
                              },
                            )
                          : null,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 14, vertical: 10),
                    ),
                  ),
                ),
                const SizedBox(width: 8),
                PopupMenuButton<String?>(
                  icon: const Icon(Icons.filter_list, color: AppColors.primary),
                  tooltip: 'Filter by Status',
                  onSelected: (val) {
                    setState(() => _selectedPaymentStatus = val);
                    _fetchInvoices();
                  },
                  itemBuilder: (ctx) => [
                    const PopupMenuItem(value: null, child: Text('All Payments')),
                    const PopupMenuItem(value: 'paid', child: Text('Paid')),
                    const PopupMenuItem(value: 'partial', child: Text('Partial')),
                    const PopupMenuItem(value: 'unpaid', child: Text('Credit (Unpaid)')),
                  ],
                ),
              ],
            ),
          ),

          const Divider(height: 1),

          // Invoices List
          Expanded(
            child: _isLoading
                ? const Center(child: CircularProgressIndicator())
                : _invoices.isEmpty
                    ? const Center(
                        child: Text(
                          'No invoices found matching criteria.',
                          style: TextStyle(color: AppColors.textSecondary),
                        ),
                      )
                    : RefreshIndicator(
                        onRefresh: _fetchInvoices,
                        child: ListView.builder(
                          padding: const EdgeInsets.all(10),
                          itemCount: _invoices.length,
                          itemBuilder: (context, index) {
                            final inv = _invoices[index];
                            final isCancelled = inv.status == 'cancelled';

                            Color statusColor = AppColors.success;
                            if (inv.paymentStatus == 'unpaid') statusColor = AppColors.error;
                            if (inv.paymentStatus == 'partial') statusColor = AppColors.warning;
                            if (isCancelled) statusColor = Colors.grey;

                            return Card(
                              margin: const EdgeInsets.only(bottom: 8),
                              child: ListTile(
                                onTap: () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                      builder: (_) => InvoicePreviewScreen(invoice: inv),
                                    ),
                                  );
                                },
                                title: Row(
                                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                  children: [
                                    Text(
                                      inv.invoiceNumber,
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 15,
                                        decoration: isCancelled ? TextDecoration.lineThrough : null,
                                      ),
                                    ),
                                    Text(
                                      "₹${inv.grandTotal.toStringAsFixed(2)}",
                                      style: TextStyle(
                                        fontWeight: FontWeight.bold,
                                        fontSize: 16,
                                        color: isCancelled ? Colors.grey : AppColors.primary,
                                      ),
                                    ),
                                  ],
                                ),
                                subtitle: Column(
                                  crossAxisAlignment: CrossAxisAlignment.start,
                                  children: [
                                    const SizedBox(height: 4),
                                    Text(
                                      "${inv.customerName} • ${inv.items.length} items",
                                      style: const TextStyle(fontSize: 12, color: AppColors.textSecondary),
                                    ),
                                    const SizedBox(height: 4),
                                    Row(
                                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                                      children: [
                                        Text(
                                          "${inv.invoiceDate} • ${inv.paymentMethod.toUpperCase()}",
                                          style: const TextStyle(fontSize: 11, color: AppColors.textMuted),
                                        ),
                                        Container(
                                          padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
                                          decoration: BoxDecoration(
                                            color: statusColor.withOpacity(0.12),
                                            borderRadius: BorderRadius.circular(4),
                                          ),
                                          child: Text(
                                            isCancelled ? 'CANCELLED' : inv.paymentStatus.toUpperCase(),
                                            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: statusColor),
                                          ),
                                        ),
                                      ],
                                    ),
                                  ],
                                ),
                                trailing: isCancelled
                                    ? null
                                    : PopupMenuButton<String>(
                                        onSelected: (val) {
                                          if (val == 'cancel') _cancelInvoice(inv);
                                        },
                                        itemBuilder: (ctx) => [
                                          const PopupMenuItem(
                                            value: 'cancel',
                                            child: Row(
                                              children: [
                                                Icon(Icons.cancel_outlined, color: AppColors.error, size: 18),
                                                SizedBox(width: 8),
                                                Text('Cancel & Revert Stock', style: TextStyle(color: AppColors.error)),
                                              ],
                                            ),
                                          ),
                                        ],
                                      ),
                              ),
                            );
                          },
                        ),
                      ),
          ),
        ],
      ),
    );
  }
}
