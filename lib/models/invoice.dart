class Invoice {
  final int id;
  final String customer;
  final String phone;
  final String date;
  final double total;
  final String itemsJson;
  final double? paidAmount;
  final String? paidDate;
  final String? reelUsed;
  final double? usedMaterialAmount;

  Invoice({
    required this.id,
    required this.customer,
    required this.phone,
    required this.date,
    required this.total,
    required this.itemsJson,
    this.paidAmount,
    this.paidDate,
    this.reelUsed,
    this.usedMaterialAmount,
  });

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      customer: map['customer'],
      phone: map['phone'],
      date: map['date'],
      total: (map['total'] as num).toDouble(),
      itemsJson: map['itemsJson'],
      paidAmount: map['paidAmount'] != null ? (map['paidAmount'] as num).toDouble() : null,
      paidDate: map['paidDate'],
      reelUsed: map['reelUsed'],
      usedMaterialAmount: map['usedMaterialAmount'] != null
          ? (map['usedMaterialAmount'] as num).toDouble()
          : null,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer': customer,
      'phone': phone,
      'date': date,
      'total': total,
      'itemsJson': itemsJson,
      'paidAmount': paidAmount,
      'paidDate': paidDate,
      'reelUsed': reelUsed,
      'usedMaterialAmount': usedMaterialAmount,
    };
  }

  /// ✅ Helper to toggle status in UI
  bool get isPaid => (paidAmount ?? 0) > 0;

  /// ✅ Used for updating paid/unpaid
  Invoice copyWith({
    int? id,
    String? customer,
    String? phone,
    String? date,
    double? total,
    String? itemsJson,
    double? paidAmount,
    String? paidDate,
    String? reelUsed,
    double? usedMaterialAmount,
  }) {
    return Invoice(
      id: id ?? this.id,
      customer: customer ?? this.customer,
      phone: phone ?? this.phone,
      date: date ?? this.date,
      total: total ?? this.total,
      itemsJson: itemsJson ?? this.itemsJson,
      paidAmount: paidAmount ?? this.paidAmount,
      paidDate: paidDate ?? this.paidDate,
      reelUsed: reelUsed ?? this.reelUsed,
      usedMaterialAmount: usedMaterialAmount ?? this.usedMaterialAmount,
    );
  }
}
