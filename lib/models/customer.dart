class Customer {
  final int? id;
  final String name;
  final String phone;
  final String location;

  Customer({
    this.id,
    required this.name,
    required this.phone,
    required this.location,
  });

  Map<String, dynamic> toMap() => {
    'id': id,
    'name': name,
    'phone': phone,
    'location': location,
  };

  factory Customer.fromMap(Map<String, dynamic> map) => Customer(
    id: map['id'],
    name: map['name'],
    phone: map['phone'],
    location: map['location'],
  );
}
