class SupplierModel {
  final int id;
  final int businessId;
  final String name;
  final String? companyName;
  final String? phone;
  final String? email;
  final String? address;
  final String? gstin;
  final String stateCode;
  final double openingBalance;
  final double currentBalance;
  final bool isActive;

  SupplierModel({
    required this.id,
    required this.businessId,
    required this.name,
    this.companyName,
    this.phone,
    this.email,
    this.address,
    this.gstin,
    required this.stateCode,
    required this.openingBalance,
    required this.currentBalance,
    required this.isActive,
  });

  factory SupplierModel.fromJson(Map<String, dynamic> json) {
    return SupplierModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      businessId: json['business_id'] is int ? json['business_id'] : int.parse(json['business_id'].toString()),
      name: json['name'] ?? '',
      companyName: json['company_name'],
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      gstin: json['gstin'],
      stateCode: json['state_code'] ?? '33',
      openingBalance: (json['opening_balance'] as num?)?.toDouble() ?? 0.0,
      currentBalance: (json['current_balance'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'company_name': companyName,
      'phone': phone,
      'email': email,
      'address': address,
      'gstin': gstin,
      'state_code': stateCode,
      'opening_balance': openingBalance,
    };
  }
}
