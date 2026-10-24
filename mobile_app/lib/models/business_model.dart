class BusinessModel {
  final int id;
  final String uuid;
  final String name;
  final String? legalName;
  final String businessType;
  final String? gstin;
  final String phone;
  final String? email;
  final String? address;
  final String? city;
  final String state;
  final String stateCode;
  final String? pincode;
  final String currency;
  final String taxType;
  final String invoicePrefix;
  final int nextInvoiceNumber;
  final String? receiptFooter;
  final String? upiVpa;
  final String? upiName;
  final bool enableThermalLogo;
  final bool enableLowStockAlerts;
  final bool isActive;
  final String? userRole;

  String? get upiId => upiVpa;
  String? get upiPayeeName => upiName;
  String? get receiptFooterMessage => receiptFooter;
  bool get isTaxInclusive => taxType == 'gst' || taxType == 'inclusive';
  int get lowStockThreshold => 5;

  BusinessModel({
    required this.id,
    required this.uuid,
    required this.name,
    this.legalName,
    required this.businessType,
    this.gstin,
    required this.phone,
    this.email,
    this.address,
    this.city,
    required this.state,
    required this.stateCode,
    this.pincode,
    required this.currency,
    required this.taxType,
    required this.invoicePrefix,
    required this.nextInvoiceNumber,
    this.receiptFooter,
    this.upiVpa,
    this.upiName,
    required this.enableThermalLogo,
    required this.enableLowStockAlerts,
    required this.isActive,
    this.userRole,
  });

  factory BusinessModel.fromJson(Map<String, dynamic> json) {
    return BusinessModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      uuid: json['uuid'] ?? '',
      name: json['name'] ?? '',
      legalName: json['legal_name'],
      businessType: json['business_type'] ?? 'retail',
      gstin: json['gstin'],
      phone: json['phone'] ?? '',
      email: json['email'],
      address: json['address'],
      city: json['city'],
      state: json['state'] ?? 'Tamil Nadu',
      stateCode: json['state_code'] ?? '33',
      pincode: json['pincode'],
      currency: json['currency'] ?? 'INR',
      taxType: json['tax_type'] ?? 'gst',
      invoicePrefix: json['invoice_prefix'] ?? 'INV-',
      nextInvoiceNumber: json['next_invoice_number'] ?? 1,
      receiptFooter: json['receipt_footer'],
      upiVpa: json['upi_vpa'],
      upiName: json['upi_name'],
      enableThermalLogo: json['enable_thermal_logo'] == 1 || json['enable_thermal_logo'] == true,
      enableLowStockAlerts: json['enable_low_stock_alerts'] == 1 || json['enable_low_stock_alerts'] == true,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      userRole: json['pivot'] != null ? json['pivot']['role'] : null,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'uuid': uuid,
      'name': name,
      'legal_name': legalName,
      'business_type': businessType,
      'gstin': gstin,
      'phone': phone,
      'email': email,
      'address': address,
      'city': city,
      'state': state,
      'state_code': stateCode,
      'pincode': pincode,
      'currency': currency,
      'tax_type': taxType,
      'invoice_prefix': invoicePrefix,
      'next_invoice_number': nextInvoiceNumber,
      'receipt_footer': receiptFooter,
      'upi_vpa': upiVpa,
      'upi_name': upiName,
      'enable_thermal_logo': enableThermalLogo,
      'enable_low_stock_alerts': enableLowStockAlerts,
      'is_active': isActive,
    };
  }
}
