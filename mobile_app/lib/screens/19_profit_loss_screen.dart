import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/report_provider.dart';

class ProfitLossScreen extends StatefulWidget {
  const ProfitLossScreen({super.key});

  @override
  State<ProfitLossScreen> createState() => _ProfitLossScreenState();
}

class _ProfitLossScreenState extends State<ProfitLossScreen> {
  DateTime _startDate = DateTime.now().subtract(const Duration(days: 30));
  DateTime _endDate = DateTime.now();

  @override
  void initState() {
    super.initState();
    _fetchPnl();
  }

  void _fetchPnl() {
    final startStr = DateFormat('yyyy-MM-dd').format(_startDate);
    final endStr = DateFormat('yyyy-MM-dd').format(_endDate);
    Provider.of<ReportProvider>(context, listen: false).fetchProfitAndLoss(startDate: startStr, endDate: endStr);
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
      _fetchPnl();
    }
  }

  @override
  Widget build(BuildContext context) {
    final reportProv = Provider.of<ReportProvider>(context);
    final pnl = reportProv.pnlStatement;

    final netSales = (pnl?['net_sales'] as num?)?.toDouble() ?? 0.0;
    final cogs = (pnl?['cogs'] as num?)?.toDouble() ?? 0.0;
    final grossProfit = (pnl?['gross_profit'] as num?)?.toDouble() ?? 0.0;
    final grossMargin = (pnl?['gross_margin_percentage'] as num?)?.toDouble() ?? 0.0;
    final expenses = (pnl?['operating_expenses'] as num?)?.toDouble() ?? 0.0;
    final netProfit = (pnl?['net_operating_profit'] as num?)?.toDouble() ?? 0.0;
    final netMargin = (pnl?['net_margin_percentage'] as num?)?.toDouble() ?? 0.0;

    final isProfit = netProfit >= 0;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Profit & Loss / லாப நஷ்ட அறிக்கை'),
        actions: [
          IconButton(icon: const Icon(Icons.date_range), onPressed: _pickDateRange),
          IconButton(icon: const Icon(Icons.refresh), onPressed: _fetchPnl),
        ],
      ),
      body: reportProv.isLoading
          ? const Center(child: CircularProgressIndicator())
          : SingleChildScrollView(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  // Date range chip
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
                    decoration: BoxDecoration(color: Colors.grey.shade100, borderRadius: BorderRadius.circular(8)),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          '${DateFormat('dd MMM yyyy').format(_startDate)} - ${DateFormat('dd MMM yyyy').format(_endDate)}',
                          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13),
                        ),
                        TextButton(onPressed: _pickDateRange, child: const Text('Change Date')),
                      ],
                    ),
                  ),
                  const SizedBox(height: 12),

                  // Net Profit Hero Banner
                  Container(
                    padding: const EdgeInsets.all(20),
                    decoration: BoxDecoration(
                      gradient: LinearGradient(
                        colors: isProfit
                            ? [Colors.teal.shade700, Colors.teal.shade900]
                            : [Colors.red.shade700, Colors.red.shade900],
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        Text(
                          isProfit ? 'Estimated Net Operating Profit' : 'Estimated Net Operating Loss',
                          style: const TextStyle(color: Colors.white70, fontSize: 13),
                        ),
                        const SizedBox(height: 6),
                        Text(
                          '₹${netProfit.abs().toStringAsFixed(2)}',
                          style: const TextStyle(color: Colors.white, fontSize: 30, fontWeight: FontWeight.bold),
                        ),
                        const SizedBox(height: 4),
                        Container(
                          padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
                          decoration: BoxDecoration(
                            color: Colors.white24,
                            borderRadius: BorderRadius.circular(12),
                          ),
                          child: Text(
                            'Net Margin: ${netMargin.toStringAsFixed(1)}%',
                            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold, fontSize: 12),
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 16),

                  // Accounting Breakdown Card
                  Card(
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                    child: Padding(
                      padding: const EdgeInsets.all(16),
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text('Income Statement / வருமான விவரம்',
                              style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16, color: AppColors.primary)),
                          const Divider(height: 20),

                          _PnlRow(
                            title: '1. Net Sales Revenue (Excl. Tax)',
                            subtitle: 'Gross revenue minus discounts & sales returns',
                            amount: netSales,
                            color: Colors.black800,
                            isBold: true,
                          ),
                          const SizedBox(height: 12),

                          _PnlRow(
                            title: '2. Cost of Goods Sold (COGS)',
                            subtitle: 'Direct product purchase acquisition costs',
                            amount: -cogs,
                            color: Colors.red.shade700,
                          ),
                          const Divider(height: 24),

                          _PnlRow(
                            title: 'Gross Profit',
                            subtitle: 'Net Sales Revenue − COGS (Margin: ${grossMargin.toStringAsFixed(1)}%)',
                            amount: grossProfit,
                            color: grossProfit >= 0 ? Colors.green.shade800 : Colors.red,
                            isBold: true,
                            fontSize: 16,
                          ),
                          const Divider(height: 24),

                          _PnlRow(
                            title: '3. Operating Expenses',
                            subtitle: 'Rent, electricity, salaries, transport, tea/snacks',
                            amount: -expenses,
                            color: Colors.red.shade700,
                          ),
                          const Divider(height: 24, thickness: 1.5),

                          _PnlRow(
                            title: 'Net Operating Profit',
                            subtitle: 'Gross Profit − Operating Expenses',
                            amount: netProfit,
                            color: isProfit ? Colors.teal.shade800 : Colors.red.shade800,
                            isBold: true,
                            fontSize: 17,
                          ),
                        ],
                      ),
                    ),
                  ),
                  const SizedBox(height: 14),

                  // Principle note
                  Container(
                    padding: const EdgeInsets.all(12),
                    decoration: BoxDecoration(
                      color: Colors.blue.shade50,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Row(
                      children: [
                        Icon(Icons.lightbulb_outline, color: AppColors.primary),
                        SizedBox(width: 8),
                        Expanded(
                          child: Text(
                            'Khata collections are balance sheet adjustments and are never counted as duplicate sales revenue.',
                            style: TextStyle(fontSize: 11, color: AppColors.primary, fontWeight: FontWeight.w500),
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

class _PnlRow extends StatelessWidget {
  final String title;
  final String subtitle;
  final double amount;
  final Color color;
  final bool isBold;
  final double fontSize;

  const _PnlRow({
    required this.title,
    required this.subtitle,
    required this.amount,
    required this.color,
    this.isBold = false,
    this.fontSize = 14,
  });

  @override
  Widget build(BuildContext context) {
    return Row(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(title, style: TextStyle(fontWeight: isBold ? FontWeight.bold : FontWeight.w600, fontSize: fontSize)),
              const SizedBox(height: 2),
              Text(subtitle, style: TextStyle(color: Colors.grey.shade600, fontSize: 11)),
            ],
          ),
        ),
        Text(
          '₹${amount.toStringAsFixed(2)}',
          style: TextStyle(
            fontWeight: isBold ? FontWeight.bold : FontWeight.w600,
            fontSize: fontSize + 1,
            color: color,
          ),
        ),
      ],
    );
  }
}
