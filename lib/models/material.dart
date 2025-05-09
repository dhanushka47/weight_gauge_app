class MaterialItem {
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
  double availableGrams; // ✅ NEW: mutable so it can be updated

  MaterialItem({
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
    this.isOutOfStock = false,
    this.availableGrams = 0.0, // ✅ default to 0.0
  });

  Map<String, dynamic> toMap() => {
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
    'availableGrams': availableGrams, // ✅ add to map
  };

  factory MaterialItem.fromMap(Map<String, dynamic> map) => MaterialItem(
    id: map['id'],
    materialId: map['materialId'],
    type: map['type'],
    color: map['color'],
    brand: map['brand'],
    source: map['source'],
    price: map['price'],
    shippingCost: map['shippingCost'] ?? 0.0,
    weight: map['weight'],
    purchaseDate: map['purchaseDate'],
    imagePath: map['imagePath'],
    isOutOfStock: map['isOutOfStock'] == 1,
    availableGrams: (map['availableGrams'] ?? 0.0) * 1.0, // ✅ support old data
  );
}
