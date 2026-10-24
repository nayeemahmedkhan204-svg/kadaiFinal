class SubscriptionPlanModel {
  final int id;
  final String slug;
  final String name;
  final double price;
  final int durationDays;
  final int maxProducts;
  final int maxMonthlyInvoices;
  final int maxStaff;
  final List<dynamic>? features;

  SubscriptionPlanModel({
    required this.id,
    required this.slug,
    required this.name,
    required this.price,
    required this.durationDays,
    required this.maxProducts,
    required this.maxMonthlyInvoices,
    required this.maxStaff,
    this.features,
  });

  factory SubscriptionPlanModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionPlanModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      slug: json['slug'] ?? '',
      name: json['name'] ?? '',
      price: (json['price'] as num?)?.toDouble() ?? 0.0,
      durationDays: json['duration_days'] ?? 30,
      maxProducts: json['max_products'] ?? 100,
      maxMonthlyInvoices: json['max_monthly_invoices'] ?? 500,
      maxStaff: json['max_staff'] ?? 1,
      features: json['features'] is List ? json['features'] : null,
    );
  }
}

class SubscriptionModel {
  final int id;
  final int businessId;
  final int planId;
  final String status;
  final String? startsAt;
  final String? expiresAt;
  final int maxProducts;
  final int maxMonthlyInvoices;
  final int maxStaff;
  final double amountPaid;
  final SubscriptionPlanModel? plan;

  SubscriptionModel({
    required this.id,
    required this.businessId,
    required this.planId,
    required this.status,
    this.startsAt,
    this.expiresAt,
    required this.maxProducts,
    required this.maxMonthlyInvoices,
    required this.maxStaff,
    required this.amountPaid,
    this.plan,
  });

  bool get isValid => status == 'active' || status == 'trial';

  factory SubscriptionModel.fromJson(Map<String, dynamic> json) {
    return SubscriptionModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      businessId: json['business_id'] is int ? json['business_id'] : int.parse(json['business_id'].toString()),
      planId: json['plan_id'] is int ? json['plan_id'] : int.parse(json['plan_id'].toString()),
      status: json['status'] ?? 'trial',
      startsAt: json['starts_at'],
      expiresAt: json['expires_at'],
      maxProducts: json['max_products'] ?? 100,
      maxMonthlyInvoices: json['max_monthly_invoices'] ?? 500,
      maxStaff: json['max_staff'] ?? 1,
      amountPaid: (json['amount_paid'] as num?)?.toDouble() ?? 0.0,
      plan: json['plan'] != null ? SubscriptionPlanModel.fromJson(json['plan']) : null,
    );
  }
}
