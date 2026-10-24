class CustomerModel {
  final int id;
  final int businessId;
  final String name;
  final String? phone;
  final String? email;
  final String? address;
  final String? gstin;
  final String stateCode;
  final double creditLimit;
  final double openingBalance;
  final double currentBalance;
  final bool isActive;

  CustomerModel({
    required this.id,
    required this.businessId,
    required this.name,
    this.phone,
    this.email,
    this.address,
    this.gstin,
    required this.stateCode,
    required this.creditLimit,
    required this.openingBalance,
    required this.currentBalance,
    required this.isActive,
  });

  bool get hasBalance => currentBalance > 0;
  double get outstandingBalance => currentBalance;
  String get displayPhone => phone ?? '';

  factory CustomerModel.fromJson(Map<String, dynamic> json) {
    return CustomerModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      businessId: json['business_id'] is int ? json['business_id'] : int.parse(json['business_id'].toString()),
      name: json['name'] ?? '',
      phone: json['phone'],
      email: json['email'],
      address: json['address'],
      gstin: json['gstin'],
      stateCode: json['state_code'] ?? '33',
      creditLimit: (json['credit_limit'] as num?)?.toDouble() ?? 0.0,
      openingBalance: (json['opening_balance'] as num?)?.toDouble() ?? 0.0,
      currentBalance: (json['current_balance'] as num?)?.toDouble() ?? 0.0,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'name': name,
      'phone': phone,
      'email': email,
      'address': address,
      'gstin': gstin,
      'state_code': stateCode,
      'credit_limit': creditLimit,
      'opening_balance': openingBalance,
    };
  }
}
