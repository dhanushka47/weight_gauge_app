import 'dart:convert';



class BankAccount {
  final String bankName;
  final String branch;
  final String accountNumber;

  BankAccount({
    required this.bankName,
    required this.branch,
    required this.accountNumber,
  });

  Map<String, dynamic> toMap() => {
    'bankName': bankName,
    'branch': branch,
    'accountNumber': accountNumber,
  };

  static BankAccount fromMap(Map<String, dynamic> map) => BankAccount(
    bankName: map['bankName'],
    branch: map['branch'],
    accountNumber: map['accountNumber'],
  );

  static BankAccount fromJsonString(String jsonString) {
    final Map<String, dynamic> map = jsonDecode(jsonString);
    return BankAccount.fromMap(map);
  }
}
