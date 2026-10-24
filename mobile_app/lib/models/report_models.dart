class DashboardMetrics {
  final double todaySales;
  final int todayBills;
  final double cashCollected;
  final double upiCollected;
  final double creditSales;
  final double customerCollections;
  final double outstandingCustomerDues;
  final double outstandingSupplierDues;
  final double todayExpenses;
  final double monthExpenses;
  final double grossProfit;
  final double netProfit;
  final int lowStockCount;

  DashboardMetrics({
    required this.todaySales,
    required this.todayBills,
    required this.cashCollected,
    required this.upiCollected,
    required this.creditSales,
    required this.customerCollections,
    required this.outstandingCustomerDues,
    required this.outstandingSupplierDues,
    required this.todayExpenses,
    required this.monthExpenses,
    required this.grossProfit,
    required this.netProfit,
    required this.lowStockCount,
  });

  double get upiPayments => upiCollected;
  double get totalExpenses => todayExpenses;

  factory DashboardMetrics.fromJson(Map<String, dynamic> json) {
    return DashboardMetrics(
      todaySales: (json['today_sales'] as num?)?.toDouble() ?? 0.0,
      todayBills: json['today_bills'] is int ? json['today_bills'] : 0,
      cashCollected: (json['cash_collected'] as num?)?.toDouble() ?? 0.0,
      upiCollected: (json['upi_collected'] as num?)?.toDouble() ?? 0.0,
      creditSales: (json['credit_sales'] as num?)?.toDouble() ?? 0.0,
      customerCollections: (json['customer_collections'] as num?)?.toDouble() ?? 0.0,
      outstandingCustomerDues: (json['outstanding_customer_dues'] as num?)?.toDouble() ?? 0.0,
      outstandingSupplierDues: (json['outstanding_supplier_dues'] as num?)?.toDouble() ?? 0.0,
      todayExpenses: (json['today_expenses'] as num?)?.toDouble() ?? 0.0,
      monthExpenses: (json['month_expenses'] as num?)?.toDouble() ?? 0.0,
      grossProfit: (json['gross_profit'] as num?)?.toDouble() ?? 0.0,
      netProfit: (json['net_profit'] as num?)?.toDouble() ?? 0.0,
      lowStockCount: json['low_stock_count'] is int ? json['low_stock_count'] : 0,
    );
  }
}

class SalesChartPoint {
  final String date;
  final String label;
  final double sales;
  final int bills;

  SalesChartPoint({
    required this.date,
    required this.label,
    required this.sales,
    required this.bills,
  });

  factory SalesChartPoint.fromJson(Map<String, dynamic> json) {
    return SalesChartPoint(
      date: json['date'] ?? '',
      label: json['label'] ?? '',
      sales: (json['sales'] as num?)?.toDouble() ?? 0.0,
      bills: json['bills'] is int ? json['bills'] : 0,
    );
  }
}
