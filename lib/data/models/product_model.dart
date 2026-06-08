class ProductModel {
  final String id;
  final String name;
  final String brand;
  final String paintType;
  final String color;
  final String hexColor;
  final String finishType;
  final double price;
  final double coverage;
  final double dryingTime;
  final List<String> sizes;
  final String usage;
  final String description;
  final double warranty;
  final List<String> images;
  final String category;
  final double rating;
  final int reviewCount;
  final String dealerId;
  final DateTime createdAt;

  ProductModel({
    required this.id,
    required this.name,
    required this.brand,
    required this.paintType,
    required this.color,
    required this.hexColor,
    required this.finishType,
    required this.price,
    required this.coverage,
    required this.dryingTime,
    required this.sizes,
    required this.usage,
    required this.description,
    required this.warranty,
    required this.images,
    required this.category,
    required this.rating,
    required this.reviewCount,
    required this.dealerId,
    required this.createdAt,
  });

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'brand': brand,
      'paintType': paintType,
      'color': color,
      'hexColor': hexColor,
      'finishType': finishType,
      'price': price,
      'coverage': coverage,
      'dryingTime': dryingTime,
      'sizes': sizes,
      'usage': usage,
      'description': description,
      'warranty': warranty,
      'images': images,
      'category': category,
      'rating': rating,
      'reviewCount': reviewCount,
      'dealerId': dealerId,
      'createdAt': createdAt.toIso8601String(),
    };
  }

  factory ProductModel.fromMap(Map<String, dynamic> map) {
    return ProductModel(
      id: map['id'] ?? '',
      name: map['name'] ?? '',
      brand: map['brand'] ?? '',
      paintType: map['paintType'] ?? '',
      color: map['color'] ?? '',
      hexColor: map['hexColor'] ?? '',
      finishType: map['finishType'] ?? '',
      price: (map['price'] ?? 0).toDouble(),
      coverage: (map['coverage'] ?? 0).toDouble(),
      dryingTime: (map['dryingTime'] ?? 0).toDouble(),
      sizes: List<String>.from(map['sizes'] ?? []),
      usage: map['usage'] ?? '',
      description: map['description'] ?? '',
      warranty: (map['warranty'] ?? 0).toDouble(),
      images: List<String>.from(map['images'] ?? []),
      category: map['category'] ?? '',
      rating: (map['rating'] ?? 0).toDouble(),
      reviewCount: map['reviewCount']?.toInt() ?? 0,
      dealerId: map['dealerId'] ?? '',
      createdAt: map['createdAt'] != null ? DateTime.parse(map['createdAt']) : DateTime.now(),
    );
  }

  ProductModel copyWith({
    String? id,
    String? name,
    String? brand,
    String? paintType,
    String? color,
    String? hexColor,
    String? finishType,
    double? price,
    double? coverage,
    double? dryingTime,
    List<String>? sizes,
    String? usage,
    String? description,
    double? warranty,
    List<String>? images,
    String? category,
    double? rating,
    int? reviewCount,
    String? dealerId,
    DateTime? createdAt,
  }) {
    return ProductModel(
      id: id ?? this.id,
      name: name ?? this.name,
      brand: brand ?? this.brand,
      paintType: paintType ?? this.paintType,
      color: color ?? this.color,
      hexColor: hexColor ?? this.hexColor,
      finishType: finishType ?? this.finishType,
      price: price ?? this.price,
      coverage: coverage ?? this.coverage,
      dryingTime: dryingTime ?? this.dryingTime,
      sizes: sizes ?? this.sizes,
      usage: usage ?? this.usage,
      description: description ?? this.description,
      warranty: warranty ?? this.warranty,
      images: images ?? this.images,
      category: category ?? this.category,
      rating: rating ?? this.rating,
      reviewCount: reviewCount ?? this.reviewCount,
      dealerId: dealerId ?? this.dealerId,
      createdAt: createdAt ?? this.createdAt,
    );
  }
}
