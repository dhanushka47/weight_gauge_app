import 'dart:convert';

class MaterialModel {
  final int? id;
  final String materialId;
  final String type;
  final String color;
  final String brand;
  final String source;
  final double price;
  final double shippingCost;
  final double weight;
  final String purchaseDate;
  final String imagePath;
  final bool isOutOfStock;
  final double availableGrams;

  MaterialModel({
    this.id,
    required this.materialId,
    required this.type,
    required this.color,
    required this.brand,
    required this.source,
    required this.price,
    required this.shippingCost,
    required this.weight,
    required this.purchaseDate,
    required this.imagePath,
    required this.isOutOfStock,
    required this.availableGrams,
  });

  MaterialModel copyWith({
    int? id,
    String? materialId,
    String? type,
    String? color,
    String? brand,
    String? source,
    double? price,
    double? shippingCost,
    double? weight,
    String? purchaseDate,
    String? imagePath,
    bool? isOutOfStock,
    double? availableGrams,
  }) {
    return MaterialModel(
      id: id ?? this.id,
      materialId: materialId ?? this.materialId,
      type: type ?? this.type,
      color: color ?? this.color,
      brand: brand ?? this.brand,
      source: source ?? this.source,
      price: price ?? this.price,
      shippingCost: shippingCost ?? this.shippingCost,
      weight: weight ?? this.weight,
      purchaseDate: purchaseDate ?? this.purchaseDate,
      imagePath: imagePath ?? this.imagePath,
      isOutOfStock: isOutOfStock ?? this.isOutOfStock,
      availableGrams: availableGrams ?? this.availableGrams,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'materialId': materialId,
      'type': type,
      'color': color,
      'brand': brand,
      'source': source,
      'price': price,
      'shippingCost': shippingCost,
      'weight': weight,
      'purchaseDate': purchaseDate,
      'imagePath': imagePath,
      'isOutOfStock': isOutOfStock ? 1 : 0,
      'availableGrams': availableGrams,
    };
  }

  factory MaterialModel.fromMap(Map<String, dynamic> map) {
    return MaterialModel(
      id: map['id'],
      materialId: map['materialId'],
      type: map['type'],
      color: map['color'],
      brand: map['brand'],
      source: map['source'],
      price: (map['price'] as num).toDouble(),
      shippingCost: (map['shippingCost'] as num).toDouble(),
      weight: (map['weight'] as num).toDouble(),
      purchaseDate: map['purchaseDate'],
      imagePath: map['imagePath'],
      isOutOfStock: map['isOutOfStock'] == 1,
      availableGrams: (map['availableGrams'] as num).toDouble(),
    );
  }

  /// Optional: JSON serialization support
  String toJsonString() => jsonEncode(toMap());

  factory MaterialModel.fromJsonString(String source) =>
      MaterialModel.fromMap(jsonDecode(source));
}
