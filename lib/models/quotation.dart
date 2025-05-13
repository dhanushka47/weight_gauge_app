import 'dart:convert';

class Quotation {
  final int? id;
  final String customer;
  final String phone;
  final String location;
  final String deliveryDate;
  final double total;
  final String createdAt;
  final String itemsJson;
  final String status;

  Quotation({
    this.id,
    required this.customer,
    required this.phone,
    required this.location,
    required this.deliveryDate,
    required this.total,
    required this.createdAt,
    required this.itemsJson,
    required this.status,
  });

  Quotation copyWith({
    int? id,
    String? customer,
    String? phone,
    String? location,
    String? deliveryDate,
    double? total,
    String? createdAt,
    String? itemsJson,
    String? status,
  }) {
    return Quotation(
      id: id ?? this.id,
      customer: customer ?? this.customer,
      phone: phone ?? this.phone,
      location: location ?? this.location,
      deliveryDate: deliveryDate ?? this.deliveryDate,
      total: total ?? this.total,
      createdAt: createdAt ?? this.createdAt,
      itemsJson: itemsJson ?? this.itemsJson,
      status: status ?? this.status,
    );
  }

  factory Quotation.fromMap(Map<String, dynamic> map) {
    return Quotation(
      id: map['id'],
      customer: map['customer'],
      phone: map['phone'],
      location: map['location'],
      deliveryDate: map['deliveryDate'],
      total: (map['total'] as num).toDouble(),
      createdAt: map['createdAt'],
      itemsJson: map['itemsJson'],
      status: map['status'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
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

  /// Optional: support saving/loading from SharedPreferences
  String toJsonString() => jsonEncode(toMap());

  factory Quotation.fromJsonString(String source) =>
      Quotation.fromMap(jsonDecode(source));
}
