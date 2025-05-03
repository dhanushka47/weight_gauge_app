class Printer {
  final int? id;
  final String name;
  final double power;
  final String imagePath;

  Printer({this.id, required this.name, required this.power, required this.imagePath});

  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'name': name,
      'power': power,
      'imagePath': imagePath,
    };
  }

  static Printer fromMap(Map<String, dynamic> map) {
    return Printer(
      id: map['id'],
      name: map['name'],
      power: map['power'],
      imagePath: map['imagePath'],
    );
  }
}
