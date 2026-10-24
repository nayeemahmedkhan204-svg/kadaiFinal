class ExpenseModel {
  final int id;
  final int businessId;
  final String expenseNumber;
  final String category;
  final String title;
  final String? description;
  final double amount;
  final String paymentMethod;
  final String expenseDate;

  ExpenseModel({
    required this.id,
    required this.businessId,
    required this.expenseNumber,
    required this.category,
    required this.title,
    this.description,
    required this.amount,
    required this.paymentMethod,
    required this.expenseDate,
  });

  factory ExpenseModel.fromJson(Map<String, dynamic> json) {
    return ExpenseModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      businessId: json['business_id'] is int ? json['business_id'] : int.parse(json['business_id'].toString()),
      expenseNumber: json['expense_number'] ?? '',
      category: json['category'] ?? 'Miscellaneous',
      title: json['title'] ?? '',
      description: json['description'],
      amount: (json['amount'] as num?)?.toDouble() ?? 0.0,
      paymentMethod: json['payment_method'] ?? 'cash',
      expenseDate: json['expense_date'] ?? '',
    );
  }
}
