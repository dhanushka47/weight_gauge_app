class Invoice {
  final int id;
  final String customer;
  final String date;

  Invoice({
    required this.id,
    required this.customer,
    required this.date,
  });

  factory Invoice.fromMap(Map<String, dynamic> map) {
    return Invoice(
      id: map['id'],
      customer: map['customer'],
      date: map['date'],
    );
  }

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'customer': customer,
      'date': date,
    };
  }
}
