import 'package:flutter/material.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/customer_model.dart';

class CustomerProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  List<CustomerModel> _customers = [];
  double _totalOutstanding = 0.0;
  bool _isLoading = false;

  List<CustomerModel> get customers => _customers;
  double get totalOutstanding => _totalOutstanding;
  bool get isLoading => _isLoading;

  Future<void> fetchCustomers({String? search, bool hasBalance = false}) async {
    _isLoading = true;
    notifyListeners();

    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (hasBalance) queryParams['has_balance'] = '1';

    final response = await _api.get(ApiEndpoints.customers, queryParams: queryParams);
    _isLoading = false;

    if (response.success && response.data != null) {
      _totalOutstanding = (response.data['total_outstanding'] as num?)?.toDouble() ?? 0.0;
      final raw = response.data['customers']['data'] as List<dynamic>? ?? [];
      _customers = raw.map((c) => CustomerModel.fromJson(c)).toList();
      notifyListeners();
    }
  }

  Future<bool> addCustomer(Map<String, dynamic> data) async {
    final response = await _api.post(ApiEndpoints.customers, data);
    if (response.success) {
      await fetchCustomers();
      return true;
    }
    return false;
  }

  Future<bool> recordPayment(int customerId, double amount, String mode, {String? reference, String? notes}) async {
    final response = await _api.post(ApiEndpoints.customerPayment(customerId), {
      'amount': amount,
      'payment_mode': mode,
      'transaction_reference': reference,
      'notes': notes,
    });
    if (response.success) {
      await fetchCustomers();
      return true;
    }
    return false;
  }
}
