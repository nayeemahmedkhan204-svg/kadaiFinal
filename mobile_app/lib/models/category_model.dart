class CategoryModel {
  final int id;
  final int businessId;
  final String name;
  final String? slug;
  final String color;
  final String icon;
  final int productsCount;

  CategoryModel({
    required this.id,
    required this.businessId,
    required this.name,
    this.slug,
    required this.color,
    required this.icon,
    this.productsCount = 0,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] is int ? json['id'] : int.parse(json['id'].toString()),
      businessId: json['business_id'] is int ? json['business_id'] : int.parse(json['business_id'].toString()),
      name: json['name'] ?? '',
      slug: json['slug'],
      color: json['color'] ?? '#1E88E5',
      icon: json['icon'] ?? 'category',
      productsCount: json['products_count'] ?? 0,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'business_id': businessId,
      'name': name,
      'slug': slug,
      'color': color,
      'icon': icon,
    };
  }
}
