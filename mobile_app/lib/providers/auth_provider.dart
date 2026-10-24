import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../core/constants/app_constants.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/business_model.dart';
import '../models/user_model.dart';

class AuthProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();

  UserModel? _user;
  List<BusinessModel> _businesses = [];
  bool _isLoading = false;
  String? _errorMessage;

  UserModel? get user => _user;
  List<BusinessModel> get businesses => _businesses;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isAuthenticated => _user != null;

  Future<bool> tryAutoLogin() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString(AppConstants.keyAuthToken);
    final userData = prefs.getString(AppConstants.keyUserData);

    if (token != null && userData != null) {
      _api.setAuthToken(token);
      _user = UserModel.fromJson(jsonDecode(userData));
      await fetchUserProfile();
      return true;
    }
    return false;
  }

  Future<bool> login(String emailOrPhone, String password) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _api.post(ApiEndpoints.login, {
      'email': emailOrPhone,
      'password': password,
    });

    _isLoading = false;

    if (response.success && response.data != null) {
      final token = response.data['token'];
      _user = UserModel.fromJson(response.data['user']);

      final rawBiz = response.data['businesses'] as List<dynamic>? ?? [];
      _businesses = rawBiz.map((b) => BusinessModel.fromJson(b)).toList();

      _api.setAuthToken(token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyAuthToken, token);
      await prefs.setString(AppConstants.keyUserData, jsonEncode(_user!.toJson()));

      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message ?? 'Login failed. Please check credentials.';
      notifyListeners();
      return false;
    }
  }

  Future<bool> register({
    required String name,
    required String email,
    required String phone,
    required String password,
    String? shopName,
    String? businessType,
    String? gstin,
  }) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final response = await _api.post(ApiEndpoints.register, {
      'name': name,
      'email': email,
      'phone': phone,
      'password': password,
      'shop_name': shopName,
      'business_type': businessType ?? 'retail',
      'gstin': gstin,
    });

    _isLoading = false;

    if (response.success && response.data != null) {
      final token = response.data['token'];
      _user = UserModel.fromJson(response.data['user']);

      if (response.data['business'] != null) {
        _businesses = [BusinessModel.fromJson(response.data['business'])];
      }

      _api.setAuthToken(token);

      final prefs = await SharedPreferences.getInstance();
      await prefs.setString(AppConstants.keyAuthToken, token);
      await prefs.setString(AppConstants.keyUserData, jsonEncode(_user!.toJson()));

      notifyListeners();
      return true;
    } else {
      _errorMessage = response.message ?? 'Registration failed.';
      notifyListeners();
      return false;
    }
  }

  Future<void> fetchUserProfile() async {
    final response = await _api.get(ApiEndpoints.me);
    if (response.success && response.data != null) {
      _user = UserModel.fromJson(response.data['user']);
      final rawBiz = response.data['businesses'] as List<dynamic>? ?? [];
      _businesses = rawBiz.map((b) => BusinessModel.fromJson(b)).toList();
      notifyListeners();
    }
  }

  Future<void> logout() async {
    await _api.post(ApiEndpoints.logout, {});
    _user = null;
    _businesses = [];
    _api.setAuthToken(null);
    _api.setActiveBusinessId(null);

    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(AppConstants.keyAuthToken);
    await prefs.remove(AppConstants.keyUserData);
    await prefs.remove(AppConstants.keySelectedBusinessId);

    notifyListeners();
  }
}
