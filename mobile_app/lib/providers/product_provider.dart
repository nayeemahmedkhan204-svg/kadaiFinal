import 'package:flutter/material.dart';
import '../core/database/app_database.dart';
import '../core/network/api_client.dart';
import '../core/network/api_endpoints.dart';
import '../models/category_model.dart';
import '../models/product_model.dart';

class ProductProvider extends ChangeNotifier {
  final ApiClient _api = ApiClient();
  final AppDatabase _db = AppDatabase();

  List<ProductModel> _products = [];
  List<ProductModel> _lowStockProducts = [];
  List<CategoryModel> _categories = [];
  bool _isLoading = false;
  String? _errorMessage;

  List<ProductModel> get products => _products;
  List<ProductModel> get lowStockProducts => _lowStockProducts;
  List<CategoryModel> get categories => _categories;
  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;

  Future<void> fetchCategories() async {
    final response = await _api.get(ApiEndpoints.categories);
    if (response.success && response.data != null) {
      final raw = response.data['categories'] as List<dynamic>? ?? [];
      _categories = raw.map((c) => CategoryModel.fromJson(c)).toList();
      notifyListeners();
    }
  }

  Future<void> fetchProducts({String? search, String? barcode, int? categoryId, bool lowStock = false}) async {
    _isLoading = true;
    _errorMessage = null;
    notifyListeners();

    final queryParams = <String, String>{};
    if (search != null && search.isNotEmpty) queryParams['search'] = search;
    if (barcode != null && barcode.isNotEmpty) queryParams['barcode'] = barcode;
    if (categoryId != null) queryParams['category_id'] = categoryId.toString();
    if (lowStock) queryParams['low_stock'] = '1';

    final response = await _api.get(ApiEndpoints.products, queryParams: queryParams);
    _isLoading = false;

    if (response.success && response.data != null) {
      final raw = response.data['products']['data'] as List<dynamic>? ?? [];
      _products = raw.map((p) => ProductModel.fromJson(p)).toList();

      // Cache into local SQLite for offline barcode lookup
      await _db.cacheProducts(raw);

      notifyListeners();
    } else if (response.statusCode == 0) {
      // Offline fallback: load from local SQLite
      final cached = await _db.getCachedProducts(search: search, barcode: barcode);
      _products = cached.map((p) => ProductModel.fromJson(p)).toList();
      notifyListeners();
    } else {
      _errorMessage = response.message ?? 'Failed to load products.';
      notifyListeners();
    }
  }

  Future<void> fetchLowStockAlerts() async {
    final response = await _api.get(ApiEndpoints.lowStockProducts);
    if (response.success && response.data != null) {
      final raw = response.data['products'] as List<dynamic>? ?? [];
      _lowStockProducts = raw.map((p) => ProductModel.fromJson(p)).toList();
      notifyListeners();
    }
  }

  Future<bool> addProduct(Map<String, dynamic> data) async {
    final response = await _api.post(ApiEndpoints.products, data);
    if (response.success) {
      await fetchProducts();
      return true;
    }
    return false;
  }

  Future<bool> updateProduct(int id, Map<String, dynamic> data) async {
    final response = await _api.put('${ApiEndpoints.products}/$id', data);
    if (response.success) {
      await fetchProducts();
      return true;
    }
    return false;
  }

  Future<bool> adjustStock(int id, String adjustmentType, double quantity, String reason) async {
    final response = await _api.post(ApiEndpoints.adjustStock(id), {
      'adjustment_type': adjustmentType,
      'quantity': quantity,
      'reason': reason,
    });
    if (response.success) {
      await fetchProducts();
      return true;
    }
    return false;
  }
}
