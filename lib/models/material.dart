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

  MaterialItem({
    this.id, // ✅ make optional
    required this.materialId,
    required this.type,
    required this.color,
    required this.brand,
    required this.source,
    required this.price,
    required this.shippingCost, // ✅ add this
    required this.weight,
    required this.purchaseDate,
    required this.imagePath,
    this.isOutOfStock = false,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'materialId': materialId,
    'type': type,
    'color': color,
    'brand': brand,
    'source': source,
    'price': price,
    'shippingCost': shippingCost, // ✅ add to map
    'weight': weight,
    'purchaseDate': purchaseDate,
    'imagePath': imagePath,
    'isOutOfStock': isOutOfStock ? 1 : 0,
  };

  factory MaterialItem.fromMap(Map<String, dynamic> map) => MaterialItem(
    id: map['id'],
    materialId: map['materialId'],
    type: map['type'],
    color: map['color'],
    brand: map['brand'],
    source: map['source'],
    price: map['price'],
    shippingCost: map['shippingCost'] ?? 0.0, // ✅ support old entries
    weight: map['weight'],
    purchaseDate: map['purchaseDate'],
    imagePath: map['imagePath'],
    isOutOfStock: map['isOutOfStock'] == 1,
  );
}
