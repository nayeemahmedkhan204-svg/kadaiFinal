class InvoiceItemModel {
  final int? id;
  final int? productId;
  final String productName;
  final String? sku;
  final String? hsnCode;
  final String unit;
  final double quantity;
  final double unitPrice;
  final double discountAmount;
  final double taxableValue;
  final double gstRate;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double total;

  InvoiceItemModel({
    this.id,
    this.productId,
    required this.productName,
    this.sku,
    this.hsnCode,
    required this.unit,
    required this.quantity,
    required this.unitPrice,
    required this.discountAmount,
    required this.taxableValue,
    required this.gstRate,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.total,
  });

  factory InvoiceItemModel.fromJson(Map<String, dynamic> json) {
    return InvoiceItemModel(
      id: json['id'],
      productId: json['product_id'],
      productName: json['product_name'] ?? '',
      sku: json['sku'],
      hsnCode: json['hsn_code'],
      unit: json['unit'] ?? 'PCS',
      quantity: (json['quantity'] as num?)?.toDouble() ?? 1.0,
      unitPrice: (json['unit_price'] as num?)?.toDouble() ?? 0.0,
      discountAmount: (json['discount_amount'] as num?)?.toDouble() ?? 0.0,
      taxableValue: (json['taxable_value'] as num?)?.toDouble() ?? 0.0,
      gstRate: (json['gst_rate'] as num?)?.toDouble() ?? 0.0,
      cgstAmount: (json['cgst_amount'] as num?)?.toDouble() ?? 0.0,
      sgstAmount: (json['sgst_amount'] as num?)?.toDouble() ?? 0.0,
      igstAmount: (json['igst_amount'] as num?)?.toDouble() ?? 0.0,
      total: (json['total'] as num?)?.toDouble() ?? 0.0,
    );
  }
}

class InvoiceModel {
  final int id;
  final String uuid;
  final int businessId;
  final String invoiceNumber;
  final String invoiceDate;
  final int? customerId;
  final String customerName;
  final String? customerPhone;
  final String? customerGstin;
  final bool isInterState;
  final bool isGst;
  final double subtotal;
  final double totalDiscount;
  final double taxableAmount;
  final double cgstAmount;
  final double sgstAmount;
  final double igstAmount;
  final double roundOff;
  final double grandTotal;
  final String paymentStatus;
  final String paymentMethod;
  final double paidAmount;
  final double balanceDue;
  final String? notes;
  final String status;
  final List<InvoiceItemModel> items;

  InvoiceModel({
    required this.id,
    required this.uuid,
    required this.businessId,
    required this.invoiceNumber,
    required this.invoiceDate,
    this.customerId,
    required this.customerName,
    this.customerPhone,
    this.customerGstin,
    required this.isInterState,
    required this.isGst,
    required this.subtotal,
    required this.totalDiscount,
    required this.taxableAmount,
    required this.cgstAmount,
    required this.sgstAmount,
    required this.igstAmount,
    required this.roundOff,
    required this.grandTotal,
    required this.paymentStatus,
    required this.paymentMethod,
    required this.paidAmount,
    required this.balanceDue,
    this.notes,
    required this.status,
    required this.items,
  });

  factory InvoiceModel.fromJson(Map<String, dynamic> json) {
    var rawItems = json['items'] as List<dynamic>? ?? [];
    List<InvoiceItemModel> itemList = rawItems.map((e) => InvoiceItemModel.fromJson(e)).toList();

    return InvoiceModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      uuid: json['uuid'] ?? '',
      businessId: json['business_id'] is int ? json['business_id'] : int.parse(json['business_id'].toString()),
      invoiceNumber: json['invoice_number'] ?? '',
      invoiceDate: json['invoice_date'] ?? '',
      customerId: json['customer_id'],
      customerName: json['customer_name'] ?? 'Walk-in Customer',
      customerPhone: json['customer_phone'],
      customerGstin: json['customer_gstin'],
      isInterState: json['is_inter_state'] == 1 || json['is_inter_state'] == true,
      isGst: json['is_gst'] == 1 || json['is_gst'] == true,
      subtotal: (json['subtotal'] as num?)?.toDouble() ?? 0.0,
      totalDiscount: (json['total_discount'] as num?)?.toDouble() ?? 0.0,
      taxableAmount: (json['taxable_amount'] as num?)?.toDouble() ?? 0.0,
      cgstAmount: (json['cgst_amount'] as num?)?.toDouble() ?? 0.0,
      sgstAmount: (json['sgst_amount'] as num?)?.toDouble() ?? 0.0,
      igstAmount: (json['igst_amount'] as num?)?.toDouble() ?? 0.0,
      roundOff: (json['round_off'] as num?)?.toDouble() ?? 0.0,
      grandTotal: (json['grand_total'] as num?)?.toDouble() ?? 0.0,
      paymentStatus: json['payment_status'] ?? 'paid',
      paymentMethod: json['payment_method'] ?? 'cash',
      paidAmount: (json['paid_amount'] as num?)?.toDouble() ?? 0.0,
      balanceDue: (json['balance_due'] as num?)?.toDouble() ?? 0.0,
      notes: json['notes'],
      status: json['status'] ?? 'completed',
      items: itemList,
    );
  }
}
