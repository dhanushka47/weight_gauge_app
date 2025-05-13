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
      paidAmount: map['paidAmount'],
      paidDate: map['paidDate'],
      reelUsed: map['reelUsed'],
      usedMaterialAmount: map['usedMaterialAmount'],
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
}
