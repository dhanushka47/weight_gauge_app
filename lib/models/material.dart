class MaterialItem {
  final int? id;
  final String imagePath;
  final String color;
  final double price;
  final double weight;
  final String brand;
  final String type;
  final String source;
  final String purchaseDate;

  MaterialItem({
    this.id,
    required this.imagePath,
    required this.color,
    required this.price,
    required this.weight,
    required this.brand,
    required this.type,
    required this.source,
    required this.purchaseDate,
  });

  Map<String, dynamic> toMap() {
    return {
      'imagePath': imagePath,
      'color': color,
      'price': price,
      'weight': weight,
      'brand': brand,
      'type': type,
      'source': source,
      'purchaseDate': purchaseDate,
    };
  }

  factory MaterialItem.fromMap(Map<String, dynamic> map) {
    return MaterialItem(
      id: map['id'],
      imagePath: map['imagePath'],
      color: map['color'],
      price: map['price'],
      weight: map['weight'],
      brand: map['brand'],
      type: map['type'],
      source: map['source'],
      purchaseDate: map['purchaseDate'],
    );
  }
}
