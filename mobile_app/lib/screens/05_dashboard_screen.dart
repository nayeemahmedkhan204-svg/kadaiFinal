import 'package:fl_chart/fl_chart.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../core/constants/app_colors.dart';
import '../providers/business_provider.dart';
import '../providers/report_provider.dart';
import '06_quick_billing_pos_screen.dart';
import '08_sales_history_screen.dart';
import '11_inventory_stock_alerts_screen.dart';
import '13_customer_management_screen.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _loadDashboard();
    });
  }

  Future<void> _loadDashboard() async {
    final report = Provider.of<ReportProvider>(context, listen: false);
    await report.fetchDashboardMetrics();
  }

  @override
  Widget build(BuildContext context) {
    final business = Provider.of<BusinessProvider>(context).currentBusiness;
    final report = Provider.of<ReportProvider>(context);
    final m = report.metrics;

    return Scaffold(
      appBar: AppBar(
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(business?.name ?? 'KadaiKhata', style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17)),
            Text(
              "${business?.city != null ? "${business!.city}, " : ""}${business?.state ?? ''}",
              style: TextStyle(fontSize: 11, color: Colors.white.withOpacity(0.85)),
            ),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Refresh Metrics',
            onPressed: _loadDashboard,
          ),
        ],
      ),
      body: RefreshIndicator(
        onRefresh: _loadDashboard,
        child: SingleChildScrollView(
          physics: const AlwaysScrollableScrollPhysics(),
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              // Main Counter Billing CTA Banner
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  gradient: const LinearGradient(
                    colors: [AppColors.primaryDark, AppColors.primaryLight],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                  borderRadius: BorderRadius.circular(14),
                  boxShadow: [
                    BoxShadow(color: AppColors.primary.withOpacity(0.3), blurRadius: 8, offset: const Offset(0, 4)),
                  ],
                ),
                child: Row(
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          const Text(
                            "COUNTER BILLING & POS",
                            style: TextStyle(color: Colors.white70, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 0.5),
                          ),
                          const SizedBox(height: 4),
                          const Text(
                            "Fast Barcode & Touch POS",
                            style: TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
                          ),
                          const SizedBox(height: 8),
                          ElevatedButton.icon(
                            onPressed: () {
                              Navigator.of(context).push(
                                MaterialPageRoute(builder: (_) => const QuickBillingPosScreen()),
                              );
                            },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: AppColors.accent,
                              foregroundColor: Colors.black87,
                              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                            ),
                            icon: const Icon(Icons.point_of_sale, size: 18),
                            label: const Text('Start New Bill', style: TextStyle(fontWeight: FontWeight.bold)),
                          ),
                        ],
                      ),
                    ),
                    const Icon(Icons.receipt_long_rounded, size: 64, color: Colors.white24),
                  ],
                ),
              ),

              const SizedBox(height: 16),

              // KPI Row 1: Today's Sales & Total Bills
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: "TODAY'S SALES",
                      value: "₹${(m?.todaySales ?? 0.0).toStringAsFixed(2)}",
                      subtitle: "${m?.todayBills ?? 0} bills completed",
                      icon: Icons.currency_rupee,
                      color: AppColors.primary,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const SalesHistoryScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricCard(
                      title: "NET PROFIT (EST.)",
                      value: "₹${(m?.netProfit ?? 0.0).toStringAsFixed(2)}",
                      subtitle: "Gross: ₹${(m?.grossProfit ?? 0.0).toStringAsFixed(0)}",
                      icon: Icons.trending_up,
                      color: AppColors.success,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // KPI Row 2: Cash & UPI Collections
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: "CASH COLLECTED",
                      value: "₹${(m?.cashCollected ?? 0.0).toStringAsFixed(2)}",
                      subtitle: "In register",
                      icon: Icons.payments_outlined,
                      color: AppColors.secondary,
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricCard(
                      title: "UPI PAYMENTS",
                      value: "₹${(m?.upiCollected ?? 0.0).toStringAsFixed(2)}",
                      subtitle: "Bank settled",
                      icon: Icons.qr_code_2,
                      color: AppColors.info,
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 8),

              // KPI Row 3: Customer Khata Dues & Low Stock Alerts
              Row(
                children: [
                  Expanded(
                    child: _buildMetricCard(
                      title: "CUSTOMER DUES",
                      value: "₹${(m?.outstandingCustomerDues ?? 0.0).toStringAsFixed(2)}",
                      subtitle: "Credit sales: ₹${(m?.creditSales ?? 0.0).toStringAsFixed(0)}",
                      icon: Icons.account_balance_wallet_outlined,
                      color: AppColors.warning,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const CustomerManagementScreen()),
                        );
                      },
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: _buildMetricCard(
                      title: "LOW STOCK",
                      value: "${m?.lowStockCount ?? 0} Items",
                      subtitle: "Tap to review",
                      icon: Icons.warning_amber_rounded,
                      color: (m?.lowStockCount ?? 0) > 0 ? AppColors.error : AppColors.textSecondary,
                      onTap: () {
                        Navigator.of(context).push(
                          MaterialPageRoute(builder: (_) => const InventoryStockAlertsScreen()),
                        );
                      },
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 16),

              // 7-Day Sales Trend Chart
              Card(
                margin: EdgeInsets.zero,
                child: Padding(
                  padding: const EdgeInsets.all(16),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text("7-Day Sales Trend", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 15)),
                          Text("Daily revenue in ₹", style: TextStyle(fontSize: 11, color: AppColors.textSecondary)),
                        ],
                      ),
                      const SizedBox(height: 16),
                      SizedBox(
                        height: 160,
                        child: report.salesChart.isNotEmpty
                            ? BarChart(
                                BarChartData(
                                  alignment: BarChartAlignment.spaceAround,
                                  maxY: (report.salesChart.fold(0.0, (max, p) => p.sales > max ? p.sales : max) * 1.2)
                                      .clamp(100.0, 100000.0),
                                  barTouchData: BarTouchData(enabled: true),
                                  titlesData: FlTitlesData(
                                    show: true,
                                    bottomTitles: AxisTitles(
                                      sideTitles: SideTitles(
                                        showTitles: true,
                                        getTitlesWidget: (val, meta) {
                                          int index = val.toInt();
                                          if (index >= 0 && index < report.salesChart.length) {
                                            return Padding(
                                              padding: const EdgeInsets.only(top: 4.0),
                                              child: Text(report.salesChart[index].label,
                                                  style: const TextStyle(fontSize: 9, color: AppColors.textSecondary)),
                                            );
                                          }
                                          return const Text('');
                                        },
                                      ),
                                    ),
                                    leftTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                    rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                                  ),
                                  gridData: const FlGridData(show: false),
                                  borderData: FlBorderData(show: false),
                                  barGroups: List.generate(report.salesChart.length, (i) {
                                    final pt = report.salesChart[i];
                                    return BarChartGroupData(
                                      x: i,
                                      barRods: [
                                        BarChartRodData(
                                          toY: pt.sales,
                                          color: i == report.salesChart.length - 1 ? AppColors.primary : AppColors.primaryLight,
                                          width: 16,
                                          borderRadius: const BorderRadius.vertical(top: Radius.circular(4)),
                                        ),
                                      ],
                                    );
                                  }),
                                ),
                              )
                            : const Center(child: Text('Loading sales trend...', style: TextStyle(color: AppColors.textSecondary))),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildMetricCard({
    required String title,
    required String value,
    required String subtitle,
    required IconData icon,
    required Color color,
    VoidCallback? onTap,
  }) {
    return Card(
      margin: EdgeInsets.zero,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Padding(
          padding: const EdgeInsets.all(12),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text(title, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: AppColors.textSecondary)),
                  Icon(icon, size: 18, color: color),
                ],
              ),
              const SizedBox(height: 6),
              Text(value, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color)),
              const SizedBox(height: 2),
              Text(subtitle, style: const TextStyle(fontSize: 11, color: AppColors.textSecondary), maxLines: 1, overflow: TextOverflow.ellipsis),
            ],
          ),
        ),
      ),
    );
  }
}
