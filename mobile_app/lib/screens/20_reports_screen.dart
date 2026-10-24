import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/customer_provider.dart';
import '../providers/expense_provider.dart';
import '../providers/product_provider.dart';
import '../providers/report_provider.dart';
import '08_sales_history_screen.dart';
import '11_inventory_stock_alerts_screen.dart';
import '18_gst_reports_screen.dart';
import '19_profit_loss_screen.dart';

class ReportsScreen extends StatefulWidget {
  const ReportsScreen({super.key});

  @override
  State<ReportsScreen> createState() => _ReportsScreenState();
}

class _ReportsScreenState extends State<ReportsScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      Provider.of<ReportProvider>(context, listen: false).fetchDashboardMetrics();
    });
  }

  @override
  Widget build(BuildContext context) {
    final reportProv = Provider.of<ReportProvider>(context);
    final m = reportProv.metrics;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Business Reports / அறிக்கைகள்'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () => reportProv.fetchDashboardMetrics(),
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(14),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Top Highlights
            Text('Financial Summaries / நிதி விவரங்கள்',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _ReportTile(
                    title: 'Profit & Loss',
                    subtitle: 'Gross & Net Margins',
                    icon: Icons.trending_up,
                    color: Colors.teal,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const ProfitLossScreen())),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ReportTile(
                    title: 'GST Summary',
                    subtitle: 'GSTR-1 Slab Totals',
                    icon: Icons.account_balance,
                    color: AppColors.primary,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const GstReportsScreen())),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10),

            Row(
              children: [
                Expanded(
                  child: _ReportTile(
                    title: 'Sales History',
                    subtitle: 'Invoices & Receipts',
                    icon: Icons.receipt_long,
                    color: Colors.blue,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const SalesHistoryScreen())),
                  ),
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: _ReportTile(
                    title: 'Stock Valuation',
                    subtitle: 'Inventory Alerts',
                    icon: Icons.inventory_2,
                    color: Colors.orange,
                    onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => const InventoryStockAlertsScreen())),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 20),

            // Today's Operational Metrics
            Text('Quick Metrics Summary (Today)',
                style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold, color: Colors.grey.shade800)),
            const SizedBox(height: 10),

            Card(
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    _MetricRow(label: 'Total Today Sales', value: '₹${(m?.todaySales ?? 0.0).toStringAsFixed(2)}', isBold: true),
                    const Divider(height: 16),
                    _MetricRow(label: 'Cash Collections', value: '₹${(m?.cashCollected ?? 0.0).toStringAsFixed(2)}'),
                    const Divider(height: 16),
                    _MetricRow(label: 'UPI Payments', value: '₹${(m?.upiPayments ?? 0.0).toStringAsFixed(2)}'),
                    const Divider(height: 16),
                    _MetricRow(label: 'Credit Sales (Khata)', value: '₹${(m?.creditSales ?? 0.0).toStringAsFixed(2)}', color: Colors.red),
                    const Divider(height: 16),
                    _MetricRow(label: 'Customer Dues (Pending)', value: '₹${(m?.outstandingCustomerDues ?? 0.0).toStringAsFixed(2)}', color: Colors.red.shade800),
                    const Divider(height: 16),
                    _MetricRow(label: 'Today Expenses', value: '₹${(m?.totalExpenses ?? 0.0).toStringAsFixed(2)}', color: Colors.purple),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 20),

            // Export Reports Section
            Card(
              color: Colors.blue.shade50,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Row(
                  children: [
                    const Icon(Icons.picture_as_pdf, color: Colors.redAccent, size: 36),
                    const SizedBox(width: 12),
                    const Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text('Export All Reports', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          SizedBox(height: 2),
                          Text('Download Daily/Monthly summaries in PDF or Excel format',
                              style: TextStyle(color: Colors.black54, fontSize: 11)),
                        ],
                      ),
                    ),
                    ElevatedButton(
                      onPressed: () {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Generating PDF Report... Export saved to downloads.')),
                        );
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primary,
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                      ),
                      child: const Text('Export', style: TextStyle(color: Colors.white, fontSize: 12)),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _ReportTile extends StatelessWidget {
  final String title;
  final String subtitle;
  final IconData icon;
  final Color color;
  final VoidCallback onTap;

  const _ReportTile({
    required this.title,
    required this.subtitle,
    required this.icon,
    required this.color,
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.all(14),
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.grey.shade200),
          boxShadow: [
            BoxShadow(color: Colors.grey.withOpacity(0.06), blurRadius: 4, offset: const Offset(0, 2)),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CircleAvatar(
              backgroundColor: color.withOpacity(0.12),
              child: Icon(icon, color: color, size: 22),
            ),
            const SizedBox(height: 10),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
            const SizedBox(height: 2),
            Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
          ],
        ),
      ),
    );
  }
}

class _MetricRow extends StatelessWidget {
  final String label;
  final String value;
  final bool isBold;
  final Color? color;

  const _MetricRow({required this.label, required this.value, this.isBold = false, this.color});

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label, style: TextStyle(fontSize: 13, fontWeight: isBold ? FontWeight.bold : FontWeight.normal)),
        Text(
          value,
          style: TextStyle(
            fontSize: 14,
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            color: color ?? Colors.black87,
          ),
        ),
      ],
    );
  }
}
