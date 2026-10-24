class PurchaseItemModel {
  final int? id;
  final int? productId;
  final String productName;
  final String unit;
  final double quantity;
  final double unitCost;
  final double gstRate;
  final double taxAmount;
  final double total;

  PurchaseItemModel({
    this.id,
    this.productId,
    required this.productName,
    required this.unit,
    required this.quantity,
    required this.unitCost,
    required this.gstRate,
    required this.taxAmount,
    required this.total,
  });

  factory PurchaseItemModel.fromJson(Map<String, dynamic> json) {
    return PurchaseItemModel(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'] ?? '',
      unit: json['unit'] ?? 'PCS',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unitCost: (json['unit_cost'] as num?)?.toDouble() ?? 0.0,
      gstRate: (json['gst_rate'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class PurchaseModel {
  final int id;
  final String uuid;
  final int businessId;
  final String purchaseNumber;
  final String? supplierInvoiceNumber;
  final int? supplierId;
  final String purchaseDate;
  final double subtotal;
  final double taxAmount;
  final double grandTotal;
  final double paidAmount;
  final double balanceDue;
  final String paymentStatus;
  final String status;
  final List<PurchaseItemModel> items;

  PurchaseModel({
    required this.id,
    required this.uuid,
    required this.businessId,
    required this.purchaseNumber,
    this.supplierInvoiceNumber,
    this.supplierId,
    required this.purchaseDate,
    required this.subtotal,
    required this.taxAmount,
    required this.grandTotal,
    required this.paidAmount,
    required this.balanceDue,
    required this.paymentStatus,
    required this.status,
    required this.items,
  });

  factory PurchaseModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] as List<dynamic>? ?? [];
    List<PurchaseItemModel> itemList = rawItems.map((e) => PurchaseItemModel.fromJson(e)).toList();

    return PurchaseModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      uuid: json['uuid'] ?? '',
      businessId: json['business_id'] is int ? json['business_id'] : int.parse(json['business_id'].toString()),
      purchaseNumber: json['purchase_number'] ?? '',
      supplierInvoiceNumber: json['supplier_invoice_number'],
      supplierId: json['supplier_id'],
      purchaseDate: json['purchase_date'] ?? '',
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      taxAmount: (json['tax_amount'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      balanceDue: (json['balance_due'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['payment_status'] ?? 'paid',
      status: json['status'] ?? 'completed',
      items: itemList,
    );
  }
}
