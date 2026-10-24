import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/expense_model.dart';

class ExpenseProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<ExpenseModel> _expenses = [];
  List<String> _categories = [];
  double _totalExpenses = 0.0;
  bool _isLoading = false;

  List<ExpenseModel> get expenses => _expenses;
  List<String> get categories => _categories;
  double get totalExpenses => _totalExpenses;
  bool get isLoading => _isLoading;

  Future<void> fetchCategories() async {
    final response = await _api.get(ApiEndpoints.expenseCategories);
    if (response.success && response.data != null) {
      final raw = response.data['categories'] as List<dynamic>? ?? [];
      _categories = raw.map((c) => c.toString()).toList();
      notifyListeners();
    }
  }

  Future<void> fetchExpenses({String? category, String? startDate, String? endDate}) async {
    _isLoading = true;
    notifyListeners();

    final queryParams = <String, String>{};
    if (category != null && category.isNotEmpty) queryParams['category'] = category;
    if (startDate != null && endDate != null) {
      queryParams['start_date'] = startDate;
      queryParams['end_date'] = endDate;
    }

    final response = await _api.get(ApiEndpoints.expenses, queryParams: queryParams);
    _isLoading = false;

    if (response.success && response.data != null) {
      _totalExpenses = (response.data['total_expenses'] as num?)?.toDouble() ?? 0.0;
      final raw = response.data['expenses']['data'] as List<dynamic>? ?? [];
      _expenses = raw.map((e) => ExpenseModel.fromJson(e)).toList();
      notifyListeners();
    }
  }

  Future<bool> addExpense(Map<String, dynamic> data) async {
    final response = await _api.post(ApiEndpoints.expenses, data);
    if (response.success) {
      await fetchExpenses();
      return true;
    }
    return false;
  }
}
