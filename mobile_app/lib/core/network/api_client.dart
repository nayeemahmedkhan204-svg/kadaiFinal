import 'dart:async';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../constants/app_constants.dart';

class ApiResponse {
  final bool success;
  final int statusCode;
  final dynamic data;
  final String? message;

  ApiResponse({
    required this.success,
    required this.statusCode,
    this.data,
    this.message,
  });
}

class ApiClient {
  static final ApiClient _instance = ApiClient._internal();
  factory ApiClient() => _instance;
  ApiClient._internal();

  String _baseUrl = AppConstants.defaultBaseUrl;
  String? _authToken;
  int? _activeBusinessId;

  String get baseUrl => _baseUrl;
  int? get activeBusinessId => _activeBusinessId;

  Future<void> init() async {
    final prefs = await SharedPreferences.getInstance();
    final customUrl = prefs.getString('custom_api_url');
    if (customUrl != null && customUrl.isNotEmpty) {
      _baseUrl = customUrl.endsWith('/') ? customUrl.substring(0, customUrl.length - 1) : customUrl;
    }
    _authToken = prefs.getString(AppConstants.keyAuthToken);
    _activeBusinessId = prefs.getInt(AppConstants.keySelectedBusinessId);
  }

  void setBaseUrl(String url) {
    _baseUrl = url.endsWith('/') ? url.substring(0, url.length - 1) : url;
  }

  void setAuthToken(String? token) {
    _authToken = token;
  }

  void setActiveBusinessId(int? businessId) {
    _activeBusinessId = businessId;
  }

  Map<String, String> _buildHeaders() {
    final headers = {
      'Content-Type': 'application/json',
      'Accept': 'application/json',
    };

    if (_authToken != null && _authToken!.isNotEmpty) {
      headers['Authorization'] = 'Bearer $_authToken';
    }

    if (_activeBusinessId != null) {
      headers['X-Business-Id'] = _activeBusinessId.toString();
    }

    return headers;
  }

  Future<ApiResponse> get(String endpoint, {Map<String, String>? queryParams}) async {
    try {
      var uri = Uri.parse('$_baseUrl$endpoint');
      if (queryParams != null && queryParams.isNotEmpty) {
        uri = uri.replace(queryParameters: queryParams);
      }

      final response = await http
          .get(uri, headers: _buildHeaders())
          .timeout(const Duration(seconds: 15));

      return _processResponse(response);
    } on SocketException {
      return ApiResponse(success: false, statusCode: 0, message: 'No internet connection. Operating offline.');
    } on TimeoutException {
      return ApiResponse(success: false, statusCode: 408, message: 'Connection timed out. Please retry.');
    } catch (e) {
      return ApiResponse(success: false, statusCode: 500, message: e.toString());
    }
  }

  Future<ApiResponse> post(String endpoint, dynamic body) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await http
          .post(uri, headers: _buildHeaders(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));

      return _processResponse(response);
    } on SocketException {
      return ApiResponse(success: false, statusCode: 0, message: 'No internet connection. Saved locally.');
    } on TimeoutException {
      return ApiResponse(success: false, statusCode: 408, message: 'Request timed out.');
    } catch (e) {
      return ApiResponse(success: false, statusCode: 500, message: e.toString());
    }
  }

  Future<ApiResponse> put(String endpoint, dynamic body) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await http
          .put(uri, headers: _buildHeaders(), body: jsonEncode(body))
          .timeout(const Duration(seconds: 15));

      return _processResponse(response);
    } catch (e) {
      return ApiResponse(success: false, statusCode: 500, message: e.toString());
    }
  }

  Future<ApiResponse> delete(String endpoint) async {
    try {
      final uri = Uri.parse('$_baseUrl$endpoint');
      final response = await http
          .delete(uri, headers: _buildHeaders())
          .timeout(const Duration(seconds: 15));

      return _processResponse(response);
    } catch (e) {
      return ApiResponse(success: false, statusCode: 500, message: e.toString());
    }
  }

  ApiResponse _processResponse(http.Response response) {
    try {
      final decoded = jsonDecode(response.body);
      final isSuccess = response.statusCode >= 200 && response.statusCode < 300;
      final message = decoded is Map<String, dynamic> ? decoded['message'] : null;

      return ApiResponse(
        success: isSuccess && (decoded['success'] ?? true),
        statusCode: response.statusCode,
        data: decoded,
        message: message,
      );
    } catch (e) {
      return ApiResponse(
        success: false,
        statusCode: response.statusCode,
        message: 'Invalid server response: ${response.statusCode}',
      );
    }
  }
}
