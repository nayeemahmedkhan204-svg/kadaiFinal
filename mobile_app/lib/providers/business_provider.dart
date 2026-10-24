import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/business_model.dart';
import '../models/subscription_model.dart';

class BusinessProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  BusinessModel? _currentBusiness;
  SubscriptionModel? _currentSubscription;
  bool _isLoading = false;

  BusinessModel? get currentBusiness => _currentBusiness;
  SubscriptionModel? get currentSubscription => _currentSubscription;
  bool get isLoading => _isLoading;

  Future<void> init(List<BusinessModel> userBusinesses) async {
    final prefs = await SharedPreferences.getInstance();
    final savedId = prefs.getInt(AppConstants.keySelectedBusinessId);

    if (savedId != null) {
      final found = userBusinesses.where((b) => b.id == savedId).toList();
      if (found.isNotEmpty) {
        _currentBusiness = found.first;
      }
    }

    if (_currentBusiness == null && userBusinesses.isNotEmpty) {
      _currentBusiness = userBusinesses.first;
      await prefs.setInt(AppConstants.keySelectedBusinessId, _currentBusiness!.id);
    }

    if (_currentBusiness != null) {
      _api.setActiveBusinessId(_currentBusiness!.id);
      await fetchBusinessDetails();
    }
  }

  Future<void> switchBusiness(BusinessModel business) async {
    _currentBusiness = business;
    _api.setActiveBusinessId(business.id);

    final prefs = await SharedPreferences.getInstance();
    await prefs.setInt(AppConstants.keySelectedBusinessId, business.id);

    notifyListeners();
    await fetchBusinessDetails();
  }

  Future<void> fetchBusinessDetails() async {
    if (_currentBusiness == null) return;

    _isLoading = true;
    notifyListeners();

    final response = await _api.get(ApiEndpoints.currentBusiness);
    _isLoading = false;

    if (response.success && response.data != null) {
      _currentBusiness = BusinessModel.fromJson(response.data['business']);
      if (response.data['business']['active_subscription'] != null) {
        _currentSubscription = SubscriptionModel.fromJson(response.data['business']['active_subscription']);
      }
      notifyListeners();
    }
  }

  Future<bool> updateBusinessSettings(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    final response = await _api.put(ApiEndpoints.currentBusiness, data);
    _isLoading = false;

    if (response.success && response.data != null) {
      _currentBusiness = BusinessModel.fromJson(response.data['business']);
      notifyListeners();
      return true;
    }
    return false;
  }

  Future<bool> createBusiness(Map<String, dynamic> data) async {
    _isLoading = true;
    notifyListeners();

    final response = await _api.post(ApiEndpoints.businesses, data);
    _isLoading = false;

    if (response.success && response.data != null) {
      final newBiz = BusinessModel.fromJson(response.data['business']);
      await switchBusiness(newBiz);
      return true;
    }
    return false;
  }
}
