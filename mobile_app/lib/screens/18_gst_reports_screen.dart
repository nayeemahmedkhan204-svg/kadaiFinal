import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/report_provider.dart';

class GstReportsScreen extends StatefulWidget {
  const GstReportsScreen({super.key});

  @override
  State<GstReportsScreen> createState() => _GstReportsScreenState();
}

class _GstReportsScreenState extends State<GstReportsScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchGst();
  }

  void _fetchGst() {
    final startStr = DateFormat('yyyy-MM-dd').format(_startDate);
    final endStr = DateFormat('yyyy-MM-dd').format(_endDate);
    Provider.of<ReportProvider>(context, listen: false).fetchGstSummary(startDate: startStr, endDate: endStr);
  }

  Future<void> _pickDateRange() async {
    final picked = await showDateRangePicker(
      context: context,
      firstDate: DateTime(2020),
      lastDate: DateTime.now().add(const Duration(days: 1)),
      initialDateRange: DateTimeRange(start: _startDate, end: _endDate),
    );
    if (picked != null) {
      setState(() {
        _startDate = picked.start;
        _endDate = picked.end;
      });
      _fetchGst();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportProv = Provider.of<ReportProvider>(context);
    final summary = reportProv.gstSummary;

    final slabBreakdown = (summary?['slabs'] as List<dynamic>? ?? []);
    final totalTaxable = (summary?['total_taxable_value'] as num?)?.toDouble() ?? 0.0;
    final totalCgst = (summary?['total_cgst'] as num?)?.toDouble() ?? 0.0;
    final totalSgst = (summary?['total_sgst'] as num?)?.toDouble() ?? 0.0;
    final totalIgst = (summary?['total_igst'] as num?)?.toDouble() ?? 0.0;
    final totalTax = (summary?['total_tax'] as num?)?.toDouble() ?? 0.0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('GST Reports / வரி அறிக்கை'),
        actions: [
          IconButton(
            icon: const Icon(Icons.date_range),
            onPressed: _pickDateRange,
            tooltip: 'Filter Date Range',
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _fetchGst,
          ),
        ],
      ),
      body: reportProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Active date filter banner
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(8),
                    ),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Period: ${DateFormat('dd MMM yyyy').format(_startDate)} to ${DateFormat('dd MMM yyyy').format(_endDate)}',
                          style: TextStyle(color: Colors.blue.shade900, fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        TextButton(onPressed: _pickDateRange, child: const Text('Change')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Total GST Liability Card
                  Container(
                    padding: const EdgeInsets.all(16),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.primaryLight],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        const Text('Total GST Liability / மொத்த வரி', style: TextStyle(color: Colors.white70, fontSize: 13)),
                        const SizedBox(height: 4),
                        Text('₹${totalTax.toStringAsFixed(2)}',
                            style: const TextStyle(color: Colors.white, fontSize: 26, fontWeight: FontWeight.bold)),
                        const Divider(color: Colors.white30, height: 20),
                        Row(
                          mainAxisAlignment: MainAxisAlignment.spaceBetween,
                          children: [
                            _TaxMiniItem(label: 'CGST', value: totalCgst),
                            _TaxMiniItem(label: 'SGST', value: totalSgst),
                            _TaxMiniItem(label: 'IGST', value: totalIgst),
                          ],
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Taxable Sales Overview
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: Padding(
                      padding: const EdgeInsets.all(14),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Text('Total Taxable Turnover:', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                          Text('₹${totalTaxable.toStringAsFixed(2)}',
                              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // GST Slabs Table
                  const Text('GST Slab-Wise Breakdown (GSTR-1)',
                      style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
                  const SizedBox(height: 8),

                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
                    child: SingleChildScrollView(
                      scrollDirection: Axis.horizontal,
                      child: DataTable(
                        headingRowColor: WidgetStateProperty.all(Colors.grey.shade100),
                        columns: const [
                          DataColumn(label: Text('Rate', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Taxable (₹)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('CGST (₹)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('SGST (₹)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('IGST (₹)', style: TextStyle(fontWeight: FontWeight.bold))),
                          DataColumn(label: Text('Total Tax (₹)', style: TextStyle(fontWeight: FontWeight.bold))),
                        ],
                        rows: slabBreakdown.isEmpty
                            ? [
                                const DataRow(cells: [
                                  DataCell(Text('0%')),
                                  DataCell(Text('0.00')),
                                  DataCell(Text('0.00')),
                                  DataCell(Text('0.00')),
                                  DataCell(Text('0.00')),
                                  DataCell(Text('0.00')),
                                ]),
                                const DataRow(cells: [
                                  DataCell(Text('5%')),
                                  DataCell(Text('0.00')),
                                  DataCell(Text('0.00')),
                                  DataCell(Text('0.00')),
                                  DataCell(Text('0.00')),
                                  DataCell(Text('0.00')),
                                ]),
                              ]
                            : slabBreakdown.map((s) {
                                final rate = s['rate'] ?? 0;
                                final taxable = (s['taxable_value'] as num?)?.toDouble() ?? 0.0;
                                final cgst = (s['cgst'] as num?)?.toDouble() ?? 0.0;
                                final sgst = (s['sgst'] as num?)?.toDouble() ?? 0.0;
                                final igst = (s['igst'] as num?)?.toDouble() ?? 0.0;
                                final tax = (s['tax_amount'] as num?)?.toDouble() ?? 0.0;
                                return DataRow(cells: [
                                  DataCell(Text('$rate%', style: const TextStyle(fontWeight: FontWeight.bold))),
                                  DataCell(Text(taxable.toStringAsFixed(2))),
                                  DataCell(Text(cgst.toStringAsFixed(2))),
                                  DataCell(Text(sgst.toStringAsFixed(2))),
                                  DataCell(Text(igst.toStringAsFixed(2))),
                                  DataCell(Text(tax.toStringAsFixed(2), style: const TextStyle(fontWeight: FontWeight.bold))),
                                ]);
                              }).toList(),
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Legal Compliance Disclaimer
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.amber.shade50,
                      borderRadius: BorderRadius.circular(10),
                      border: Border.all(color: Colors.amber.shade200),
                    ),
                    child: Row(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Icon(Icons.info_outline, color: Colors.amber.shade900, size: 20),
                        const SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Note: This GST report is an internal operational calculation derived from recorded invoices. For filing GSTR-1 and GSTR-3B on the GST portal, consult your chartered accountant.',
                            style: TextStyle(color: Colors.amber.shade900, fontSize: 11),
                          ),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
            ),
    );
  }
}

class _TaxMiniItem extends StatelessWidget {
  final String label;
  final double value;

  const _TaxMiniItem({required this.label, required this.value});

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(color: Colors.white70, fontSize: 12)),
        const SizedBox(height: 2),
        Text('₹${value.toStringAsFixed(2)}',
            style: const TextStyle(color: Colors.white, fontSize: 15, fontWeight: FontWeight.bold)),
      ],
    );
  }
}
