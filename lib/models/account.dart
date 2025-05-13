import 'dart:convert';

class BankAccount {
  final String accountName;
  final String bankName;
  final String branch;
  final String accountNumber;

  BankAccount({
    required this.accountName,
    required this.bankName,
    required this.branch,
    required this.accountNumber,
  });

  Map<String, dynamic> toMap() => {
    'accountName': accountName,
    'bankName': bankName,
    'branch': branch,
    'accountNumber': accountNumber,
  };

  static BankAccount fromMap(Map<String, dynamic> map) => BankAccount(
    accountName: map['accountName'] ?? '',
    bankName: map['bankName'],
    branch: map['branch'],
    accountNumber: map['accountNumber'],
  );

  static BankAccount fromJsonString(String jsonString) {
    final Map<String, dynamic> map = jsonDecode(jsonString);
    return BankAccount.fromMap(map);
  }

  String toJsonString() => jsonEncode(toMap());
}
