import 'category_model.dart';

class ProductModel {
  final int id;
  final int businessId;
  final int? categoryId;
  final String name;
  final String? sku;
  final String? barcode;
  final String unit;
  final double purchaseCost;
  final double sellingPrice;
  final double? wholesalePrice;
  final double gstRate;
  final String? hsnCode;
  final bool isTaxInclusive;
  final double openingStock;
  final double currentStock;
  final double minStockThreshold;
  final bool isActive;
  final CategoryModel? category;

  ProductModel({
    required this.id,
    required this.businessId,
    this.categoryId,
    required this.name,
    this.sku,
    this.barcode,
    required this.unit,
    required this.purchaseCost,
    required this.sellingPrice,
    this.wholesalePrice,
    required this.gstRate,
    this.hsnCode,
    required this.isTaxInclusive,
    required this.openingStock,
    required this.currentStock,
    required this.minStockThreshold,
    required this.isActive,
    this.category,
  });

  bool get isLowStock => currentStock <= minStockThreshold;

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    return ProductModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      businessId: json['business_id'] is int ? json['business_id'] : int.parse(json['business_id'].toString()),
      categoryId: json['category_id'] != null ? (json['category_id'] is int ? json['category_id'] : int.tryParse(json['category_id'].toString())) : null,
      name: json['name'] ?? '',
      sku: json['sku'],
      barcode: json['barcode'],
      unit: json['unit'] ?? 'PCS',
      purchaseCost: (json['purchase_cost'] as num?)?.toDouble() ?? 0.0,
      sellingPrice: (json['selling_price'] as num?)?.toDouble() ?? 0.0,
      wholesalePrice: (json['wholesale_price'] as num?)?.toDouble(),
      gstRate: (json['gst_rate'] as num?)?.toDouble() ?? 0.0,
      hsnCode: json['hsn_code'],
      isTaxInclusive: json['is_tax_inclusive'] == 1 || json['is_tax_inclusive'] == true,
      openingStock: (json['opening_stock'] as num?)?.toDouble() ?? 0.0,
      currentStock: (json['current_stock'] as num?)?.toDouble() ?? 0.0,
      minStockThreshold: (json['min_stock_threshold'] as num?)?.toDouble() ?? 5.0,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      category: json['category'] != null ? CategoryModel.fromJson(json['category']) : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'category_id': categoryId,
      'name': name,
      'sku': sku,
      'barcode': barcode,
      'unit': unit,
      'purchase_cost': purchaseCost,
      'selling_price': sellingPrice,
      'wholesale_price': wholesalePrice,
      'gst_rate': gstRate,
      'hsn_code': hsnCode,
      'is_tax_inclusive': isTaxInclusive,
      'opening_stock': openingStock,
      'current_stock': currentStock,
      'min_stock_threshold': minStockThreshold,
      'is_active': isActive,
    };
  }
}
