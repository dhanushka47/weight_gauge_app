class Quotation {
  int? id;
  final String customer;
  final String phone;
  final String location;
  final String deliveryDate;
  final double total;
  final String createdAt;
  final String itemsJson;
  String status; // <-- Add this line

  Quotation({
    this.id,
    required this.customer,
    required this.phone,
    required this.location,
    required this.deliveryDate,
    required this.total,
    required this.createdAt,
    required this.itemsJson,
    this.status = 'pending', // <-- default value
  });

  factory Quotation.fromMap(Map<String, dynamic> map) => Quotation(
    id: map['id'],
    customer: map['customer'],
    phone: map['phone'],
    location: map['location'],
    deliveryDate: map['deliveryDate'],
    total: map['total'],
    createdAt: map['createdAt'],
    itemsJson: map['itemsJson'],
    status: map['status'] ?? 'pending',
  );

  Map<String, dynamic> toMap() => {
    'id': id,
    'customer': customer,
    'phone': phone,
    'location': location,
    'deliveryDate': deliveryDate,
    'total': total,
    'createdAt': createdAt,
    'itemsJson': itemsJson,
    'status': status,
  };
}
