import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/report_models.dart';

class ReportProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  DashboardMetrics? _metrics;
  List<SalesChartPoint> _salesChart = [];
  Map<String, dynamic>? _pnlStatement;
  Map<String, dynamic>? _gstSummary;
  bool _isLoading = false;

  DashboardMetrics? get metrics => _metrics;
  List<SalesChartPoint> get salesChart => _salesChart;
  Map<String, dynamic>? get pnlStatement => _pnlStatement;
  Map<String, dynamic>? get gstSummary => _gstSummary;
  bool get isLoading => _isLoading;

  Future<void> fetchDashboardMetrics() async {
    _isLoading = true;
    notifyListeners();

    final response = await _api.get(ApiEndpoints.reportDashboard);
    _isLoading = false;

    if (response.success && response.data != null) {
      if (response.data['metrics'] != null) {
        _metrics = DashboardMetrics.fromJson(response.data['metrics']);
      }
      final rawChart = response.data['sales_chart'] as List<dynamic>? ?? [];
      _salesChart = rawChart.map((c) => SalesChartPoint.fromJson(c)).toList();
      notifyListeners();
    }
  }

  Future<void> fetchProfitAndLoss({String? startDate, String? endDate}) async {
    _isLoading = true;
    notifyListeners();

    final queryParams = <String, String>{};
    if (startDate != null && endDate != null) {
      queryParams['start_date'] = startDate;
      queryParams['end_date'] = endDate;
    }

    final response = await _api.get(ApiEndpoints.reportProfitLoss, queryParams: queryParams);
    _isLoading = false;

    if (response.success && response.data != null) {
      _pnlStatement = response.data['statement'];
      notifyListeners();
    }
  }

  Future<void> fetchGstSummary({String? startDate, String? endDate}) async {
    _isLoading = true;
    notifyListeners();

    final queryParams = <String, String>{};
    if (startDate != null && endDate != null) {
      queryParams['start_date'] = startDate;
      queryParams['end_date'] = endDate;
    }

    final response = await _api.get(ApiEndpoints.reportGstSummary, queryParams: queryParams);
    _isLoading = false;

    if (response.success && response.data != null) {
      _gstSummary = response.data;
      notifyListeners();
    }
  }
}
