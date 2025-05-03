class Expense {
  final int? id;
  final int printerId;
  final String printerName;
  final String imagePath;
  final double maintenanceCost;
  final double rentalCost;
  final double unitPrice;

  Expense({
    this.id,
    required this.printerId,
    required this.printerName,
    required this.imagePath,
    required this.maintenanceCost,
    required this.rentalCost,
    required this.unitPrice,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'printerId': printerId,
    'printerName': printerName,
    'imagePath': imagePath,
    'maintenanceCost': maintenanceCost,
    'rentalCost': rentalCost,
    'unitPrice': unitPrice,
  };

  factory Expense.fromMap(Map<String, dynamic> map) => Expense(
    id: map['id'],
    printerId: map['printerId'],
    printerName: map['printerName'],
    imagePath: map['imagePath'],
    maintenanceCost: map['maintenanceCost'],
    rentalCost: map['rentalCost'],
    unitPrice: map['unitPrice'],
  );
}
